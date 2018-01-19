//
//  ViewController.m
//  陀螺仪
//
//  Created by admin on 2018/1/19.
//  Copyright © 2018年 gcg. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()

/** <##> */
@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //加速度计使用pull的方式

//    [self useAccelerometerPull];

//    [self useAccelerometerPush];
    [self useGyroPush];
}

- (void)useAccelerometerPull{
    CMMotionManager *manager = [[CMMotionManager alloc] init];
    self.motionManager = manager;
    if ([manager isAccelerometerAvailable] && ![manager isAccelerometerActive]) {
        manager.accelerometerUpdateInterval = 0.01;
        [manager startAccelerometerUpdates];
    }
    //获取并处理加速度计数据
    CMAccelerometerData *newestAccele = self.motionManager.accelerometerData;
    NSLog(@"X = %.4f",newestAccele.acceleration.x);
    NSLog(@"Y = %.4f",newestAccele.acceleration.y);
    NSLog(@"Z = %.4f",newestAccele.acceleration.z);
}

- (void)useAccelerometerPush{
    //初始化全局管理对象
    CMMotionManager *manager = [[CMMotionManager alloc] init];
    self.motionManager = manager;
    //判断加速度计可不可用，判断加速度计是否开启
    if ([manager isAccelerometerAvailable] && ![manager isAccelerometerActive]){
        //告诉manager，更新频率是100Hz
        manager.accelerometerUpdateInterval = 0.01;
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        //Push方式获取和处理数据
        [manager startAccelerometerUpdatesToQueue:queue
                                      withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
         {
             NSLog(@"X = %.04f",accelerometerData.acceleration.x);
             NSLog(@"Y = %.04f",accelerometerData.acceleration.y);
             NSLog(@"Z = %.04f",accelerometerData.acceleration.z);
         }];
    }
}

- (void)useGyroPush{
    //初始化全局管理对象
    CMMotionManager *manager = [[CMMotionManager alloc] init];
    self.motionManager = manager;
    //判断陀螺仪可不可以，判断陀螺仪是不是开启
    if ([manager isGyroAvailable] && ![manager isGyroActive]){
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        //告诉manager，更新频率是100Hz
        manager.gyroUpdateInterval = 1.0;
        //Push方式获取和处理数据
        [manager startGyroUpdatesToQueue:queue
                             withHandler:^(CMGyroData *gyroData, NSError *error)
         {
             NSLog(@"Gyro Rotation x = %.04f", gyroData.rotationRate.x);
             NSLog(@"Gyro Rotation y = %.04f", gyroData.rotationRate.y);
             NSLog(@"Gyro Rotation z = %.04f", gyroData.rotationRate.z);
         }];
    }
}

- (void)stopMonitor{
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopGyroUpdates];
    [self.motionManager stopDeviceMotionUpdates];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
