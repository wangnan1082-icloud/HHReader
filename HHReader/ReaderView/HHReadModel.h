//
//  HHReadModel.h
//  HHReader
//
//  Created by 王楠 on 2018/5/11.
//  Copyright © 2018年 王楠. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HHReadChapterModel.h"

@interface HHReadModel : NSObject

@property (nonatomic, strong) NSURL *resource;  /**< 资源路径*/
@property (nonatomic, copy) NSString *bookId;   /**< 书名*/
@property (nonatomic, copy) NSString *content;  /**< 书的内容字符串*/
@property (nonatomic, strong) NSMutableArray<HHReadChapterModel *> *chapterListArr; /**< 章节列表*/

- (instancetype)initWithContent:(NSString *)content bookId:(NSString *)bookId;
- (instancetype)getLocalModelWithURL:(NSURL *)url;
@end
