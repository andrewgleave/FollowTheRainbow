//
//  CLLocation+Direction.m
//  FollowTheRainbow
//
//  Created by Andrew on 24/10/2013.
//  Copyright (c) 2013 Red Robot Studios. All rights reserved.
//

#import "CLLocation+Direction.h"


#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(degrees) -1.0f * (M_PI / 180.0) * (degrees)


@implementation CLLocation (Direction)

- (CLLocationDirection)directionToLocation:(CLLocation *)location {
    
    CLLocationCoordinate2D coord1 = self.coordinate;
	CLLocationCoordinate2D coord2 = location.coordinate;
	
    float fLat = DEGREES_TO_RADIANS(coord1.latitude);
    float fLng = DEGREES_TO_RADIANS(coord1.longitude);
    float tLat = DEGREES_TO_RADIANS(coord2.latitude);
    float tLng = DEGREES_TO_RADIANS(coord2.longitude);
    
	CLLocationDegrees deltaLong = tLng - fLng;
	CLLocationDegrees yComponent = sin(deltaLong) * cos(tLat);
	CLLocationDegrees xComponent = (cos(fLat) * sin(tLat)) - (sin(fLat) * cos(tLat) * cos(deltaLong));
	
	CLLocationDegrees radians = atan2(yComponent, xComponent);
	CLLocationDegrees degrees = RADIANS_TO_DEGREES(radians) + 360;
    
	return fmod(degrees, 360);
}

@end
