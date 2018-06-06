//
//  NSString+Range.m
//  HHReader
//
//  Created by 王楠 on 2018/6/4.
//  Copyright © 2018年 王楠. All rights reserved.
//

#import "NSString+Range.h"

@implementation NSString (Range)

- (NSArray <NSValue *> *)rangesOfString:(NSString *)searchString options:(NSStringCompareOptions)mask serachRange:(NSRange)range {
    
    NSMutableArray *array = [NSMutableArray array];
    [self rangeOfString:searchString range:NSMakeRange(0, self.length) array:array options:mask];
    
    return array;
}

- (void)rangeOfString:(NSString *)searchString
                range:(NSRange)searchRange
                array:(NSMutableArray *)array
              options:(NSStringCompareOptions)mask {
    if (!searchString) {
        return;
    }
    NSRange range = [self rangeOfString:searchString options:mask range:searchRange];
    
    if (range.location != NSNotFound) {
        
        [array addObject:[NSValue valueWithRange:range]];
        [self rangeOfString:searchString
                      range:NSMakeRange(range.location + range.length, self.length - (range.location + range.length))
                      array:array
                    options:mask];
    }
}

@end
