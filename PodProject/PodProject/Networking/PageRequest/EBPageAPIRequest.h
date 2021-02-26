//
//  EBPageAPIRequest.h
//  EBusinessPlatform
//
//  Created by 嘉嘉高 on 2019/9/12.
//  Copyright © 2019 嘉嘉高. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EBNetProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PageDelegate <NSObject>

@required

//
- (NSArray *)buildPageArray;

@end

// 获取相应响应操作
@interface EBPageAPIRequest : NSObject <APIManager>


@end

NS_ASSUME_NONNULL_END
