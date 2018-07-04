//
//  XMWeakTarget.h
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/2.
//  Copyright © 2018年 MC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMWeakTarget : NSProxy

@property (nonatomic, weak) id weakTarget;
@property (nonatomic, assign) SEL seletor;

- (instancetype)initWithTarget:(id)target selector:(SEL)selector;

@end
