//
//  XMException
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/4.
//  Copyright © 2018年 MC. All rights reserved.
//

#import "XMException.h"

@implementation XMException

- (NSString *)description {
    return [NSString stringWithFormat: @"Error: %@\nReson: %@\n%@\nCrash time: %@\n\nCall Stack: \n%@", self.name, self.reason, self.appVersion, self.time, self.callStack];
}

@end
