//
//  RRIndicatorView.h
//  FollowTheRainbow
//
//  Created by Andrew on 22/10/2013.
//  Copyright (c) 2013 Red Robot Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RRIndicatorView : UIView


- (void)orientateIndicatorArrowToDirection:(CLLocationDirection)angle;
- (void)drawBackgroundGradientForDistance:(CLLocationDistance)distance;
- (void)animateIndicatorArrowPulseForProximity:(CLProximity) proximity;
- (void)drawBackgroundGradientForLocationUpdate;

@end
