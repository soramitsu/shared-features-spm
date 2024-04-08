/**
 * Copyright Soramitsu Co., Ltd. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

#import <Foundation/Foundation.h>

@protocol IRGrantablePermission <NSObject>

@property (nonatomic, readonly) int32_t value;

@end

typedef NS_ENUM(NSUInteger, IRGrantablePermissionError) {
    IRInvalidGrantablePermissionValue
};

@protocol IRGrantablePermissionFactoryProtocol <NSObject>

+ (nullable id<IRGrantablePermission>)permissionWithValue:(int32_t)value error:(NSError *_Nullable *_Nullable)error;

@end

@interface IRGrantablePermissionFactory : NSObject<IRGrantablePermissionFactoryProtocol>

+ (nonnull id<IRGrantablePermission>)canAddMySignatory;
+ (nonnull id<IRGrantablePermission>)canRemoveMySignatory;
+ (nonnull id<IRGrantablePermission>)canSetMyQuorum;
+ (nonnull id<IRGrantablePermission>)canSetMyAccountDetail;

@end
