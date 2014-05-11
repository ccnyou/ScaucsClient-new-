//
//  ServiceClient.m
//  SOAPDemo
//
//  Created by ccnyou on 14-3-28.
//  Copyright (c) 2014年 ccnyou. All rights reserved.
//

#import "ServiceClient.h"
#import "GDataXMLNode.h"
#import <CommonCrypto/CommonDigest.h>

#define SERVER_URL  @"http://wcf.scaucs.net/mainservice.svc"

//暂时没用
//typedef enum {
//    MethodNameNone,
//    MethodNameUserLogin,
//    MethodNameInvalid
//}MethodName;

@interface ServiceClient () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

//都暂时没用
//@property (nonatomic, strong) NSURLConnection* connection;
//@property (nonatomic, strong) NSMutableDictionary* connDict;
//@property (nonatomic, strong) NSCondition* condition;
//@property (nonatomic, assign) MethodName methodName;

@end

@implementation ServiceClient


- (id)init
{
    self = [super init];
    if (self) {

    }
    
    return self;
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
    NSString* soapAction = [NSString stringWithFormat:@"\"http://tempuri.org/IMainService/%@\"", methodName];
    [request addValue:soapAction forHTTPHeaderField:@"SOAPAction"];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    [request setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
    
    return request;
}

- (NSString *)userLogin:(NSString *)userName andPswMD5:(NSString *)pswMD5
{
    NSString* resultString = nil;
    //构造请求
    NSMutableString* bodyString = [NSMutableString stringWithString:@"<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\">"];
    [bodyString appendString:@"<s:Body><UserLogin xmlns=\"http://tempuri.org/\">"];
    [bodyString appendFormat:@"<strUserName>%@</strUserName>", userName];
    [bodyString appendFormat:@"<strPassWordMd5>%@</strPassWordMd5>", pswMD5];
    [bodyString appendString:@"</UserLogin></s:Body></s:Envelope>"];
    NSData* bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString* serverUrlString = SERVER_URL;
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverUrlString]];
    [request addValue:@"\"http://tempuri.org/IMainService/UserLogin\"" forHTTPHeaderField:@"SOAPAction"];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    [request setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
    
    NSError* error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSAssert(error == nil, @"err = %@", error);
    
    if (data) {
        GDataXMLDocument* doc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
        GDataXMLElement* rootElement = [doc rootElement];
        GDataXMLNode* node = [rootElement childAtIndex:0];
        node = [node childAtIndex:0];
        node = [node childAtIndex:0];
        NSAssert([[node name] isEqualToString:@"UserLoginResult"], @"貌似出错了，返回数据不是 UserLoginResult");
        
        resultString = [node stringValue];
    }
    
    return resultString;
}


- (NSArray *)getMyCourseDetail:(NSString *)userName andSession:(NSString *)session
{
    NSMutableArray* resultArray = nil;
    
    //构造请求
    NSMutableString* bodyString = [NSMutableString stringWithString:@"<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\">"];
    [bodyString appendString:@"<s:Body><GetMyCourseDetail xmlns=\"http://tempuri.org/\">"];
    [bodyString appendFormat:@"<strUserNumber>%@</strUserNumber>", userName];
    [bodyString appendFormat:@"<strSession>%@</strSession>", session];
    [bodyString appendString:@"</GetMyCourseDetail></s:Body></s:Envelope>"];
    NSData* bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString* serverUrlString = SERVER_URL;
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverUrlString]];
    [request addValue:@"\"http://tempuri.org/IMainService/GetMyCourseDetail\"" forHTTPHeaderField:@"SOAPAction"];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    [request setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
    
    NSError* error = nil;
    NSData* xmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSAssert(error == nil, @"err = %@", error);
    
    GDataXMLDocument* doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:nil];
    GDataXMLElement* rootElement = [doc rootElement];
    GDataXMLNode* node = [rootElement childAtIndex:0];
    node = [node childAtIndex:0];
    node = [node childAtIndex:0];
    
    NSMutableArray* results = [[NSMutableArray alloc] init];
    NSArray* array = [node children];
    for (GDataXMLElement* objNode in array) {
        NSAssert([[objNode name] isEqualToString:@"a:ArrayOfstring"], @"貌似出错了，返回数据不是一个字符串数组");
        
        NSMutableArray* strings = [[NSMutableArray alloc] initWithCapacity:5];
        NSArray* elems = [objNode children];
        for (GDataXMLElement* elem in elems) {
            [strings addObject:[elem stringValue]];
        }
        
        if ([strings count] > 0) {
            [results addObject:strings];
        }
    }
    
    resultArray = results;
    return resultArray;
}

+ (NSData *)commonCall:(NSString *)methodName andParams:(NSDictionary *)params
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
    NSString* soapAction = [NSString stringWithFormat:@"\"http://tempuri.org/IMainService/%@\"", methodName];
    [request addValue:soapAction forHTTPHeaderField:@"SOAPAction"];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    [request setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
    
    NSError* error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSAssert(error == nil, @"err = %@", error);

    return data;
}

- (void)userLoginAsync:(NSString *)userName andPswMD5:(NSString *)pswMD5
{
    //构造请求
    NSDictionary* params = @{
                             @"strUserName" : userName,
                             @"strPassWordMd5" : pswMD5
                             };
    NSURLRequest* request = [self requestWithMethodName:@"UserLogin" andParams:params];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([_delegate respondsToSelector:@selector(serviceClient:loginCompletedWithResult:)]) {
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
                NSAssert([[node name] isEqualToString:@"UserLoginResult"], @"貌似出错了，返回数据不是 UserLoginResult");
                
                resultString = [node stringValue];
            }
            
            [_delegate serviceClient:self loginCompletedWithResult:resultString];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([_delegate respondsToSelector:@selector(serviceClient:loginFailedWithError:)]) {
            [_delegate serviceClient:self loginFailedWithError:error];
        }
    }];
    
    [operation start];
}






- (void)getMyCourseDetailAsync:(NSString *)userName andSession:(NSString *)session
{
    //用字典储存数据，利用string来匹配获取
    NSDictionary* params = @{
                             @"strUserNumber" : userName,
                             @"strSession" : session
                             };
    //封装请求。
    NSURLRequest* request = [self requestWithMethodName:@"GetMyCourseDetail" andParams:params];
    //获取了xml
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([_delegate respondsToSelector:@selector(serviceClient:getCourseDetailCompletedWithResult:)]) {
            //对XMl进行解析
            NSData* xmlData = responseObject;
            //使用NSData对象初始化
            GDataXMLDocument* doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:nil];
            //获取根节点
            GDataXMLElement* rootElement = [doc rootElement];
            //获取根节点下的节点
            GDataXMLNode* node = [rootElement childAtIndex:0];
            node = [node childAtIndex:0];
            node = [node childAtIndex:0];
            
            NSMutableArray* results = [[NSMutableArray alloc] init];
            NSArray* array = [node children];
            for (GDataXMLElement* objNode in array) {
                NSAssert([[objNode name] isEqualToString:@"a:ArrayOfstring"], @"貌似出错了，返回数据不是一个字符串数组");
                
                NSMutableArray* strings = [[NSMutableArray alloc] initWithCapacity:5];
                NSArray* elems = [objNode children];
                for (GDataXMLElement* elem in elems) {
                    [strings addObject:[elem stringValue]];
                }
                
                if ([strings count] > 0) {
                    [results addObject:strings];
                }
            }
            
            [_delegate serviceClient:self getCourseDetailCompletedWithResult:results];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([_delegate respondsToSelector:@selector(serviceClient:getCourseDetailFailedWithError:)]) {
            [_delegate serviceClient:self getCourseDetailFailedWithError:error];
        }
    }];
    
    [operation start];
}

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


- (NSArray *)getMyHomeWorkDetail:(NSString *)userName andSession:(NSString *)session
{
    NSMutableArray* resultArray = nil;
    
    //构造请求
    NSMutableString* bodyString = [NSMutableString stringWithString:@"<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\">"];
    [bodyString appendString:@"<s:Body><GetMyHomeWorkDetail xmlns=\"http://tempuri.org/\">"];
    [bodyString appendFormat:@"<strUserNumber>%@</strUserNumber>", userName];
    [bodyString appendFormat:@"<strSession>%@</strSession>", session];
    [bodyString appendString:@"</GetMyHomeWorkDetail></s:Body></s:Envelope>"];
    NSData* bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString* serverUrlString = SERVER_URL;
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverUrlString]];
    [request addValue:@"\"http://tempuri.org/IMainService/GetMyHomeWorkDetail\"" forHTTPHeaderField:@"SOAPAction"];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    [request setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
    
    NSError* error = nil;
    NSData* xmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSAssert(error == nil, @"err = %@", error);
    
    GDataXMLDocument* doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:nil];
    GDataXMLElement* rootElement = [doc rootElement];
    GDataXMLNode* node = [rootElement childAtIndex:0];
    node = [node childAtIndex:0];
    node = [node childAtIndex:0];
    
    NSMutableArray* results = [[NSMutableArray alloc] init];
    NSArray* array = [node children];
    for (GDataXMLElement* objNode in array) {
        NSAssert([[objNode name] isEqualToString:@"a:ArrayOfstring"], @"貌似出错了，返回数据不是一个字符串数组");
        
        NSMutableArray* strings = [[NSMutableArray alloc] initWithCapacity:5];
        NSArray* elems = [objNode children];
        for (GDataXMLElement* elem in elems) {
            [strings addObject:[elem stringValue]];
        }
        
        if ([strings count] > 0) {
            [results addObject:strings];
        }
    }
    
    resultArray = results;
    return resultArray;
    
    
}




//以下是我添加的各种坑爹函数
- (void)userLoginForHomeworkAsync:(NSString *)userName andPswMD5:(NSString *)pswMD5
{
    //构造请求
    NSDictionary* params = @{
                             @"strUserName" : userName,
                             @"strPassWordMd5" : pswMD5
                             };
    NSURLRequest* request = [self requestWithMethodName:@"UserLogin" andParams:params];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([_delegate respondsToSelector:@selector(serviceClient:loginCompletedWithResult:)]) {
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
                NSAssert([[node name] isEqualToString:@"UserLoginResult"], @"貌似出错了，返回数据不是 UserLoginResult");
                
                resultString = [node stringValue];
            }
            
            [_delegate serviceClient:self loginForHomeworkWithResult:resultString];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([_delegate respondsToSelector:@selector(serviceClient:loginFailedWithError:)]) {
            [_delegate serviceClient:self loginFailedWithError:error];
        }
    }];
    
    [operation start];
}


- (void)getMyHomeWorkDetailAsync:(NSString *)userName andSession:(NSString *)session
{
    NSDictionary* params = @{
                             @"strUserNumber" : userName,
                             @"strSession" : session
                             };
    NSURLRequest* request = [self requestWithMethodName:@"GetMyHomeWorkDetail" andParams:params];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([_delegate respondsToSelector:@selector(serviceClient:getMyHomeWorkDetailCompletedWithResult:)]) {
            
            NSData* xmlData = responseObject;
            GDataXMLDocument* doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:nil];
            GDataXMLElement* rootElement = [doc rootElement];
            GDataXMLNode* node = [rootElement childAtIndex:0];
            node = [node childAtIndex:0];
            node = [node childAtIndex:0];
            
            NSMutableArray* results = [[NSMutableArray alloc] init];
            NSArray* array = [node children];
            for (GDataXMLElement* objNode in array) {
                NSAssert([[objNode name] isEqualToString:@"a:ArrayOfstring"], @"貌似出错了，返回数据不是一个字符串数组");
                
                NSMutableArray* strings = [[NSMutableArray alloc] initWithCapacity:5];
                NSArray* elems = [objNode children];
                for (GDataXMLElement* elem in elems) {
                    [strings addObject:[elem stringValue]];
                }
                
                if ([strings count] > 0) {
                    [results addObject:strings];
                }
            }
            
            [_delegate serviceClient:self getMyHomeWorkDetailCompletedWithResult:results];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([_delegate respondsToSelector:@selector(serviceClient:getMyHomeWorkDetailFailedWithError:)]) {
            [_delegate serviceClient:self getMyHomeWorkDetailFailedWithError:error];
        }
    }];
    
    [operation start];
}



@end
