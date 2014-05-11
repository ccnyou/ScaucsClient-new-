//
//  LvKangServiceClient.h
//  ScaucsClient
//
//  Created by ccnyou on 14-4-7.
//  Copyright (c) 2014年 ccnyou. All rights reserved.
//

#import <Foundation/Foundation.h>


@class LvKangServiceClient;

@protocol LvKangServiceClientDelegate <NSObject>

- (void)lkServiceClient:(LvKangServiceClient *)client getPswCompletedWithResult:(NSString *)result;
- (void)lkServiceClient:(LvKangServiceClient *)client getPswFailedWithError:(NSError *)error;

- (void)lkServiceClient:(LvKangServiceClient *)client getUpcaCompletedWithResult:(NSData *)result;
- (void)lkServiceClient:(LvKangServiceClient *)client getUpcaFailedWithError:(NSError *)error;

@end

@interface LvKangServiceClient : NSObject

@property (nonatomic, weak) id<LvKangServiceClientDelegate> delegate;

- (void)getMyPassword:(NSString *)userName andPsw:(NSString *)password;

- (void)getUPCA:(NSString *)userName andPsw:(NSString *)password;

@end
