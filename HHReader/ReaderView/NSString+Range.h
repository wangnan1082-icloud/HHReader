//
//  NSString+Range.h
//  HHReader
//
//  Created by 王楠 on 2018/6/4.
//  Copyright © 2018年 王楠. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Range)
/**
 *  Finds and returns the ranges of a given string, within the given range of the receiver.
 *
 *  @param searchString searchString.
 *  @param mask         A mask specifying search options. The following options may be specified by combining them with the C bitwise OR operator: NSCaseInsensitiveSearch, NSLiteralSearch, NSBackwardsSearch, NSAnchoredSearch. See String Programming Guide for details on these options.
 *  @param range        serachRange.
 *
 *  @return Ranges.
 */
- (NSArray <NSValue *> *)rangesOfString:(NSString *)searchString options:(NSStringCompareOptions)mask serachRange:(NSRange)range;

@end
