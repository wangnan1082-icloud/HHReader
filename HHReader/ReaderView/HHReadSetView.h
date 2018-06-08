//
//  HHReadSetView.h
//  HHReader
//
//  Created by 王楠 on 2018/6/7.
//  Copyright © 2018年 王楠. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HHReadSetType) {
    /// 自动阅读速度
    HHReadSetTypeAutoReadSpeed,
    /// 主题颜色
    HHReadSetTypeThemeColor,
};

typedef void(^HHReadSetViewSelectedBlock)(NSDictionary *setValue);

@interface HHReadSetView : UIView

@property (nonatomic, assign) HHReadSetType setType; /**< 设置类型*/
@property (nonatomic, copy) HHReadSetViewSelectedBlock block; /**< block*/
@property (nonatomic, assign) CGRect showFrame; /**< 位置*/

+ (instancetype)sharedInstance;

+ (void)show;
+ (void)dismiss;

@end
