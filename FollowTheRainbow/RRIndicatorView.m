//
//  RRIndicatorView.m
//  FollowTheRainbow
//
//  Created by Andrew on 22/10/2013.
//  Copyright (c) 2013 Red Robot Studios. All rights reserved.
//

#import "RRIndicatorView.h"
#import "RRGradientView.h"
#import "UIColor+HCL.h"


@interface RRIndicatorView () {
    
    RRGradientView      *_gradientView;
    CAShapeLayer        *_needleLayer;
    CAShapeLayer        *_startButtonLayer;
    CGFloat             _needleRotation;
    NSArray             *_gradientBaseColors;
    NSUInteger          _currentGradientIndex;
    NSDictionary        *_distanceColorMapping;
    NSArray             *_sortedDistanceArray;
    BOOL                _isFlashingLocationUpdate;
    BOOL                _isIndicatorIsPulsing;
    
    BOOL                _isMonitoringForBeacon;
}

@end


#define DEGREES_TO_RADIANS(degrees) (M_PI / 180.0) * (degrees)

static const CGFloat kGradientLuminanceDelta = -18.0f;


@implementation RRIndicatorView


- (void)awakeFromNib {
    
    _needleRotation = DEGREES_TO_RADIANS(180);
    _isFlashingLocationUpdate = NO;
    _isMonitoringForBeacon = NO;
    _isIndicatorIsPulsing = NO;
    _currentGradientIndex = 0;
    
    _gradientView = [[RRGradientView alloc] initWithFrame:self.frame];
    
    [self initGradientColors];
    [self drawBackgroundGradientForDistance:99999.00];
    
    [self addSubview:_gradientView];
    [self.layer addSublayer:[self needleLayer]];
}

- (void)initGradientColors {
    
    /*
     var colors = ["#28A0BB",
     "#4A9BC8",
     "#6E94CE",
     "#918BCE",
     "#B280C7",
     "#CF73B9",
     "#E666A6",
     "#F65C8D",
     "#FE5771",
     "#FD5B54"]
     
     #31C099
     
     #2CD778
     
     */
    
    _distanceColorMapping = @{@99999999: [[LABHCLColor alloc] initWithHue:-134.50257345930802 chroma:32.43084664500044 luminance:60.93824033693183],
                            @1600: [[LABHCLColor alloc] initWithHue:-109.8138012487884 chroma:32.42181720607475 luminance:60.839969337047265],
                            @800: [[LABHCLColor alloc] initWithHue:-85.69422189678805 chroma:33.99239065153089 luminance:60.73678287711704],
                            @400: [[LABHCLColor alloc] initWithHue:-62.87373864076418 chroma:37.89478190826004 luminance:60.72907993765445],
                            @200: [[LABHCLColor alloc] initWithHue:-42.60969114089887 chroma:43.46995442835824 luminance:60.80600385921264],
                            @100: [[LABHCLColor alloc] initWithHue:-24.96361180475489 chroma:50.235681495978945 luminance:60.8100050536316],
                            @50: [[LABHCLColor alloc] initWithHue:-10.02395367538862 chroma:57.178518374652626 luminance:60.854890389018934],
                            @25: [[LABHCLColor alloc] initWithHue:4.472364138224754 chroma:62.956560173631495 luminance:60.93642524453648],
                            @10: [[LABHCLColor alloc] initWithHue:18.145134235681606 chroma:68.2450878376211 luminance:60.85730500261228],
                            @5: [[LABHCLColor alloc] initWithHue:31.632128043109297 chroma:71.81935417057703 luminance:60.791644494856556]};
    
    _sortedDistanceArray = [[_distanceColorMapping allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        int first = [obj1 intValue];
        int second = [obj2 intValue];
        
        if ( first < second ) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if ( first > second ) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
    }];
}

- (void)orientateIndicatorArrowToDirection:(CLLocationDirection)angle {
    
    CGFloat newAngle = DEGREES_TO_RADIANS(angle);
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.1];
    _needleLayer.affineTransform = CGAffineTransformMakeRotation(newAngle);
    [CATransaction commit];
    
    _needleRotation = newAngle;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    CGPoint location = [[touches anyObject] locationInView:self];
    
    location = [self convertPoint:location toView:nil];
    
    CALayer *hitLayer = [[[self startButtonLayer] presentationLayer] hitTest:location];
    
    if(hitLayer) {
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        CABasicAnimation *opacityAnimation = [[CABasicAnimation alloc] init];
        opacityAnimation.duration = 0.20;
        [_startButtonLayer addAnimation:opacityAnimation forKey:@"opactiy"];
        opacityAnimation.autoreverses = YES;
        _startButtonLayer.opacity = 0.0;
        [CATransaction commit];
    }
}

- (void)drawBackgroundGradientForDistance:(CLLocationDistance)distance {
    
    if(_isFlashingLocationUpdate) {
        return;
    }
    
    LABHCLColor     *topColor;
    NSNumber        *nextBracket;
    UIColor         *topGradientColor;
    UIColor         *bottomGradientColor;
    
    NSUInteger roundedDistance = (unsigned int)distance;
    
    for (NSNumber *distanceBracket in _sortedDistanceArray) {
        
        NSUInteger temp = [distanceBracket unsignedIntegerValue];
        
        if(roundedDistance <= temp) {
            
            topColor = [_distanceColorMapping objectForKey:distanceBracket];
            
            if(temp > [[_sortedDistanceArray firstObject] unsignedIntegerValue]) {
                
                NSUInteger nextBracketIndex = [_sortedDistanceArray indexOfObject:distanceBracket] - 1;
                nextBracket = [_sortedDistanceArray objectAtIndex:nextBracketIndex];
            }
            break;
        }
    }
    
    if(nextBracket) {
        
        double fraction = [nextBracket doubleValue] / roundedDistance;
        
        //Calc the top progression
        LABHCLColor *nextTopColor = [_distanceColorMapping objectForKey:nextBracket];
        
        //Calc the bottom progression
        LABHCLColor *bottomColor = [self adjustColor:topColor withLuminanceDelta:kGradientLuminanceDelta];
        LABHCLColor *nextBottomColor = [self adjustColor:nextTopColor withLuminanceDelta:kGradientLuminanceDelta];
        
        topGradientColor = [UIColor interpolateHCLColor:topColor with:nextTopColor distance:fraction];
        bottomGradientColor = [UIColor interpolateHCLColor:bottomColor with:nextBottomColor distance:fraction];
        
    }
    else {
        
        LABHCLColor *bottomColor = [self adjustColor:topColor withLuminanceDelta:kGradientLuminanceDelta];
        
        topGradientColor = [UIColor colorWithHCLColor:topColor alpha:1.0];
        bottomGradientColor = [UIColor colorWithHCLColor:bottomColor alpha:1.0];
    }
    
    [self animateGradientForColors:@[(id)bottomGradientColor.CGColor, (id)topGradientColor.CGColor]
                          duration:1.5f
               withCompletionBlock:nil];
}

- (void)animateIndicatorArrowPulseForProximity:(CLProximity) proximity {
    
    CGFloat duration = 0.0f;
    
    switch (proximity) {
        case CLProximityImmediate:
            duration = 0.25;
            break;
        case CLProximityNear:
            duration = 0.75f;
            break;
        case CLProximityFar:
            duration = 1.5f;
            break;
        default:
            break;
    }
    
    if(duration > 0.0f) {
        
        CAAnimation *currentAnimation = [_needleLayer animationForKey:@"opacity"];
        
        if(!_isIndicatorIsPulsing || currentAnimation.duration != duration) {
            
            [_needleLayer removeAnimationForKey:@"opacity"];
            
            CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            opacityAnimation.duration = duration;
            opacityAnimation.fromValue = [NSNumber numberWithDouble:1.0f];
            opacityAnimation.toValue = [NSNumber numberWithDouble:0.40f];
            opacityAnimation.repeatCount = HUGE_VALF;
            opacityAnimation.beginTime = CACurrentMediaTime();
            opacityAnimation.autoreverses = YES;
            opacityAnimation.fillMode = kCAFillModeForwards;
            
            [_needleLayer addAnimation:opacityAnimation forKey:@"opacity"];
        
            _isIndicatorIsPulsing = YES;
        }
    }
    else if(duration == 0.0f && _isIndicatorIsPulsing) {
        [_needleLayer removeAnimationForKey:@"opacity"];
        _isIndicatorIsPulsing = NO;
    }
}

- (void)animateGradientForColors:(NSArray *)colors
                        duration:(CGFloat)duration
             withCompletionBlock:(void (^)(void))block {
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setCompletionBlock:block];
    CABasicAnimation *colorAnimation = [[CABasicAnimation alloc] init];
    colorAnimation.duration = duration;
    [_gradientView.gradientLayer addAnimation:colorAnimation forKey:@"colors"];
    _gradientView.gradientLayer.colors = colors;
    [CATransaction commit];
}

- (void)drawBackgroundGradientForLocationUpdate {
    
    _isFlashingLocationUpdate = YES;
    
    LABHCLColor *topColor = [[LABHCLColor alloc] initWithHue:168.92805366237627
                                                      chroma:47.26112865673222
                                                   luminance:69.92934113693721];
    LABHCLColor *bottomColor = [self adjustColor:topColor withLuminanceDelta:kGradientLuminanceDelta];
    
    UIColor *topGradientColor = [UIColor colorWithHCLColor:topColor alpha:1.0f];
    UIColor *bottomGradientColor = [UIColor colorWithHCLColor:bottomColor alpha:1.0f];
    
    
    [self animateGradientForColors:@[(id)bottomGradientColor.CGColor, (id)topGradientColor.CGColor]
                          duration:1.0f
               withCompletionBlock:^{
                   _isFlashingLocationUpdate = NO;
               }];
}

- (LABHCLColor *)adjustColor:(LABHCLColor *)color
          withLuminanceDelta:(CGFloat)delta {
    
    LABHCLColor *newColor = [[LABHCLColor alloc] init];
    
    newColor.h = color.h;
    newColor.c = color.c;
    newColor.l = color.l  - delta;
    
    return newColor;
}

- (CALayer*)needleLayer {
    
    if(!_needleLayer) {
        
        CGSize indicatorSize = CGSizeMake(76.0, 100.0);
        
        CGPoint position = CGPointMake(floorf(((self.frame.size.width) / 2.0)),
                                       floorf((self.frame.size.height) / 2.0));

        UIBezierPath *aPath = [UIBezierPath bezierPath];
        
        [aPath moveToPoint:CGPointMake(0.0, 0.0)];
        [aPath addLineToPoint:CGPointMake(floorf(indicatorSize.width / 2.0), indicatorSize.height)];
        [aPath addLineToPoint:CGPointMake(indicatorSize.width, 0)];
        [aPath addLineToPoint:CGPointMake(floorf(indicatorSize.width / 2.0), floorf(indicatorSize.width / 3.0))];
        [aPath closePath];
        
        _needleLayer = [CAShapeLayer layer];
        _needleLayer.path = aPath.CGPath;
        _needleLayer.frame = CGRectMake(0, 0, indicatorSize.width, indicatorSize.height);
        _needleLayer.fillColor = [UIColor colorWithWhite:1.0 alpha:0.3].CGColor;
        _needleLayer.contentsScale = [[UIScreen mainScreen] scale];
        _needleLayer.position = position;
        _needleLayer.anchorPoint = CGPointMake(0.5, 0.5);
        
    }
    return _needleLayer;
}

- (CAShapeLayer *)startButtonLayer {
    
    if(!_startButtonLayer) {
        
        CGFloat buttonDiameter = 85.0f;
        CGPoint position = CGPointMake(floorf(((self.frame.size.width) / 2.0)),
                                       floorf(((self.frame.size.height) / 2.0)) + 200.0f);
        
        _startButtonLayer = [CAShapeLayer layer];
        _startButtonLayer.frame = CGRectMake(0, 0, buttonDiameter, buttonDiameter);
        _startButtonLayer.path = [UIBezierPath bezierPathWithOvalInRect:_startButtonLayer.frame].CGPath;
        _startButtonLayer.strokeColor = [UIColor colorWithWhite:1.0 alpha:0.90].CGColor;
        _startButtonLayer.fillColor = [UIColor clearColor].CGColor;
        _startButtonLayer.position = position;
        _startButtonLayer.anchorPoint = CGPointMake(0.5, 0.5);
        _startButtonLayer.contentsScale = [[UIScreen mainScreen] scale];
    }
    return _startButtonLayer;
}

@end
