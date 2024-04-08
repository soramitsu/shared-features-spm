/**
 * Copyright Soramitsu Co., Ltd. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

#import "IRRolesResponse.h"

@implementation IRRolesResponse
@synthesize roles = _roles;
@synthesize queryHash = _queryHash;

- (nonnull instancetype)initWithRoles:(nonnull NSArray<id<IRRoleName>>*)roles
                            queryHash:(nonnull NSData *)queryHash {
    if (self = [super init]) {
        _roles = roles;
        _queryHash = queryHash;
    }

    return self;
}

@end
