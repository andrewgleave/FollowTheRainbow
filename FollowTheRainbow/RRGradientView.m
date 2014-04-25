//
//  RRGradientView.m
//  BackgroundLocation
//
//  Created by Andrew on 22/10/2013.
//  Copyright (c) 2013 Red Robot Studios. All rights reserved.
//

#import "RRGradientView.h"

@implementation RRGradientView

#pragma mark - UIView

+ (Class)layerClass {
    
    return [CAGradientLayer class];
}

- (CAGradientLayer *)gradientLayer
{
    return (CAGradientLayer *)self.layer;
}

@end
