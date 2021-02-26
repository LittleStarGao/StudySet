//
//  EBBaseAPIProxy.h
//  EBusinessPlatform
//
//  Created by 嘉嘉高 on 2019/9/11.
//  Copyright © 2019 嘉嘉高. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EBBaseAPIResponse.h"
#import "AFNetworking.h"
#import "EBBaseAPIResponse.h"
#import "EBNetworkAddressMacro.h"
#import "NSObject+Additions.h"

NS_ASSUME_NONNULL_BEGIN

// 定义发起请求的类型
typedef NS_ENUM (NSUInteger, APIManagerRequestType){
    APIManagerRequestTypeGet,
    APIManagerRequestTypePost,
    APIManagerRequestTypeUpload,
    APIManagerRequestTypeDelete,
    APIManagerRequestTypePut
};

//
typedef void(^EBAPICallback)(EBBaseAPIResponse *response);

@interface EBBaseAPIProxy : NSObject
/// 请求序列化
@property (nonatomic, strong) AFHTTPRequestSerializer <AFURLRequestSerialization> * requestSerializer;
/// 响应的序列化
@property (nonatomic, strong) AFHTTPResponseSerializer <AFURLResponseSerialization> * responseSerializer;
/// 
+ (instancetype)sharedInstance;

/**
 具体发起网络的类型

 @param requestType 请求是 POST 和 GET
 @param params 发起网络请求的参数
 @param requestPath 请求资源的路径
 @param uploadBlock 下载下的数据
 @param success 成功信息
 @param fail 失败的信息
 @return 返回请求标识，用于取消网络请求使用
 */
- (NSInteger)callAPIWithRequestType:(APIManagerRequestType)requestType params:(NSDictionary *)params requestPath:(NSString *)requestPath uploadBlock:(void (^)(id <AFMultipartFormData> formData))uploadBlock success:(EBAPICallback)success fail:(EBAPICallback)fail;

/**
 
 取消网络请求
 
 @param requestID 请求网络的唯一标识
 
 */
- (void)cancelRequestWithRequestID:(NSNumber *)requestID;

/**
 
 取消网络的请求操作
 
 @param requestIDList 发起请求的列表操作
 */

- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;

@end

NS_ASSUME_NONNULL_END
