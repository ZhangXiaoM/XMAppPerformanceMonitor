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
//    [[NSMutableArray array] addObject:nil];
    [[XMFPSMonitor sharedMonitor] startMonitor];
    [[XMCPUMonitor sharedMonitor] startMonitor];
    [[XMMemoryMonitor sharedMonitor] startMonitor];
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
    for (int i = 0; i < 10000000; ++i) {
        
    }
    
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
