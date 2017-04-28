//
//  LWCommonButton.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 19/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWCommonButton.h"

@interface LWCommonButton()
{
    NSString *title;
    COMMON_BUTTON_TYPE myType;
}

@property BOOL flagModified;
@end

@implementation LWCommonButton

-(void) awakeFromNib
{
    [super awakeFromNib];
    self.clipsToBounds=YES;
    myType=BUTTON_TYPE_COLORED;
}


+(LWCommonButton *) buttonWithType:(UIButtonType) buttonType
{
    LWCommonButton *button=[super buttonWithType:UIButtonTypeCustom];

    button.flagModified=NO;
    button.type=BUTTON_TYPE_COLORED;
    button.clipsToBounds=YES;
    return button;
}


-(void) setTitle:(NSString *)_title forState:(UIControlState)state
{
    title=_title;
    [self update];
    
}

-(void) setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
        [self update];

}

-(void) setType:(COMMON_BUTTON_TYPE)type
{
    myType=type;
    [self update];
}

-(COMMON_BUTTON_TYPE) type
{
    return myType;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    self.layer.cornerRadius=self.bounds.size.height/2;
    if(!self.flagModified)
        [self update];
    

}

-(void) update
{
    if(!title && !self.titleLabel.text)
        return;
    self.adjustsImageWhenHighlighted=NO;
    self.clipsToBounds=YES;
    self.flagModified=YES;
    self.layer.borderColor=[UIColor colorWithRed:229.0/255 green:239.0/255 blue:233.0/255 alpha:1].CGColor;
    self.layer.borderWidth=1;
    self.backgroundColor=[UIColor whiteColor];
    
    if(!title)
        title=self.titleLabel.text;
    
    NSDictionary *buttonEnabledAttributes;
    NSDictionary *buttonDisabledAttributes= @{NSKernAttributeName:@(1.5), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:17], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.2]};

    if(myType==BUTTON_TYPE_COLORED)
    {
        [self setBackgroundImage:[UIImage imageNamed:@"ButtonOK_square"] forState:UIControlStateNormal];
        [self setBackgroundImage:[self whiteImage] forState:UIControlStateDisabled];

        buttonEnabledAttributes=@{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:17], NSForegroundColorAttributeName:[UIColor whiteColor]};

    }
    else if(myType==BUTTON_TYPE_CLEAR)
    {
        [self setBackgroundImage:nil forState:UIControlStateNormal];
        [self setBackgroundImage:[self whiteImage] forState:UIControlStateDisabled];
        buttonEnabledAttributes=@{NSKernAttributeName:@(1.5), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:17], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]};
        
    }
    else if(myType==BUTTON_TYPE_GREEN)
    {
        self.backgroundColor=[UIColor colorWithRed:19.0/255 green:183.0/255 blue:42.0/255 alpha:1];
        buttonEnabledAttributes=@{NSKernAttributeName:@(1.5), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:17], NSForegroundColorAttributeName:[UIColor whiteColor]};
        
    }
    else if(myType==BUTTON_TYPE_YELLOW)
    {
        self.backgroundColor=[UIColor colorWithRed:255.0/255 green:174.0/255 blue:44.0/255 alpha:1];
        buttonEnabledAttributes=@{NSKernAttributeName:@(1.5), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:17], NSForegroundColorAttributeName:[UIColor whiteColor]};
        buttonDisabledAttributes= @{NSKernAttributeName:@(1.5), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:17], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.2]};

        [self setBackgroundImage:[self whiteImage] forState:UIControlStateDisabled];

    }
    else if(myType==BUTTON_TYPE_VIOLET)
    {
        self.backgroundColor=[UIColor colorWithRed:171.0/255 green:0.0/255 blue:255.0/255 alpha:1];
        buttonEnabledAttributes=@{NSKernAttributeName:@(1.5), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:17], NSForegroundColorAttributeName:[UIColor whiteColor]};
        buttonDisabledAttributes= @{NSKernAttributeName:@(1.5), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:17], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.2]};
        [self setBackgroundImage:[self whiteImage] forState:UIControlStateDisabled];


    }
    else if(myType==BUTTON_TYPE_GRAY)
    {
        self.backgroundColor=[UIColor colorWithRed:245.0/255 green:246.0/255 blue:247.0/255 alpha:1];
        buttonEnabledAttributes=@{NSKernAttributeName:@(1.5), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:17], NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]};
        self.layer.borderWidth = 0;
        
        
    }
    if(self.enabled)
        self.titleLabel.textColor=buttonEnabledAttributes[NSForegroundColorAttributeName];
    else
        self.titleLabel.textColor=buttonDisabledAttributes[NSForegroundColorAttributeName];
    
    [super setAttributedTitle:[[NSAttributedString alloc] initWithString:title attributes:buttonEnabledAttributes] forState:UIControlStateNormal];
    [super setAttributedTitle:[[NSAttributedString alloc] initWithString:title attributes:buttonDisabledAttributes] forState:UIControlStateDisabled];

    

}

-(UIImage *) whiteImage
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
    view.backgroundColor=[UIColor whiteColor];
    UIGraphicsBeginImageContextWithOptions(view.layer.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return img;

}




@end
