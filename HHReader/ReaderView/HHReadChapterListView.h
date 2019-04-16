//
//  HHReadChapterListView.h
//  HHReader
//
//  Created by 王楠 on 2018/5/17.
//  Copyright © 2018年 王楠. All rights reserved.
//  章节列表View

#import <UIKit/UIKit.h>
#import "HHReadModel.h"

@protocol HHReadChapterListViewDelegate <NSObject>

- (void)chapterListViewDidSelectedIndex:(NSInteger)index;
@end

typedef void(^HHReadChapterListViewSelectBlock)(NSInteger index, NSInteger searchChapterPage, NSString *searchContent);

@interface HHReadChapterListView : UIView

@property (nonatomic, strong) HHReadModel *readModel; /**< 模型*/
@property (nonatomic, assign) NSInteger currentChapter; /**< 当前章*/

@property (nonatomic, copy) NSArray<HHReadChapterModel *> *searchChapterModelArray; /**< 搜索章节模型数组*/

@property (nonatomic, weak) id<HHReadChapterListViewDelegate> delegate; /**< 代理*/
@property (nonatomic, copy) HHReadChapterListViewSelectBlock block; /**< block*/

+ (instancetype)sharedInstance;

+ (void)show;
+ (void)dismiss;

@end
