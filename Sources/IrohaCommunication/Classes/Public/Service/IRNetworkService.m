/**
 * Copyright Soramitsu Co., Ltd. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

#import "IRNetworkService.h"
#import "Endpoint.pbrpc.h"
#import "Queries.pbobjc.h"
#import "IRTransactionImpl.h"
#import "Transaction.pbobjc.h"
#import "IRTransactionStatusResponseImpl+Proto.h"
#import "IRQueryResponse+Proto.h"
#import "IRBlockQueryRequestImpl.h"
#import "IRBlockQueryResponse+Proto.h"
#import "GRPCProtoCall+Cancellable.h"
#import <GRPCClient/GRPCCall+Tests.h>
#import <IrohaCrypto/NSData+Hex.h>

@interface IRNetworkService()

@property (nonatomic, strong) CommandService_v1 *commandService;
@property (nonatomic, strong) QueryService_v1 *queryService;

@end

@implementation IRNetworkService

#pragma mark - Initialize

- (nonnull instancetype)initWithAddress:(nonnull id<IRAddress>)address {
    return [self initWithAddress:address useSecuredConnection:NO];
}

- (nonnull instancetype)initWithAddress:(nonnull id<IRAddress>)address useSecuredConnection:(BOOL)secured {
    if (self = [super init]) {
        _responseSerialQueue = dispatch_get_main_queue();

        _commandService = [[CommandService_v1 alloc] initWithHost:address.value];
        _queryService = [[QueryService_v1 alloc] initWithHost:address.value];

        if (!secured) {
            [GRPCCall useInsecureConnectionsForHost:address.value];
        }
    }

    return self;
}

#pragma mark - Transaction

- (nonnull IRPromise *)executeTransaction:(nonnull id<IRTransaction>)transaction {
    IRPromise *promise = [IRPromise promise];

    if (![transaction conformsToProtocol:@protocol(IRProtobufTransformable)]) {
        NSString *message = @"Unsupported transaction implementation";
        NSError *error = [NSError errorWithDomain:NSStringFromClass([IRNetworkService class])
                                             code:IRTransactionErrorSerialization
                                         userInfo:@{NSLocalizedDescriptionKey: message}];

        [promise fulfillWithResult:error];
        return promise;
    }

    NSError *error = nil;
    Transaction *pbTransaction = [(id<IRProtobufTransformable>)transaction transform:&error];

    if (!pbTransaction) {
        [promise fulfillWithResult:error];
        return promise;
    }

    error = nil;
    NSData *transactionHash = [transaction transactionHashWithError:&error];
    if (!transactionHash) {
        [promise fulfillWithResult:error];
        return promise;
    }

    GRPCProtoCall *call = [_commandService RPCToToriiWithRequest:pbTransaction
                                   handler:^(GPBEmpty * _Nullable response, NSError * _Nullable error) {
                                       if (error) {
                                           [promise fulfillWithResult: error];
                                       } else {
                                           [promise fulfillWithResult:transactionHash];
                                       }
                                   }];

    [call setResponseDispatchQueue:_responseSerialQueue];

    [call start];

    return promise;
}

- (nonnull IRPromise *)executeBatchTransactions:(nonnull NSArray<id<IRTransaction>>*)transactions {
    IRPromise *promise = [IRPromise promise];

    NSMutableArray<Transaction*> *pbTransactions = [NSMutableArray array];

    NSMutableArray<NSData *> *transactionHashes = [NSMutableArray array];

    for (NSUInteger i = 0; i < transactions.count; i++) {
        if (![transactions[i] conformsToProtocol:@protocol(IRProtobufTransformable)]) {
            NSString *message = @"Unsupported transaction implementation";
            NSError *error = [NSError errorWithDomain:NSStringFromClass([IRNetworkService class])
                                                 code:IRTransactionErrorSerialization
                                             userInfo:@{NSLocalizedDescriptionKey: message}];

            [promise fulfillWithResult:error];
            return promise;
        }

        NSError *error = nil;
        Transaction *pbTransaction = [(id<IRProtobufTransformable>)transactions[i] transform:&error];

        if (!pbTransaction) {
            [promise fulfillWithResult:error];
            return promise;
        }

        [pbTransactions addObject:pbTransaction];

        error = nil;
        NSData *transactionHash = [transactions[i] transactionHashWithError:&error];
        if (!transactionHash) {
            [promise fulfillWithResult:error];
            return promise;
        }

        [transactionHashes addObject:transactionHash];
    }

    TxList *txList = [[TxList alloc] init];
    txList.transactionsArray = pbTransactions;

    GRPCProtoCall *call = [_commandService RPCToListToriiWithRequest:txList
                                                             handler:^(GPBEmpty * _Nullable response, NSError * _Nullable error) {
                                                                 if (error) {
                                                                     [promise fulfillWithResult: error];
                                                                 } else {
                                                                     [promise fulfillWithResult:transactionHashes];
                                                                 }
                                                             }];

    [call setResponseDispatchQueue:_responseSerialQueue];
    
    [call start];

    return promise;
}

- (nonnull IRPromise *)fetchTransactionStatus:(nonnull NSData *)transactionHash {
    TxStatusRequest *statusRequest = [[TxStatusRequest alloc] init];
    statusRequest.txHash = [transactionHash toHexString];

    __weak typeof(self) weakSelf = self;

    IRPromise *promise = [[IRPromise alloc] init];

    IRTransactionStatusBlock handler = ^(id<IRTransactionStatusResponse> response, BOOL done, NSError *error) {
        if (response) {
            [promise fulfillWithResult:response];
        } else {
            [promise fulfillWithResult:error];
        }
    };

    GRPCProtoCall *call = [_commandService RPCToStatusWithRequest:statusRequest
                                                          handler:^(ToriiResponse * _Nullable response, NSError * _Nullable error) {
                                                         [weakSelf proccessTransactionStatusResponse:response
                                                                              error:error
                                                                               done:YES
                                                                            handler:handler];
                                                     }];

    [call setResponseDispatchQueue:_responseSerialQueue];

    [call start];

    return promise;
}

- (id<IRCancellable>)streamTransactionStatus:(nonnull NSData *)transactionHash
                                   withBlock:(nonnull IRTransactionStatusBlock)block {
    TxStatusRequest *statusRequest = [[TxStatusRequest alloc] init];
    statusRequest.txHash = [transactionHash toHexString];

    __weak typeof(self) weakSelf = self;

    GRPCProtoCall *call = [_commandService RPCToStatusStreamWithRequest:statusRequest
                                                           eventHandler:^(BOOL done, ToriiResponse *response, NSError *error) {
                                                               [weakSelf proccessTransactionStatusResponse:response
                                                                                                     error:error
                                                                                                      done:done
                                                                                                   handler:block];
                                                           }];
    [call setResponseDispatchQueue:_responseSerialQueue];
    [call start];

    return call;
}

#pragma mark - Query

- (nonnull IRPromise*)executeQueryRequest:(nonnull id<IRQueryRequest>)queryRequest {
    IRPromise *promise = [IRPromise promise];

    if (![queryRequest conformsToProtocol:@protocol(IRProtobufTransformable)]) {
        NSString *message = @"Unsupported query implementation";
        NSError *error = [NSError errorWithDomain:NSStringFromClass([IRNetworkService class])
                                             code:IRQueryRequestErrorSerialization
                                         userInfo:@{NSLocalizedDescriptionKey: message}];

        [promise fulfillWithResult:error];
        return promise;
    }

    NSError *error = nil;
    Query *protobufQuery = [(id<IRProtobufTransformable>)queryRequest transform:&error];

    if (!protobufQuery) {
        [promise fulfillWithResult:error];
        return promise;
    }

    GRPCProtoCall *call = [_queryService RPCToFindWithRequest:protobufQuery
                                                      handler:^(QueryResponse* _Nullable response, NSError * _Nullable error) {
                                                          if (response) {
                                                              NSError *parsingError = nil;
                                                              id<IRQueryResponse> queryResponse = [IRQueryResponseProtoFactory responseFromProtobuf:response
                                                                                                                                              error:&parsingError];

                                                              if (queryResponse) {
                                                                  [promise fulfillWithResult:queryResponse];
                                                              } else {
                                                                  [promise fulfillWithResult:parsingError];
                                                              }
                                                          } else {
                                                              [promise fulfillWithResult:error];
                                                          }
                                                      }];

    [call setResponseDispatchQueue:_responseSerialQueue];

    [call start];

    return promise;
}

#pragma mark - Commits

- (id<IRCancellable>)streamCommits:(nonnull id<IRBlockQueryRequest>)request
                         withBlock:(nonnull IRCommitStreamBlock)block {
    if (![request conformsToProtocol:@protocol(IRProtobufTransformable)]) {
        NSString *message = @"Unsupported block query request implementation";
        NSError *error = [NSError errorWithDomain:NSStringFromClass([IRNetworkService class])
                                             code:IRQueryRequestErrorSerialization
                                         userInfo:@{NSLocalizedDescriptionKey: message}];
        block(nil, true, error);
        return nil;
    }

    NSError *pbError = nil;
    BlocksQuery *pbBlockQuery = [(id<IRProtobufTransformable>)request transform:&pbError];

    if (!pbBlockQuery) {
        block(nil, true, pbError);
        return nil;
    }

    GRPCProtoCall *call = [_queryService RPCToFetchCommitsWithRequest:pbBlockQuery
                                                         eventHandler:^(BOOL done, BlockQueryResponse * _Nullable pbResponse, NSError * _Nullable error) {
                                                             if (pbResponse) {
                                                                 NSError *parsingError = nil;
                                                                 id<IRBlockQueryResponse> response = [IRBlockQueryResponse responseFromPbResponse:pbResponse
                                                                                                                                            error:&parsingError];
                                                                 block(response, done, parsingError);
                                                             } else {
                                                                 block(nil, done, error);
                                                             }
                                                         }];

    [call setResponseDispatchQueue:_responseSerialQueue];

    [call start];

    return call;
}

#pragma mark - Private

- (void)proccessTransactionStatusResponse:(nullable ToriiResponse *)toriiResponse
                                    error:(nullable NSError *)error
                                     done:(BOOL)done
                                  handler:(nonnull IRTransactionStatusBlock)handler {
    if (toriiResponse) {
        NSError *parsingError = nil;
        id<IRTransactionStatusResponse> statusResponse = [IRTransactionStatusResponse statusResponseWithToriiResponse:toriiResponse
                                                                                                                error:&parsingError];

        handler(statusResponse, done, parsingError);
    } else {
        handler(nil, done, error);
    }
}

@end
