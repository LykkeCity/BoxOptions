//
//  UIView+ThinLines.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 25/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "UIView+ThinLines.h"

@implementation UIView(ThinLines)

-(void) adjustThinLinesInView:(UIView *) view
{
    for(UIView *l in view.subviews)
    {

        if([l isKindOfClass:[UIView class]])
        {
            BOOL found=NO;
            for(NSLayoutConstraint *c in l.constraints)
            {
//                NSLayoutConstraint *cc=[NSLayoutConstraint const]
                
                if((c.firstAttribute==NSLayoutAttributeHeight && c.constant==1) || (c.firstAttribute==NSLayoutAttributeWidth && c.constant==1))
                {
                    c.constant=0.5;
                    found=YES;
                    break;
                }
            }
            if(found==NO)
                [self adjustThinLinesInView:l];
        }
        
    }
}

-(void) adjustThinLines
{
    [self adjustThinLinesInView:self];
}

@end
