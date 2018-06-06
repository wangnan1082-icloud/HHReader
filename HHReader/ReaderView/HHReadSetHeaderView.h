//
//  HHReadSetHeaderView.h
//  HHReader
//
//  Created by 王楠 on 2018/5/28.
//  Copyright © 2018年 王楠. All rights reserved.
//  设置顶端View

#import <UIKit/UIKit.h>
#import "HHReadModel.h"

@interface HHReadSetHeaderView : UIView

@property (nonatomic, strong) HHReadModel *readModel; /**< 模型*/
@property (nonatomic, assign) NSInteger currentChapter; /**< 当前章*/

@end
