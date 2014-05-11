//
//  LvKangServiceClient.m
//  ScaucsClient
//
//  Created by ccnyou on 14-4-7.
//  Copyright (c) 2014年 ccnyou. All rights reserved.
//

#import "LvKangServiceClient.h"
#import "GDataXMLNode.h"
#import "AFNetworking.h"
#import "GTMBase64.h"
#import <CommonCrypto/CommonDigest.h>

#define SERVER_URL  @"http://t.vip315.net:8800/ScauCsService.svc"

@interface LvKangServiceClient ()

@end

@implementation LvKangServiceClient


+ (NSString *)getMD5:(NSString *)src
{
    const char* cstr = [src UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cstr, strlen(cstr), digest);
    
    NSMutableString* result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
}


- (NSURLRequest *)requestWithMethodName:(NSString *)methodName andParams:(NSDictionary *)params
{
    NSArray* keys = [params allKeys];
    
    //构造请求
    NSMutableString* bodyString = [NSMutableString stringWithString:@"<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\">"];
    
    [bodyString appendFormat:@"<s:Body><%@ xmlns=\"http://tempuri.org/\">", methodName];
    for (NSString* key in keys) {
        NSString* value = [params valueForKey:key];
        [bodyString appendFormat:@"<%@>%@</%@>", key, value, key];
    }
    [bodyString appendFormat:@"</%@></s:Body></s:Envelope>", methodName];
    NSData* bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSString* serverUrlString = SERVER_URL;
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverUrlString]];
    NSString* soapAction = [NSString stringWithFormat:@"\"http://tempuri.org/IScauCSService/%@\"", methodName];
    [request addValue:soapAction forHTTPHeaderField:@"SOAPAction"];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    [request setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
    
    return request;
}


- (void)getMyPassword:(NSString *)userName andPsw:(NSString *)password
{
    NSString* pswMD5 = [LvKangServiceClient getMD5:password];
    
    //构造请求
    NSDictionary* params = @{
                             @"strStudentNumber" : userName,
                             @"strPassWordMD5" : pswMD5
                             };
    NSURLRequest* request = [self requestWithMethodName:@"GetMyPassword" andParams:params];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([_delegate respondsToSelector:@selector(lkServiceClient:getPswCompletedWithResult:)]) {
            NSString* resultString = nil;
            NSError* error = nil;
            NSData* data = responseObject;
            NSAssert(error == nil, @"err = %@", error);
            
            if (data) {
                GDataXMLDocument* doc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
                GDataXMLElement* rootElement = [doc rootElement];
                GDataXMLNode* node = [rootElement childAtIndex:0];
                node = [node childAtIndex:0];
                node = [node childAtIndex:0];
                NSAssert([[node name] isEqualToString:@"GetMyPasswordResult"], @"貌似出错了，返回数据不是 UserLoginResult");
                
                resultString = [node stringValue];
            }
            
            [_delegate lkServiceClient:self getPswCompletedWithResult:resultString];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([_delegate respondsToSelector:@selector(lkServiceClient:getPswFailedWithError:)]) {
            [_delegate lkServiceClient:self getPswFailedWithError:error];
        }
    }];
    
    [operation start];
}

- (void)getUPCA:(NSString *)userName andPsw:(NSString *)password
{
    NSString* pswMD5 = [LvKangServiceClient getMD5:password];
    
    //构造请求
    NSDictionary* params = @{
                             @"strStudentNumber" : userName,
                             @"strPassWordMD5" : pswMD5
                             };
    NSURLRequest* request = [self requestWithMethodName:@"GetUPCA" andParams:params];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([_delegate respondsToSelector:@selector(lkServiceClient:getUpcaCompletedWithResult:)]) {
            NSString* resultString = nil;
            NSData* resultData = nil;
            NSError* error = nil;
            NSData* data = responseObject;
            NSAssert(error == nil, @"err = %@", error);
            
            if (data) {
                GDataXMLDocument* doc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
                GDataXMLElement* rootElement = [doc rootElement];
                GDataXMLNode* node = [rootElement childAtIndex:0];
                node = [node childAtIndex:0];
                node = [node childAtIndex:0];
                NSAssert([[node name] isEqualToString:@"GetUPCAResult"], @"貌似出错了，返回数据不是 UserLoginResult");
                
                resultString = [node stringValue];
                
                resultData = [GTMBase64 decodeString:resultString];
            }
            
            [_delegate lkServiceClient:self getUpcaCompletedWithResult:resultData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([_delegate respondsToSelector:@selector(lkServiceClient:getPswFailedWithError:)]) {
            [_delegate lkServiceClient:self getUpcaFailedWithError:error];
        }
    }];
    
    [operation start];
}

@end
