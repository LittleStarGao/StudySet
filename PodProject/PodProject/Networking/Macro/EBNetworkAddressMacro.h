//
//  EBNetworkAddressMacro.h
//  EBusinessPlatform
//
//  Created by 嘉嘉高 on 2019/9/11.
//  Copyright © 2019 嘉嘉高. All rights reserved.
//

#ifndef EBNetworkAddressMacro_h
#define EBNetworkAddressMacro_h

#if defined APP_DEBUG

//-----------------------------------  测试环境  ------------------------------------

#define Service_Address  @""

// **********************************************************************************

#else

//-----------------------------------  生产环境  ------------------------------------

#define Service_Address     @""

#endif

#define BaseUrl     Service_Address @""

#define Login_Url                       @""
//商品列表
#define Goods_List_Url                  @"/mall/shopList"
//加入购物车
#define Add_To_Cart_Url                 @"/mall/addToCart"



#endif /* EBNetworkAddressMacro_h */
