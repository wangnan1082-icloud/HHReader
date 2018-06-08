//
//  HHReadTool.m
//  HHReader
//
//  Created by 王楠 on 2018/5/11.
//  Copyright © 2018年 王楠. All rights reserved.
//

#import "HHReadTool.h"
#import <CoreText/CoreText.h>
#import "HHReadConfig.h"

@interface HHReadTool ()

@property (nonatomic, strong) NSMutableArray *pageArray;
@property (nonatomic, assign) NSInteger pageCount;
@end

@implementation HHReadTool

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pageArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark - 拆分章节

+ (void)separateChapter:(NSMutableArray * __autoreleasing *)chapters content:(NSString *)content bookId:(NSString *)bookId {
    [*chapters removeAllObjects];
    NSString *key = [NSString stringWithFormat:@"%@-ToTalChapter", bookId];
    NSString *count = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (count) {
        for (NSInteger i = 0; i < count.integerValue; i++) {
            NSString *chapterId = [NSString stringWithFormat:@"%ld", (long)i];
            BOOL b = [self isExistPathWithBookId:bookId chapterId:chapterId];
            if (b) {
                HHReadChapterModel *model = [self getReadModelBookId:bookId chapterId:chapterId];
                [*chapters addObject:model];
            }
        }
    }else {
        [self subSeparateChapter:chapters content:content bookId:bookId];
    }
    
}

+ (void)subSeparateChapter:(NSMutableArray *__autoreleasing *)chapters content:(NSString *)content bookId:(NSString *)bookId  {
    
    NSString *parten = @"第[0-9零一二三四五六七八九十百千万]*[章回集卷部篇][ ].*";
    NSError *error = NULL;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:parten options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *match = [reg matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, [content length])];
    if (match.count != 0) {
        __block NSRange lastRange = NSMakeRange(0, 0);
        // 保存总章节数
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lu", (unsigned long)match.count] forKey:[NSString stringWithFormat:@"%@-ToTalChapter", bookId]];
        
        [match enumerateObjectsUsingBlock:^(NSTextCheckingResult *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {            
//            NSLog(@"归档 ---  %@/%@", @(idx), @(match.count));
            NSRange range = [obj range];
            NSInteger local = range.location;
            if (idx == 0) {
                HHReadChapterModel *model = [[HHReadChapterModel alloc] init];
                model.chapterTitle = @"开始";
                model.bookId = bookId;
                NSUInteger len = local;
                NSString *temp = [content substringWithRange:NSMakeRange(0, len)];
                NSString *typeSetContent = [self contnetTypeset:temp];
                model.chapterContent = typeSetContent;
                model.chapterId = [NSString stringWithFormat:@"%lu", (unsigned long)idx];
                
                CGRect rect = [UIScreen mainScreen].bounds;
                rect.origin.x += 20;
                rect.origin.y += StatusBarHeight + 40;
                rect.size.width -= 40;
                rect.size.height -= StatusBarHeight + 80;
                NSArray *arr = [self getChapterCountContent:typeSetContent rect:rect];
                model.chapterPageCount = arr.count;
                
                [*chapters addObject:model];
                [HHReadTool saveReadModel:model bookId:model.bookId chapterId:model.chapterId];
            }if (idx > 0) {
                HHReadChapterModel *model = [[HHReadChapterModel alloc] init];
                model.chapterTitle = [content substringWithRange:lastRange];
                model.bookId = bookId;
                NSUInteger len = local-lastRange.location;
                NSString *temp = [content substringWithRange:NSMakeRange(lastRange.location, len)];
                NSString *typeSetContent = [self contnetTypeset:temp];
                model.chapterContent = typeSetContent;
                model.chapterId = [NSString stringWithFormat:@"%lu", (unsigned long)idx];
                
                CGRect rect = [UIScreen mainScreen].bounds;
                rect.origin.x += 20;
                rect.origin.y += StatusBarHeight + 40;
                rect.size.width -= 40;
                rect.size.height -= StatusBarHeight + 80;
                NSArray *arr = [self getChapterCountContent:typeSetContent rect:rect];
                model.chapterPageCount = arr.count;
                
                [*chapters addObject:model];
                [HHReadTool saveReadModel:model bookId:model.bookId chapterId:model.chapterId];
                
            }if (idx == match.count-1) {
                HHReadChapterModel *model = [[HHReadChapterModel alloc] init];
                model.chapterTitle = [content substringWithRange:range];
                model.bookId = bookId;
                NSString *temp = [content substringWithRange:NSMakeRange(local, content.length-local)];
                NSString *typeSetContent = [self contnetTypeset:temp];
                model.chapterContent = typeSetContent;
                model.chapterId = [NSString stringWithFormat:@"%lu", (unsigned long)idx];
                
                CGRect rect = [UIScreen mainScreen].bounds;
                rect.origin.x += 20;
                rect.origin.y += StatusBarHeight + 40;
                rect.size.width -= 40;
                rect.size.height -= StatusBarHeight + 80;
                NSArray *arr = [self getChapterCountContent:typeSetContent rect:rect];
                model.chapterPageCount = arr.count;
                
                [*chapters addObject:model];
                [HHReadTool saveReadModel:model bookId:model.bookId chapterId:model.chapterId];
            }
            lastRange = range;
        }];
    }
    else{
        HHReadChapterModel *model = [[HHReadChapterModel alloc] init];
        model.chapterContent = content;
        [*chapters addObject:model];
    }
    
}

#pragma mark - 内容编码

+ (NSString *)encodeWithURL:(NSURL *)url {
    if (!url) {
        return @"";
    }
    NSString *content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    if (!content) {
        //  GB 18030
        content = [NSString stringWithContentsOfURL:url encoding:0x80000632 error:nil];
    }
    if (!content) {
        // GBK
        content = [NSString stringWithContentsOfURL:url encoding:0x80000631 error:nil];
    }
    if (!content) {
        return @"";
    }
    return content;
    
}

#pragma mark -

+ (void)saveReadModel:(HHReadChapterModel *)readModel bookId:(NSString *)bookId chapterId:(NSString *)chapterId {
    if (![self isExistPathWithBookId:bookId chapterId:chapterId]) {
        NSString *filePath = [self createPathWithBookId:bookId chapterId:chapterId];
        [NSKeyedArchiver archiveRootObject:readModel toFile:[NSString stringWithFormat:@"%@/%@.archiver", filePath, chapterId]];
    }
}

+ (HHReadChapterModel *)getReadModelBookId:(NSString *)bookId chapterId:(NSString *)chapterId {
    NSString *filePath = [self createPathWithBookId:bookId chapterId:chapterId];
    HHReadChapterModel *data = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSString stringWithFormat:@"%@/%@.archiver", filePath, chapterId]];
    return data;
}

+ (void)removeReadModelBookId:(NSString *)bookId chapterId:(NSString *)chapterId {
    NSString *filePath = [self createPathWithBookId:bookId chapterId:chapterId];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *temp = [NSString stringWithFormat:@"%@/%@.archiver", filePath, chapterId];
    NSError *error;
    [fileManager removeItemAtPath:temp error:&error];
    if (!error) {
        NSLog(@"删除成功--- %@", chapterId);
    }
}

+ (BOOL)isExistPathWithBookId:(NSString *)bookId {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *temp = [NSString stringWithFormat:@"HHReader/%@.archiver", bookId];
    NSString *filePath = [docPath stringByAppendingPathComponent:temp];
    BOOL b = [fileManager fileExistsAtPath:filePath];
    return b;
}

+ (BOOL)isExistPathWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *temp = [NSString stringWithFormat:@"HHReader/%@/%@.archiver", bookId, chapterId];
    NSString *filePath = [docPath stringByAppendingPathComponent:temp];
    BOOL b = [fileManager fileExistsAtPath:filePath];
    return b;
}

+ (NSString *)createPathWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *temp = [NSString stringWithFormat:@"HHReader/%@", bookId];
    NSString *filePath = [docPath stringByAppendingPathComponent:temp];
    
    if (![fileManager fileExistsAtPath:filePath]) {
        // 创建路径
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //    NSLog(@"filePath %@", filePath);
    return filePath;
}

#pragma mark - 内容排版

+ (NSString *)contnetTypeset:(NSString *)contnet {
    NSString *result;
    result = [contnet stringByReplacingOccurrencesOfString:@"\r" withString:@""];

//    NSRegularExpression *express = [NSRegularExpression regularExpressionWithPattern:@"\\s*\\n+\\s*" options:NSRegularExpressionCaseInsensitive error:nil];
//    result = [express stringByReplacingMatchesInString:result options:NSMatchingAnchored range:NSMakeRange(0, result.length) withTemplate:@"\n"];
    return result;
}

#pragma mark - 获取某一章的页数

+ (NSArray *)getChapterCountContent:(NSString *)content rect:(CGRect)rect {
    NSMutableArray *countArray = [NSMutableArray arrayWithCapacity:10];
    
    NSAttributedString *attrString;
    CTFramesetterRef frameSetter;
    CGPathRef path;
    NSMutableAttributedString *attrStr;
    attrStr = [[NSMutableAttributedString  alloc] initWithString:content];

    NSMutableDictionary *attribute = [NSMutableDictionary dictionary];
    attribute[NSForegroundColorAttributeName] = [HHReadConfig shareInstance].fontColor;
    CGFloat fontSize = [HHReadConfig shareInstance].fontSize;
    attribute[NSFontAttributeName] = [UIFont systemFontOfSize:fontSize];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    attribute[NSParagraphStyleAttributeName] = paragraphStyle;
    
    [attrStr setAttributes:attribute range:NSMakeRange(0, attrStr.length)];
    attrString = [attrStr copy];
    frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attrString);
    path = CGPathCreateWithRect(rect, NULL);
    int currentOffset = 0;
    int currentInnerOffset = 0;
    BOOL hasMorePages = YES;
    
    // 防止死循环，如果在同一个位置获取CTFrame超过2次，则跳出循环
    int preventDeadLoopSign = currentOffset;
    int samePlaceRepeatCount = 0;
    
    while (hasMorePages) {
        if (preventDeadLoopSign == currentOffset) {
            ++samePlaceRepeatCount;
        }else {
            samePlaceRepeatCount = 0;
        }
        
        if (samePlaceRepeatCount > 1) {
            // 退出循环前检查一下最后一页是否已经加上
            if (countArray.count == 0) {
                [countArray addObject:@(currentOffset)];
            }else {
                NSUInteger lastOffset = [[countArray lastObject] integerValue];
                if (lastOffset != currentOffset) {
                    [countArray addObject:@(currentOffset)];
                }
            }
            break;
        }
        
        [countArray addObject:@(currentOffset)];
        
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(currentInnerOffset, 0), path, NULL);
        CFRange range = CTFrameGetVisibleStringRange(frame);
        if ((range.location + range.length) != attrString.length) {
            currentOffset += range.length;
            currentInnerOffset += range.length;
        } else {
            // 已经分完，提示跳出循环
            hasMorePages = NO;
        }
        if (frame) CFRelease(frame);
    }
    
    CGPathRelease(path);
    CFRelease(frameSetter);
    return countArray.copy;
}

+ (NSString *)stringOfPage:(NSUInteger)index content:(NSString *)content chapterPageArray:(NSArray *)chapterPageArray {
    if (index >= chapterPageArray.count) {
        return [NSString stringWithFormat:@"超页啦  %lu 页  实际一共只有%lu 页", (unsigned long)index, (unsigned long)chapterPageArray.count];
    }
    NSUInteger local = [chapterPageArray[index] integerValue];
    NSUInteger length;
    if (index < chapterPageArray.count - 1) {
        length = [chapterPageArray[index+1] integerValue] - [chapterPageArray[index] integerValue];
    }else{
        length = content.length - [chapterPageArray[index] integerValue];
    }
    return [content substringWithRange:NSMakeRange(local, length)];
}

+ (UIButton *)createButtonWithTarget:(nullable id)target selecter:(SEL)sel image:(UIImage *)image selectedImage:(UIImage *)selectedImage {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:selectedImage forState:UIControlStateSelected];
    [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
@end
