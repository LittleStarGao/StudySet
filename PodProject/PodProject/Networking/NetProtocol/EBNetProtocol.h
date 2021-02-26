//
//  EBNetProtocol.h
//  EBusinessPlatform
//
//  Created by 嘉嘉高 on 2019/9/12.
//  Copyright © 2019 嘉嘉高. All rights reserved.
//

#ifndef EBNetProtocol_h
#define EBNetProtocol_h



#endif /* EBNetProtocol_h */

#import "EBBaseAPIResponse.h"
#import "EBBaseAPIProxy.h"

@class EBBaseAPIRequest;

@protocol APIManagerApiCallBackDelegate <NSObject>

@required

// 请求成功回调
- (void)managerCallAPIDidSuccess:(EBBaseAPIRequest *)request;
// 请求失败的回调
- (void)managerCallAPIDidFailed:(EBBaseAPIRequest *)request;

@end

/*---------------------API参数-----------------------*/
@protocol APIManagerParamSourceDelegate <NSObject>

@required

- (NSDictionary *)paramsForApi:(EBBaseAPIRequest *)request;
@optional
- (void (^)(id <AFMultipartFormData> formData))uploadBlock:(EBBaseAPIRequest *)request;

@end

/*---------------------API验证器-----------------------*/
@protocol APIManagerValidator <NSObject>

@required


- (BOOL)manager:(EBBaseAPIRequest *)request isCorrectWithCallBackData:(EBBaseResponse *)data;

@end

@protocol APIManager <NSObject>

@optional
// 响应数据
- (Class)responseClass;

- (AFHTTPRequestSerializer <AFURLRequestSerialization> *)requestSerializer;

- (AFHTTPResponseSerializer <AFURLResponseSerialization> *)responseSerializer;

- (NSDictionary *)reformParamsForApi:(NSDictionary *)params;

- (void)reformData;

@required


- (NSString *)requestPath;

- (APIManagerRequestType)requestType;

@end
