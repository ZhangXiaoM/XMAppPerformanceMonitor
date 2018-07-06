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

/***********
 * 数据库的设计需求是一段时间获取所有本地异常信息上传到服务器统计，然后删除本地数据，
 * 防止数据增长导致磁盘内存不可控，因此仅支持查找和删除一张表内所有数据
 **********/

@interface XMMonitorDBManager : NSObject

+ (instancetype)sharedManager;

- (void)creatTableWithType:(XMAppMonitorDBType)type;
- (void)insertWithType:(XMAppMonitorDBType)type obj:(__kindof id)obj;
- (void)deleteAllRecordWithType:(XMAppMonitorDBType)type;
- (NSArray <__kindof id> *)selectAllRecordWithType:(XMAppMonitorDBType)type;

@end
