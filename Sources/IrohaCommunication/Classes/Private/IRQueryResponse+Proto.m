/**
 * Copyright Soramitsu Co., Ltd. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

#import "IRQueryResponse+Proto.h"
#import "QryResponses.pbobjc.h"
#import "IRQueryResponseAll.h"
#import <IrohaCrypto/NSData+Hex.h>
#import <IrohaCrypto/IRIrohaPublicKey.h>
#import "IRTransactionImpl+Proto.h"
#import "Primitive.pbobjc.h"
#import "IRBatchInfo.h"

@implementation IRQueryResponseProtoFactory

+ (nullable id<IRQueryResponse>)responseFromProtobuf:(nonnull QueryResponse*)pbResponse
                                               error:(NSError *_Nullable*_Nullable)error {

    if (!pbResponse.queryHash) {
        if (error) {
            NSString *message = @"Query hash is missing";
            *error = [NSError errorWithDomain:NSStringFromClass([IRQueryResponseProtoFactory class])
                                         code:IRQueryResponseFactoryErrorMissingRequiredAgrument
                                     userInfo:@{NSLocalizedDescriptionKey: message}];
        }

        return nil;
    }

    NSData *queryHash = [[NSData alloc] initWithHexString:pbResponse.queryHash
                                                    error:error];

    if (!queryHash) {
        return nil;
    }

    switch (pbResponse.responseOneOfCase) {
        case QueryResponse_Response_OneOfCase_AssetResponse:
            return [self assetResponseFromProtobuf:pbResponse.assetResponse
                                         queryHash:queryHash
                                             error:error];
            break;
        case QueryResponse_Response_OneOfCase_AccountResponse:
            return [self accountResponseFromProtobuf:pbResponse.accountResponse
                                           queryHash:queryHash
                                               error:error];
            break;
        case QueryResponse_Response_OneOfCase_ErrorResponse:
            return [self errorResponseFromProtobuf:pbResponse.errorResponse
                                         queryHash:queryHash
                                             error:error];
            break;
        case QueryResponse_Response_OneOfCase_RolesResponse:
            return [self rolesResponseFromPbResponse:pbResponse.rolesResponse
                                           queryHash:queryHash
                                               error:error];
            break;
        case QueryResponse_Response_OneOfCase_SignatoriesResponse:
            return [self signatoriesResponseFromPbResponse:pbResponse.signatoriesResponse
                                                 queryHash:queryHash
                                                     error:error];
            break;
        case QueryResponse_Response_OneOfCase_TransactionsResponse:
            return [self transactionsResponseFromPbResponse:pbResponse.transactionsResponse
                                                  queryHash:queryHash
                                                      error:error];
            break;
        case QueryResponse_Response_OneOfCase_AccountAssetsResponse:
            return [self accountAssetsResponseFromPbResponse:pbResponse.accountAssetsResponse
                                                   queryHash:queryHash
                                                       error:error];
            break;
        case QueryResponse_Response_OneOfCase_AccountDetailResponse:
            return [self accountDetailResponseFromPbResponse:pbResponse.accountDetailResponse
                                                   queryHash:queryHash
                                                       error:error];
            break;
        case QueryResponse_Response_OneOfCase_RolePermissionsResponse:
            return [self rolePermissionsResponseFromPbResponse:pbResponse.rolePermissionsResponse
                                                     queryHash:queryHash
                                                         error:error];
            break;
        case QueryResponse_Response_OneOfCase_TransactionsPageResponse:
            return [self transactionPageResponseFromPbResponse:pbResponse.transactionsPageResponse
                                                     queryHash:queryHash
                                                         error:error];
            break;
        case QueryResponse_Response_OneOfCase_PendingTransactionsPageResponse:
            return [self pendingTransactionPageResponseFromPbResponse:pbResponse.pendingTransactionsPageResponse
                                                            queryHash:queryHash
                                                                error:error];
            break;
        case QueryResponse_Response_OneOfCase_PeersResponse:
            return [self peersResponseFromPbResponse:pbResponse.peersResponse queryHash:queryHash error:error];
            break;
        default:
            if (error) {
                NSString *message = [NSString stringWithFormat:@"Unexpected query response type %@", @(pbResponse.responseOneOfCase)];
                *error = [NSError errorWithDomain:NSStringFromClass([IRQueryResponseProtoFactory class])
                                             code:IRQueryResponseFactoryErrorUnexpectedResponseType
                                         userInfo:@{NSLocalizedDescriptionKey: message}];
            }
            return nil;
            break;
    }
}

#pragma mark - Responses

+ (nullable id<IRAssetResponse>)assetResponseFromProtobuf:(nonnull AssetResponse*)pbResponse
                                                queryHash:(nonnull NSData *)queryHash
                                                    error:(NSError **)error {
    id<IRAssetId> assetId = [IRAssetIdFactory assetWithIdentifier:pbResponse.asset.assetId
                                                            error:error];

    if (!assetId) {
        return nil;
    }

    return [[IRAssetResponse alloc] initWithAssetId:assetId
                                          precision:pbResponse.asset.precision
                                          queryHash:queryHash];
}

+ (nullable id<IRAccountResponse>)accountResponseFromProtobuf:(nonnull AccountResponse*)pbResponse
                                                    queryHash:(nonnull NSData *)queryHash
                                                        error:(NSError **)error {
    id<IRAccountId> accountId = [IRAccountIdFactory accountWithIdentifier:pbResponse.account.accountId
                                                                    error:error];

    if (!accountId) {
        return nil;
    }

    NSMutableArray<id<IRRoleName>> *roles = [NSMutableArray array];

    for (NSString *roleName in pbResponse.accountRolesArray) {
        id<IRRoleName> role = [IRRoleNameFactory roleWithName:roleName
                                                        error:error];

        if (!role) {
            return nil;
        }

        [roles addObject:role];
    }

    return [[IRAccountResponse alloc] initWithAccountId:accountId
                                                 quorum:pbResponse.account.quorum
                                                details:pbResponse.account.jsonData
                                                  roles:roles
                                              queryHash:queryHash];
}

+ (nullable id<IRErrorResponse>)errorResponseFromProtobuf:(nonnull ErrorResponse*)pbResponse
                                                queryHash:(nonnull NSData *)queryHash
                                                    error:(NSError **)error {

    IRErrorResponseReason reason;

    switch (pbResponse.reason) {
        case ErrorResponse_Reason_NoAsset:
            reason = IRErrorResponseReasonNoAsset;
            break;
        case ErrorResponse_Reason_NoRoles:
            reason = IRErrorResponseReasonNoRoles;
            break;
        case ErrorResponse_Reason_NoAccount:
            reason = IRErrorResponseReasonNoAccount;
            break;
        case ErrorResponse_Reason_NotSupported:
            reason = IRErrorResponseReasonNotSupported;
            break;
        case ErrorResponse_Reason_NoSignatories:
            reason = IRErrorResponseReasonNoSignatories;
            break;
        case ErrorResponse_Reason_NoAccountAssets:
            reason = IRErrorResponseReasonNoAccountAssets;
            break;
        case ErrorResponse_Reason_NoAccountDetail:
            reason = IRErrorResponseReasonNoAccountDetail;
            break;
        case ErrorResponse_Reason_StatefulInvalid:
            reason = IRErrorResponseReasonStatefulInvalid;
            break;
        case ErrorResponse_Reason_StatelessInvalid:
            reason = IRErrorResponseReasonStatelessInvalid;
            break;
        default:
            if (error) {
                NSString *message = [NSString stringWithFormat:@"Invalid error reason %@", @(pbResponse.reason)];
                *error = [NSError errorWithDomain:NSStringFromClass([IRQueryResponseProtoFactory class])
                                             code:IRQueryResponseFactoryErrorInvalidAgrument
                                         userInfo:@{NSLocalizedDescriptionKey: message}];
            }
            return nil;
            break;
    }

    NSString *message = pbResponse.message ? pbResponse.message : @"";

    return [[IRErrorResponse alloc] initWithReason:reason
                                           message:message
                                              code:pbResponse.errorCode
                                         queryHash:queryHash];
}

+ (nullable id<IRRolesResponse>)rolesResponseFromPbResponse:(nonnull RolesResponse*)pbResponse
                                                  queryHash:(nonnull NSData *)queryHash
                                                      error:(NSError **)error {

    NSMutableArray<id<IRRoleName>> *roles = [NSMutableArray array];

    for (NSString *roleName in pbResponse.rolesArray) {
        id<IRRoleName> role = [IRRoleNameFactory roleWithName:roleName
                                                        error:error];

        if (!role) {
            return nil;
        }

        [roles addObject:role];
    }

    return [[IRRolesResponse alloc] initWithRoles:roles
                                        queryHash:queryHash];
}

+ (nullable id<IRSignatoriesResponse>)signatoriesResponseFromPbResponse:(nonnull SignatoriesResponse*)pbResponse
                                                              queryHash:(nonnull NSData *)queryHash
                                                                  error:(NSError **)error {

    NSMutableArray<id<IRPublicKeyProtocol>> *publicKeys = [NSMutableArray array];

    for (NSString *pbPublicKey in pbResponse.keysArray) {
        NSData *rawPublicKey = [[NSData alloc] initWithHexString:pbPublicKey error:error];

        if (!rawPublicKey) {
            return nil;
        }

        id<IRPublicKeyProtocol> publicKey = [[IRIrohaPublicKey alloc] initWithRawData:rawPublicKey
                                                                                error:error];

        if (!publicKey) {
            return nil;
        }

        [publicKeys addObject:publicKey];
    }

    return [[IRSignatoriesResponse alloc] initWithPublicKeys:publicKeys
                                                   queryHash:queryHash];
}

+ (nullable id<IRTransactionsResponse>)transactionsResponseFromPbResponse:(nonnull TransactionsResponse*)pbResponse
                                                                queryHash:(nonnull NSData *)queryHash
                                                                    error:(NSError **)error {

    NSArray<id<IRTransaction>> *transactions = [self transactionsFromPbTransactions:pbResponse.transactionsArray
                                                                              error:error];

    if (!transactions) {
        return nil;
    }

    return [[IRTransactionsResponse alloc] initWithTransactions:transactions
                                                      queryHash:queryHash];
}

+ (nullable id<IRAccountAssetsResponse>)accountAssetsResponseFromPbResponse:(nonnull AccountAssetResponse*)pbResponse
                                                                  queryHash:(nonnull NSData *)queryHash
                                                                      error:(NSError **)error {

    NSMutableArray<id<IRAccountAsset>> *accountAssets = [NSMutableArray array];

    for (AccountAsset *pbAccountAsset in pbResponse.accountAssetsArray) {
        id<IRAccountId> accountId = [IRAccountIdFactory accountWithIdentifier:pbAccountAsset.accountId
                                                                        error:error];

        if (!accountId) {
            return nil;
        }

        id<IRAssetId> assetId = [IRAssetIdFactory assetWithIdentifier:pbAccountAsset.assetId
                                                                error:error];

        if (!assetId) {
            return nil;
        }

        id<IRAmount> balance = [IRAmountFactory amountFromString:pbAccountAsset.balance
                                                           error:error];

        if (!balance) {
            return nil;
        }

        id<IRAccountAsset> accountAsset = [IRAccountAssetFactory accountAssetWithAccountId:accountId
                                                                                   assetId:assetId
                                                                                   balance:balance
                                                                                     error:error];

        if (!accountAsset) {
            return nil;
        }

        [accountAssets addObject:accountAsset];
    }

    id<IRAssetId> nextAssetId = nil;

    if (pbResponse.nextAssetId && pbResponse.nextAssetId.length > 0) {
        NSError * error = nil;
        nextAssetId = [IRAssetIdFactory assetWithIdentifier: pbResponse.nextAssetId error:&error];

        if (error) {
            return nil;
        }
    }

    return [[IRAccountAssetsResponse alloc] initWithAccountAssets:accountAssets
                                                       totalCount:pbResponse.totalNumber
                                                      nextAssetId:nextAssetId
                                                        queryHash:queryHash];
}

+ (nullable id<IRAccountDetailResponse>)accountDetailResponseFromPbResponse:(nonnull AccountDetailResponse*)pbResponse
                                                                  queryHash:(nonnull NSData *)queryHash
                                                                      error:(NSError **)error {

    NSString *detail = pbResponse.detail ? pbResponse.detail : @"";
    
    id<IRAccountDetailRecordId> nextRecordId = nil;
    
    if (pbResponse.hasNextRecordId) {
        nextRecordId = [IRAccountDetailRecordIdFactory accountDetailRecordIdWithWriter:pbResponse.nextRecordId.writer
                                                                                   key:pbResponse.nextRecordId.key];
    }

    return [[IRAccountDetailResponse alloc] initWithDetail:detail
                                                totalCount:pbResponse.totalNumber
                                              nextRecordId:nextRecordId
                                                 queryHash:queryHash];
}

+ (nullable id<IRRolePermissionsResponse>)rolePermissionsResponseFromPbResponse:(nonnull RolePermissionsResponse*)pbResponse
                                                                      queryHash:(nonnull NSData *)queryHash
                                                                          error:(NSError **)error {
    NSMutableArray<id<IRRolePermission>>* permissions = [NSMutableArray array];
    for (NSUInteger i = 0; i < pbResponse.permissionsArray.count; i++) {
        id<IRRolePermission> permission = [IRRolePermissionFactory permissionWithValue:[pbResponse.permissionsArray valueAtIndex:i]
                                                                                 error:error];

        if (!permission) {
            return nil;
        }

        [permissions addObject:permission];
    }

    return [[IRRolePermissionsResponse alloc] initWithPermissions:permissions
                                                        queryHash:queryHash];
}

+ (nullable id<IRTransactionsPageResponse>)transactionPageResponseFromPbResponse:(nonnull TransactionsPageResponse*)pbResponse
                                                                       queryHash:(nonnull NSData *)queryHash
                                                                           error:(NSError **)error {

    NSArray<id<IRTransaction>> *transactions = [self transactionsFromPbTransactions:pbResponse.transactionsArray
                                                                              error:error];

    if (!transactions) {
        return nil;
    }

    NSData *nextTransactionHash = nil;

    if (pbResponse.nextTxHash && pbResponse.nextTxHash.length > 0) {
        nextTransactionHash = [[NSData alloc] initWithHexString:pbResponse.nextTxHash error:error];

        if (!nextTransactionHash) {
            return nil;
        }
    }

    return [[IRTransactionsPageResponse alloc] initWithTransactions:transactions
                                                         totalCount:pbResponse.allTransactionsSize
                                                nextTransactionHash:nextTransactionHash
                                                          queryHash:queryHash];
}

+ (nullable id<IRPendingTransactionsPageResponse>)pendingTransactionPageResponseFromPbResponse:(nonnull PendingTransactionsPageResponse *)pbResponse
                                                                                     queryHash:(nonnull NSData *)queryHash
                                                                                         error:(NSError **)error {
    
    NSArray<id<IRTransaction>> *transactions = [self transactionsFromPbTransactions:pbResponse.transactionsArray
                                                                              error:error];
    
    if (!transactions) {
        return nil;
    }
    
    IRBatchInfo *nextBatch = nil;
    
    if (pbResponse.nextBatchInfo && pbResponse.nextBatchInfo.batchSize > 0) {
        nextBatch = [[IRBatchInfo alloc] initWithNextHash:pbResponse.nextBatchInfo.firstTxHash
                                                batchSize:pbResponse.nextBatchInfo.batchSize];
        
        if (!nextBatch) {
            if (error) {
                NSString *message = [NSString stringWithFormat:@"Invalid transaction batch info %@", pbResponse.nextBatchInfo];
                *error = [NSError errorWithDomain:NSStringFromClass([IRQueryResponseProtoFactory class])
                                             code:IRQueryResponseFactoryErrorInvalidAgrument
                                         userInfo:@{NSLocalizedDescriptionKey: message}];
            }
            
            return nil;
        }
    }
    
    return [[IRPendingTransactionsPageResponse alloc] initWithTransactions:transactions
                                                                totalCount:pbResponse.allTransactionsSize
                                                                 nextBatch:nextBatch
                                                                 queryHash:queryHash];
}

+ (nullable NSArray<id<IRTransaction>> *)transactionsFromPbTransactions:(nonnull NSArray<Transaction*> *)pbTransactions
                                                                 error:(NSError **)error {

    NSMutableArray<id<IRTransaction>> *transactions = [NSMutableArray array];

    for (Transaction *pbTransaction in pbTransactions) {
        id<IRTransaction> transaction = [IRTransaction transactionFromPbTransaction:pbTransaction
                                                                              error:error];

        if (!transaction) {
            return nil;
        }

        [transactions addObject: transaction];
    }

    return transactions;
}

+ (nullable id<IRPeersResponse>)peersResponseFromPbResponse:(nonnull PeersResponse*)pbResponse
                                                  queryHash:(nonnull NSData *)queryHash
                                                      error:(NSError **)error {
    NSMutableArray<id<IRPeer>> *peers = [NSMutableArray array];
    
    for (Peer *pbPeer in pbResponse.peersArray) {
        id<IRAddress> address = [IRAddressFactory addressWithValue:pbPeer.address error:error];
        
        if (!address) {
            return nil;
        }
        
        NSData *rawPublicKey = [[NSData alloc] initWithHexString:pbPeer.peerKey error:error];
        
        if (!rawPublicKey) {
            return nil;
        }
        
        id<IRPublicKeyProtocol> publicKey = [[IRIrohaPublicKey alloc] initWithRawData:rawPublicKey error:error];
        
        if (!publicKey) {
            return nil;
        }
        
        id<IRPeer> peer = [IRPeerFactory peerWithAddress:address key:publicKey error:error];
        
        [peers addObject:peer];
    }
    
    return [[IRPeersResponse alloc] initWithPeers:peers queryHash:queryHash];
}

@end
