//
//  HHReadChapterModel.h
//  HHReader
//
//  Created by 王楠 on 2018/5/10.
//  Copyright © 2018年 王楠. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HHReadChapterModel : NSObject <NSCoding>

@property (nonatomic, copy) NSString *bookId; /**< 小说Id*/
@property (nonatomic, copy) NSString *bookName; /**< 小说名*/
@property (nonatomic, copy) NSString *chapterId; /**< 章节Id*/
@property (nonatomic, copy) NSString *chapterTitle; /**< 章节标题*/
@property (nonatomic, copy) NSString *chapterContent; /**< 章节内容*/
@property (nonatomic, assign) NSUInteger chapterPageCount; /**< 章节页数*/
@property (nonatomic, assign) NSUInteger searchChapterPage; /**< 搜索到的章节页*/
@property (nonatomic, copy) NSString *searchContent; /**< 搜索的内容*/

@end
