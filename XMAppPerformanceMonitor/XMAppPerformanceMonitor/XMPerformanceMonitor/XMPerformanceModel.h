//
//  XMPerformanceModel.h
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/5.
//  Copyright © 2018年 MC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMAppInfo.h"

typedef NS_ENUM(NSUInteger, XMPerformanceType) {
    XMPerformanceTypeFPS,
    XMPerformanceTypeCPU,
    XMPerformanceTypeMemory
};

//@interface XMCPUModel : XMAppInfo
//@property (nonatomic, assign) NSInteger cpuUsage;
//@end
//
//@interface XMFPSModel : XMAppInfo
//@property (nonatomic, assign) NSInteger fps;
//@end
//
//@interface XMMemoryModel : XMAppInfo
//@property (nonatomic, assign) NSInteger memoryUsage;
//@end

@interface XMPerformanceModel : XMAppInfo
@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, assign) XMPerformanceType type;
@property (nonatomic, assign) NSInteger value;
@end
