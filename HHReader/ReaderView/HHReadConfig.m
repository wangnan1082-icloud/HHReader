//
//  HHReadConfig.m
//  HHReader
//
//  Created by 王楠 on 2018/5/24.
//  Copyright © 2018年 王楠. All rights reserved.
//

#import "HHReadConfig.h"

@implementation HHReadConfig

+ (instancetype)shareInstance {
    static HHReadConfig *readConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        readConfig = [[self alloc] init];
    });
    return readConfig;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"ReadConfig"];
        if (data) {
            NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
            HHReadConfig *config = [unarchive decodeObjectForKey:@"ReadConfig"];
            [config addObserver:config forKeyPath:@"fontSize" options:NSKeyValueObservingOptionNew context:NULL];
            [config addObserver:config forKeyPath:@"lineSpace" options:NSKeyValueObservingOptionNew context:NULL];
            [config addObserver:config forKeyPath:@"fontColor" options:NSKeyValueObservingOptionNew context:NULL];
            [config addObserver:config forKeyPath:@"themeColor" options:NSKeyValueObservingOptionNew context:NULL];
            return config;
        }
        _lineSpace = 10.0f;
        _fontSize = 14.0f;
        _fontColor = [UIColor blackColor];
        _themeColor = [UIColor whiteColor];
        [self addObserver:self forKeyPath:@"fontSize" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"lineSpace" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"fontColor" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"themeColor" options:NSKeyValueObservingOptionNew context:NULL];
        
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    NSMutableData *data=[[NSMutableData alloc]init];
    NSKeyedArchiver *archiver=[[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:self forKey:@"ReadConfig"];
    [archiver finishEncoding];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"ReadConfig"];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:self.fontSize forKey:@"fontSize"];
    [aCoder encodeDouble:self.lineSpace forKey:@"lineSpace"];
    [aCoder encodeObject:self.fontColor forKey:@"fontColor"];
    [aCoder encodeObject:self.themeColor forKey:@"themeColor"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.fontSize = [coder decodeDoubleForKey:@"fontSize"];
        self.lineSpace = [coder decodeDoubleForKey:@"lineSpace"];
        self.fontColor = [coder decodeObjectForKey:@"fontColor"];
        self.themeColor = [coder decodeObjectForKey:@"themeColor"];
    }
    return self;
}

@end
