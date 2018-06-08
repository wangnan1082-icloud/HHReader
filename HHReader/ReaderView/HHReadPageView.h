//
//  HHReadPageView.h
//  HHReader
//
//  Created by 王楠 on 2018/5/14.
//  Copyright © 2018年 王楠. All rights reserved.
//  通过CoreText来显示正解内容

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface HHReadPageView : UIView

@property (nonatomic, assign) CTFrameRef frameRef; /**< frameRef*/
@property (nonatomic, copy) NSString *content; /**< 内容*/

@end
