#ifndef TriangulationAlgorithm_h
#define TriangulationAlgorithm_h


@interface TriangulationCalculator:NSObject
{
    //NSMutableArray *beaconPositionX;
    //NSMutableArray *beaconPositionY;
    CGPoint beaconPosition [5];
    //double beaconPositionY[3];
    
}
- (CGPoint) calculatePosition:(int)beaconId1 beaconId2:(int)beaconId2 beaconId3:(int)beaconId3 beaconId4:(int)beaconId4 beaconId5:(int)beaconId5 beaconDis1:(float)beaconDis1 beaconDis2:(float)beaconDis2 beaconDis3:(float)beaconDis3 beaconDis4:(float)beaconDis4 beaconDis5:(float)beaconDis5;
- (CGPoint)applyCorrectionForPoint:(CGPoint)calculatedCoordinate
                  forBeaconDiscances:(float *)beaconDistances;

@end

#endif /* TriangulationAlgorithm_h */
