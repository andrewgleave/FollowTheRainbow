//
//  RRViewController.h
//  FollowTheRainbow
//
//  Created by Andrew on 22/10/2013.
//  Copyright (c) 2013 Red Robot Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RRIndicatorView.h"


@interface RRViewController : UIViewController <CLLocationManagerDelegate>


@property (nonatomic, strong) IBOutlet RRIndicatorView *indicatorView;


@end
