/**
 * Copyright Soramitsu Co., Ltd. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

#import <Foundation/Foundation.h>
#import "IRCommandAll.h"

@class Command;

typedef NS_ENUM(NSUInteger, IRCommandProtoFactoryError){
    IRCommandProtoFactoryErrorInvalidArgument
};

@interface IRCommandProtoFactory : NSObject

+ (nullable id<IRCommand>)commandFromPbCommand:(nonnull Command*)command
                                         error:(NSError *_Nullable*_Nullable)error;

@end
