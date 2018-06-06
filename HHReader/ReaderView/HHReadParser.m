//
//  HHReadParser.m
//  HHReader
//
//  Created by 王楠 on 2018/5/14.
//  Copyright © 2018年 王楠. All rights reserved.
//

#import "HHReadParser.h"
#import <UIKit/UIKit.h>
#import "HHReadConfig.h"
#import "NSString+Range.h"

@implementation HHReadParser

+ (CTFrameRef)parserContent:(NSString *)content searchContent:(NSString *)searchContent bouds:(CGRect)bounds {
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
    NSDictionary *attribute = [self parserAttributeWithSearchColor:nil];
    [attributedString setAttributes:attribute range:NSMakeRange(0, content.length)];
    
    NSArray *arr = [content rangesOfString:searchContent options:NSCaseInsensitiveSearch serachRange:NSMakeRange(0, content.length)];
    for (NSValue *value in arr) {
        NSRange range = value.rangeValue;
        NSDictionary *attribute = [self parserAttributeWithSearchColor:[UIColor blueColor]];
        [attributedString setAttributes:attribute range:range];
    }
    
    CTFramesetterRef setterRef = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
    CGPathRef pathRef = CGPathCreateWithRect(bounds, NULL);
    CTFrameRef frameRef = CTFramesetterCreateFrame(setterRef, CFRangeMake(0, 0), pathRef, NULL);
    CFRelease(setterRef);
    CFRelease(pathRef);
    return frameRef;
}

+ (NSDictionary *)parserAttributeWithSearchColor:(UIColor *)searchColor {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    // 文字颜色
    dict[NSForegroundColorAttributeName] = searchColor? searchColor:[HHReadConfig shareInstance].fontColor;
    // 文字大小
    CGFloat fontSize = [HHReadConfig shareInstance].fontSize;
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:fontSize];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    // 行间距
    paragraphStyle.lineSpacing = 8;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    // 首行缩进
    paragraphStyle.firstLineHeadIndent = 0;
    dict[NSParagraphStyleAttributeName] = paragraphStyle;
    return [dict copy];
}

@end
