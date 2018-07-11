//
//  XMCPUMonitor.h
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/3.
//  Copyright © 2018年 MC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMCPUMonitor : NSObject

@property (nonatomic, copy) void(^display)(NSString *text);

+ (XMCPUMonitor *)sharedMonitor;

- (void)startMonitor;
- (void)stopMonitor;

@end
