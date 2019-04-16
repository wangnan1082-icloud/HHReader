//
//  HHReadSetView.m
//  HHReader
//
//  Created by 王楠 on 2018/6/7.
//  Copyright © 2018年 王楠. All rights reserved.
//

#import "HHReadSetView.h"

#define ThemeColor(color) [UIColor colorWithPatternImage:[UIImage imageNamed:color]]
CGFloat const contentViewWidth = 180;
CGFloat const triangleWidth = 15;

@interface HHReadSetCollectionViewCell: UICollectionViewCell
@property (nonatomic, strong) UILabel *textLabel; /**< textLabel*/
@property (nonatomic, strong) UIImageView *colorImgView; /**< colorImgView*/

@end

@implementation HHReadSetCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.colorImgView = [[UIImageView alloc] init];
        self.colorImgView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self.contentView addSubview:self.colorImgView];

        self.textLabel = [UILabel new];
        self.textLabel.font = [UIFont systemFontOfSize:15];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.textLabel.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.textLabel];

    }
    return self;
}

@end

@interface HHReadSetView ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    UIWindow *_window;
    UIView *_contentView;
    UIImageView *_triangleImgView;
}
@property (nonatomic, copy) NSArray *setDataArray; /**< 数据数组*/
@property (nonatomic, strong) UICollectionView *collectionView; /**< collectionView*/

@end

@implementation HHReadSetView

#pragma mark - Class Methods

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static HHReadSetView *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HHReadSetView alloc] init];
    });
    return sharedInstance;
}

+ (void)show {
    [[self sharedInstance] setViewShow];
}

+ (void)dismiss {
    [[self sharedInstance] setViewDismiss];
}

#pragma mark - Initialization Methods

- (instancetype)init {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    self.backgroundColor = [UIColor clearColor];
    _window = [[UIApplication sharedApplication] keyWindow];
    _window.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    return self;
}

- (void)setViewShow {
    if (self.collectionView) {
        [self.collectionView removeFromSuperview];
        self.collectionView = nil;
    }
    CGFloat contentViewHeight = contentViewWidth;
    CGFloat itemHight = 0;
    if (self.setType == HHReadSetTypeAutoReadSpeed) {
        contentViewHeight = contentViewWidth/self.setDataArray.count;
        itemHight = contentViewHeight;
    }else if (self.setType == HHReadSetTypeThemeColor) {
        contentViewHeight = contentViewWidth;
        itemHight = contentViewHeight/3;
    }
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - contentViewHeight - 30 - 44, contentViewWidth, contentViewHeight)];
    _contentView.backgroundColor = [UIColor blackColor];
    [self addSubview:_contentView];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(itemHight, itemHight)];
    flowLayout.sectionInset = UIEdgeInsetsMake(0,0,0,0);
    flowLayout.minimumLineSpacing = 0.0;//行间距(最小值)
    flowLayout.minimumInteritemSpacing = 0.0;//item间距(最小值)
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);//设置section的边距
    flowLayout.headerReferenceSize = CGSizeZero;
    flowLayout.footerReferenceSize = CGSizeZero;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, contentViewWidth, contentViewHeight) collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[HHReadSetCollectionViewCell class] forCellWithReuseIdentifier:@"HHReadSetCollectionViewCellID"];

    [_contentView addSubview:self.collectionView];
    
    _triangleImgView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_contentView.frame) - triangleWidth, CGRectGetMaxY(_contentView.frame), triangleWidth, triangleWidth)];
    _triangleImgView.image = [UIImage imageNamed:@"Bottom-TriangleLeft"];
    [self addSubview:_triangleImgView];
    
    if (self.superview == nil) {
        [_window addSubview:self];
    }else {
        [self.superview addSubview:self];
    }
    [self.collectionView reloadData];
}

- (void)setViewDismiss {
    [self.collectionView removeFromSuperview];
    self.collectionView = nil;
    [_contentView removeFromSuperview];
    [_triangleImgView removeFromSuperview];
    [self removeFromSuperview];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.setDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HHReadSetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HHReadSetCollectionViewCellID" forIndexPath:indexPath];
    if (self.setDataArray.count > 0) {
        if (self.setType == HHReadSetTypeAutoReadSpeed) {
            NSString *textStr = self.setDataArray[indexPath.item];
            cell.textLabel.text = textStr;
            cell.textLabel.hidden = NO;
            cell.colorImgView.hidden = YES;
            return cell;
        }else if (self.setType == HHReadSetTypeThemeColor) {
            UIColor *color = self.setDataArray[indexPath.item];
            cell.colorImgView.backgroundColor = color;
            cell.textLabel.hidden = YES;
            cell.colorImgView.hidden = NO;
            return cell;
        }
    }

    return [[HHReadSetCollectionViewCell alloc] init];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.setType == HHReadSetTypeAutoReadSpeed) {
        NSString *str = self.setDataArray[indexPath.item];
        NSDictionary *dic = @{@"key": str};
        self.block(dic);
    }else if (self.setType == HHReadSetTypeThemeColor) {
        UIColor *color = self.setDataArray[indexPath.item];
        NSDictionary *dic = @{@"key": color};
        self.block(dic);
    }
}

#pragma mark - Setter

- (void)setSetType:(HHReadSetType)setType {
    if (setType == HHReadSetTypeAutoReadSpeed) {
        self.setDataArray = @[AutoPagingTimeFaster, AutoPagingTimeSlower, AutoPagingTimeStop, AutoPagingTimeStart];
    }else if (setType == HHReadSetTypeThemeColor) {
        self.setDataArray = @[[UIColor whiteColor], RGBColor(248, 200, 200, 1), RGBColor(201, 248, 248, 1), RGBColor(248, 248, 201, 1), RGBColor(152, 200, 248, 1), RGBColor(254, 205, 254, 1), RGBColor(152, 124, 88, 1), RGBColor(103, 132, 101, 1), RandomColor];
        /*
         @[ThemeColor(@"Theme-1"), ThemeColor(@"Theme-2"), ThemeColor(@"Theme-3"), ThemeColor(@"Theme-4"), ThemeColor(@"Theme-5"), ThemeColor(@"Theme-6"), ThemeColor(@"Theme-7"), ThemeColor(@"Theme-8"), RandomColor];
         */
    }
    _setType = setType;
}

- (void)setShowFrame:(CGRect)showFrame {
    _showFrame = showFrame;
    CGRect frame = _contentView.frame;
    frame.origin.x = showFrame.origin.x + showFrame.size.width/2 - contentViewWidth;
    _contentView.frame = frame;
    
    CGRect triFrame = _triangleImgView.frame;
    triFrame.origin.x = CGRectGetMaxX(_contentView.frame) - triangleWidth;
    _triangleImgView.frame = triFrame;
}

@end
