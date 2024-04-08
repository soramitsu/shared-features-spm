/**
 * Copyright Soramitsu Co., Ltd. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

#import <Foundation/Foundation.h>
#import "IRQuery.h"
#import "IRProtobufTransformable.h"

@interface IRGetAccountDetail : NSObject<IRGetAccountDetail, IRProtobufTransformable>

- (nonnull instancetype)initWithAccountId:(nullable id<IRAccountId>)accountId
                                   writer:(nonnull NSString*)writer
                                      key:(nonnull NSString*)key;

- (nonnull instancetype)initWithAccountId:(nullable id<IRAccountId>)accountId
                               pagination:(nonnull id<IRAccountDetailPagination>)pagination;

@end
