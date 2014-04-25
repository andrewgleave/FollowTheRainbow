//
//  RRViewController.m
//  FollowTheRainbow
//
//  Created by Andrew on 22/10/2013.
//  Copyright (c) 2013 Red Robot Studios. All rights reserved.
//

#import "RRViewController.h"


#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

static const CGFloat kBeaconRegistrationDistance = 100.0f;


@interface RRViewController () {
    
    CLLocationManager       *_locationManager;
    CLLocationDirection     _currentCourse;
    CLLocationDistance      _currentDistance;
    CLLocationDirection     _directionToTarget;
    CLLocation              *_targetLocation;
    CLLocation              *_currentLocation;
    CLBeaconRegion          *_beaconRegion;
}

- (void)startMonitoringLocationAndHeadingNotification:(NSNotification*)notification;
- (void)stopMonitoringLocationAndHeadingNotification:(NSNotification*)notification;
- (void)updateTargetLocationNotification:(NSNotification *)notification;

@end

@implementation RRViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    _targetLocation = [[CLLocation alloc] initWithLatitude:[[defaults objectForKey:@"targetLatitude"] doubleValue]
                                                 longitude:[[defaults objectForKey:@"targetLongitude"] doubleValue]];
    
    [self initializeLocationManager];
}

- (void)initializeLocationManager {
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    _locationManager.activityType = CLActivityTypeFitness;
    _locationManager.pausesLocationUpdatesAutomatically = YES;
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"FollowTheRainbow Region"];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startMonitoringLocationAndHeadingNotification:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopMonitoringLocationAndHeadingNotification:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTargetLocationNotification:)
                                                 name:@"RRUpdateTargetLocationNotification"
                                               object:nil];
}

- (void)startMonitoringLocationAndHeadingNotification:(NSNotification*)notification {
    
#ifdef DEBUG_LOGGING
    NSLog(@"Did become active");
#endif
    
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
}

- (void)stopMonitoringLocationAndHeadingNotification:(NSNotification*)notification {
    
#ifdef DEBUG_LOGGING
    NSLog(@"Resigning active");
#endif
    
    [_locationManager stopUpdatingLocation];
    [_locationManager stopUpdatingHeading];
}

- (void)updateTargetLocationNotification:(NSNotification *)notification {
    
    NSArray *coordinates = (NSArray *)notification.object;
    
    double targetLatitude = [[coordinates objectAtIndex:0] doubleValue];
    double targetLongitude = [[coordinates objectAtIndex:1] doubleValue];
    
    //Store in defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
    [defaults setObject:[NSNumber numberWithDouble:targetLatitude] forKey:@"targetLatitude"];
    [defaults setObject:[NSNumber numberWithDouble:targetLongitude] forKey:@"targetLongitude"];
    [defaults synchronize];
    
    _targetLocation = [[CLLocation alloc] initWithLatitude:targetLatitude
                                                 longitude:targetLongitude];
    
    [self.indicatorView drawBackgroundGradientForLocationUpdate];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    _currentLocation = (CLLocation *)[locations lastObject];
    _directionToTarget = [_currentLocation directionToLocation:_targetLocation];
    
    CLLocationDistance newDistance = [_currentLocation distanceFromLocation:_targetLocation];
    
    //Only update after ~5m of movement
    if(newDistance - _currentDistance < -5.0 ||  newDistance - _currentDistance > 5.0) {
        
        //Start/stop beacon searching
        if(newDistance <= kBeaconRegistrationDistance) {
            [_locationManager startMonitoringForRegion:_beaconRegion];
        }
        else if (newDistance > kBeaconRegistrationDistance) {
            [_locationManager stopMonitoringForRegion:_beaconRegion];
        }
        
        [self.indicatorView drawBackgroundGradientForDistance:newDistance];
        
        _currentDistance = newDistance;
    }
    
#ifdef DEBUG_LOGGING
    NSLog(@"Current Distance: %f", _currentDistance);
    NSLog(@"Direction to target: %f", _directionToTarget);
    NSLog(@"Lat Lon: %f, %f", _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude);
#endif

}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
    _currentCourse = newHeading.trueHeading;
    
#ifdef DEBUG_LOGGING
    NSLog(@"Current heading: %f", _currentCourse);
    NSLog(@"Adjusted bearing: %f", _directionToTarget - _currentCourse);
#endif
    
    [self.indicatorView orientateIndicatorArrowToDirection:(_directionToTarget - _currentCourse)];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    
#ifdef DEBUG_LOGGING
    NSLog(@"Started monitoring for region: %@", region);
#endif
    
    [_locationManager requestStateForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state
              forRegion:(CLRegion *)region {
    
    switch (state) {
        case CLRegionStateInside:
            
#ifdef DEBUG_LOGGING
            NSLog(@"Determined state is inside region: %@. Started ranging...", region);
#endif
            
            [_locationManager startRangingBeaconsInRegion:_beaconRegion];
            break;
        case CLRegionStateOutside:
        case CLRegionStateUnknown:
        default:
            
#ifdef DEBUG_LOGGING
            NSLog(@"Determined state is outside region: %@. Stopped ranging.", region);
#endif
            
            [_locationManager stopRangingBeaconsInRegion:_beaconRegion];
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region {
    
    if([beacons count] > 0) {
        
        CLBeacon *beacon = [beacons firstObject];
        
        [self.indicatorView animateIndicatorArrowPulseForProximity:beacon.proximity];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
