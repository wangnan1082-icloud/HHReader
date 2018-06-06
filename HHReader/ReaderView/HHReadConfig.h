//
//  HHReadConfig.h
//  HHReader
//
//  Created by 王楠 on 2018/5/24.
//  Copyright © 2018年 王楠. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HHReadConfig : NSObject<NSObject>

+ (instancetype)shareInstance;

@property (nonatomic, assign) CGFloat fontSize;    /**< 文字大小*/
@property (nonatomic, assign) CGFloat lineSpace;    /**< 行间距*/
@property (nonatomic, strong) UIColor *fontColor;    /**< 文字颜色*/
@property (nonatomic, strong) UIColor *themeColor;    /**< 主题颜色*/
@property (nonatomic, strong) UIColor *lastChangeThemeColor;    /**< 上次的主题颜色*/

@end
