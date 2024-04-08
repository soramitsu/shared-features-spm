/**
 * Copyright Soramitsu Co., Ltd. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

#import <Foundation/Foundation.h>
#import "IRQuery.h"
#import "IRProtobufTransformable.h"

@interface IRGetAccountTransactions : NSObject<IRGetAccountTransactions, IRProtobufTransformable>

- (nonnull instancetype)initWithAccountId:(nonnull id<IRAccountId>)accountId
                               pagination:(nullable id<IRPagination>)pagination;

@end
