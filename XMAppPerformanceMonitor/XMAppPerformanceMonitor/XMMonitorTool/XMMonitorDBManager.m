//
//  XMMonitorDBManager.m
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/5.
//  Copyright © 2018年 MC. All rights reserved.
//

#import "XMMonitorDBManager.h"
#import "XMAppInfo.h"
#import "XMPerformanceModel.h"
#import "XMException.h"
#import <sqlite3.h>

static sqlite3 *_shared_db = nil;

@interface XMMonitorDBManager()

@end

@implementation XMMonitorDBManager

+ (instancetype)sharedManager {
    static XMMonitorDBManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

static inline const char *shared_db_path() {
    static const char *path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *targetPath = [docPath stringByAppendingPathComponent:@"app_monitor.sqlite"];
        path = targetPath.UTF8String;
    });
    
    return path;
}

- (BOOL)openDB {
    //打开数据库文件,如果为nil 则会自动创建一个
    int result = sqlite3_open(shared_db_path(), &_shared_db);
    if (result == SQLITE_OK) {
        NSLog(@"打开数据库成功！");
    }else{
        NSLog(@"打开数据库失败！");
    }
    return result == SQLITE_OK;
}

- (BOOL)closeDB {
    //关闭数据库
    int result = sqlite3_close(_shared_db);
    if (result == SQLITE_OK) {
        NSLog(@"成功关闭数据库！");
    }else{
        NSLog(@"关闭数据库失败！");
    }
    return result == SQLITE_OK;
}

// 建表
- (void)creatTableWithSql:(NSString *)sql {
    
    // 错误信息
    char *errmsg = NULL;
    // 执行语句，参数1：数据库，参数2：sql语句，参数3：回调函数，参数4：回调函数里使用的指针，参数5：错误信息
    int result = sqlite3_exec(_shared_db, sql.UTF8String, NULL, NULL, &errmsg);
    if (result == SQLITE_OK) {
        NSLog(@"建表成功！");
    }else{
        NSLog(@"建表失败！\n error:%c", *errmsg);
    }
}

- (void)creatTableWithType:(XMAppMonitorDBType)type {
    NSString *sql;
    switch (type) {
        case XMAppMonitorDBTypeFPS:
            sql = @"CREATE TABLE IF NOT EXISTS FPS (id integer PRIMARY KEY AUTOINCREMENT,app_info text,fps integer)";
            break;
        case XMAppMonitorDBTypeCPU:
            sql = @"CREATE TABLE IF NOT EXISTS CPU (id integer PRIMARY KEY AUTOINCREMENT,app_info text,cpu integer)";
            break;
        case XMAppMonitorDBTypeMemory:
            sql = @"CREATE TABLE IF NOT EXISTS Memory (id integer PRIMARY KEY AUTOINCREMENT,app_info text,memory integer)";
            break;
        case XMAppMonitorDBTypeException:
            sql = @"CREATE TABLE IF NOT EXISTS Exception (id integer PRIMARY KEY AUTOINCREMENT,app_info text, name text, reson text, call_stack text)";
            break;
            
        default:
            break;
    }
    
    [self creatTableWithSql:sql];
}

- (void)insertWithSql:(NSString *)sql {
    
    if (![self openDB]) {
        NSLog(@"打开数据库失败");
        return;
    }
    
    //插入sql语句
//    NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO student(name,age) VALUES('%@',%d)",name,age];
    
    char *errmsg = NULL;
    //执行语句，参数和建表类似
    int result = sqlite3_exec(_shared_db, sql.UTF8String, NULL, NULL, &errmsg);
    
    if (result == SQLITE_OK) {
    } else {
    }
    
    [self closeDB];
}

- (void)insertWithType:(XMAppMonitorDBType)type obj:(__kindof id)obj {
    NSString *sql;
    NSString *appInfo = [XMAppInfo appInfo];
    switch (type) {
        case XMAppMonitorDBTypeFPS:
            sql = [NSString stringWithFormat:@"INSERT INTO FPS(app_info ,fps) VALUES('%@',%ld)",appInfo, ((XMFPSModel *)obj).fps];
            break;
        case XMAppMonitorDBTypeCPU:
            sql = [NSString stringWithFormat:@"INSERT INTO CPU(app_info ,cpu) VALUES('%@',%ld)",appInfo, ((XMCPUModel *)obj).cpuUsage];
            break;
        case XMAppMonitorDBTypeMemory:
            sql = [NSString stringWithFormat:@"INSERT INTO CPU(app_info ,memory) VALUES('%@',%ld)",appInfo, ((XMMemoryModel *)obj).memoryUsage];;
            break;
        case XMAppMonitorDBTypeException: {
            XMException *exc = obj;
            sql = [NSString stringWithFormat:@"INSERT INTO CPU(app_info ,name, reson, call_stack) VALUES('%@','%@', '%@', '%@')",appInfo, exc.name, exc.reason, exc.callStack];;
        }
            break;
            
        default:
            break;
    }
    [self insertWithSql:sql];
}


@end
