//
//  BaseDefine.h
//  TempSlider
//
//  Created by mac on 2019/5/22.
//  Copyright © 2019 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+Extension.h"
#import "BDExtend.h"
//获取手机屏幕大小
#define kFullScreen [[UIScreen mainScreen] bounds]
//判断是否是ipad
#define kIsIPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//判断是否是iphone
#define kIsIPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//判断是否是视网膜屏
#define kIsRetina ([[UIScreen mainScreen] scale] >= 2.0)
//手机的型号判断
#define kIsIPhone_4 (kIsIPhone && kFullScreen.size.height < 568.0)
#define kIsIPhone_5 (kIsIPhone && kFullScreen.size.height == 568.0)
#define kIsIPhone_6_7_8 (kIsIPhone && kFullScreen.size.height == 667.0)
#define kIsIPhone_6P_7P_8P (kIsIPhone && kFullScreen.size.height == 736.0)
#define kIsIPhone_X (kIsIPhone && kFullScreen.size.height == 812.0)
#define kIsIPhone_XR (kIsIPhone && kFullScreen.size.height == 896.0)
#define kIsIPhone_XS (kIsIPhone && kFullScreen.size.height == 812.0)
#define kIsIPhone_XS_MAX (kIsIPhone && kFullScreen.size.height == 896.0)
//页面尺寸适配
#define kHeight(x) (kIsIPhone?((kIsIPhone_X||kIsIPhone_XS||kIsIPhone_XS_MAX||kIsIPhone_XR)?(x*kFullScreen.size.height/812.0f):(x*kFullScreen.size.height/667.0f)):(x*kFullScreen.size.height/1024.0f))
//字体大小适配
#define kFont(x) [UIFont systemFontOfSize:((kIsIPhone_4 || kIsIPhone_5)?(x - 2):(kIsIPhone_6_7_8?x:(x + 1)))]
#define kFontBold(x) [UIFont boldSystemFontOfSize:((kIsIPhone_4 || kIsIPhone_5)?(x - 2):(kIsIPhone_6_7_8?x:(x + 1)))]
#define KFontSize(x) (kIsIPhone_4 || kIsIPhone_5)?(x - 1):(kIsIPhone_6_7_8?x:(x + 1))
//颜色16进制转换
#define kColor(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]
// 绿色
#define kMainColor kColor(0x97be0cff)
// 灰色
#define kDarkGray kColor(0x5a5a5aff)
#define kDarkGrayAlpha kColor(0x5a5a5a7e)
#define kDarkGrayAlpha2 kColor(0x5a5a5a9e)
#define kLightGray kColor(0xb4b4b4ff)
//基础线颜色
#define kLineColor kColor(0xecececFF)

NS_ASSUME_NONNULL_BEGIN

@interface BaseDefine : NSObject

@end

NS_ASSUME_NONNULL_END
