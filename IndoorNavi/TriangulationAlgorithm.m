#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TriangulationAlgorithm.h"

@implementation TriangulationCalculator


- (instancetype)init
{
    self = [super init];
    if (self) {
        //initialize the positions of the 5 beacons
        //beaconPosition[0].h=0;
        //beaconPosition[0].v=0;
        beaconPosition[0].x=9.2;
        beaconPosition[0].y=10.6;
        beaconPosition[1].x=0;
        beaconPosition[1].y=1;
        beaconPosition[2].x=0;
        beaconPosition[2].y=13.6;
        beaconPosition[3].x=0;
        beaconPosition[3].y=6.6;
        beaconPosition[4].x=9.2;
        beaconPosition[4].y=3.2;
    }
    return self;
}

- (CGPoint) calculatePosition: (int)beaconId1 beaconId2:(int)beaconId2 beaconId3:(int)beaconId3 beaconId4:(int)beaconId4 beaconId5:(int)beaconId5 beaconDis1:(float)beaconDis1 beaconDis2:(float)beaconDis2 beaconDis3:(float)beaconDis3 beaconDis4:(float)beaconDis4 beaconDis5:(float)beaconDis5
{
    
    //find the three largest values
    NSMutableArray *numbers = [[NSMutableArray alloc] init];
    NSNumber *num1 = [NSNumber numberWithFloat:beaconDis1];
    [numbers addObject:num1];
    NSNumber *num2 = [NSNumber numberWithFloat:beaconDis2];
    [numbers addObject:num2];
    NSNumber *num3 = [NSNumber numberWithFloat:beaconDis3];
    [numbers addObject:num3];
    NSNumber *num4 = [NSNumber numberWithFloat:beaconDis4];
    [numbers addObject:num4];
    NSNumber *num5 = [NSNumber numberWithFloat:beaconDis5];
    [numbers addObject:num5];
    
    NSArray *sorted = [numbers sortedArrayUsingSelector:@selector(compare:)];
    
 
    //get top three
    float BeaconDistanceOne   =    [[sorted objectAtIndex:0] floatValue];
    float BeaconDistanceTwo   =    [[sorted objectAtIndex:1] floatValue];
    float BeaconDistanceThree =    [[sorted objectAtIndex:2] floatValue];
    // get the corresponding three indices
    float beaconOneCoordinateX      = beaconPosition[0].x;
    float beaconOneCoordinateY      = beaconPosition[0].y;
    
    
    float beaconTwoCoordinateX      = beaconPosition[1].x;
    float beaconTwoCoordinateY      = beaconPosition[1].y;
    
    float beaconThreeCoordinateX    = beaconPosition[2].x;
    float beaconThreeCoordinateY    = beaconPosition[2].y;
    // check for beacon1
    if (BeaconDistanceOne == beaconDis1)
    {
         beaconOneCoordinateX      = beaconPosition[0].x;
         beaconOneCoordinateY      = beaconPosition[0].y;
        NSLog(@"beacon 1 selected = %d", 1);
    }
    else if (BeaconDistanceOne == beaconDis2)
    {
        beaconOneCoordinateX      = beaconPosition[1].x;
        beaconOneCoordinateY      = beaconPosition[1].y;
         NSLog(@"beacon 1 selected = %d", 2);
    }
    else if (BeaconDistanceOne == beaconDis3)
    {
        beaconOneCoordinateX      = beaconPosition[2].x;
        beaconOneCoordinateY      = beaconPosition[2].y;
         NSLog(@"beacon 1 selected = %d", 3);
    }
    else if (BeaconDistanceOne == beaconDis4)
    {
        beaconOneCoordinateX      = beaconPosition[3].x;
        beaconOneCoordinateY      = beaconPosition[3].y;
         NSLog(@"beacon 1 selected = %d", 4);
    }
    else if (BeaconDistanceOne == beaconDis5)
    {
        beaconOneCoordinateX      = beaconPosition[4].x;
        beaconOneCoordinateY      = beaconPosition[4].y;
         NSLog(@"beacon 1 selected = %d", 5);
    }
    //check for beacon2
    if ((BeaconDistanceTwo == beaconDis1) && ((beaconPosition[0].x != beaconOneCoordinateX) || (beaconPosition[0].y != beaconOneCoordinateY)))
    {
        beaconTwoCoordinateX      = beaconPosition[0].x;
        beaconTwoCoordinateY      = beaconPosition[0].y;
        NSLog(@"beacon 2 selected = %d", 1);

    }
    else if ((BeaconDistanceTwo == beaconDis2) && ((beaconPosition[1].x != beaconOneCoordinateX) || (beaconPosition[1].y != beaconOneCoordinateY)))
    {
        beaconTwoCoordinateX      = beaconPosition[1].x;
        beaconTwoCoordinateY      = beaconPosition[1].y;
        NSLog(@"beacon 2 selected = %d", 2);

    }
    else if ((BeaconDistanceTwo == beaconDis3) && ((beaconPosition[2].x != beaconOneCoordinateX) || (beaconPosition[2].y != beaconOneCoordinateY)))
    {
        beaconTwoCoordinateX      = beaconPosition[2].x;
        beaconTwoCoordinateY      = beaconPosition[2].y;
        NSLog(@"beacon 2 selected = %d", 3);

    }
    else if ((BeaconDistanceTwo == beaconDis4) && ((beaconPosition[3].x != beaconOneCoordinateX) || (beaconPosition[3].y != beaconOneCoordinateY)))
    {
        beaconTwoCoordinateX      = beaconPosition[3].x;
        beaconTwoCoordinateY      = beaconPosition[3].y;
        NSLog(@"beacon 2 selected = %d", 4);

    }
    else if ((BeaconDistanceTwo == beaconDis5) && ((beaconPosition[4].x != beaconOneCoordinateX) || (beaconPosition[4].y != beaconOneCoordinateY)))
    {
        beaconTwoCoordinateX      = beaconPosition[4].x;
        beaconTwoCoordinateY      = beaconPosition[4].y;
        NSLog(@"beacon 2 selected = %d", 5);

    }
    
    //check for beacon3
    if ((BeaconDistanceThree == beaconDis1) && ((beaconPosition[0].x != beaconOneCoordinateX) || (beaconPosition[0].y != beaconOneCoordinateY)) && ((beaconPosition[0].x != beaconTwoCoordinateX) || (beaconPosition[0].y != beaconTwoCoordinateY)))
    {
        beaconThreeCoordinateX      = beaconPosition[0].x;
        beaconThreeCoordinateY      = beaconPosition[0].y;
        NSLog(@"beacon 3 selected = %d", 1);
    }
    else if ((BeaconDistanceThree == beaconDis2) &&  ((beaconPosition[1].x != beaconOneCoordinateX) || (beaconPosition[1].y != beaconOneCoordinateY)) && ((beaconPosition[1].x != beaconTwoCoordinateX) || (beaconPosition[1].y != beaconTwoCoordinateY)))
    {
        beaconThreeCoordinateX      = beaconPosition[1].x;
        beaconThreeCoordinateY      = beaconPosition[1].y;
        NSLog(@"beacon 3 selected = %d", 2);
    }
    else if ((BeaconDistanceThree == beaconDis3) && ((beaconPosition[2].x != beaconOneCoordinateX) || (beaconPosition[2].y != beaconOneCoordinateY)) && ((beaconPosition[2].x != beaconTwoCoordinateX) || (beaconPosition[2].y != beaconTwoCoordinateY)))
    {
        beaconThreeCoordinateX      = beaconPosition[2].x;
        beaconThreeCoordinateY      = beaconPosition[2].y;
        NSLog(@"beacon 3 selected = %d", 3);
    }
    else if ((BeaconDistanceThree == beaconDis4) &&  ((beaconPosition[3].x != beaconOneCoordinateX) || (beaconPosition[3].y != beaconOneCoordinateY)) && ((beaconPosition[3].x != beaconTwoCoordinateX) || (beaconPosition[3].y != beaconTwoCoordinateY)))
    {
        beaconThreeCoordinateX      = beaconPosition[3].x;
        beaconThreeCoordinateY      = beaconPosition[3].y;
        NSLog(@"beacon 3 selected = %d", 4);
    }
    else if ((BeaconDistanceThree == beaconDis5) &&  ((beaconPosition[4].x != beaconOneCoordinateX) || (beaconPosition[4].y != beaconOneCoordinateY)) && ((beaconPosition[4].x != beaconTwoCoordinateX) || (beaconPosition[4].y != beaconTwoCoordinateY)))
    {
        beaconThreeCoordinateX      = beaconPosition[4].x;
        beaconThreeCoordinateY      = beaconPosition[4].y;
        NSLog(@"beacon 3 selected = %d", 5);
    }

    CGPoint positionCoordinate = CGPointMake(0,0);

    
    //Calculating Distances with Factor (cm to Pixel)   *1 = Factor cm to Pixel
    //BeaconDistanceOne   = (BeaconDistanceOne * 100)     *1;
    //BeaconDistanceTwo   = (BeaconDistanceTwo * 100)     *1;
    //BeaconDistanceThree = (BeaconDistanceThree * 100)   *1;
    
//    if ((BeaconDistanceOne + BeaconDistanceTwo) <= 330 || (BeaconDistanceTwo + BeaconDistanceThree) <= 300 || (BeaconDistanceOne+ BeaconDistanceThree) <= 300)
//    {
//        positionCoordinate.x = 0;
//        positionCoordinate.y = 0;
//        return positionCoordinate;
//    }
    
    //Calculating Delta Alpha Beta
    float Delta   = 4 * ((beaconOneCoordinateX - beaconTwoCoordinateX) * (beaconOneCoordinateY - beaconThreeCoordinateY) - (beaconOneCoordinateX - beaconThreeCoordinateX) * (beaconOneCoordinateY - beaconTwoCoordinateY));
    if (Delta == 0)
    {
        return positionCoordinate;
    }
    float Alpha   = (BeaconDistanceTwo * BeaconDistanceTwo) - (BeaconDistanceOne * BeaconDistanceOne) - (beaconTwoCoordinateX * beaconTwoCoordinateX) + (beaconOneCoordinateX * beaconOneCoordinateX) - (beaconTwoCoordinateY * beaconTwoCoordinateY) + (beaconOneCoordinateY * beaconOneCoordinateY);
    float Beta    = (BeaconDistanceThree * BeaconDistanceThree) - (BeaconDistanceOne * BeaconDistanceOne) - (beaconThreeCoordinateX * beaconThreeCoordinateX) + (beaconOneCoordinateX * beaconOneCoordinateX) - (beaconThreeCoordinateY * beaconThreeCoordinateY) + (beaconOneCoordinateY * beaconOneCoordinateY);
    NSLog(@"beaconOne is : x:%.1f y:%.1f, distance1 is: %.1f", beaconOneCoordinateX,beaconOneCoordinateY,BeaconDistanceOne);
    NSLog(@"beaconTwo is : x:%.1f y:%.1f, distance2 is: %.1f", beaconTwoCoordinateX,beaconTwoCoordinateY, BeaconDistanceTwo);
    NSLog(@"beaconThree is : x:%.1f y:%.1f, distance3 is: %.1f", beaconThreeCoordinateX,beaconThreeCoordinateY,BeaconDistanceThree);
    
    //NSLog(@"Delta is : %.1f", Delta);
    
    //Real Calculating the Position Triletaration
    float PositionX = (1/Delta) * (2 * Alpha * (beaconOneCoordinateY - beaconThreeCoordinateY) - 2 * Beta * (beaconOneCoordinateY - beaconTwoCoordinateY));
    float PositionY = (1/Delta) * (2 * Beta * (beaconOneCoordinateX - beaconTwoCoordinateX) - 2 * Alpha * (beaconOneCoordinateX - beaconThreeCoordinateX));
    
//    NSLog(@"Method1 output is: ");
//    NSLog(@"PositionX = %f", PositionX);
//    NSLog(@"PositionY = %f", PositionY);
    
    positionCoordinate.x = PositionX;
    positionCoordinate.y = PositionY;
    
    
    float  distanceArray[] = {beaconDis1,beaconDis2,beaconDis3};
    
    CGPoint correctedCoordinate = [self applyCorrectionForPoint:positionCoordinate
                                      forBeaconDiscances:distanceArray];
    
    
//   NSLog(@"Corrected output is: ");
//   NSLog(@"PositionX = %f", correctedCoordinate.x);
//   NSLog(@"PositionY = %f", correctedCoordinate.y);
    return correctedCoordinate;
}

- (CGPoint)applyCorrectionForPoint:(CGPoint)calculatedCoordinate
forBeaconDiscances:(float *)beaconDistances
{
    // Take in consideration that the signal is the most precise when closest to a beacon.
    // find the vector for each beacon:
    CGPoint totalVector = CGPointZero;
    CGFloat weight = 0;
    for (int i = 0; i < 3; i++) {
        CGFloat
        dX = beaconPosition[i].x - calculatedCoordinate.x,
        dY = beaconPosition[i].y - calculatedCoordinate.y;
        
        CGFloat c1 = sqrt(dX*dX + dY*dY);
        CGFloat d1 = c1 - beaconDistances[i];
        CGFloat ratio = d1 / c1;
        CGFloat multiplier = 1/beaconDistances[i];
        
        totalVector.x += dX * ratio * multiplier;
        totalVector.y += dY * ratio * multiplier;
        weight += multiplier;
    }
    CGPoint coordinateWithCorrection = calculatedCoordinate;
    coordinateWithCorrection.x += totalVector.x / weight;
    coordinateWithCorrection.y += totalVector.y / weight;
    
    return coordinateWithCorrection;
}

@end
