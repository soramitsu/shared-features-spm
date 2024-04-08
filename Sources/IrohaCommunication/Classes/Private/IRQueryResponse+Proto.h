/**
 * Copyright Soramitsu Co., Ltd. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

#import <Foundation/Foundation.h>
#import "IRQueryResponse.h"

@class QueryResponse;

typedef NS_ENUM(NSUInteger, IRQueryResponseFactoryError) {
    IRQueryResponseFactoryErrorQueryHashInvalid,
    IRQueryResponseFactoryErrorUnexpectedResponseType,
    IRQueryResponseFactoryErrorMissingRequiredAgrument,
    IRQueryResponseFactoryErrorInvalidAgrument
};

@interface IRQueryResponseProtoFactory : NSObject

+ (nullable id<IRQueryResponse>)responseFromProtobuf:(nonnull QueryResponse*)pbResponse
                                               error:(NSError *_Nullable*_Nullable)error;

@end
