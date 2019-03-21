//
//  HHReadPageView.m
//  HHReader
//
//  Created by 王楠 on 2018/5/14.
//  Copyright © 2018年 王楠. All rights reserved.
//

#import "HHReadPageView.h"

@implementation HHReadPageView

#pragma mark -

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)dealloc {
    if (_frameRef) {
        CFRelease(_frameRef);
        _frameRef = nil;
    }
}

#pragma mark -

- (void)longPress:(UILongPressGestureRecognizer *)sender {
    
}

- (void)pan:(UIPanGestureRecognizer *)sender {
    
}

#pragma mark -

- (void)setFrameRef:(CTFrameRef)frameRef {
    if (_frameRef != frameRef) {
        if (_frameRef) {
            CFRelease(_frameRef);
            _frameRef = nil;
        }
        _frameRef = frameRef;
    }
    [self setNeedsDisplay];
}

#pragma mark -

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (!_frameRef) {
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CTFrameDraw(_frameRef, context);
}

@end
