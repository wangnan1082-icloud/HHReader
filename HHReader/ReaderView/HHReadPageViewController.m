//
// HHReadPageViewController.m
// HHReader
//
// Created by 王楠 on 2018/4/25.
// Copyright © 2018年 王楠. All rights reserved.
//

#import "HHReadPageViewController.h"
#import "HHReadViewController.h"
#import "HHReadTool.h"
#import "HHReadChapterListView.h"

#import <CoreText/CoreText.h>

#import "HHReadSetHeaderView.h"
#import "HHReadSetBottomView.h"
#import "HHReadSetView.h"
#import "NSString+Range.h"

@interface HHReadPageViewController ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource, HHReadChapterListViewDelegate>
{
    __block NSInteger _chapter;    // 当前显示的章节
    __block NSInteger _page;       // 当前显示的页数
    NSUInteger _chapterChange;  // 将要变化的章节
    NSUInteger _pageChange;     // 将要变化的页数
    HHReadChapterModel *currentChapterModel;    // 当前的章节模型
    HHReadSetHeaderView *_headerView;
    HHReadSetBottomView *_bottomView;
    HHReadChapterListView *listView;
    __block NSTimer *_autoPagingTimer;
    __block NSUInteger _autoPagingTime;
}
@property (nonatomic, strong) UIPageViewController *pageViewController;
/// 当前阅读视图
@property (nonatomic, strong) HHReadViewController *readViewController;
/// 下一页阅读视图
@property (nonatomic, strong) HHReadViewController *nextReadViewController;
/// 阅读数据模型
@property (nonatomic, strong) HHReadModel *dataModel;
/// 调整整体进度
@property (nonatomic, strong) UISlider *slider;

@end

@implementation HHReadPageViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.dataModel = [[HHReadModel alloc] init];
    self.dataModel = [self.dataModel getLocalModelWithURL:self.resourceURL];
    
    NSNumber *recordChapter = [[NSUserDefaults standardUserDefaults] objectForKey:[self recordWithBookId:self.dataModel.bookId key:BookMarkChapter]];
    NSNumber *recordPage = [[NSUserDefaults standardUserDefaults] objectForKey:[self recordWithBookId:self.dataModel.bookId key:BookMarkPage]];

    _chapter = recordChapter.integerValue;
    _page = recordPage.integerValue;
    
    [self addChildViewController:self.pageViewController];
    [self.pageViewController setViewControllers:@[self.readViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    // 添加手势
    [self addTap];
    // 添加通知
    [self addNotify];
    
    [self initAutoPagingTime];
}

- (void)addNotify {
    // 调整字体大小
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontSizeChange:) name:ChangeFontSizeNotification object:nil];
    // 调整夜间模式
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModel:) name:NightModelNotification object:nil];
    // 显示章节列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chapterList:) name:ChapterListNotification object:nil];
    // 返回
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readBack:) name:ReadBackNotification object:nil];
    // 更新进度
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:UpdateProgressNotification object:nil];
    // 搜索
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchContent:) name:SearchNotification object:nil];
    // 更多
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setMore:) name:MoreNotification object:nil];
    // 改变亮度
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBright:) name:ChangeBrightNotification object:nil];
    
}

- (void)initAutoPagingTime {
    NSNumber *num = [[NSUserDefaults standardUserDefaults] valueForKey:AutoPagingTime];
    if (num.integerValue > 0) {
        _autoPagingTime = num.integerValue;
    }else {
        _autoPagingTime = 5;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ChangeFontSizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NightModelNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ChapterListNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ReadBackNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UpdateProgressNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SearchNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MoreNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ChangeBrightNotification object:nil];
    _autoPagingTimer = nil;
}

- (void)viewDidLayoutSubviews {
    _pageViewController.view.frame = self.view.frame;
}

#pragma mark -

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - 添加章节列表

- (void)addChapterListView {
    listView = [HHReadChapterListView sharedInstance];
    listView.readModel = self.dataModel;
    listView.delegate = self;
    [HHReadChapterListView show];
    listView.currentChapter = _chapter;
}

#pragma mark -

- (void)addTap {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tap];
}

- (void)tap:(UITapGestureRecognizer *)sender {
    if (self.dataModel) {
        if (!_headerView) {
            _headerView = [[HHReadSetHeaderView alloc] initWithFrame:CGRectZero];
            _headerView.readModel = self.dataModel;
            _headerView.currentChapter = _chapter;
            [self.view addSubview:_headerView];
            _headerView.translatesAutoresizingMaskIntoConstraints = NO;

            UILayoutGuide *layoutGuide;
            if (@available(iOS 11.0, *)) {
                // 约束添加到安全区域内
                layoutGuide = self.view.safeAreaLayoutGuide;
            } else {
                layoutGuide = self.view.layoutMarginsGuide;
            }
            [UIView animateWithDuration:0.5 animations:^{
                [self->_headerView.topAnchor constraintEqualToAnchor:layoutGuide.topAnchor].active = YES;
                [self->_headerView.leftAnchor constraintEqualToAnchor:layoutGuide.leftAnchor].active = YES;
                [self->_headerView.rightAnchor constraintEqualToAnchor:layoutGuide.rightAnchor].active = YES;
                [self->_headerView.heightAnchor constraintEqualToConstant:44].active = YES;
            }];
        }else {
            // 再次点击时，移除
            [_headerView removeFromSuperview];
            _headerView = nil;
        }
        
        if (!_bottomView) {
            _bottomView = [[HHReadSetBottomView alloc] initWithFrame:CGRectZero];
            [self.view addSubview:_bottomView];
            _bottomView.translatesAutoresizingMaskIntoConstraints = NO;

            UILayoutGuide *layoutGuide;
            if (@available(iOS 11.0, *)) {
                // 约束添加到安全区域内
                layoutGuide = self.view.safeAreaLayoutGuide;
            } else {
                layoutGuide = self.view.layoutMarginsGuide;
            }
            [UIView animateWithDuration:0.5 animations:^{
                [self->_bottomView.bottomAnchor constraintEqualToAnchor:layoutGuide.bottomAnchor].active = YES;
                [self->_bottomView.leftAnchor constraintEqualToAnchor:layoutGuide.leftAnchor].active = YES;
                [self->_bottomView.rightAnchor constraintEqualToAnchor:layoutGuide.rightAnchor].active = YES;
                [self->_bottomView.heightAnchor constraintEqualToConstant:44].active = YES;
            }];
        }else {
            [_bottomView removeFromSuperview];
            [self.slider removeFromSuperview];
            _bottomView = nil;
            self.slider = nil;
        }
    }
}

#pragma mark - sliderChange

- (void)sliderChange:(UISlider *)slider {
    NSUInteger random = slider.value;
    _chapter = random;
    _page = 0;
    // 更新进度
    HHReadChapterModel *chapterModel = self.dataModel.chapterListArr[_chapter];
    _readViewController.currentPage = _page;
    _readViewController.currentChapterModel = chapterModel;
    // 保存记录
    [self recordReadChapter:_chapter page:_page bookId:self.dataModel.bookId];
}

#pragma mark -  更改进度

- (void)updateProgress:(NSNotification *)sender {
    // 添加滑动进度条
    self.slider.maximumValue = self.dataModel.chapterListArr.count - 1;
    self.slider.value = _chapter;
    [self.view addSubview:self.slider];
}

#pragma mark -  改变字体大小

- (void)fontSizeChange:(NSNotification *)sender {
    
    HHReadChapterModel *chapterModel = self.dataModel.chapterListArr[_chapter];

    CGFloat topSpace = 0;
    CGFloat bottomSpace = 0;
    CGRect rect = self.view.bounds;
    if (@available(iOS 11.0, *)) {
        if (rect.size.height == 618) {
            topSpace = 44;
            bottomSpace = 34;
        }
    } else {
        
    }
    rect.origin.x += 20;
    rect.origin.y += StatusBarHeight + 40 + topSpace;
    rect.size.width -= 40;
    rect.size.height -= StatusBarHeight + 80 + topSpace + bottomSpace;
    
    // 重新计算该章节的页数
    NSArray *arr = [HHReadTool getChapterCountContent:chapterModel.chapterContent rect:rect];
    chapterModel.chapterPageCount = arr.count;
    self.dataModel.chapterListArr[_chapter] = chapterModel;
    
    _readViewController.currentPage = _page;
    _readViewController.currentChapterModel = chapterModel;

}

- (void)nightModel:(NSNotification *)sender {
    HHReadChapterModel *chapterModel = self.dataModel.chapterListArr[_chapter];
    _readViewController.currentPage = _page;
    _readViewController.currentChapterModel = chapterModel;

    // [HHReadConfig shareInstance].fontColor = [UIColor whiteColor];
}

#pragma mark - 改变亮度

- (void)changeBright:(NSNotification *)sender {
    NSDictionary *dic = sender.object;
    NSValue *value = dic[@"key"];
    CGRect frame = value.CGRectValue;
    HHReadSetView *setView = [HHReadSetView sharedInstance];
    setView.setType = HHReadSetTypeAutoReadSpeed;
    setView.block = ^(NSDictionary *setValue) {
        NSString *str = setValue[@"key"];
        // 先停止定时器
        [self stopTimer];
        if ([str isEqualToString:AutoPagingTimeFaster]) {
            self->_autoPagingTime -=1;
            if (self->_autoPagingTime == 1) {
                self->_autoPagingTime = 1;
                [HHReadSetView dismiss];
            }
        }else if ([str isEqualToString:AutoPagingTimeSlower]) {
            self->_autoPagingTime +=1;
        }else if ([str isEqualToString:AutoPagingTimeStop]) {
            [HHReadSetView dismiss];
        }else if ([str isEqualToString:AutoPagingTimeStart]) {
            [self addTimer];
            [HHReadSetView dismiss];
        }
    };
    [HHReadSetView show];
    
    setView.showFrame = frame;
}

#pragma mark - 更多-自动翻页

- (void)setMore:(NSNotification *)sender {
    [self stopTimer];
}

- (void)stopTimer {
    if (_autoPagingTimer) {
        [_autoPagingTimer setFireDate:[NSDate distantFuture]];
        [_autoPagingTimer invalidate];
        _autoPagingTimer = nil;
        return;
    }
}

- (void)addTimer {
    [self stopTimer];
    _autoPagingTimer = [NSTimer timerWithTimeInterval:_autoPagingTime target:self selector:@selector(autoPagingTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_autoPagingTimer forMode:NSRunLoopCommonModes];
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:_autoPagingTime] forKey:AutoPagingTime];
}

- (void)autoPagingTimer:(NSTimer *)timer {
    // 如果超过总章节数 则直接返回当前页
    if (self->_chapter > self.dataModel.chapterListArr.count -1) {
        [timer invalidate];
        timer = nil;
        return;
    }else if (self->_chapter == self.dataModel.chapterListArr.count -1) {
        // 最后一章 最后一页时 停止
        HHReadChapterModel *chapterModel = self.dataModel.chapterListArr.lastObject;
        if (self->_page == chapterModel.chapterPageCount - 1) {
            [timer invalidate];
            timer = nil;
            return;
        }
    }
    [self goToNextPage];
}

#pragma mark - 搜索

- (void)searchContent:(NSNotification *)sender {
    
    NSDictionary *dic = sender.object;
    NSNumber *chapterId = dic[@"chapterId"];
    NSNumber *pageNum = dic[@"page"];
    NSString *searchContent = dic[@"searchContent"];
    _chapter = chapterId.integerValue;
    _page = pageNum.integerValue;
    
    HHReadChapterModel *chapterModel = self.dataModel.chapterListArr[_chapter];
    chapterModel.searchContent = searchContent;
    _readViewController.currentPage = _page;
    _readViewController.currentChapterModel = chapterModel;

}

#pragma mark - 返回

- (void)readBack:(NSNotification *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 章节列表

- (void)chapterList:(NSNotification *)sender {
    [self addChapterListView];
}

#pragma mark - HHReadChapterListViewDelegate

- (void)chapterListViewDidSelectedIndex:(NSInteger)index {
    [HHReadChapterListView dismiss];
    if (index > self.dataModel.chapterListArr.count) {
        return;
    }
    _chapter = index;
    _page = 0;
    // 保存阅读记录
    [self recordReadChapter:_chapter page:_page bookId:self.dataModel.bookId];
    // 显示内容
    HHReadChapterModel *chapterModel = self.dataModel.chapterListArr[_chapter];
    _readViewController.currentPage = _page;
    _readViewController.currentChapterModel = chapterModel;

}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    // 保存阅读进度
    [self recordReadChapter:_chapter page:_page bookId:self.dataModel.bookId];
}

#pragma mark - UIPageViewControllerDataSource

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    _readViewController = [[HHReadViewController alloc] init];;
    _readViewController.currentModel = self.dataModel;
    
    if (_page > 0) {
        _page -= 1;
    }else if (_page <= 0) {
        _chapter -= 1;
        if (_chapter < 0) {
            _chapter = 0;
        }
        HHReadChapterModel *previousChapterModel = self.dataModel.chapterListArr[_chapter];
        _page = previousChapterModel.chapterPageCount - 1;
    }
    
    
    if (_chapter < self.dataModel.chapterListArr.count) {
        HHReadChapterModel *chapterModel = self.dataModel.chapterListArr[_chapter];
        _readViewController.currentPage = _page;
        _readViewController.currentChapterModel = chapterModel;

    }
    
    return _readViewController;
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    _readViewController = [[HHReadViewController alloc] init];;
    _readViewController.currentModel = self.dataModel;
    
    // 如果超过总章节数 则直接返回当前页
    if (_chapter > self.dataModel.chapterListArr.count -1) {
        HHReadChapterModel *chapterModel = self.dataModel.chapterListArr[_chapter];
        _readViewController.currentPage = _page;
        _readViewController.currentChapterModel = chapterModel;

        return _readViewController;
    }

    [self goToNextPage];
    return _readViewController;
}

- (void)goToNextPage {
    HHReadChapterModel *chapterModel = self.dataModel.chapterListArr[_chapter];
    _page += 1;
    // 如果超过当前章节的总页数，则进入下一章
    if (_page > chapterModel.chapterPageCount -1) {
        // 最后一章时，最后一页不变
        if (_chapter == self.dataModel.chapterListArr.count -1) {
            _page = chapterModel.chapterPageCount - 1;
        }else {
            _chapter += 1;
            _page = 0;
        }
        if (_chapter < self.dataModel.chapterListArr.count) {
            chapterModel = self.dataModel.chapterListArr[_chapter];
        }
    }
    currentChapterModel = chapterModel;
    
    _readViewController.currentPage = _page;
    _readViewController.currentChapterModel = chapterModel;
    
    // 保存阅读进度
    [self recordReadChapter:_chapter page:_page bookId:self.dataModel.bookId];
}

#pragma mark - 记录阅读章节和页号

- (void)recordReadChapter:(NSInteger)chapter page:(NSInteger)page bookId:(NSString *)bookId {
    [[NSUserDefaults standardUserDefaults] setObject:@(_chapter) forKey:[self recordWithBookId:bookId key:BookMarkChapter]];
    [[NSUserDefaults standardUserDefaults] setObject:@(_page) forKey:[self recordWithBookId:bookId key:BookMarkPage]];
}

- (NSString *)recordWithBookId:(NSString *)bookId key:(NSString *)key {
    NSString *str = [NSString stringWithFormat:@"%@-%@", bookId, key];
    return str;
}

#pragma mark - Setter

- (UIPageViewController *)pageViewController {
    if (!_pageViewController) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        [self.view addSubview:_pageViewController.view];
    }
    return _pageViewController;
}

- (HHReadViewController *)readViewController {
    
    if (!_readViewController) {
        _readViewController = [[HHReadViewController alloc] init];
        _readViewController.currentModel = _dataModel;
        _readViewController.currentPage = _page;
        HHReadChapterModel *chapterModel = (HHReadChapterModel *)_dataModel.chapterListArr[_chapter];
        _readViewController.currentChapterModel = chapterModel;

    }
    return _readViewController;
}

- (UISlider *)slider {
    if (!_slider) {
        _slider = [[UISlider alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(_bottomView.frame) - 44, self.view.bounds.size.width, 44)];
        _slider.minimumValue = 0;
        [_slider setThumbImage:[UIImage imageNamed:@"MoreSetting-SliderUnselectedCircle"] forState:UIControlStateNormal];
        [_slider setThumbImage:[UIImage imageNamed:@"MoreSetting-SliderSelectedCircle"] forState:UIControlStateSelected];
        [_slider setMinimumTrackImage:[UIImage imageNamed:@"MoreSetting-SliderBold"] forState:UIControlStateNormal];
        [_slider setMaximumTrackImage:[UIImage imageNamed:@"MoreSetting-SliderThin"] forState:UIControlStateNormal];
        [_slider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
