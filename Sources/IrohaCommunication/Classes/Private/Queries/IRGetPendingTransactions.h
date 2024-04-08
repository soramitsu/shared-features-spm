/**
 * Copyright Soramitsu Co., Ltd. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

#import <Foundation/Foundation.h>
#import "IRQuery.h"
#import "IRProtobufTransformable.h"


@interface IRGetPendingTransactions : NSObject<IRGetPendingTransactions, IRProtobufTransformable>

- (nonnull instancetype)initWithPagination:(nonnull id<IRPagination>)pagination;

@end
