//
//  HHReadConst.h
//  HHReader
//
//  Created by 王楠 on 2018/5/25.
//  Copyright © 2018年 王楠. All rights reserved.
//

#ifndef HHReadConst_h
#define HHReadConst_h

#define RGBColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
#define RandomColor RGBColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), 255)

#define StatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height

#define NightFontColor RGBColor(108.0, 108.0, 108.0, 255)

// 通知

#define UpdateProgressNotification @"UpdateProgressNotification"
#define ChangeFontSizeNotification @"ChangeFontSizeNotification"
#define NightModelNotification @"NightModelNotification"
#define ChangeThemeColorNotification @"ChangeThemeColorNotifications"
#define ChangeBrightNotification @"ChangeBrightNotification"
#define MoreNotification @"MoreNotification"

#define ReadBackNotification @"ReadBackNotification"
#define SearchNotification @"SearchNotification"
#define ChapterListNotification @"ChapterListNotification"
#define BookMarkNotification @"BookMarkNotification"

// 保存当前阅读记录的章节和页号
#define BookMarkChapter @"BookMarkChapter"
#define BookMarkPage @"BookMarkPage"

// 自动翻页
#define AutoPagingTimeFaster @"变快"
#define AutoPagingTimeSlower @"变慢"
#define AutoPagingTimeStop @"停止"
#define AutoPagingTimeStart @"开始"

#define AutoPagingTime @"AutoPagingTime"

#endif /* HHReadConst_h */
