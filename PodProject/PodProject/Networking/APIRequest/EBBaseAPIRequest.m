//
//  EBBaseAPIRequest.m
//  EBusinessPlatform
//
//  Created by 嘉嘉高 on 2019/9/11.
//  Copyright © 2019 嘉嘉高. All rights reserved.
//

#import "EBBaseAPIRequest.h"
#import "EBNetworkTipsMacro.h"
#import "YYModel.h"

@interface EBBaseAPIRequest ()
// 创建相应的数据操作
@property (nonatomic, copy, readwrite) NSString *errorMessage;
// 成功的消息操作
@property (nonatomic, copy, readwrite) NSString *successMessage;
// 错误的类型操作
@property (nonatomic, readwrite) APIManagerErrorType errorType;
// 请求的列表
@property (nonatomic, strong) NSMutableArray *requestIdList;

@property (nonatomic, assign)NSInteger reloginCount;

@end


@implementation EBBaseAPIRequest

-(instancetype)initWithDelegate:(id)delegate paramSource:(id)paramSource
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _paramSource = paramSource;
        _validator = (id)self;
        _errorType = APIManagerErrorTypeDefault;
        
        if ([self conformsToProtocol:@protocol(APIManager)]) {
            self.child = (id <APIManager>)self;
        }
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegate = nil;
        _paramSource = nil;
        _validator = (id)self;
        _errorType = APIManagerErrorTypeDefault;
        
        if ([self conformsToProtocol:@protocol(APIManager)]) {
            self.child = (id <APIManager>)self;
        }
    }
    return self;
}

- (void)dealloc
{
    [self cancelAllRequests];
    self.requestIdList = nil;
}

#pragma mark - calling api
-(NSInteger)loadDataWithHUDOnView:(UIView *)view
{
    return [self loadDataWithHUDOnView:view HUDMsg:@""];
}

-(NSInteger)loadDataWithHUDOnView:(UIView *)view HUDMsg:(NSString *)HUDMsg
{
    [self cancelAllRequests];
//    if (view) {
//        self.hudSuperView = view;
//        //[MBProgressHUD showLoadingHUD:HUDMsg onView:self.hudSuperView];
//    }
    NSDictionary *params = [self.paramSource paramsForApi:self];
    if ([self.child respondsToSelector:@selector(reformParamsForApi:)]) {
        params = [self.child reformParamsForApi:params];
    }
    //    params = [self signatureParams:params];
    NSInteger requestId = [self loadDataWithParams:params];
    return requestId;
}

- (NSInteger)loadDataWithParams:(NSDictionary *)params
{
    NSInteger requestId = 0;
    
    if ([self isReachable]) {
        
        if ([self.child respondsToSelector:@selector(requestSerializer)]) {
            
            [EBBaseAPIProxy sharedInstance].requestSerializer = self.child.requestSerializer;
            
        } else {
            
            [EBBaseAPIProxy sharedInstance].requestSerializer = [AFHTTPRequestSerializer serializer]; // 拼接，如果是JSON换成AFJSON
            
        }
        
        
        if ([self.child respondsToSelector:@selector(responseSerializer)]) {
            
            [EBBaseAPIProxy sharedInstance].responseSerializer = self.child.responseSerializer;
            
            
        } else {
            
            [EBBaseAPIProxy sharedInstance].responseSerializer = [AFJSONResponseSerializer serializer];
        }
        
        [[EBBaseAPIProxy sharedInstance] callAPIWithRequestType:self.child.requestType params:params requestPath:self.child.requestPath uploadBlock:[self.paramSource respondsToSelector:@selector(uploadBlock:)] ?  [self.paramSource uploadBlock: self] : nil success:^(EBBaseAPIResponse *response) {
            //
            [self successedOnCallingAPI: response];
            
        } fail:^(EBBaseAPIResponse *response) {
            
            [self failedOnCallingAPI: response withErrorType:response.errorType];
        }];
        [self.requestIdList addObject:@(requestId)];
        return requestId;
        
    } else {
        
        // 返回是网络未连接处理操作
        [self failedOnCallingAPI: nil withErrorType: APIManagerErrorTypeNoNetWork];
        return requestId;
        
    }
    return requestId;
}

// 成功获取的网络请求操作
- (void)successedOnCallingAPI:(EBBaseAPIResponse *)response
{

    [self removeRequestIdWithRequestID:response.requestId];
    
    
    // 响应相应的网络请求，然后进行
    if ([self.child respondsToSelector:@selector(responseClass)]) {
        self.responseData =  [[self.child responseClass] yy_modelWithDictionary: response.responseData];
        if (self.responseData.errcode!= 10000) {
            response.msg = self.responseData.msg;
            [self failedOnCallingAPI:response withErrorType:APIManagerErrorTypeDefault];
            return;
        }
    } else {
        self.responseData = response.responseData;
        
    }
    
    if ([self.validator respondsToSelector:@selector(manager:isCorrectWithCallBackData:)] && ![self.validator manager:self isCorrectWithCallBackData: self.responseData]) {
        [self failedOnCallingAPI:response withErrorType: APIManagerErrorTypeNoContent];
        
    } else {
        
        if ([self.child respondsToSelector:@selector(reformData)]) {
            [self.child reformData];
        }
        [self.delegate managerCallAPIDidSuccess: self];
    }
}

- (void)failedOnCallingAPI:(EBBaseAPIResponse *)response withErrorType:(APIManagerErrorType)errorType {

    self.errorType = errorType;
    self.msg = response.msg;
    [self removeRequestIdWithRequestID:response.requestId];
    switch (errorType) {
        case APIManagerErrorTypeDefault:
            self.errorMessage = response.msg;
            
            break;
        case APIManagerErrorTypeSuccess:
            break;
        case APIManagerErrorTypeNoContent:
            break;
        case APIManagerErrorTypeParamsError:
            break;
        case APIManagerErrorTypeTimeout:
            self.msg = Tip_RequestOutTime;
            break;
        case APIManagerErrorTypeNoNetWork:
            self.msg = Tip_NoNetwork;
            break;
        case APIManagerErrorLoginTimeout:
            self.msg = Tip_LoginTimeOut;
            break;
        default:
            break;
    }
    
    // 回调请求失败进行相应的操作
    [self.delegate managerCallAPIDidFailed: self ];
}

#pragma mark - private methods
- (void)cancelAllRequests
{
    [[EBBaseAPIProxy sharedInstance] cancelRequestWithRequestIDList: self.requestIdList];
    [self.requestIdList removeAllObjects];
}

- (void)cancelRequestWithRequestId:(NSInteger)requestID
{
    [self removeRequestIdWithRequestID: requestID];
    [[EBBaseAPIProxy sharedInstance] cancelRequestWithRequestID:@(requestID)];
}

- (void)removeRequestIdWithRequestID:(NSInteger)requestId
{
    NSNumber *requestIDToRemove = nil;
    for (NSNumber *storedRequestId in self.requestIdList) {
        if ([storedRequestId integerValue] == requestId) {
            requestIDToRemove = storedRequestId;
        }
    }
    //
    if (requestIDToRemove) {
        [self.requestIdList removeObject:requestIDToRemove];
    }
}


#pragma mark - getters and setters
- (BOOL)isReachable
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        return YES;
    } else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}

- (NSMutableArray *)requestIdList
{
    if (_requestIdList == nil) {
        _requestIdList = [[NSMutableArray alloc] init];
    }
    return _requestIdList;
}


@end


