/**
 * Copyright Soramitsu Co., Ltd. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

#import <Foundation/Foundation.h>
#import "IRQueryResponse.h"

@interface IRTransactionsPageResponse : NSObject<IRTransactionsPageResponse>

- (nonnull instancetype)initWithTransactions:(nonnull NSArray<id<IRTransaction>>*)transactions
                                  totalCount:(UInt32)totalCount
                         nextTransactionHash:(nullable NSData *)nextTransactionHash
                                   queryHash:(nonnull NSData *)queryHash;

@end
