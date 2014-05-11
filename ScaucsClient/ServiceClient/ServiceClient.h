//
//  ServiceClient.h
//  SOAPDemo
//
//  Created by ccnyou on 14-3-28.
//  Copyright (c) 2014年 ccnyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@class ServiceClient;

@protocol ServiceClientDelegate <NSObject>

@optional
//模仿loginCompletedWithResult弄出来的。
- (void)serviceClient:(ServiceClient *)client loginForHomeworkWithResult:(NSString *)result;

- (void)serviceClient:(ServiceClient *)client loginCompletedWithResult:(NSString *)result;
- (void)serviceClient:(ServiceClient *)client loginFailedWithError:(NSError *)error;

- (void)serviceClient:(ServiceClient *)client getMyHomeWorkDetailFailedWithError:(NSError *)error;
- (void)serviceClient:(ServiceClient *)client getMyHomeWorkDetailCompletedWithResult:(NSArray *)result;

- (void)serviceClient:(ServiceClient *)client getCourseDetailCompletedWithResult:(NSArray *)result;
- (void)serviceClient:(ServiceClient *)client getCourseDetailFailedWithError:(NSError *)error;
@end


@interface ServiceClient : NSObject

@property (nonatomic, weak) id<ServiceClientDelegate> delegate;

//同步登陆
- (NSString *)userLogin:(NSString *)userName andPswMD5:(NSString *)pswMD5;

//同步获取作业相关信息
- (NSArray *)getMyHomeWorkDetail:(NSString *)userName andSession:(NSString *)session;

//同步 获取课程信息以及通知
- (NSArray *)getMyCourseDetail:(NSString *)userName andSession:(NSString *)session;

//通用同步方法调用
+ (NSData *)commonCall:(NSString *)methodName andParams:(NSDictionary *)params;

//异步登陆接口
- (void)userLoginAsync:(NSString *)userName andPswMD5:(NSString *)pswMD5;

//异步登陆接口
- (void)userLoginForHomeworkAsync:(NSString *)userName andPswMD5:(NSString *)pswMD5;


//异步获取课程信息以及通知
- (void)getMyCourseDetailAsync:(NSString *)userName andSession:(NSString *)session;

//异步获取课程作业信息以及通知
- (void)getMyHomeWorkDetailAsync:(NSString *)userName andSession:(NSString *)session;

//MD5计算
+ (NSString *)getMD5:(NSString *)src;
@end

