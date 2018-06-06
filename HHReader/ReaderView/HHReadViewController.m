//
//  HHReadViewController.m
//  HHReader
//
//  Created by 王楠 on 2018/4/25.
//  Copyright © 2018年 王楠. All rights reserved.
//

#import "HHReadViewController.h"
#import "HHReadTool.h"

#import "HHReadModel.h"
#import "HHReadTool.h"
#import "HHReadParser.h"

#import "HHReadConfig.h"

@interface HHReadViewController ()
 
@property (nonatomic, strong) UILabel *titleLabel;   /**< 用于显示书名或者章节名*/
@property (nonatomic, strong) UILabel *pageLabel;   /**< 用于显示每一章的当前页和总页数*/
@property (nonatomic, strong) UILabel *sysTimeLabel;   /**< 用于显示系统时间*/

@end

@implementation HHReadViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [HHReadConfig shareInstance].themeColor;
    
    [self addReadView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeThemeColor:) name:ChangeThemeColorNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModel:) name:NightModelNotification object:nil];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ChangeThemeColorNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NightModelNotification object:nil];
}

#pragma mark -
//  更新主题颜色
- (void)changeThemeColor:(NSNotification *)sender {
    UIColor *color = sender.object;
    [HHReadConfig shareInstance].themeColor = color;
    [HHReadConfig shareInstance].lastChangeThemeColor = color;
    self.view.backgroundColor = color;
}

- (void)nightModel:(NSNotification *)sender {
    self.view.backgroundColor = [HHReadConfig shareInstance].themeColor;
}

#pragma mark - 

- (void)addReadView {
    CGRect rect = self.view.bounds;
    rect.origin.x += 20;
    rect.origin.y += StatusBarHeight + 40;
    rect.size.width -= 40;
    rect.size.height -= StatusBarHeight + 80;
    self.readView = [[HHReadPageView alloc] initWithFrame:rect];
    [self.view addSubview:self.readView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, StatusBarHeight + 20, self.view.bounds.size.width - 40, 20)];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.titleLabel];
    
    CGFloat pageLabelWidth = 80;
    self.pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - pageLabelWidth - 20, CGRectGetMaxY(self.readView.frame), pageLabelWidth, 20)];
    self.pageLabel.textAlignment = NSTextAlignmentRight;
    self.pageLabel.font = [UIFont systemFontOfSize:15];
    self.pageLabel.textColor = [UIColor blueColor];
    [self.view addSubview:self.pageLabel];
    
    self.sysTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.readView.frame), pageLabelWidth, 20)];
    self.sysTimeLabel.textAlignment = NSTextAlignmentLeft;
    self.sysTimeLabel.font = [UIFont systemFontOfSize:15];
    self.sysTimeLabel.textColor = [UIColor blueColor];
    [self.view addSubview:self.sysTimeLabel];
    
}

#pragma mark -

- (void)setCurrentChapterModel:(HHReadChapterModel *)currentChapterModel {
    _currentChapterModel = currentChapterModel;
    
    CGRect rect = self.view.bounds;
    rect.origin.x += 20;
    rect.origin.y += StatusBarHeight + 40;
    rect.size.width -= 40;
    rect.size.height -= StatusBarHeight + 80;
    
    self.readView.frameRef = nil;

    NSArray *arr = [HHReadTool getChapterCountContent:currentChapterModel.chapterContent rect:rect];
    NSString *content = [HHReadTool stringOfPage:self.currentPage content:currentChapterModel.chapterContent chapterPageArray:arr];
        
    CTFrameRef temp = [HHReadParser parserContent:content searchContent:currentChapterModel.searchContent bouds:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    
    self.readView.frameRef = temp;
    
    self.readView.content = content;
    NSString *titleString = [NSString stringWithFormat:@"%@", currentChapterModel.chapterTitle];
    // 第一页时使用书名作为内容
    if (self.currentPage == 0) {
        titleString = currentChapterModel.bookId;
    }
    self.titleLabel.text = titleString;
    self.titleLabel.textColor = [HHReadConfig shareInstance].fontColor;
    self.pageLabel.text = [NSString stringWithFormat:@"%@ / %@", @(self.currentPage), @(currentChapterModel.chapterPageCount)];
    
    self.sysTimeLabel.text = [self getCurrentTime];
    self.sysTimeLabel.textColor = [HHReadConfig shareInstance].fontColor;
    [self.view setNeedsDisplay];

}

- (NSString *)getCurrentTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [dateFormatter stringFromDate:datenow];
    return currentTimeString;
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
