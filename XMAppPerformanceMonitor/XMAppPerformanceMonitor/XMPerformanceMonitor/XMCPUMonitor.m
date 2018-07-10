//
//  XMCPUMonitor.m
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/3.
//  Copyright © 2018年 MC. All rights reserved.
//

#import "XMCPUMonitor.h"
#import "XMWeakTarget.h"

#include <mach/thread_info.h>
#include <mach/mach_types.h>
#include <mach/task.h>
#include <mach/mach_init.h>
#include <mach/thread_act.h>
#include <mach/vm_map.h>
#import "XMPerformanceModel.h"
#import "XMMonitorDBManager.h"

@interface XMCPUMonitor()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isMonitoring;

@end

@implementation XMCPUMonitor

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

static dispatch_queue_t sharedQueue() {
    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("CPUMonitorQueue", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

+ (XMCPUMonitor *)sharedMonitor {
    static XMCPUMonitor *sharedMonitor = nil;
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
            NSLog(@"%@",[NSThread currentThread].name);
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
    int cpu = (int)round(cpu_usage());
//    NSLog(@"CPU Usage: %d", (int)round(cpuUsage()));
//        if (cpu > 80) {
    XMPerformanceModel *model = [XMPerformanceModel new];
    model.value = cpu;
    [[XMMonitorDBManager sharedManager] insertWithType:XMAppMonitorDBTypeCPU obj:model];
//        }
}

float cpu_usage() {
    double usage_ratio = 0;
    thread_info_data_t thinfo;
    thread_act_array_t threads;
    // 由内核提供的该进程内线程的信息，包括：运行时间、运行状态、CPU 用量、睡眠时间等
    thread_basic_info_t basic_info_t;
    mach_msg_type_number_t count = 0;
    mach_msg_type_number_t thread_info_count = THREAD_INFO_MAX;
    
    if (task_threads(mach_task_self(), &threads, &count) == KERN_SUCCESS) {
        for (int idx = 0; idx < count; idx++) {
            if (thread_info(threads[idx], THREAD_BASIC_INFO, (thread_info_t)thinfo, &thread_info_count) == KERN_SUCCESS) {
                basic_info_t = (thread_basic_info_t)thinfo;
                if (!(basic_info_t->flags & TH_FLAGS_IDLE)) {
                    usage_ratio += basic_info_t->cpu_usage / (double)TH_USAGE_SCALE;
                }
            }
        }
        assert(vm_deallocate(mach_task_self(), (vm_address_t)threads, count * sizeof(thread_t)) == KERN_SUCCESS);
    }
    return usage_ratio * 100.;
}

#pragma clang diagnostic pop

@end
