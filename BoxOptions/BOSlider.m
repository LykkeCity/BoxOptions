//
//  BOSlider.m
//  BoxOptions
//
//  Created by Andrey Snetkov on 04/05/2017.
//  Copyright © 2017 Andrey Snetkov. All rights reserved.
//

#import "BOSlider.h"

@implementation BOSlider

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    CGRect orig = [super thumbRectForBounds:bounds trackRect:rect value:value];
    CGRect newArea = CGRectInset(orig, -30, -30);
    return newArea;
    return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], 10 , 10);
}
@end
