//
//  XMPerformanceModel.h
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/5.
//  Copyright © 2018年 MC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMCPUModel : NSObject
@property (nonatomic, assign) NSInteger cpuUsage;
@end

@interface XMFPSModel : NSObject
@property (nonatomic, assign) NSInteger fps;
@end

@interface XMMemoryModel : NSObject
@property (nonatomic, assign) NSInteger memoryUsage;
@end

@interface XMPerformanceModel : NSObject

@end
