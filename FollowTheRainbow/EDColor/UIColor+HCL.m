//
//  UIColor+HCL.m
//  BackgroundLocation
//
//  Created by Andrew on 22/10/2013.
//  Copyright (c) 2013 Red Robot Studios. All rights reserved.
//

#import "UIColor+HCL.h"
#import "UIColor+CIELAB.h"


@implementation LABHCLColor

- (id)initWithHue:(CGFloat) hue
           chroma:(CGFloat) chroma
        luminance:(CGFloat) luminance {
    
    self = [super init];
    if (self) {
        
        _h = hue;
        _c = chroma;
        _l = luminance;
    }
    return self;
}

@end


@implementation UIColor (HCL)

+ (UIColor *)colorWithHCLColor:(LABHCLColor *)color
                         alpha:(CGFloat)alpha {
    
    float degrees = M_PI / 180.0;
    
    CGFloat hueDegrees = color.h * degrees;
    CGFloat laba = cosf(hueDegrees) * color.c;
    CGFloat labb = sinf(hueDegrees) * color.c;
    
    return [self colorWithLightness:color.l A:laba B:labb alpha:alpha];
    
}

+ (UIColor *)interpolateHCLColor:(LABHCLColor *)colorA
                            with:(LABHCLColor *)colorB
                            distance:(float)distance {
    
    CGFloat ah, ac, al;
    CGFloat bh, bc, bl;
    
    ah = colorA.h;
    ac = colorA.c;
    al = colorA.l;
    
    bh = colorB.h - ah;
    bc = colorB.c - ac;
    bl = colorB.l - al;
    
    if(bh > 180.0) {
        bh -= 360.0;
    }
    else if (bh < -180.0) {
        bh += 360.0;
    }
    
    LABHCLColor *newColor = [[LABHCLColor alloc] init];
    
    newColor.h = ah + bh * distance;
    newColor.c = ac + bc * distance;
    newColor.l = al + bl * distance;
    
    return [self colorWithHCLColor:newColor alpha:1.0];
}

@end
