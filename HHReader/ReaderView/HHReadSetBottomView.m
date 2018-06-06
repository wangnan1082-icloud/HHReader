//
//  HHReadSetBottomView.m
//  HHReader
//
//  Created by 王楠 on 2018/5/22.
//  Copyright © 2018年 王楠. All rights reserved.
//  设置的底部View

#import "HHReadSetBottomView.h"
#import "HHReadTool.h"
#import "HHReadConfig.h"

@interface HHReadSetBottomView()

@property (nonatomic, strong) UIImageView *bgImageView; /**< 背景*/
@property (nonatomic, strong) UIButton *updateProgress; /**< 更改进度*/
@property (nonatomic, strong) UIButton *fontSize; /**< 字体大小*/
@property (nonatomic, strong) UIButton *neightModel; /**< 夜间模式*/
@property (nonatomic, strong) UIButton *brightChange; /**< 亮度调整*/
@property (nonatomic, strong) UIButton *themeColor; /**< 主题颜色*/
@property (nonatomic, strong) UIButton *setMore; /**< 设置更多*/

@end

@implementation HHReadSetBottomView

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
    [self addSubview:self.bgImageView];

    [self addSubview:self.updateProgress];
    [self addSubview:self.fontSize];
    [self addSubview:self.neightModel];
    [self addSubview:self.brightChange];
    [self addSubview:self.themeColor];
    [self addSubview:self.setMore];
}

#pragma mark -

- (void)layoutSubviews {
    [super layoutSubviews];
    _bgImageView.frame = self.frame;

    CGFloat width = self.frame.size.width/6;
    CGFloat height = self.frame.size.height;
    CGFloat space = 2;
    CGFloat btnHeight = height - space;
    _updateProgress.frame = CGRectMake(0, space/2, width, btnHeight);
    _fontSize.frame = CGRectMake(CGRectGetMaxX(_updateProgress.frame), space/2, width, btnHeight);
    _neightModel.frame = CGRectMake(CGRectGetMaxX(_fontSize.frame), space/2, width, btnHeight);
    _brightChange.frame = CGRectMake(CGRectGetMaxX(_neightModel.frame), space/2, width, btnHeight);
    _themeColor.frame = CGRectMake(CGRectGetMaxX(_brightChange.frame), space/2, width, btnHeight);
    _setMore.frame = CGRectMake(CGRectGetMaxX(_themeColor.frame), space/2, width, height);
}

#pragma mark - Getter

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView  = [[UIImageView alloc] init];
        _bgImageView.image = [UIImage imageNamed:@"Bottom-BackColor"];;
    }
    return _bgImageView;
}

- (UIButton *)updateProgress {
    if (!_updateProgress) {
        _updateProgress = [HHReadTool createButtonWithTarget:self selecter:@selector(updateProgressButtonClick:) image:[UIImage imageNamed:@"Bottom-Skip"] selectedImage:[UIImage imageNamed:@"Bottom-Skip"]];
    }
    return _updateProgress;
}

- (UIButton *)fontSize {
    if (!_fontSize) {
        _fontSize = [HHReadTool createButtonWithTarget:self selecter:@selector(fontSizeButtonClick:) image:[UIImage imageNamed:@"Bottom-Font"] selectedImage:[UIImage imageNamed:@"Bottom-Font"]];
    }
    return _fontSize;
}

- (UIButton *)neightModel {
    if (!_neightModel) {
        _neightModel = [HHReadTool createButtonWithTarget:self selecter:@selector(neightModelButtonClick:) image:[UIImage imageNamed:@"Bottom-Sun1"] selectedImage:[UIImage imageNamed:@"Bottom-Night1"]];
    }
    return _neightModel;
}

- (UIButton *)brightChange {
    if (!_brightChange) {
        _brightChange = [HHReadTool createButtonWithTarget:self selecter:@selector(brightChangeButtonClick:) image:[UIImage imageNamed:@"Bottom-Light"] selectedImage:[UIImage imageNamed:@"Bottom-Light"]];
    }
    return _brightChange;
}

- (UIButton *)themeColor {
    if (!_themeColor) {
        _themeColor = [HHReadTool createButtonWithTarget:self selecter:@selector(themeColorButtonClick:) image:[UIImage imageNamed:@"Bottom-Skin"] selectedImage:[UIImage imageNamed:@"Bottom-Skin"]];
    }
    return _themeColor;
}

- (UIButton *)setMore {
    if (!_setMore) {
        _setMore = [HHReadTool createButtonWithTarget:self selecter:@selector(setMoreButtonClick:) image:[UIImage imageNamed:@"Bottom-More"] selectedImage:[UIImage imageNamed:@"Bottom-More"]];
    }
    return _setMore;
}

#pragma mark - Button Click

- (void)updateProgressButtonClick:(UIButton *)sender {
    //  阅读进度更新
    [[NSNotificationCenter defaultCenter] postNotificationName:UpdateProgressNotification object:nil];

}

- (void)fontSizeButtonClick:(UIButton *)sender {
    //  字体大小调整
    CGFloat fontSize = [HHReadConfig shareInstance].fontSize;
    if (fontSize < 25 && fontSize > 5) {
        [HHReadConfig shareInstance].fontSize++;
    }else if (fontSize >=25) {
        [HHReadConfig shareInstance].fontSize -= 10;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ChangeFontSizeNotification object:nil];
}

- (void)neightModelButtonClick:(UIButton *)sender {
    if (!sender.selected) {
        //  变成夜间模式
        [HHReadConfig shareInstance].fontColor = NightFontColor;
        UIColor *temp = [HHReadConfig shareInstance].themeColor;
        [HHReadConfig shareInstance].lastChangeThemeColor = temp;
        [HHReadConfig shareInstance].themeColor = [UIColor blackColor];
    }else {
        //  变成上次的状态
        [HHReadConfig shareInstance].fontColor = [UIColor blackColor];
        UIColor *temp = [HHReadConfig shareInstance].lastChangeThemeColor;
        [HHReadConfig shareInstance].themeColor = temp;
    }
    
    sender.selected = !sender.selected;
    [[NSNotificationCenter defaultCenter] postNotificationName:NightModelNotification object:nil];
}

- (void)brightChangeButtonClick:(UIButton *)sender {
    //  亮度调整
}

- (void)themeColorButtonClick:(UIButton *)sender {
    //  主题颜色
    [[NSNotificationCenter defaultCenter] postNotificationName:ChangeThemeColorNotification object:RandomColor];
}

- (void)setMoreButtonClick:(UIButton *)sender {
    //  更多设置
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
