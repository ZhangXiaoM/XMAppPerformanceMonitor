//
//  XMWeakTarget.m
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/2.
//  Copyright © 2018年 MC. All rights reserved.
//

#import "XMWeakTarget.h"

@implementation XMWeakTarget

- (instancetype)initWithTarget:(id)target selector:(SEL)selector {
    
    self.weakTarget = target;
    self.seletor = selector;
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)timerFire:(id)sender {
    if (self.weakTarget) {
        [self.weakTarget performSelector:self.seletor withObject:sender];
    } else {
        [sender invalidate];
    }
}
#pragma clang diagnostic pop

@end
