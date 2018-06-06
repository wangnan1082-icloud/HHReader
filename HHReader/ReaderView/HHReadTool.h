//
//  HHReadTool.h
//  HHReader
//
//  Created by 王楠 on 2018/5/11.
//  Copyright © 2018年 王楠. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HHReadModel.h"
#import "HHReadChapterModel.h"

@interface HHReadTool : NSObject


/**
 章节正则拆分

 @param chapters 拆分后的章节列表
 @param content 小说内容
 @param bookId 书Id
 */
+ (void)separateChapter:(NSMutableArray **)chapters content:(NSString *)content bookId:(NSString *)bookId;

/**
 内容编码

 @param url 文件路径
 @return 编码后的内容
 */
+ (NSString *)encodeWithURL:(NSURL *)url;

+ (void)saveReadModel:(HHReadChapterModel *)readModel bookId:(NSString *)bookId chapterId:(NSString *)chapterId;

+ (HHReadChapterModel *)getReadModelBookId:(NSString *)bookId chapterId:(NSString *)chapterId;

+ (void)removeReadModelBookId:(NSString *)bookId chapterId:(NSString *)chapterId;

/**
 根据内容拆分成章的各个页

 @param content 章的内容
 @param rect 显示区域
 @return 章节页的内容数组
 */
+ (NSArray *)getChapterCountContent:(NSString *)content rect:(CGRect)rect;

/**
 获取章的某一页的内容

 @param index 页号
 @param content 章的内容
 @param chapterPageArray 章节页数组
 @return 页的内容
 */
+ (NSString *)stringOfPage:(NSUInteger)index content:(NSString *)content chapterPageArray:(NSArray *)chapterPageArray;

+ (UIButton *)createButtonWithTarget:(nullable id)target selecter:(SEL)sel image:(UIImage *)image selectedImage:(UIImage *)selectedImage;
@end
