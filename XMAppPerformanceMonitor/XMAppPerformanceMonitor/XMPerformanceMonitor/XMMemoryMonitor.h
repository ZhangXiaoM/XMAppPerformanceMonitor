//
//  XMMemoryMonitor.h
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/3.
//  Copyright © 2018年 MC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMMemoryMonitor : NSObject

+ (XMMemoryMonitor *)sharedMonitor;
- (void)startMonitor;
- (void)stopMonitor;

@end
