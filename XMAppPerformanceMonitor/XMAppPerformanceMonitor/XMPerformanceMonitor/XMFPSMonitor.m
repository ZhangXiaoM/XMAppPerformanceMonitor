//
//  XMFPSMonitor.m
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/3.
//  Copyright © 2018年 MC. All rights reserved.
//

#import "XMFPSMonitor.h"
#import "XMWeakTarget.h"
#import "XMMonitorDBManager.h"
#import "XMPerformanceModel.h"

@interface XMFPSMonitor()

@property (nonatomic, assign) NSTimeInterval lastTamp;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) BOOL isMonitoring;
@end

@implementation XMFPSMonitor

static dispatch_queue_t sharedQueue() {
    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.xm.monitor.fpsQueue", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

+ (XMFPSMonitor *)sharedMonitor {
    static XMFPSMonitor *sharedMonitor = nil;
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

- (void)tick:(CADisplayLink *)link {
    
    // 计算在子线程执行，减少主线程拥塞
    dispatch_async(sharedQueue(), ^{
        // 主线程不会访问和修改临界区内容
        if (self.lastTamp == 0) {
            self.lastTamp = link.timestamp;
            return;
        }
        
        self.count ++;
        NSTimeInterval delta = link.timestamp - self.lastTamp;
        if (delta < 1) return;
        int fps = (int)round(self.count / delta);
//        if (fps < 55) {
        XMPerformanceModel *model = [XMPerformanceModel new];
        model.value = fps;
        [[XMMonitorDBManager sharedManager] insertWithType:XMAppMonitorDBTypeFPS obj:model];
//        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.display) {
                self.display([NSString stringWithFormat:@"FPS:%d", fps]);
            }
        });
        
        NSLog(@"%d",fps);
        self.lastTamp = link.timestamp;
        self.count = 0;
    });
}

- (void)startMonitor {
    if (!self.isMonitoring) {
        self.isMonitoring = YES;
        XMWeakTarget *weakTarget = [[XMWeakTarget alloc] initWithTarget:self selector:@selector(tick:)];
        self.link = [CADisplayLink displayLinkWithTarget:weakTarget selector:@selector(timerFire:)];
        // 页面的绘制在主线程执行，因此 link 只能添加到主线程的 runLoop
        [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stopMonitor {
    self.isMonitoring = NO;
    [self.link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [self.link invalidate];
    NSLog(@"stopped");
}

#pragma clang diagnostic pop

@end
