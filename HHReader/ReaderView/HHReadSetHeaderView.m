//
//  HHReadSetHeaderView.m
//  HHReader
//
//  Created by 王楠 on 2018/5/28.
//  Copyright © 2018年 王楠. All rights reserved.
//  设置顶端View

#import "HHReadSetHeaderView.h"
#import "HHReadTool.h"
#import "HHReadConfig.h"

#import "HHReadChapterListView.h"

@interface HHReadSetHeaderView()

@property (nonatomic, strong) UIButton *backBtn; /**< 返回*/
@property (nonatomic, strong) UIButton *searchBook; /**< 搜索*/
@property (nonatomic, strong) UIButton *chapterList; /**< 章节列表*/
@property (nonatomic, strong) UIButton *bookMark; /**< 书签*/

@end

@implementation HHReadSetHeaderView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addView];
    }
    return self;
}

- (void)addView {
    [self addSubview:self.backBtn];
    [self addSubview:self.searchBook];
    [self addSubview:self.chapterList];
    [self addSubview:self.bookMark];
}

#pragma mark -

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width/6;
    CGFloat height = self.frame.size.height;
    CGFloat space = 2;
    CGFloat btnHeight = height - space;
    _backBtn.frame = CGRectMake(0, space/2, width, btnHeight);
    _bookMark.frame = CGRectMake(self.frame.size.width - width, space/2, width, btnHeight);
    _chapterList.frame = CGRectMake(self.frame.size.width - 2*width, space/2, width, btnHeight);
    _searchBook.frame = CGRectMake(self.frame.size.width - 3*width, space/2, width, btnHeight);
}

#pragma mark - Getter

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [HHReadTool createButtonWithTarget:self selecter:@selector(backButtonClick:) image:[UIImage imageNamed:@"Top-ReadBack"] selectedImage:[UIImage imageNamed:@"Top-ReadBack"]];
    }
    return _backBtn;
}

- (UIButton *)searchBook {
    if (!_searchBook) {
        _searchBook = [HHReadTool createButtonWithTarget:self selecter:@selector(searchBookButtonClick:) image:[UIImage imageNamed:@"Top-Search"] selectedImage:[UIImage imageNamed:@"Top-Search"]];
    }
    return _searchBook;
}

- (UIButton *)chapterList {
    if (!_chapterList) {
        _chapterList = [HHReadTool createButtonWithTarget:self selecter:@selector(chapterListButtonClick:) image:[UIImage imageNamed:@"Top-Catalog"] selectedImage:[UIImage imageNamed:@"Top-Catalog"]];
    }
    return _chapterList;
}

- (UIButton *)bookMark {
    if (!_bookMark) {
        _bookMark = [HHReadTool createButtonWithTarget:self selecter:@selector(bookMarkButtonClick:) image:[UIImage imageNamed:@"Top-Mark"] selectedImage:[UIImage imageNamed:@"Top-Mark"]];
    }
    return _bookMark;
}

#pragma mark - Button Click


- (void)backButtonClick:(UIButton *)sender {
    //  返回
    [[NSNotificationCenter defaultCenter] postNotificationName:ReadBackNotification object:nil];
}

- (void)searchBookButtonClick:(UIButton *)sender {
    //  搜索
    HHReadChapterListView *chapterListView = [HHReadChapterListView sharedInstance];
    if (chapterListView.searchChapterModelArray.count == 0) {
        chapterListView.readModel = self.readModel;
    }
    
    chapterListView.currentChapter = self.currentChapter;
    chapterListView.block = ^(NSInteger index, NSInteger searchChapterPage, NSString *searchContent) {
        NSDictionary *dic = @{@"chapterId":@(index), @"page":@(searchChapterPage), @"searchContent": searchContent};
        [[NSNotificationCenter defaultCenter] postNotificationName:SearchNotification object:dic];
    };
    
    [HHReadChapterListView show];
}

- (void)chapterListButtonClick:(UIButton *)sender {
    //  章节列表
    [[NSNotificationCenter defaultCenter] postNotificationName:ChapterListNotification object:nil];
}

- (void)bookMarkButtonClick:(UIButton *)sender {
    //  书签
    [[NSNotificationCenter defaultCenter] postNotificationName:BookMarkNotification object:nil];

}

@end
