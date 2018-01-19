//
//  XHomeViewController.m
//  陀螺仪
//
//  Created by admin on 2018/1/19.
//  Copyright © 2018年 gcg. All rights reserved.
//

#import "XHomeViewController.h"
#import "XOneViewController.h"

static NSString *cellID = @"cellIdentifier";
@interface XHomeViewController ()

@end

@implementation XHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"DeviceStatus";
    }else{
        cell.textLabel.text = @"Game";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        XOneViewController *oneVC = [[XOneViewController alloc] init];
        oneVC.title = @"One";
        [self.navigationController pushViewController:oneVC animated:YES];
    }else{
    
    }
}




@end
