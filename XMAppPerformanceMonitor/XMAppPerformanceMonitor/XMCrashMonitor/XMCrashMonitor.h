//
//  XMCrashMonitor.h
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/4.
//  Copyright © 2018年 MC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMCrashMonitor : NSObject

+ (XMCrashMonitor *)sharedMonitor;
- (void)startMonitor;

@end
