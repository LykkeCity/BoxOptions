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
        
        CGContextRef context=UIGraphicsGetCurrentContext();

        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        CGFloat colors1[] =
        {
            216.0/255, 241.0/255.0, 255.0/255.0, 1.0,
            1.0, 1.0, 1.0, 1.0   //RGBA values (so red to green in this case)
        };
        
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors1, NULL, 2);
        CGColorSpaceRelease(colorSpace);
        
        
        CGFloat xPosition = 0.0;
        CGFloat xMargin = 5.0;
        CGSize const size = self.frame.size;
        
        
        
        CGFloat const xStep = (size.width - xMargin) / (self.changes.count - 1);
        NSNumber *firstPoint = self.changes[0];
        NSNumber *lastPoint = self.changes[self.changes.count - 1];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth = 1;
        [path moveToPoint:CGPointMake(xPosition, [self point:firstPoint forSize:size])];
        
        CGFloat prevY = [self point:firstPoint forSize:size];
        // prepare drawing data
        for (NSNumber *change in self.changes) {
            CGFloat const yPosition = [self point:change forSize:size];
            [path addLineToPoint:CGPointMake(xPosition, yPosition)];
            xPosition += xStep;
            
            
            
            
            CGMutablePathRef pathRef = CGPathCreateMutable();
            
            CGPathMoveToPoint(pathRef, NULL, xPosition-xStep, self.bounds.size.height);
            
            
            CGPathAddLineToPoint(pathRef, NULL, xPosition-xStep, prevY);
            CGPathAddLineToPoint(pathRef, NULL, xPosition, yPosition);
            CGPathAddLineToPoint(pathRef, NULL, xPosition, self.bounds.size.height);

            CGPathCloseSubpath(pathRef);
            
//            CGPathAddRect(pathRef, NULL, CGRectMake(xPosition, 0, xStep, yPosition));
            
            CGContextSaveGState(context);
            
            CGContextAddPath(context, pathRef);
            CGContextClip(context);
            
            CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, self.bounds.size.height), 0);
            
            CGContextDrawPath(context, kCGPathFillStroke);
            
            //            CGGradientRelease(gradient);
            CGContextRestoreGState(context);
            CGPathRelease(pathRef);
            
            prevY = yPosition;

            
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
        
        
        CGRect rect0 = CGRectMake(xPosition - xStep - 2.5, [self point:lastPoint forSize:size] - 2.5, 5.0, 5.0);
        UIBezierPath *cicle0 = [UIBezierPath bezierPathWithOvalInRect:rect0];
        
        
        [[UIColor whiteColor] set];
        [cicle0 fill];

        
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
