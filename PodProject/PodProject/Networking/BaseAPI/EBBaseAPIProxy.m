//
//  EBBaseAPIProxy.m
//  EBusinessPlatform
//
//  Created by 嘉嘉高 on 2019/9/11.
//  Copyright © 2019 嘉嘉高. All rights reserved.

#import "EBBaseAPIProxy.h"

#define kCookie @"Cookie"

/// 匿名内部类
@interface EBBaseAPIProxy ()

/**
    存储请求的的NSURLSessionDataTask任务
*/

@property (nonatomic, strong) NSMutableDictionary *dispatchTable;
//
@property (nonatomic, strong) NSNumber *recordedRequestId;

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation EBBaseAPIProxy

//
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static EBBaseAPIProxy *shareInstance = nil;
    dispatch_once(&onceToken, ^{
        shareInstance = [[EBBaseAPIProxy alloc] init];
    });
    return shareInstance;
}


- (NSInteger)callAPIWithRequestType:(APIManagerRequestType)requestType params:(NSDictionary *)params requestPath:(NSString *)requestPath uploadBlock:(void (^)(id<AFMultipartFormData> _Nonnull))uploadBlock success:(EBAPICallback)success fail:(EBAPICallback)fail {
    
    NSString *urlString = [NSString stringWithFormat: @"%@%@", BaseUrl , requestPath];
    NSNumber *requestId = [self callApi:urlString requestType:requestType params:params uploadBlock:uploadBlock success:success fail:fail];
    
    return [requestId integerValue];
}

// 取消网络请求
- (void)cancelRequestWithRequestID:(NSNumber *)requestID {
    NSURLSessionDataTask *dataTask = self.dispatchTable[requestID];
    [dataTask cancel];
    //
    [self.dispatchTable removeObjectForKey:requestID];
}

// 取消请求列表
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList {
    for (NSNumber *requestId
         in requestIDList) {
        [self cancelRequestWithRequestID:requestId];
    }
}


- (NSNumber *)callApi:(NSString *)URLString requestType:(APIManagerRequestType)requestType params:(NSDictionary *)params uploadBlock:(void (^)(id <AFMultipartFormData> formData))uploadBlock success:(EBAPICallback)success fail:(EBAPICallback)fail
{
    // 之所以不用getter，是因为如果放到getter里面的话，每次调用self.recordedRequestId的时候值就都变了，违背了getter的初衷
    NSNumber *requestId = [self generateRequestId];
    
    self.sessionManager.requestSerializer = self.requestSerializer;
    self.sessionManager.requestSerializer.timeoutInterval = 10;
    self.sessionManager.responseSerializer = self.responseSerializer;
    [self setCookie];
    // 跑到这里的block的时候，就已经是主线程了。
    NSURLSessionDataTask *dataTask;
    switch (requestType)
    {
        case APIManagerRequestTypeGet:
        {
            dataTask = [self.sessionManager GET:URLString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handelSuccessRequst:requestId task:task responseObject:responseObject success:success];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handelFailRequest:requestId task:task error:error fail:fail];
            }];
        }
            break;
        case APIManagerRequestTypePost:
        {
            dataTask = [self.sessionManager POST:URLString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handelSuccessRequst:requestId task:task responseObject:responseObject success:success];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handelFailRequest:requestId task:task error:error fail:fail];
            }];
        }
            break;
        case APIManagerRequestTypeUpload:
        {
            self.sessionManager.requestSerializer.timeoutInterval = 20;
            dataTask = [self.sessionManager POST:URLString parameters:params constructingBodyWithBlock:uploadBlock progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handelSuccessRequst:requestId task:task responseObject:responseObject success:success];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handelFailRequest:requestId task:task error:error fail:fail];
            }];
        }
            break;
        case APIManagerRequestTypeDelete:
        {
            dataTask = [self.sessionManager DELETE:URLString parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handelSuccessRequst:requestId task:task responseObject:responseObject success:success];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handelFailRequest:requestId task:task error:error fail:fail];
            }];
        }
            break;
        case APIManagerRequestTypePut:
        {
            dataTask = [self.sessionManager PUT:URLString parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handelSuccessRequst:requestId task:task responseObject:responseObject success:success];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handelFailRequest:requestId task:task error:error fail:fail];
            }];
        }
            break;
        default:
            break;
    }
    
    self.dispatchTable[requestId] = dataTask;
    return requestId;
}

- (void)handelSuccessRequst:(NSNumber *)requestId task:(NSURLSessionDataTask *)task responseObject:(id)responseObject success:(EBAPICallback)success
{
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    //存储归档后的cookie
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:cookiesData forKey:kCookie];
    [self setCookie];
    
    NSURLSessionDataTask *storedTask = self.dispatchTable[requestId];
    if (storedTask == nil) {
        // 如果这个task是被cancel的，那就不用处理回调了。
        return;
    } else {
        [self.dispatchTable removeObjectForKey:requestId];
    }
    
    // EBBaseAPIResponse
    EBBaseAPIResponse *response = [[EBBaseAPIResponse alloc] initWithRequestId: requestId responseObject:responseObject urlResponse:(NSHTTPURLResponse *)task.response];
    
    success ? success(response) : nil;
}

- (void)handelFailRequest:(NSNumber *)requestId task:(NSURLSessionDataTask *)task error:(NSError *)error fail:(EBAPICallback)fail
{
    NSURLSessionDataTask *storedTask = self.dispatchTable[requestId];
    if (storedTask == nil) {
        // 如果这个task是被cancel的，那就不用处理回调了。
        return;
    } else {
        [self.dispatchTable removeObjectForKey:requestId];
    }
    
    EBBaseAPIResponse *response = [[EBBaseAPIResponse alloc] initWithRequestId:requestId urlResponse:(NSHTTPURLResponse *)task.response error:error];
    
    fail ? fail(response) : nil;
}

- (NSNumber *)generateRequestId {
    if (_recordedRequestId == nil) {
        _recordedRequestId = @(1);
    } else {
        if ([_recordedRequestId integerValue] == NSIntegerMax) {
            _recordedRequestId = @(1);
        } else {
            _recordedRequestId = @([_recordedRequestId integerValue] + 1);
        }
    }
    return _recordedRequestId;
}

- (void)setCookie {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:kCookie]) {
        return;
    }
    // 对取出的cookie进行反归档处理
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey: kCookie]];
    
    if (cookies) {
        //设置cookie
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (id cookie in cookies) {
            [cookieStorage setCookie:(NSHTTPCookie *)cookie];
        }
    }
}

#pragma mark - getters and setters

- (NSMutableDictionary *)dispatchTable {
    if (_dispatchTable == nil) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager == nil) {
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
    }
    return _sessionManager;
}

//
- (NSString *)cookie {
    return nil;//safeString( [[NSUserDefaults standardUserDefaults] valueForKey: kCookie]);
}



@end
