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
#include <pthread.h>

// 数据库名字
static NSString *const kMonitorDBName = @"app_monitor.sqlite";
#pragma mark - 建表sql指令
static NSString *const kMonitorDBFPSTableSql = @"CREATE TABLE IF NOT EXISTS %@ (id integer PRIMARY KEY AUTOINCREMENT,app_info text,fps integer)";
static NSString *const kMonitorDBCPUTableSql = @"CREATE TABLE IF NOT EXISTS %@ (id integer PRIMARY KEY AUTOINCREMENT,app_info text, cpu integer)";
static NSString *const kMonitorDBMemoryTableSql = @"CREATE TABLE IF NOT EXISTS %@ (id integer PRIMARY KEY AUTOINCREMENT,app_info text, memory integer)";
static NSString *const kMonitorDBExceptionTableSql = @"CREATE TABLE IF NOT EXISTS %@ (id integer PRIMARY KEY AUTOINCREMENT,app_info text, name text, time text, reson text, call_stack text)";

#pragma mark - 插入sql语句
static NSString *const kMonitorDBFPSInsertSqlFmt = @"INSERT INTO %@(app_info ,fps) VALUES('%@',%ld)";
static NSString *const kMonitorDBCPUInsertSqlFmt = @"INSERT INTO %@(app_info ,cpu) VALUES('%@',%ld)";
static NSString *const kMonitorDBMemoryInsertSqlFmt = @"INSERT INTO %@(app_info ,memory) VALUES('%@',%ld)";
static NSString *const kMonitorDBExceptionInsertSqlFmt = @"INSERT INTO %@(app_info ,name, time, reson, call_stack) VALUES('%@', '%@', '%@', '%@', '%@')";

#pragma mark - 删除sql语句
static NSString *const kMonitorDBDeleteSqlFmt = @"DELETE FROM %@";

#pragma mark - 查询sql语句
static NSString *const kMonitorDBSelectSqlFmt = @"SELECT * FROM %@";

static NSString *const kMonitorDBFPSTableName       = @"XMFPSTable";
static NSString *const kMonitorDBCPUTableName       = @"XMCPUTable";
static NSString *const kMonitorDBMemoryTableName    = @"XMMemoryTable";
static NSString *const kMonitorDBExceptionTableName = @"XMExceptionTable";

// 共享数据库
static sqlite3 *_shared_db = nil;

@interface XMMonitorDBManager()
@property (nonatomic, assign) BOOL hasDBOpened;
@end

@implementation XMMonitorDBManager {
    pthread_mutex_t _mutex;
}

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
        NSString *targetPath = [docPath stringByAppendingPathComponent:kMonitorDBName];
        path = targetPath.UTF8String;
        NSLog(@"%@",targetPath);
    });
    
    return path;
}

- (instancetype)init {
    if (self = [super init]) {
        pthread_mutex_init(&_mutex, NULL);
    }
    return self;
}

- (BOOL)openDB {
    //打开数据库文件,如果为nil 则会自动创建一个
    if (self.hasDBOpened) {
        return YES;
    }
    pthread_mutex_lock(&_mutex);
    int result = sqlite3_open(shared_db_path(), &_shared_db);
    result == SQLITE_OK? NSLog(@"打开数据库成功！"): NSLog(@"打开数据库失败！");
    self.hasDBOpened = result == SQLITE_OK;
    pthread_mutex_unlock(&_mutex);
    return result == SQLITE_OK;
}

- (BOOL)closeDB {
    //关闭数据库
    int result = sqlite3_close(_shared_db);
    self.hasDBOpened = result != SQLITE_OK;
    result == SQLITE_OK? NSLog(@"关闭数据库成功！"): NSLog(@"关闭数据库失败！");
    return result == SQLITE_OK;
}

- (void)excSql:(NSString *)sql successMsg:(NSString *)sMsg failMsg:(NSString *)fMsg {
    
    if (!sql.length) {
        NSLog(@"sql语句不合法");
        return;
    }
    
    if (![self openDB]) {
        NSLog(@"打开数据库失败");
        return;
    }
    
    pthread_mutex_lock(&_mutex);
    // 错误信息
    char *errmsg = NULL;
    // 执行语句，参数1：数据库，参数2：sql语句，参数3：回调函数，参数4：回调函数里使用的指针，参数5：错误信息
    int result = sqlite3_exec(_shared_db, sql.UTF8String, NULL, NULL, &errmsg);
    result == SQLITE_OK? NSLog(@"%@", sMsg) :NSLog(@"%@\n error:%c", fMsg, *errmsg);
    pthread_mutex_unlock(&_mutex);
}

#pragma mark - 建表
- (void)creatTableWithSql:(NSString *)sql {
    [self excSql:sql successMsg:@"建表成功！" failMsg:@"建表失败！"];
}

- (void)creatTableWithType:(XMAppMonitorDBType)type {
    NSString *sql;
    switch (type) {
        case XMAppMonitorDBTypeFPS:
            sql = [NSString stringWithFormat:kMonitorDBFPSTableSql, kMonitorDBFPSTableName] ;
            break;
        case XMAppMonitorDBTypeCPU:
            sql = [NSString stringWithFormat:kMonitorDBCPUTableSql, kMonitorDBCPUTableName] ;
            break;
        case XMAppMonitorDBTypeMemory:
            sql = [NSString stringWithFormat:kMonitorDBMemoryTableSql, kMonitorDBMemoryTableName] ;
            break;
        case XMAppMonitorDBTypeException:
            sql = [NSString stringWithFormat:kMonitorDBExceptionTableSql, kMonitorDBExceptionTableName] ;
            break;
            
        default:
            break;
    }
    
    [self creatTableWithSql:sql];
}

#pragma mark - 增
- (void)insertWithSql:(NSString *)sql {
    [self excSql:sql successMsg:@"插入成功" failMsg:@"插入失败"];
}

- (void)insertWithType:(XMAppMonitorDBType)type obj:(__kindof id)obj {
    NSString *sql;
    NSString *appInfo = [XMAppInfo appInfo];
    switch (type) {
        case XMAppMonitorDBTypeFPS:
            sql = [NSString stringWithFormat:kMonitorDBFPSInsertSqlFmt, kMonitorDBFPSTableName, appInfo, ((XMPerformanceModel *)obj).value];
            break;
        case XMAppMonitorDBTypeCPU:
            sql = [NSString stringWithFormat:kMonitorDBCPUInsertSqlFmt, kMonitorDBCPUTableName, appInfo, ((XMPerformanceModel *)obj).value];
            break;
        case XMAppMonitorDBTypeMemory:
            sql = [NSString stringWithFormat:kMonitorDBMemoryInsertSqlFmt, kMonitorDBMemoryTableName, appInfo, ((XMPerformanceModel *)obj).value];
            break;
        case XMAppMonitorDBTypeException: {
            XMException *exc = obj;
            sql = [NSString stringWithFormat:kMonitorDBExceptionInsertSqlFmt,kMonitorDBExceptionTableName, appInfo, exc.name, exc.time, exc.reason, exc.callStack];
        }
            break;
            
        default:
            break;
    }
    // 如果表已存在，不会重复创建
    [self creatTableWithType:type];
    [self insertWithSql:sql];
}

#pragma mark - 删
- (void)deleteAllRecordWithSql:(NSString *)sql {
    [self excSql:sql successMsg:@"删除成功" failMsg:@"删除失败"];
}

- (void)deleteAllRecordWithType:(XMAppMonitorDBType)type {
    NSString *sql;
    switch (type) {
        case XMAppMonitorDBTypeFPS:
            sql = [NSString stringWithFormat:kMonitorDBDeleteSqlFmt, kMonitorDBFPSTableName];
            break;
        case XMAppMonitorDBTypeCPU:
            sql = [NSString stringWithFormat:kMonitorDBDeleteSqlFmt, kMonitorDBCPUTableName];
            break;
        case XMAppMonitorDBTypeMemory:
            sql = [NSString stringWithFormat:kMonitorDBDeleteSqlFmt, kMonitorDBMemoryTableName];
            break;
        case XMAppMonitorDBTypeException: {
            sql = [NSString stringWithFormat:kMonitorDBDeleteSqlFmt, kMonitorDBExceptionTableName];
        }
            break;
            
        default:
            break;
    }
    [self deleteAllRecordWithSql:sql];
}

#pragma mark - 查
- (NSArray <__kindof id> *)selectAllRecordWithType:(XMAppMonitorDBType)type {
    NSString *sql;
    switch (type) {
        case XMAppMonitorDBTypeFPS:
            sql = [NSString stringWithFormat:kMonitorDBSelectSqlFmt, kMonitorDBFPSTableName];
            break;
        case XMAppMonitorDBTypeCPU:
            sql = [NSString stringWithFormat:kMonitorDBSelectSqlFmt, kMonitorDBCPUTableName];
            break;
        case XMAppMonitorDBTypeMemory:
            sql = [NSString stringWithFormat:kMonitorDBSelectSqlFmt, kMonitorDBMemoryTableName];
            break;
        case XMAppMonitorDBTypeException: {
            sql = [NSString stringWithFormat:kMonitorDBSelectSqlFmt, kMonitorDBExceptionTableName];
        }
            break;
            
        default:
            break;
    }
    NSArray *result = [self selectAllRecordWithSql:sql type:type];
    return result;
}

- (NSArray <__kindof id> *)selectAllRecordWithSql:(NSString *)sql type:(XMAppMonitorDBType)type {
    NSMutableArray *result = [NSMutableArray new];
    if (!sql.length) {
        NSLog(@"sql语句不合法");
        return nil;
    }
    
    if (![self openDB]) {
        NSLog(@"打开数据库失败");
        return nil;
    }
    
    // 加锁
    pthread_mutex_lock(&_mutex);
    // 遍历数据库指针
    sqlite3_stmt *stmt = NULL;
    // 判断查询语句是否正确
    if (sqlite3_prepare_v2(_shared_db, sql.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {
        // 遍历输出
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            @autoreleasepool {
                id obj = handle_selected_data(type, stmt);
                !obj?: [result addObject:obj];
            }
        }
    }
    // 释放遍历指针
    sqlite3_finalize(stmt);
    pthread_mutex_unlock(&_mutex);
    return [result copy];
}

__kindof id handle_selected_data(XMAppMonitorDBType type, sqlite3_stmt *stmt) {
    id res;
    if (type == XMAppMonitorDBTypeException) {
        res = handle_exceptin_selected_data(stmt);
    } else {
        res = handle_perfomance_selected_data((NSInteger)type, stmt);
    }
    return res;
}

XMPerformanceModel *
handle_perfomance_selected_data(XMAppMonitorDBType type, sqlite3_stmt *stmt) {
    
    int ID = sqlite3_column_int(stmt, 0);
    const unsigned char *app_info = sqlite3_column_text(stmt, 1);
    NSString *objcAppInfo = [NSString stringWithCString:(const char *)app_info encoding:NSUTF8StringEncoding];
    int value = sqlite3_column_int(stmt, 2);
    
    XMPerformanceModel *m = [XMPerformanceModel new];
    m.ID = ID;
    m.appInfo = objcAppInfo;
    m.value = value;
    m.type = (NSInteger)type;
    return m;
}

XMException *handle_exceptin_selected_data(sqlite3_stmt *stmt) {
    int ID = sqlite3_column_int(stmt, 0);
    const unsigned char *app_info = sqlite3_column_text(stmt, 1);
    NSString *objcAppInfo = [NSString stringWithCString:(const char *)app_info encoding:NSUTF8StringEncoding];
    NSString *name = [NSString stringWithCString:(const char *)sqlite3_column_text(stmt, 2) encoding:NSUTF8StringEncoding];
    NSString *time = [NSString stringWithCString:(const char *)sqlite3_column_text(stmt, 3) encoding:NSUTF8StringEncoding];
    NSString *reason = [NSString stringWithCString:(const char *)sqlite3_column_text(stmt, 4) encoding:NSUTF8StringEncoding];
    NSString *callStack = [NSString stringWithCString:(const char *)sqlite3_column_text(stmt, 5) encoding:NSUTF8StringEncoding];
    
    XMException *exc = [XMException new];
    exc.ID = ID;
    exc.appInfo = objcAppInfo;
    exc.name = name;
    exc.time = time;
    exc.reason = reason;
    exc.callStack = callStack;
    return exc;
}

- (void)dealloc {
    [self closeDB];
    pthread_mutex_destroy(&_mutex);
}

@end
