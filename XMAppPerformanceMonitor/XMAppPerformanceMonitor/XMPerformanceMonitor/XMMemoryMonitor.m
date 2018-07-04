//
//  XMMemoryMonitor.m
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/3.
//  Copyright © 2018年 MC. All rights reserved.
//

#import "XMMemoryMonitor.h"
#import "XMWeakTarget.h"

#include <mach/task_info.h>
#include <mach/task.h>
#include <mach/mach_init.h>

#define MEMORY_SIZE_PER_MB (1024 * 1024)

typedef struct XMMemoryUsage {
    
    double hasUsage;
    double total;
    double ratio;
    
} XMMemoryUsage;


@interface XMMemoryMonitor()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isMonitoring;

@end

@implementation XMMemoryMonitor

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

static dispatch_queue_t sharedQueue() {
    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("MemoryMonitorQueue", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

+ (XMMemoryMonitor *)sharedMonitor {
    static XMMemoryMonitor *sharedMonitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMonitor = [[[self class] alloc] init];
    });
    return sharedMonitor;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)startMonitor {
    if (!self.isMonitoring) {
        dispatch_async(sharedQueue(), ^{
            self.isMonitoring = YES;
            XMWeakTarget *t = [[XMWeakTarget alloc] initWithTarget:self selector:@selector(tick:)];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:.5f target:t selector:@selector(timerFire:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
            [[NSRunLoop currentRunLoop] run];
        });
    }
}

- (void)stopMonitor {
    NSLog(@"stopped");
    self.isMonitoring = NO;
    [self.timer invalidate];
}

- (void)tick:(NSTimer *)sender {
    XMMemoryUsage usage = memoryUsage();
    NSLog(@"Memory usage:%ld MB, total:%ld MB, ratio:%f", (long)round(usage.hasUsage), (long)round(usage.total), usage.ratio);
}

XMMemoryUsage memoryUsage() {
    struct mach_task_basic_info info;
    mach_msg_type_number_t count = sizeof(info) / sizeof(integer_t);
    if (task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &count) == KERN_SUCCESS) {
        
        XMMemoryUsage usage;
        usage.hasUsage = info.resident_size / MEMORY_SIZE_PER_MB;
        usage.total = [NSProcessInfo processInfo].physicalMemory / MEMORY_SIZE_PER_MB;
        usage.ratio = (double)info.resident_size / (double)[NSProcessInfo processInfo].physicalMemory * 100;
        return usage;
    }
    return (XMMemoryUsage){ 0 };
}

#pragma clang diagnostic pop

@end
