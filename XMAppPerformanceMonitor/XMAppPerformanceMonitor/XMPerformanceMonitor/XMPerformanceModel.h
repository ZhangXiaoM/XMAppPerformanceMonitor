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

@interface XMPerformanceModel : XMAppInfo
@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, assign) XMPerformanceType type;
@property (nonatomic, assign) NSInteger value;
@end
