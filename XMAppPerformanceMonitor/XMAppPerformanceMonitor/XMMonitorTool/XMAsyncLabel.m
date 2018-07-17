//
//  XMAsyncLabel.m
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/11.
//  Copyright © 2018年 MC. All rights reserved.
//

#import "XMAsyncLabel.h"
#import <CoreText/CoreText.h>

@implementation XMAsyncLabel

+ (instancetype)showInView:(UIView *)view frame:(CGRect)frame {
    XMAsyncLabel *lab = [[[self class] alloc] initWithFrame:frame];
    lab.font = [UIFont systemFontOfSize:16.f];
    lab.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = [UIColor redColor];
    [view addSubview:lab];
    return lab;
}

+ (instancetype)showInWindowWithframe:(CGRect)frame {
    UIWindow *w = [UIApplication sharedApplication].delegate.window;
    XMAsyncLabel *lab = [[self class] showInView:w frame:frame];
    return lab;
}

- (void)setText:(NSString *)text {
    [self displayAttributedText:[[NSAttributedString alloc] initWithString:text attributes: @{ NSFontAttributeName:self.font, NSForegroundColorAttributeName:self.textColor, NSBackgroundColorAttributeName: self.backgroundColor }]];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [self displayAttributedText:attributedText];
}

- (void)displayAttributedText:(NSAttributedString *)attributedText {
    
    NSTextAlignment align = self.textAlignment;
    CGSize size = self.frame.size;
    UIFont *font = self.font;
    size.height += 10;

    if ([NSThread isMainThread]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self displayAttributedText:attributedText Align:align size:size font:font];
        });
    } else {
        [self displayAttributedText:attributedText Align:align size:size font:font];
    }
}

- (void)displayAttributedText:(NSAttributedString *)attributedText
                            Align:(NSTextAlignment)align
                             size:(CGSize)size
                             font:(UIFont *)font
{
    attributedText = attributedText.mutableCopy;
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = align;
    [((NSMutableAttributedString *)attributedText) addAttributes: @{ NSParagraphStyleAttributeName:style } range: NSMakeRange(0, attributedText.length)];
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context != NULL) {
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1, -1);
        
        CGSize textSize = [attributedText.string boundingRectWithSize:size options: NSStringDrawingUsesLineFragmentOrigin attributes: @{ NSFontAttributeName:font } context: nil].size;
        textSize.width = ceil(textSize.width);
        textSize.height = ceil(textSize.height);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake((size.width - textSize.width) / 2, 5, textSize.width, textSize.height));
        CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedText);
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attributedText.length), path, NULL);
        CTFrameDraw(frame, context);
        
        UIImage *contents = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CFRelease(frameSetter);
        CFRelease(frame);
        CFRelease(path);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.layer.contents = (id)contents.CGImage;
        });
    }
}




@end
