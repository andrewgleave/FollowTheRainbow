//
//  CLLocation+Direction.h
//  FollowTheRainbow
//
//  Created by Andrew on 24/10/2013.
//  Copyright (c) 2013 Red Robot Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CLLocation (Direction)

- (CLLocationDirection)directionToLocation:(CLLocation *)location;

@end
