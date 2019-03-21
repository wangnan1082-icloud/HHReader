//
//  HHReadChapterListView.m
//  HHReader
//
//  Created by 王楠 on 2018/5/17.
//  Copyright © 2018年 王楠. All rights reserved.
//

#import "HHReadChapterListView.h"
#import "HHReadChapterModel.h"
#import "NSString+Range.h"

@interface HHReadChapterListView ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
    UIWindow *_window;
    UIView *_contentView;
    UIView *_tapView;

}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UISearchBar *searchBar;   /**< 搜索框*/
@end

NSString *const HHReadChapterListViewCellID = @"HHReadChapterListViewCellId";
CGFloat const percentNum = 0.67;

@implementation HHReadChapterListView

#pragma mark - Class Methods

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static HHReadChapterListView *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HHReadChapterListView alloc] init];
    });
    return sharedInstance;
}

+ (void)show {
    [[self sharedInstance] tableViewShow];
}

+ (void)dismiss {
    [[self sharedInstance] tableViewHide];
}

#pragma mark - Initialization Methods

- (instancetype)init {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    self.backgroundColor = [UIColor clearColor];
    _window = [[UIApplication sharedApplication] keyWindow];
    _window.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    self.dataArray = [NSMutableArray arrayWithCapacity:10];
    //    self.alpha = 0;
    
    return self;
}

- (void)tableViewShow {
    if (self.tableView) {
        return;
    }
    
    CGFloat topSpace = 44;
    CGFloat bottomSpace = 44;
    if (@available(iOS 11.0, *)) {
        CGFloat topPadding = _window.safeAreaInsets.top;
        CGFloat bottomPadding = _window.safeAreaInsets.bottom;
        topSpace = topPadding;
        bottomSpace = bottomPadding;
    }
    
    CGFloat tableViewHeight = self.frame.size.height - topSpace - bottomSpace;
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, topSpace, self.frame.size.width*percentNum, tableViewHeight)];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_contentView];
    // 添加搜索框
    [_contentView addSubview:self.searchBar];
    self.searchBar.delegate = self;
    
    _tapView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_contentView.frame), topSpace, self.frame.size.width/3, tableViewHeight)];
    _tapView.backgroundColor = [UIColor clearColor];
    [self addSubview:_tapView];;
    // 添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [_tapView addGestureRecognizer:tap];
    // 章节列表
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topSpace, _contentView.frame.size.width, _contentView.frame.size.height - topSpace) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:HHReadChapterListViewCellID];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [_contentView addSubview:self.tableView];
    
    if (self.superview == nil) {
        [_window addSubview:self];
    }else {
        [self.superview addSubview:self];
    }
    [self.tableView reloadData];
}

- (void)tableViewHide {
    [self.tableView removeFromSuperview];
    self.tableView = nil;
    [_searchBar removeFromSuperview];
    [_tapView removeFromSuperview];
    [_contentView removeFromSuperview];
    [self removeFromSuperview];
}

#pragma mark - Tap

- (void)tap {
    [self tableViewHide];    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataArray.count > 0) {
        return self.dataArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HHReadChapterListViewCellID forIndexPath:indexPath];
    if (self.dataArray.count > 0) {
        HHReadChapterModel *chapterModel = self.dataArray[indexPath.row];
        cell.textLabel.text = chapterModel.chapterTitle;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.numberOfLines = 2;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(chapterListViewDidSelectedIndex:)]) {
        HHReadChapterModel *model = self.dataArray[indexPath.row];
        [self.delegate chapterListViewDidSelectedIndex:model.chapterId.integerValue];
    }else {
        if (self.block) {
            HHReadChapterModel *model = self.dataArray[indexPath.row];
            self.block(model.chapterId.integerValue, model.searchChapterPage, model.searchContent);
        }
    }
    [self tableViewHide];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar endEditing:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    NSString *searchStr = searchBar.text;
    
    NSMutableArray *muArr = [NSMutableArray arrayWithCapacity:10];
    
    for (NSInteger i = 0; i < self.dataArray.count; i++) {
        HHReadChapterModel *chapterModel = self.dataArray[i];
        NSArray *arr = [chapterModel.chapterContent rangesOfString:searchStr options:NSCaseInsensitiveSearch serachRange:NSMakeRange(0, chapterModel.chapterContent.length)];
        if (arr.count > 0) {
            NSValue *value = arr.firstObject;
            NSRange range = value.rangeValue;
            NSUInteger temp = chapterModel.chapterContent.length/chapterModel.chapterPageCount;
            // 暂时先这么算 可能不大准 后面再调整
            NSUInteger page = (int)range.location/temp;
            chapterModel.searchChapterPage = page;
            chapterModel.searchContent = searchBar.text;
            [muArr addObject:chapterModel];
            NSLog(@"page: %@/%@", @(page), @(chapterModel.chapterPageCount));
        }
        
        if (i == (self.dataArray.count - 1) && muArr.count > 0) {
            [self.dataArray removeAllObjects];
            self.searchChapterModelArray = nil;
            
//            self.dataArray = muArr.mutableCopy;
            self.searchChapterModelArray = muArr.copy;;
//            [self.tableView reloadData];
        }
    }

}

#pragma mark - Setter

- (void)setCurrentChapter:(NSInteger)currentChapter {
    
    _currentChapter = currentChapter;
    if (currentChapter < self.dataArray.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(currentChapter) inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (void)setReadModel:(HHReadModel *)readModel {
    if (readModel.chapterListArr.count > 0) {
        if (self.dataArray.count > 0) {
            [self.dataArray removeAllObjects];
        }
        for (HHReadChapterModel *model in readModel.chapterListArr) {
            [self.dataArray addObject:model];
        }
        [self.tableView reloadData];
    }
    
}

- (void)setSearchChapterModelArray:(NSArray<HHReadChapterModel *> *)searchChapterModelArray {
    if (searchChapterModelArray.count > 0) {
        if (self.dataArray.count > 0) {
            [self.dataArray removeAllObjects];
        }
        for (HHReadChapterModel *model in searchChapterModelArray) {
            [self.dataArray addObject:model];
        }
        [self.tableView reloadData];
    }
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.placeholder = @"搜索";
        _searchBar.keyboardType = UIReturnKeySearch;
        _searchBar.frame = CGRectMake(0, 0, self.frame.size.width*percentNum, 44);
        _searchBar.barTintColor = RGBColor(238, 238, 238, 1);
        _searchBar.backgroundImage = [[UIImage alloc] init];
    }
    return _searchBar;
}

@end
