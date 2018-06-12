//
//  HHReadViewController.h
//  HHReader
//
//  Created by 王楠 on 2018/4/25.
//  Copyright © 2018年 王楠. All rights reserved.
//  阅读页面（包含阅读View）

#import <UIKit/UIKit.h>
#import "HHReadPageView.h"
#import "HHReadModel.h"
#import "HHReadChapterModel.h"

@interface HHReadViewController : UIViewController

@property (nonatomic, strong) HHReadPageView *readView;

@property (nonatomic, strong) HHReadModel *currentModel; /**< 当前的数据*/
@property (nonatomic, strong) HHReadChapterModel *currentChapterModel; /**< 当前章节的数据*/
@property (nonatomic, assign) NSInteger currentPage; /**< 当前的章节页*/

- (void)configCurrentChapterModel:(HHReadChapterModel *)currentChapterModel;

@end
