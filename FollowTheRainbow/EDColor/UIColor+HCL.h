//
//  UIColor+HCL.h
//  BackgroundLocation
//
//  Created by Andrew on 22/10/2013.
//  Copyright (c) 2013 Red Robot Studios. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LABHCLColor : NSObject

- (id)initWithHue:(CGFloat) hue
           chroma:(CGFloat) chroma
        luminance:(CGFloat) luminance;

@property (nonatomic, assign) CGFloat h;
@property (nonatomic, assign) CGFloat c;
@property (nonatomic, assign) CGFloat l;

@end


@interface UIColor (HCL)

+ (UIColor *)colorWithHCLColor:(LABHCLColor *)color
                         alpha:(CGFloat)alpha;

+ (UIColor *)interpolateHCLColor:(LABHCLColor *)colorA
                            with:(LABHCLColor *)colorB
                        distance:(float) distance;

@end
