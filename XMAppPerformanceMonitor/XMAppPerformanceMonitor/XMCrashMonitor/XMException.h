//
//  XMException.h
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/4.
//  Copyright © 2018年 MC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMAppInfo.h"

@interface XMException : XMAppInfo

@property (nonatomic, assign) NSInteger ID;

@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * reason;
@property (nonatomic, copy) NSString * callStack;
@property (nonatomic, copy) NSString * time;

@end
