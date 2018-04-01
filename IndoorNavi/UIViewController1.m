//
//  ViewController1.m
//  IndoorNavi
//
//  Created by Yewei Wang on 2018/3/11.
//  Copyright © 2018年 Yewei Wang. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "UIViewController1.h"
#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <BabyBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "TriangulationAlgorithm.h"
#include <math.h>
#import "fingerprinting.h"
#import "rssi_data.h"

@interface ViewController1 () {
    NSMutableArray * peripheralDataArray;
    BabyBluetooth * baby;
    TriangulationCalculator * triangulationCalculator;
    int PowerLevel;
    int heading;
    double x_point;
    double y_point;
}

@end

@implementation ViewController1

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Starting Navi");
    //Database Setup
    //    DataBaseHandle * dataBaseHandle = [DataBaseHandle dataBaseHandleWithDataBaseName:@"Rssi2DB"];
    
    //NSMutableArray * result = [dataBaseHandle selectOneByrssi:1 value:-69];
    //NSLog(@"%@", result);
    //[dataBaseHandle selectAllKeyValues];
    
    // Update Data
    //[dataBaseHandle updateRssi:-80 x_value:100 y_value:321];
    //[dataBaseHandle updateRssi:-90 x_value:200 y_value:421 ];
    
    // Delete one of data
    //[dataBaseHandle deleteOneRssi:100 y_value:321];
    
    // Delete the table
    //[dataBaseHandle dropTable];
    
    // Do any additional setup after loading the view, typically from a nib.
    //    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(182, 30, 10, 10)];
    //    view2.backgroundColor = [UIColor orangeColor];
    //    [self.view addSubview:view2];
    //    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(49, 770, 10, 10)];
    //    view3.backgroundColor = [UIColor orangeColor];
    //    [self.view addSubview:view3];
    //    UIView *view4 = [[UIView alloc] initWithFrame:CGRectMake(315, 770, 10, 10)];
    //    view4.backgroundColor = [UIColor orangeColor];
    //    [self.view addSubview:view4];
    
    UIButton *button1 = [[UIButton alloc] init];
    button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake(100, 100, 180, 90);
    [button1 setTitle:@"Power: Low" forState:UIControlStateNormal];
    [button1 setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(click1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIButton *button2 = [[UIButton alloc] init];
    button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(100, 300, 180, 90);
    [button2 setTitle:@"Power: Medium" forState:UIControlStateNormal];
    [button2 setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(click2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    UIButton *button3 = [[UIButton alloc] init];
    button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.frame = CGRectMake(100, 500, 180, 90);
    [button3 setTitle:@"Power: High" forState:UIControlStateNormal];
    [button3 setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(click3) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    
//    UIButton *button4 = [[UIButton alloc] init];
//    button4 = [UIButton buttonWithType:UIButtonTypeCustom];
//    button4.frame = CGRectMake(100, 600, 180, 90);
//    [button4 setTitle:@"Config" forState:UIControlStateNormal];
//    [button4 setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
//    [button4 addTarget:self action:@selector(click4) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button4];
    
    //    UIButton * button1 = [[UIButton alloc]initWithFrame:CGRectMake(150, 100, 90, 90)];
    //    button1.backgroundColor = [UIColor greenColor];
    //    [button1 addTarget:self action:@selector(click1) forControlEvents:UIControlEventTouchUpInside];
    //    [self.view addSubview:button1];
    
    //    UIButton * button2 = [[UIButton alloc]initWithFrame:CGRectMake(150, 300, 90, 90)];
    //    button2.backgroundColor = [UIColor greenColor];
    //    [button2 addTarget:self action:@selector(click2) forControlEvents:UIControlEventTouchUpInside];
    //    [self.view addSubview:button2];
    //
    //    UIButton * button3 = [[UIButton alloc]initWithFrame:CGRectMake(150, 500, 90, 90)];
    //    button3.backgroundColor = [UIColor greenColor];
    //    [button3 addTarget:self action:@selector(click3) forControlEvents:UIControlEventTouchUpInside];
    //    [self.view addSubview:button3];
    
    //bluetooth init
    NSLog(@"viewDidLoad");
    peripheralDataArray = [[NSMutableArray alloc] init];
    //Initialize BabyBluetooth library
    baby = [BabyBluetooth shareBabyBluetooth];
    
    //initialize triangulation calculator
    triangulationCalculator = [[TriangulationCalculator alloc]init];
    
    //directly use without waiting for CBCentralManagerStatePoweredOn
    baby.scanForPeripherals().begin();
    //baby.scanForPeripherals().begin().stop(10);
}

- (void)click1 {
    UIImage *backGroundImage = [UIImage imageNamed:@"background.jpg"];
    self.view.contentMode = UIViewContentModeScaleAspectFill;
    self.view.layer.contents = (__bridge id _Nullable)(backGroundImage.CGImage);
    
    //compass
    self->locationManager=[[CLLocationManager alloc] init];
    self->locationManager.distanceFilter = 100;
    self->locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self->locationManager.delegate = self;
    [self->locationManager startUpdatingHeading];
    
    PowerLevel = 20;
    //Set bluetooth Delegate
    [self babyDelegate];
    
    //add a new point
    //UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(182, 300, 10, 10)];
    //view1.backgroundColor = [UIColor greenColor];
    UIImageView * view1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me.png"]];
    //[self.view addSubview:view1];
    view1.tag = 1;
    [self.view addSubview:view1];
    //Remove all button
    for( UIButton *v in self.view.subviews ) {
        if( [v isKindOfClass:[UIButton class]] ) {
            [v removeFromSuperview];
        }
    }
}

- (void)click2 {
    UIImage *backGroundImage = [UIImage imageNamed:@"background.jpg"];
    self.view.contentMode = UIViewContentModeScaleAspectFill;
    self.view.layer.contents = (__bridge id _Nullable)(backGroundImage.CGImage);
    
    //compass
    self->locationManager=[[CLLocationManager alloc] init];
    self->locationManager.distanceFilter = 100;
    self->locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self->locationManager.delegate = self;
    [self->locationManager startUpdatingHeading];
    
    PowerLevel = 30;
    //Set bluetooth Delegate
    [self babyDelegate];
    
    //add a new point
    UIImageView * view1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me.png"]];
    view1.tag = 1;
    [self.view addSubview:view1];
    //Remove all button
    for( UIButton *v in self.view.subviews ) {
        if( [v isKindOfClass:[UIButton class]] ) {
            [v removeFromSuperview];
        }
    }
}

- (void)click3 {
    UIImage *backGroundImage = [UIImage imageNamed:@"background.jpg"];
    self.view.contentMode = UIViewContentModeScaleAspectFill;
    self.view.layer.contents = (__bridge id _Nullable)(backGroundImage.CGImage);
    
    //compass
    self->locationManager=[[CLLocationManager alloc] init];
    self->locationManager.distanceFilter = 100;
    self->locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self->locationManager.delegate = self;
    [self->locationManager startUpdatingHeading];
    
    PowerLevel = 50;
    //Set bluetooth Delegate
    [self babyDelegate];
    
    //add a new point
    UIImageView * view1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me.png"]];
    view1.tag = 1;
    [self.view addSubview:view1];
    //Remove all button
    for( UIButton *v in self.view.subviews ) {
        if( [v isKindOfClass:[UIButton class]] ) {
            [v removeFromSuperview];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    float mHeading = newHeading.magneticHeading;
    if ((mHeading >= 315) || (mHeading <= 45)) {
        self->heading = 1;
        //NSLog(@"N!!!!!!!!");
    }else if ((mHeading > 45) && (mHeading <= 135)) {
        self->heading = 2;
        //NSLog(@"E!!!!!!!!");
    }else if ((mHeading > 135) && (mHeading <= 225)) {
        self->heading = 3;
        //NSLog(@"S!!!!!!!!");
    }else if ((mHeading > 225) && (mHeading <= 315)) {
        self->heading = 4;
        //NSLog(@"W!!!!!!!!");
    }
}



#pragma mark -Bluetooth config and control

//Bluetooth Delegate setting
-(void)babyDelegate{
    
    __weak typeof(self) weakSelf = self;
    // database opened
    DataBaseHandle * dataBaseHandle = [DataBaseHandle dataBaseHandleWithDataBaseName:@"Rssi4DB"];
    //print all data in database
    [dataBaseHandle selectAllKeyValues];
    
    //Store previous two rssi values
    static int prev_rssi1 = 0;
    static int prevprev_rssi1 = 0;
    static int prev_rssi2 = 0;
    static int prevprev_rssi2 = 0;
    static int prev_rssi3 = 0;
    static int prevprev_rssi3 = 0;
    
    //Store avarge rssi values
    static int avag_rssi_one = 0;
    static int avag_rssi_two = 0;
    static int avag_rssi_three = 0;
    static int ignore_count = 0;
    
    //Store distance values
    static float distance_one = 0;
    static float distance_two = 0;
    static float distance_three = 0;
    
    static NSMutableArray *rssi_array_one;
    rssi_array_one = [[NSMutableArray alloc] init];
    static NSMutableArray *rssi_array_two;
    rssi_array_two = [[NSMutableArray alloc] init];
    static NSMutableArray *rssi_array_three;
    rssi_array_three = [[NSMutableArray alloc] init];
    static int flag = 0;
    
    //Handle Delegate
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        //Searching for different BrtBeacon
        
        NSLog(@"%@ and RSSI: %d", peripheral.identifier, [RSSI intValue]);
        
        if ([[peripheral.identifier UUIDString] isEqualToString:@"A8EBB481-DFD3-C514-8433-99709FBF29C9"]) {
            //NSLog(@"RSSI:%@", RSSI);
            if (ignore_count > 2 && [RSSI intValue] != 127) {
                if ( [rssi_array_one count] < self->PowerLevel ) {
                    [rssi_array_one addObject:RSSI];
                }
                else {
                    //Start the compass updates.
                    [self->locationManager startUpdatingHeading];
                    NSUInteger count;
                    NSUInteger i;
                    float container = 0;
                    for (i = 0, count = [rssi_array_one count]; i < count; i = i+1) {
                        container = container + [[rssi_array_one objectAtIndex:i] intValue];
                    }
                    float u = container/(self->PowerLevel);
                    float container2 = 0;
                    
                    for (i = 0, count = [rssi_array_one count]; i < count; i = i+1) {
                        double temp = 0.0;
                        temp = [[rssi_array_one objectAtIndex:i] doubleValue] - u;
                        //NSLog(@"temp:%.lf pow:%.1f", temp, pow(temp,2));
                        container2 = container2 + pow(temp,2);
                    }
                    float v = pow(container2/(self->PowerLevel-1),0.5);
                    //NSLog(@"u:%.lf  v:%.1f", u, v);
                    
                    float rssi_sum = 0;
                    float rssi_count = 0;
                    for (i = 0, count = [rssi_array_one count]; i < count; i = i+1) {
                        if ([[rssi_array_one objectAtIndex:i] doubleValue] < (u+v) && [[rssi_array_one objectAtIndex:i] doubleValue] > (u-v))
                        {
                            //NSLog(@"haha:%.lf ", [[rssi_array objectAtIndex:i] doubleValue]);
                            rssi_sum = rssi_sum + [[rssi_array_one objectAtIndex:i] doubleValue];
                            rssi_count = rssi_count + 1;
                        }
                    }
                    avag_rssi_one = rssi_sum / rssi_count;
                    
                    //Moving average Algorithm
                    if (prev_rssi1 == 0 || prevprev_rssi1 == 0) {
                        prev_rssi1 = avag_rssi_one;
                        prevprev_rssi1 = avag_rssi_one;
                    }
                    avag_rssi_one = (avag_rssi_one + prev_rssi1 + prevprev_rssi1)/3;
                    prevprev_rssi1 = prev_rssi1;
                    prev_rssi1 = avag_rssi_one;
                    
                    //Translate RSSI value into distance
                    double txPower = -56;
                    
                    //                    if (avag_rssi_one == 0) {
                    //                        distance_one = -1.0;
                    //                    }
                    //                    double ratio = avag_rssi_one*1.0/txPower;
                    //                    if (ratio < 1.0) {
                    //                        distance_one = pow(ratio,10);
                    //                    }
                    //                    else {
                    //                        distance_one = (0.89976)*pow(ratio,7.7095) + 0.111;
                    //                    }
                    distance_one = pow(10,((txPower - avag_rssi_one)/22));
                    NSLog(@"Purple has RSSI: %d and %.1f meters", avag_rssi_one, distance_one);
                    [rssi_array_one removeAllObjects];
                    flag = 1;
                }
            }
            else {
                ignore_count = ignore_count + 1;
            }
        }
        else if ([[peripheral.identifier UUIDString] isEqualToString:@"66759CA1-7928-1CF1-FB19-33DA8F7E62F2"]) {
            //NSLog(@"RSSI:%@", RSSI);
            if (ignore_count > 2 && [RSSI intValue] != 127) {
                if ( [rssi_array_two count] < self->PowerLevel ) {
                    [rssi_array_two addObject:RSSI];
                }
                else {
                    //Start the compass updates.
                    [self->locationManager startUpdatingHeading];
                    NSUInteger count;
                    NSUInteger i;
                    float container = 0;
                    for (i = 0, count = [rssi_array_two count]; i < count; i = i+1) {
                        container = container + [[rssi_array_two objectAtIndex:i] intValue];
                    }
                    float u = container/(self->PowerLevel);
                    float container2 = 0;
                    
                    for (i = 0, count = [rssi_array_two count]; i < count; i = i+1) {
                        double temp = 0.0;
                        temp = [[rssi_array_two objectAtIndex:i] doubleValue] - u;
                        //NSLog(@"temp:%.lf pow:%.1f", temp, pow(temp,2));
                        container2 = container2 + pow(temp,2);
                    }
                    float v = pow((container2/(self->PowerLevel-1)),0.5);
                    //NSLog(@"u:%.lf  v:%.1f", u, v);
                    
                    float rssi_sum = 0;
                    float rssi_count = 0;
                    for (i = 0, count = [rssi_array_two count]; i < count; i = i+1) {
                        if ([[rssi_array_two objectAtIndex:i] doubleValue] < (u+v) && [[rssi_array_two objectAtIndex:i] doubleValue] > (u-v))
                        {
                            //NSLog(@"haha:%.lf ", [[rssi_array objectAtIndex:i] doubleValue]);
                            rssi_sum = rssi_sum + [[rssi_array_two objectAtIndex:i] doubleValue];
                            rssi_count = rssi_count + 1;
                        }
                    }
                    avag_rssi_two = rssi_sum / rssi_count;
                    //NSLog(@"%@ has RSSI: %d and %.1f meters", peripheral.name, avag_rssi_two, distance_two);
                    //Moving average Algorithm
                    if (prev_rssi2 == 0 || prevprev_rssi2 == 0) {
                        prev_rssi2 = avag_rssi_two;
                        prevprev_rssi2 = avag_rssi_two;
                    }
                    avag_rssi_two = (avag_rssi_two + prev_rssi2 + prevprev_rssi2)/3;
                    prevprev_rssi2 = prev_rssi2;
                    prev_rssi2 = avag_rssi_two;
                    
                    //Translate RSSI value into distance
                    double txPower = -56;
                    
                    distance_two = pow(10,((txPower - avag_rssi_two)/22));
                    NSLog(@"Mint has RSSI: %d and %.1f meters", avag_rssi_two, distance_two);
                    [rssi_array_two removeAllObjects];
                    flag = 1;
                }
            }
            else {
                ignore_count = ignore_count + 1;
            }
        }
        else if ([[peripheral.identifier UUIDString] isEqualToString:@"307813A9-C731-67B8-4889-DB1833C17491"]) {
            //NSLog(@"RSSI:%@", RSSI);
            if (ignore_count > 2 && [RSSI intValue] != 127) {
                if ( [rssi_array_three count] < self->PowerLevel ) {
                    [rssi_array_three addObject:RSSI];
                }
                else {
                    //Start the compass updates.
                    [self->locationManager startUpdatingHeading];
                    NSUInteger count;
                    NSUInteger i;
                    float container = 0;
                    for (i = 0, count = [rssi_array_three count]; i < count; i = i+1) {
                        container = container + [[rssi_array_three objectAtIndex:i] intValue];
                    }
                    float u = container/(self->PowerLevel);
                    float container2 = 0;
                    
                    for (i = 0, count = [rssi_array_three count]; i < count; i = i+1) {
                        double temp = 0.0;
                        temp = [[rssi_array_three objectAtIndex:i] doubleValue] - u;
                        //NSLog(@"temp:%.lf pow:%.1f", temp, pow(temp,2));
                        container2 = container2 + pow(temp,2);
                    }
                    float v = pow((container2/(self->PowerLevel-1)),0.5);
                    //NSLog(@"u:%.lf  v:%.1f", u, v);
                    
                    float rssi_sum = 0;
                    float rssi_count = 0;
                    for (i = 0, count = [rssi_array_three count]; i < count; i = i+1) {
                        if ([[rssi_array_three objectAtIndex:i] doubleValue] < (u+v) && [[rssi_array_three objectAtIndex:i] doubleValue] > (u-v))
                        {
                            //NSLog(@"haha:%.lf ", [[rssi_array objectAtIndex:i] doubleValue]);
                            rssi_sum = rssi_sum + [[rssi_array_three objectAtIndex:i] doubleValue];
                            rssi_count = rssi_count + 1;
                        }
                    }
                    avag_rssi_three = rssi_sum / rssi_count;
                    //NSLog(@"%@ has RSSI: %d and %.1f meters", peripheral.name, avag_rssi_three, distance_three);
                    //Moving average Algorithm
                    if (prev_rssi3 == 0 || prevprev_rssi3 == 0) {
                        prev_rssi3 = avag_rssi_three;
                        prevprev_rssi3 = avag_rssi_three;
                    }
                    avag_rssi_three = (avag_rssi_three + prev_rssi3 + prevprev_rssi3)/3;
                    prevprev_rssi3 = prev_rssi3;
                    prev_rssi3 = avag_rssi_three;
                    
                    //Translate RSSI value into distance
                    double txPower = -56;
                    
                    distance_three = pow(10,((txPower - avag_rssi_three)/22));
                    NSLog(@"Blue has RSSI: %d and %.1f meters", avag_rssi_three, distance_three);
                    [rssi_array_three removeAllObjects];
                    flag = 1;
                }
            }
            else {
                ignore_count = ignore_count + 1;
            }
        }
        
        //ignore the first several data (no coordinate)
        if (flag != 0 && avag_rssi_one !=0 && avag_rssi_two != 0 && avag_rssi_three != 0) {
            //Trilangulation Algorithm
            CGPoint position = [self->triangulationCalculator calculatePosition:1 beaconId2:2 beaconId3:3 beaconDis1:distance_one beaconDis2:distance_two beaconDis3:distance_three];
            //NSLog(@" Beacon1: %d, Beacon2: %d, Beacon3: %d With Position = (%f, %f) ", avag_rssi_one, avag_rssi_two, avag_rssi_three, position.x, position.y);
            //NSLog(@" Beacon1: %d and %.2f, Beacon2: %d and %.2f, Beacon3: %d and %.2f", avag_rssi_one, distance_one, avag_rssi_two, distance_two, avag_rssi_three, distance_three);

            float finger_x = 0;
            float finger_y = 0;

            //if the lowest Power Level is chose, Fingerprinting will not be implemented
            if (self->PowerLevel != 20) {
                //Fingerprinting Algorithm
                NSMutableArray * xy_one = [dataBaseHandle selectOneByrssi:1 value:avag_rssi_one heading_value:self->heading];
                NSMutableArray * xy_two = [dataBaseHandle selectOneByrssi:2 value:avag_rssi_two heading_value:self->heading];
                NSMutableArray * xy_three = [dataBaseHandle selectOneByrssi:3 value:avag_rssi_three heading_value:self->heading];

                NSMutableDictionary * xy_dict = [NSMutableDictionary dictionary];

                for (NSString *string in xy_one) {
                    //if xy is already in the dictionary
                    if ([xy_dict objectForKey:string]) {
                        [xy_dict setObject:@([[xy_dict objectForKey:string] integerValue] + avag_rssi_one + 127) forKey:string];
                    }
                    //if xy is not in the dictionary
                    else {
                        [xy_dict setObject:@(avag_rssi_one) forKey:string];
                    }
                }
                for (NSString *string in xy_two) {
                    if ([xy_dict objectForKey:string]) {
                        [xy_dict setObject:@([[xy_dict objectForKey:string] integerValue] + avag_rssi_two + 127) forKey:string];
                    }
                    else {
                        [xy_dict setObject:@(avag_rssi_two) forKey:string];
                    }
                }
                for (NSString *string in xy_three) {
                    if ([xy_dict objectForKey:string]) {
                        [xy_dict setObject:@([[xy_dict objectForKey:string] integerValue] + avag_rssi_three + 127) forKey:string];
                    }
                    else {
                        [xy_dict setObject:@(avag_rssi_three) forKey:string];
                    }
                }
                NSLog(@"%@", xy_dict);

                NSArray * Sorted_XY = [xy_dict keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {

                    if ([obj1 integerValue] > [obj2 integerValue]) {
                        return (NSComparisonResult)NSOrderedAscending;
                    }
                    if ([obj1 integerValue] < [obj2 integerValue]) {
                        return (NSComparisonResult)NSOrderedDescending;
                    }
                    return (NSComparisonResult)NSOrderedSame;
                }];

                NSArray * Seperated_XY = [[Sorted_XY firstObject] componentsSeparatedByString:@" "];
                finger_x = [[Seperated_XY objectAtIndex:0] floatValue];
                finger_y = [[Seperated_XY objectAtIndex:1] floatValue];

                //NSMutableArray * result = [dataBaseHandle selectOneByrssi:1 value:-65];
                NSLog(@"Fingerprint XY: %.1f and %.1f", finger_x, finger_y);
            }

            //Weighted fused results from both Algorithm
            float weighted_x;
            float weighted_y;
            if (finger_x != 0 && finger_y != 0){
                weighted_x = (70*finger_x/100) + (30*position.x/100);
                weighted_y = (70*finger_y/100) + (30*position.y/100);
            }
            else {
                weighted_x = position.x;
                weighted_y = position.y;
            }

            if (position.x != 0) {
                //convert to pixels
                //NSLog(@"WEIGHTED xy: %.1f and %.1f", weighted_x, weighted_y);
                //for iphone_7plus
                float x = weighted_x*76.8;  //384/5
                float y = weighted_y*38.068 + 39; //670/17.6
                //NSLog(@"weighted pixel: %.1f and %.1f", x, y);
                //for iphone 7 plus
                //float x = weighted_x * 45.1765;
                //float y= weighted_y * 42.9487 + 39;
                for (UIView *i in weakSelf.view.subviews){
                    if([i isKindOfClass:[UIView class]]){
                        UILabel *newLbl = (UILabel *)i;
                        if(newLbl.tag == 1){
                            //change the position of view1
                            i.center = CGPointMake(x, y);
                        }//if
                    }//if
                }//for loop
            }//if
            //set flag back to zero
            flag = 0;
        }
    }];
    
    
    //Set searching filter
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        //Only search device with this prefix
        if ([peripheralName hasPrefix:@"EST"] ) {
            return YES;
        }
        return NO;
    }];
    
    
    [baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
    
    [baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelScanBlock");
    }];
    
    //Ignore same Peripherals found
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //connect device->
    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
