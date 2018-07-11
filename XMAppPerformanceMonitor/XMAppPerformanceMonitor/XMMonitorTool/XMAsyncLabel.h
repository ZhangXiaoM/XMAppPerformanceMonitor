//
//  XMAsyncLabel.h
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/11.
//  Copyright © 2018年 MC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMAsyncLabel : UILabel

+ (instancetype)showInView:(UIView *)view frame:(CGRect)frame;
+ (instancetype)showInWindowWithframe:(CGRect)frame;

@end
