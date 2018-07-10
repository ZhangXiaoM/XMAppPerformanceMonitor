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

#import "XMPerformanceModel.h"
#import "XMMonitorDBManager.h"

#define MEMORY_SIZE_PER_MB (1024 * 1024)

typedef struct XMMemoryUsage {
    
    double has_usage;
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

/********************************************
 * 监听整个 APP 生命周期的内存情况
 * 用一个常驻内存的共享队列来处理，
 * 内存的计算和处理，以及定时器都是常驻线程处理，不会阻塞主线程，
 * 也不会影响 APP 性能
 *********************************************/

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
    XMMemoryUsage usage = memory_usage();
//        if (usage.hasUsage > 45) {
    XMPerformanceModel *model = [XMPerformanceModel new];
    model.value = usage.has_usage;
    [[XMMonitorDBManager sharedManager] insertWithType:XMAppMonitorDBTypeMemory obj:model];
//        }
    NSLog(@"Memory usage:%ld MB, total:%ld MB, ratio:%f", (long)round(usage.has_usage), (long)round(usage.total), usage.ratio);
}

XMMemoryUsage memory_usage() {
    // 由内核提供的关于该进程的内存信息，包括虚拟内存，常驻内存，物理内存，最大常驻内存等
    struct mach_task_basic_info info;
    mach_msg_type_number_t count = sizeof(info) / sizeof(integer_t);
    if (task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &count) == KERN_SUCCESS) {
        
        XMMemoryUsage usage;
        usage.has_usage = info.resident_size / MEMORY_SIZE_PER_MB;
        usage.total = [NSProcessInfo processInfo].physicalMemory / MEMORY_SIZE_PER_MB;
        usage.ratio = (double)info.resident_size / (double)[NSProcessInfo processInfo].physicalMemory * 100;
        return usage;
    }
    return (XMMemoryUsage){ 0 };
}

#pragma clang diagnostic pop

@end
