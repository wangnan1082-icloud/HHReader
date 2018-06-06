//
//  HHReadChapterModel.m
//  HHReader
//
//  Created by 王楠 on 2018/5/10.
//  Copyright © 2018年 王楠. All rights reserved.
//

#import "HHReadChapterModel.h"

@implementation HHReadChapterModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.bookId = [aDecoder decodeObjectForKey:@"bookId"];
        self.bookName = [aDecoder decodeObjectForKey:@"bookName"];
        self.chapterId = [aDecoder decodeObjectForKey:@"chapterId"];
        self.chapterTitle = [aDecoder decodeObjectForKey:@"chapterTitle"];
        self.chapterContent = [aDecoder decodeObjectForKey:@"chapterContent"];
        self.chapterPageCount = [aDecoder decodeIntegerForKey:@"chapterPageCount"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.bookId forKey:@"bookId"];
    [aCoder encodeObject:self.bookName forKey:@"bookName"];
    [aCoder encodeObject:self.chapterId forKey:@"chapterId"];
    [aCoder encodeObject:self.chapterTitle forKey:@"chapterTitle"];
    [aCoder encodeObject:self.chapterContent forKey:@"chapterContent"];
    [aCoder encodeInteger:self.chapterPageCount forKey:@"chapterPageCount"];
}

@end
