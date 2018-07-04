//
//  TestTableViewCell.m
//  XMAppPerformanceMonitor
//
//  Created by Koudai on 2018/7/3.
//  Copyright © 2018年 MC. All rights reserved.
//

#import "TestTableViewCell.h"

@implementation TestTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.lab = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        self.lab.textColor = [UIColor blackColor];
        self.lab.layer.masksToBounds = YES;
        self.lab.layer.cornerRadius = 3.0f;
        [self.contentView addSubview:self.lab];
    }
    return self;
}


@end
