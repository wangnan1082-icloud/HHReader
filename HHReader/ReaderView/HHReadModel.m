//
//  HHReadModel.m
//  HHReader
//
//  Created by 王楠 on 2018/5/11.
//  Copyright © 2018年 王楠. All rights reserved.
//

#import "HHReadModel.h"
#import "HHReadTool.h"

@implementation HHReadModel

#pragma mark -

- (instancetype)initWithContent:(NSString *)content bookId:(NSString *)bookId{
    self = [super init];
    if (self) {
        _content = content;
        NSMutableArray *charpter = [NSMutableArray array];
        [HHReadTool separateChapter:&charpter content:content bookId:bookId];
        _chapterListArr = charpter;
        
    }
    return self;
}

#pragma mark -

- (instancetype)getLocalModelWithURL:(NSURL *)url {
    if (url.path.length == 0) {
        NSAssert(url.path.length == 0, @"文件路径不存在");
    }
    
    NSString *key = [url.path lastPathComponent];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!data) {
        if ([[key pathExtension] isEqualToString:@"txt"]) {
            NSString *temp = [url.path componentsSeparatedByString:@"/"].lastObject;
            NSString *bookId = temp.stringByDeletingPathExtension;
            
            HHReadModel *model;
            BOOL b = [self isExistPathWithBookId:bookId];
            if (b) {
                model = [self getReadModelBookId:bookId];
            }else {
                model = [[HHReadModel alloc] initWithContent:[HHReadTool encodeWithURL:url] bookId:bookId];
                NSLog(@"url: %@  bookId: %@", url.path, bookId);
                model.resource = url;
                model.bookId = bookId;
                [self saveReadModel:model bookId:bookId];
            }
            return model;
        }else if ([[key pathExtension] isEqualToString:@"epub"]){
            NSLog(@"this is epub");
        } else{
            @throw [NSException exceptionWithName:@"FileException" reason:@"文件格式错误" userInfo:nil];
        }
        
    }
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    // 主线程操作
    HHReadModel *model = [unarchive decodeObjectForKey:key];
    return model;
}

- (void)saveReadModel:(HHReadModel *)model bookId:(NSString *)bookId {
    BOOL b = [self isExistPathWithBookId:bookId];
    if (!b) {
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *temp = [NSString stringWithFormat:@"HHReader/%@/%@.archiver", bookId, bookId];
        NSString *filePath = [docPath stringByAppendingPathComponent:temp];
        [NSKeyedArchiver archiveRootObject:model toFile:filePath];
    }
}

- (HHReadModel *)getReadModelBookId:(NSString *)bookId {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *temp = [NSString stringWithFormat:@"HHReader/%@/%@.archiver", bookId, bookId];
    NSString *filePath = [docPath stringByAppendingPathComponent:temp];
    HHReadModel *model = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    return model;
}


- (BOOL)isExistPathWithBookId:(NSString *)bookId {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *temp = [NSString stringWithFormat:@"HHReader/%@/%@.archiver", bookId, bookId];
    NSString *filePath = [docPath stringByAppendingPathComponent:temp];
    BOOL b = [fileManager fileExistsAtPath:filePath];
    return b;
}

#pragma mark -

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.bookId = [aDecoder decodeObjectForKey:@"bookId"];
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.resource = [aDecoder decodeObjectForKey:@"resource"];
        self.chapterListArr = [aDecoder decodeObjectForKey:@"chapterListArr"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.bookId forKey:@"bookId"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.resource forKey:@"resource"];
    [aCoder encodeObject:self.chapterListArr forKey:@"chapterListArr"];
}

@end
