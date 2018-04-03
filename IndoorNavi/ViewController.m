//
//  ViewController.m
//  IndoorNavi
//
//  Created by Yewei Wang on 2018/3/11.
//  Copyright © 2018年 Yewei Wang. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "ViewController.h"
#import "UIViewController1.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <BabyBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "TriangulationAlgorithm.h"
#include <math.h>
#import "fingerprinting.h"
#import "rssi_data.h"


@interface ViewController () {
    NSMutableArray * peripheralDataArray;
    BabyBluetooth * baby;
    TriangulationCalculator * triangulationCalculator;
    int PowerLevel;
    int heading;
    double x_point;
    double y_point;
}
@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    //if (self) {
        //custom initialization
    //}
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Change the Config point here!!!
    x_point = 1.06;
    y_point = 8.215;
    
    NSLog(@"Starting Config");
    
//    //testing database
    DataBaseHandle * dataBaseHandle = [DataBaseHandle dataBaseHandleWithDataBaseName:@"Rssi4DB"];
//    RssiEntity * entity2 = [[RssiEntity alloc] init];
//    entity2.x = self->x_point;
//    entity2.y = self->y_point;
//    entity2.beacon = 2;
//    entity2.value = -127;
//    entity2.heading = 2;
//    [dataBaseHandle insertDataWithKeyValues:entity2];
//    //NSLog(@"Config 3 x:%f y:%f heading: %d  value: %d", self->x_point, self->y_point,self->heading,avag_rssi_three);
//    //NSMutableArray * result = [dataBaseHandle selectOneByrssi:1 value:-69];
    [dataBaseHandle selectAllKeyValues];
    
    // Update Data
    //[dataBaseHandle updateRssi:-80 x_value:100 y_value:321];
    //[dataBaseHandle updateRssi:-90 x_value:200 y_value:421 ];

    // Delete one of data
    //[dataBaseHandle deleteOneRssi:100 y_value:321];
    
    // Delete the table
    //[dataBaseHandle dropTable];

      //Draw three reference points
//    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(182, 30, 10, 10)];
//    view2.backgroundColor = [UIColor orangeColor];
//    [self.view addSubview:view2];
//    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(49, 770, 10, 10)];
//    view3.backgroundColor = [UIColor orangeColor];
//    [self.view addSubview:view3];
//    UIView *view4 = [[UIView alloc] initWithFrame:CGRectMake(315, 770, 10, 10)];
//    view4.backgroundColor = [UIColor orangeColor];
//    [self.view addSubview:view4];
    
    UIImage *backGroundImage = [UIImage imageNamed:@"background.jpg"];
    self.view.contentMode = UIViewContentModeScaleAspectFill;
    self.view.layer.contents = (__bridge id _Nullable)(backGroundImage.CGImage);
    //Remove all button
//    for( UIButton *v in self.view.subviews ) {
//        if( [v isKindOfClass:[UIButton class]] ) {
//            [v removeFromSuperview];
//        }
//    }
    
    //add a new point
    UIButton *point = [[UIButton alloc]initWithFrame:CGRectMake(36.36*x_point+35, 64.13*y_point+26, 50, 50)];
    point.backgroundColor = [UIColor redColor];
    [point addTarget:self action:@selector(startconfig) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:point];

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

- (void)startconfig {
    //compass
    self->locationManager=[[CLLocationManager alloc] init];
    self->locationManager.distanceFilter = 100;
    self->locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self->locationManager.delegate = self;
    [self->locationManager startUpdatingHeading];
    
    for( UIButton *v in self.view.subviews ) {
        if( [v isKindOfClass:[UIButton class]] ) {
            v.backgroundColor = [UIColor greenColor];
        }
    }
    UIImage *backGroundImage = [UIImage imageNamed:@"background.jpg"];
    self.view.contentMode = UIViewContentModeScaleAspectFill;
    self.view.layer.contents = (__bridge id _Nullable)(backGroundImage.CGImage);
    
    PowerLevel = 40;
    //Set bluetooth Delegate
    [self babyDelegate];
}


-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    float mHeading = newHeading.magneticHeading;
    if ((mHeading >= 315) || (mHeading <= 45)) {
        //[direction setText:@"N"];
        self->heading = 1;
        //NSLog(@"N!!!!!!!!");
    }else if ((mHeading > 45) && (mHeading <= 135)) {
        //[direction setText:@"E"];
        self->heading = 2;
        //NSLog(@"E!!!!!!!!");
    }else if ((mHeading > 135) && (mHeading <= 225)) {
        //[direction setText:@"S"];
        self->heading = 3;
        //NSLog(@"S!!!!!!!!");
    }else if ((mHeading > 225) && (mHeading <= 315)) {
        //[direction setText:@"W"];
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
        //NSLog(@"%@ and RSSI: %d", peripheral.identifier, [RSSI intValue]);

        if ([peripheral.name isEqual:@"BrtBeacon01"]) {
            //NSLog(@"RSSI:%@", RSSI);
            if (ignore_count > 5 && [RSSI intValue] != 127) {
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
                    float u = container/self->PowerLevel;
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
                    //double txPower = -54;

                    //distance_one = pow(10,((txPower - avag_rssi_one)/22));
                    //NSLog(@"Beacon1 has RSSI: %d and %.1f meters", avag_rssi_one, distance_one);
                    [rssi_array_one removeAllObjects];
                    flag = 1;
                    //Config process

                    RssiEntity * entity1 = [[RssiEntity alloc] init];
                    //entity.number = nil;
                    entity1.x = self->x_point;
                    entity1.y = self->y_point;
                    entity1.beacon = 1;
                    entity1.value = avag_rssi_one;
                    entity1.heading = self->heading;
                    [dataBaseHandle insertDataWithKeyValues:entity1];
                    NSLog(@"Config 1 x:%f y:%f heading: %d  value: %d", self->x_point, self->y_point,self->heading,avag_rssi_one);
                    [dataBaseHandle selectAllKeyValues];
                }
            }
            else {
                ignore_count = ignore_count + 1;
            }
        }
        else if ([peripheral.name isEqual:@"BrtBeacon02"]) {
             //NSLog(@"RSSI:%@", RSSI);
             if (ignore_count > 5 && [RSSI intValue] != 127) {
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
                     float u = container/self->PowerLevel;
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
                     //double txPower = -54;

                     //distance_two = pow(10,((txPower - avag_rssi_two)/22));
                     //NSLog(@"Beacon2 has RSSI: %d and %.1f meters", avag_rssi_two, distance_two);
                     [rssi_array_two removeAllObjects];
                     flag = 1;
                     //Config process
                     RssiEntity * entity1 = [[RssiEntity alloc] init];
                     //entity.number = nil;
                     entity1.x = self->x_point;
                     entity1.y = self->y_point;
                     entity1.beacon = 2;
                     entity1.value = avag_rssi_two;
                     entity1.heading = self->heading;
                     [dataBaseHandle insertDataWithKeyValues:entity1];
                     NSLog(@"Config 2 x:%f y:%f heading: %d  value: %d", self->x_point, self->y_point,self->heading,avag_rssi_two);
                     [dataBaseHandle selectAllKeyValues];
                 }
             }
             else {
                 ignore_count = ignore_count + 1;
             }
        }
        else if ([peripheral.name isEqual:@"BrtBeacon03"]) {
            //NSLog(@"RSSI:%@", RSSI);
            if (ignore_count > 5 && [RSSI intValue] != 127) {
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
                    float u = container/self->PowerLevel;
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
                    //double txPower = -54;

                    //distance_three = pow(10,((txPower - avag_rssi_three)/22));
                    //NSLog(@"Beacon3 has RSSI: %d and %.1f meters", avag_rssi_three, distance_three);
                    [rssi_array_three removeAllObjects];
                    flag = 1;
                    //Config process
                    RssiEntity * entity1 = [[RssiEntity alloc] init];
                    //entity.number = nil;
                    entity1.x = self->x_point;
                    entity1.y = self->y_point;
                    entity1.beacon = 3;
                    entity1.value = avag_rssi_three;
                    entity1.heading = self->heading;
                    [dataBaseHandle insertDataWithKeyValues:entity1];
                    NSLog(@"Config 3 x:%f y:%f heading: %d  value: %d", self->x_point, self->y_point,self->heading,avag_rssi_three);
                    [dataBaseHandle selectAllKeyValues];
                }
            }
            else {
                ignore_count = ignore_count + 1;
            }
        }
    }];
    
    
    //Set searching filter
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        //Only search device with this prefix
        if ([peripheralName hasPrefix:@"BrtBeacon"] ) {
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
