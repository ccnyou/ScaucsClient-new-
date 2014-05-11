//
//  ScaucsSession.m
//  ScaucsClient
//
//  Created by ccnyou on 14-4-7.
//  Copyright (c) 2014年 ccnyou. All rights reserved.
//

#import "ScaucsSession.h"
#import "ServiceClient.h"

@interface ScaucsSession () <ServiceClientDelegate>

@end

@implementation ScaucsSession

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedSession];
}

+ (ScaucsSession *)sharedSession
{
    static ScaucsSession* sharedClientObject = nil;
    if (sharedClientObject == nil) {
        sharedClientObject = [[super allocWithZone:NULL] init];
    }
    
    return sharedClientObject;
}

@end
