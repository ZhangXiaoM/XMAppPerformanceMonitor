//
//  XMAppInfo.m
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/5.
//  Copyright © 2018年 MC. All rights reserved.
//

#import "XMAppInfo.h"
#import <UIKit/UIKit.h>

static NSString *const kAppVersionKey = @"CFBundleShortVersionString";
static NSString *const kAppInfoFmt    = @"Device: %@\nVersion: %@\nSystem: %@";

@implementation XMAppInfo

+ (NSString *)appInfo {
    NSDictionary * infoDict = [[NSBundle mainBundle] infoDictionary];
    return [NSString stringWithFormat:kAppInfoFmt, [UIDevice currentDevice].model, infoDict[kAppVersionKey], [[UIDevice currentDevice].systemName stringByAppendingString: [UIDevice currentDevice].systemVersion]];
}

- (NSString *)device {
    _device = [UIDevice currentDevice].model;
    return _device;
}

- (NSString *)appVersion {
    NSDictionary * infoDict = [[NSBundle mainBundle] infoDictionary];
    _appVersion = infoDict[kAppVersionKey];
    return _appVersion;
}

- (NSString *)system {
    _system = [[UIDevice currentDevice].systemName stringByAppendingString: [UIDevice currentDevice].systemVersion];
    return _system;
}

@end
