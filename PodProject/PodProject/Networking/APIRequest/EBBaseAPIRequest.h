//
//  EBBaseAPIRequest.h
//  EBusinessPlatform
//
//  Created by 嘉嘉高 on 2019/9/11.
//  Copyright © 2019 嘉嘉高. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EBBaseAPIProxy.h"
#import "EBNetProtocol.h"

@class EBBaseAPIRequest;

NS_ASSUME_NONNULL_BEGIN

@interface EBBaseAPIRequest : NSObject

@property (nonatomic, weak) id<APIManagerApiCallBackDelegate> delegate;

@property (nonatomic, weak) id<APIManagerParamSourceDelegate> paramSource;

@property (nonatomic, weak) id<APIManagerValidator> validator;
// 协议的代理指针
@property (nonatomic, weak) id<APIManager> child;

@property (nonatomic, assign, readonly) BOOL isReachable;

@property (nonatomic, strong) EBBaseResponse *responseData;

@property (nonatomic, assign, readonly)APIManagerErrorType errorType;

@property (nonatomic, copy) NSString *msg;

@property (nonatomic, assign) BOOL disableErrorTip;

//
-(instancetype)initWithDelegate:(id)delegate paramSource:(id)paramSource;

- (NSInteger)loadDataWithHUDOnView:(UIView *)view; 

- (NSInteger)loadDataWithHUDOnView:(UIView *)view HUDMsg:(NSString *)HUDMsg;

- (void)cancelAllRequests;

- (void)cancelRequestWithRequestId:(NSInteger)requestID;


@end

NS_ASSUME_NONNULL_END
