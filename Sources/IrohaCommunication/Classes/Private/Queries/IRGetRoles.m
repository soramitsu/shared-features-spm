/**
 * Copyright Soramitsu Co., Ltd. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

#import "IRGetRoles.h"
#import "Queries.pbobjc.h"

@implementation IRGetRoles

#pragma mark - Protobuf Transformable

- (nullable id)transform:(NSError **)error {
    GetRoles *query = [[GetRoles alloc] init];

    Query_Payload *payload = [[Query_Payload alloc] init];
    payload.getRoles = query;

    return payload;
}

@end
