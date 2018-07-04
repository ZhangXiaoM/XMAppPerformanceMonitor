//
//  XMCrashMonitor.m
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/4.
//  Copyright © 2018年 MC. All rights reserved.
//

#import "XMCrashMonitor.h"
#import "XMException.h"
#import <UIKit/UIKit.h>

@implementation XMCrashMonitor

+ (XMCrashMonitor *)sharedMonitor {
    static XMCrashMonitor *sharedMonitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMonitor = [[[self class] alloc] init];
    });
    return sharedMonitor;
}

static inline NSString * signal_name(int sigal) {
    
    switch (sigal) {
        case SIGILL:
            // 无效指令
            return @"SIGILL";
            // 计算错误
        case SIGFPE:
            return @"SIGFPE";
            // 总线错误
        case SIGBUS:
            return @"SIGBUS";
            // 进程同步错误
        case SIGPIPE:
            return @"SIGPIPE";
            // 无效地址
        case SIGSEGV:
            return @"SIGSEGV";
            // 中止信号
        case SIGABRT:
            return @"SIGABRT";
        default:
            return @"Unknown";
    }
}

static inline NSString * signal_reson(int signal) {
    switch (signal) {
        case SIGILL:
            // 无效指令
            return @"SIGILL";
            // 计算错误
        case SIGFPE:
            return @"SIGFPE";
            // 总线错误
        case SIGBUS:
            return @"SIGBUS";
            // 进程同步错误
        case SIGPIPE:
            return @"SIGPIPE";
            // 无效地址
        case SIGSEGV:
            return @"SIGSEGV";
            // 中止信号
        case SIGABRT:
            return @"SIGABRT";
        default:
            return @"Unknown";
    }
}

- (void)startMonitor {
    NSSetUncaughtExceptionHandler(&catch_exception_handle);
    signal(SIGILL, signal_handler);
    signal(SIGFPE, signal_handler);
    signal(SIGBUS, signal_handler);
    signal(SIGPIPE, signal_handler);
    signal(SIGSEGV, signal_handler);
    signal(SIGABRT, signal_handler);
}

static void signal_handler(int signal) {
    catch_exception_handle([NSException exceptionWithName:signal_name(signal) reason: signal_reson(signal) userInfo: nil]);
    [XMCrashMonitor killApp];
}

void catch_exception_handle(NSException *exception) {
    NSDictionary * infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString * appInfo = [NSString stringWithFormat: @"Device: %@\n Version: %@\n System: %@", [UIDevice currentDevice].model, infoDict[@"CFBundleShortVersionString"], [[UIDevice currentDevice].systemName stringByAppendingString: [UIDevice currentDevice].systemVersion]];
    
    NSString *callStackSymbols = [[exception callStackSymbols] componentsJoinedByString:@"\n"];
    if (callStackSymbols && callStackSymbols.length) {
        NSArray *callStack = [[exception userInfo] objectForKey:@""];
        if (callStack.count > 0) {
            callStackSymbols = [callStack componentsJoinedByString:@"\n"];
        }
    }
    
    XMException *exc = [XMException new];
    exc.name = exception.name ?: @"";
    exc.reason = exception.reason ?: @"";
    exc.callStack = callStackSymbols;
    exc.appVersion = appInfo;
    NSDateFormatter *fmt = [NSDateFormatter new];
    fmt.dateFormat = @"yyyy-HH-dd HH:mm:ss";
    exc.time = [fmt stringFromDate:[NSDate date]];
    
    NSLog(@"%@", [exc description]);
}


#pragma mark - Private
+ (void)killApp {
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGILL, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGABRT, SIG_DFL);
    kill(getpid(), SIGKILL);
}

@end
