//
//  XMMonitorDBManager.h
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/5.
//  Copyright © 2018年 MC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, XMAppMonitorDBType) {
    XMAppMonitorDBTypeFPS,
    XMAppMonitorDBTypeCPU,
    XMAppMonitorDBTypeMemory,
    XMAppMonitorDBTypeException
};

@interface XMMonitorDBManager : NSObject

@end
