//
//  UIViewController1.h
//  IndoorNavi
//
//  Created by Yewei Wang on 2018/3/31.
//  Copyright © 2018年 Yewei Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <BabyBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "ViewController.h"

@interface ViewController1 : UIViewController <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}

@end
