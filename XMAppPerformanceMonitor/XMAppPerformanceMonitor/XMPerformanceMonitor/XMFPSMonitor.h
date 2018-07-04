//
//  XMFPSMonitor.h
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/3.
//  Copyright © 2018年 MC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface XMFPSMonitor : NSObject
@property (nonatomic, strong) CADisplayLink *link;

+ (XMFPSMonitor *)sharedMonitor;
- (void)startMonitor;
- (void)stopMonitor;

@end
