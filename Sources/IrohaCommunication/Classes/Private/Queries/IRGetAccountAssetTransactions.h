/**
 * Copyright Soramitsu Co., Ltd. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

#import <Foundation/Foundation.h>
#import "IRQuery.h"
#import "IRProtobufTransformable.h"

@interface IRGetAccountAssetTransactions : NSObject<IRGetAccountAssetTransactions, IRProtobufTransformable>

- (nonnull instancetype)initWithAccountId:(nonnull id<IRAccountId>)accountId
                                  assetId:(nonnull id<IRAssetId>)assetId
                               pagination:(nullable id<IRPagination>)pagination;

@end
