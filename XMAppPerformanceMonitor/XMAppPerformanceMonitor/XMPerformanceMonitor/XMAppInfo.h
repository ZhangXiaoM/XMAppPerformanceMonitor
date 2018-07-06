//
//  XMAppInfo.h
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/5.
//  Copyright © 2018年 MC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMAppInfo : NSObject

@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *device;
@property (nonatomic, copy) NSString *system;

@property (nonatomic, copy) NSString *appInfo;

+ (NSString *)appInfo;

@end
