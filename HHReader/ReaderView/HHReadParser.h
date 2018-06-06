//
//  HHReadParser.h
//  HHReader
//
//  Created by 王楠 on 2018/5/14.
//  Copyright © 2018年 王楠. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface HHReadParser : NSObject

+ (CTFrameRef)parserContent:(NSString *)content searchContent:(NSString *)searchContent bouds:(CGRect)bounds;

@end
