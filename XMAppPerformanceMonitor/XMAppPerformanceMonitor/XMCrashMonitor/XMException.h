//
//  XMException.h
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/4.
//  Copyright © 2018年 MC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMException : NSObject

@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * reason;
@property (nonatomic, copy) NSString * callStack;
@property (nonatomic, copy) NSString * time;
@property (nonatomic, copy) NSString * appVersion;

@end
