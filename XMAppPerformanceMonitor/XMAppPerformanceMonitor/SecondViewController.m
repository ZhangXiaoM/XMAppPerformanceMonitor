//
//  SecondViewController.m
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/3.
//  Copyright © 2018年 MC. All rights reserved.
//

#import "SecondViewController.h"
#import "TestTableViewCell.h"
#import "XMFPSMonitor.h"
#import "XMCPUMonitor.h"
#import "XMMemoryMonitor.h"
#import "XMAsyncLabel.h"

@interface SecondViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *table;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.table = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];
    
    XMAsyncLabel *fpsLab = [XMAsyncLabel showInWindowWithframe:CGRectMake(30, 50, 100, 30)];
    XMAsyncLabel *cpuLab = [XMAsyncLabel showInWindowWithframe:CGRectMake(130, 50, 100, 30)];
    XMAsyncLabel *memoryLab = [XMAsyncLabel showInWindowWithframe:CGRectMake(230, 50, 100, 30)];
    [[XMFPSMonitor sharedMonitor] startMonitor];
    [XMFPSMonitor sharedMonitor].display = ^(NSString *text) {
        fpsLab.text = text;
    };
    
    [[XMCPUMonitor sharedMonitor] startMonitor];
    [XMCPUMonitor sharedMonitor].display = ^(NSString *text) {
        cpuLab.text = text;
    };
    
    [[XMMemoryMonitor sharedMonitor] startMonitor];
    [XMMemoryMonitor sharedMonitor].display = ^(NSString *text) {
        memoryLab.text = text;
    };
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    [[XMFPSMonitor sharedMonitor] stopMonitor];
//    [[XMCPUMonitor sharedMonitor] stopMonitor];
//    [[XMMemoryMonitor sharedMonitor] stopMonitor];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1000;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[TestTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"cell"];
    }
    // 模拟主线程繁忙
    for (int i = 0; i < 10000000; ++i) {}
    
    cell.lab.text = [NSString stringWithFormat:@"%ld row", (long)indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)dealloc {
    NSLog(@"second vc dealloc");
}

@end
