//
//  ViewController.m
//  X_Toturial2_shader
//
//  Created by admin on 2017/12/29.
//  Copyright © 2017年 gcg. All rights reserved.
//

#import "ViewController.h"
#import "LearnView.h"

@interface ViewController ()

/** <##> */
@property (nonatomic, strong) LearnView *myView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.myView = (LearnView *)self.view;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
