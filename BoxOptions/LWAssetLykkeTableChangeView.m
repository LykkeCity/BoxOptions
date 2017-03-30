//
//  LWAssetLykkeTableChangeView.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 18.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWAssetLykkeTableChangeView.h"
//#import "LWConstants.h"
//#import "LWColorizer.h"


@interface LWAssetLykkeTableChangeView () {
    
}

@end

@implementation LWAssetLykkeTableChangeView


- (void)drawRect:(CGRect)rect {
    
    if (self.changes && self.changes.count >= 2) {
        // calculation preparation
        
        
        
        
        CGFloat xPosition = 0.0;
        CGFloat xMargin = 5.0;
        CGSize const size = self.frame.size;
        
        
        
        CGFloat const xStep = (size.width - xMargin) / (self.changes.count - 1);
        NSNumber *firstPoint = self.changes[0];
        NSNumber *lastPoint = self.changes[self.changes.count - 1];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth = 1;
        [path moveToPoint:CGPointMake(xPosition, [self point:firstPoint forSize:size])];
        
        // prepare drawing data
        for (NSNumber *change in self.changes) {
            CGFloat const yPosition = [self point:change forSize:size];
            [path addLineToPoint:CGPointMake(xPosition, yPosition)];
            xPosition += xStep;
        }
        
        UIColor *color = nil;
        // set negative or positive color
        if(_defaultColor)
            color=_defaultColor;
        else
        {
            if (firstPoint.doubleValue > lastPoint.doubleValue) {
                color = [UIColor colorWithRed:1 green:62.0/255 blue:45.0/255 alpha:1];
            }
            else {
                color = [UIColor colorWithRed:18.0/255 green:183.0/255 blue:42.0/255 alpha:1];
            }
        }
        // draw
        [color setStroke];
        [path stroke];
        
        // draw last point
        CGRect rect = CGRectMake(xPosition - xStep - 1.5, [self point:lastPoint forSize:size] - 1.5, 3.0, 3.0);
        UIBezierPath *cicle = [UIBezierPath bezierPathWithOvalInRect:rect];
        
        
        [color set];
        [cicle fill];
    }
}

- (CGFloat)point:(NSNumber *)point forSize:(CGSize)size {
    
    CGFloat result=size.height-(2+(size.height-4)*point.floatValue);
    
    
    return result;
}

@end
