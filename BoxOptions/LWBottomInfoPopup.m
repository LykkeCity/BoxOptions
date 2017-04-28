//
//  LWBottomInfoPopup.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/04/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWBottomInfoPopup.h"
#import "LWCommonButton.h"

@interface LWBottomInfoPopup()
{
    
    UIView *shadowView;
    NSMutableArray *gestures;
}

@property (strong, nonatomic) NSString *text;

@end

@implementation LWBottomInfoPopup

+(id) popupWithText:(NSString *)_text {
    
    LWBottomInfoPopup *popup = [[LWBottomInfoPopup alloc] init];
    popup.text = _text;
    
    return popup;
    
}

-(void) show {
    
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    
    CGFloat windowWidth = MIN(window.bounds.size.width, window.bounds.size.height);
    CGFloat windowHeight = MAX(window.bounds.size.width, window.bounds.size.height);
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, 30, windowWidth - 12 - 60, 0)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:18];
    titleLabel.text = _text;
    titleLabel.numberOfLines = 0;
    titleLabel.textColor = [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1];
    [self addSubview:titleLabel];
    
    CGSize size = [titleLabel sizeThatFits:CGSizeMake(windowWidth - 12 - 60, 0)];
    titleLabel.frame = CGRectMake(28, 30, windowWidth - 12 - 60, size.height);
    
    self.frame = CGRectMake(0, 0, windowWidth - 12, size.height + 30 + 44 + 46 + 29);
    

    LWCommonButton *button = [LWCommonButton buttonWithType:UIButtonTypeCustom];
    button.type = BUTTON_TYPE_GRAY;
    [button setTitle:@"CLOSE" forState:UIControlStateNormal];
    button.frame = CGRectMake(20, self.bounds.size.height - 29 - 46, self.bounds.size.width - 40, 46);
    [self addSubview:button];
    
    [button addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 12;
    
    
    
    shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, windowHeight, windowHeight)];
    shadowView.alpha = 0;
    shadowView.backgroundColor = [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.32];
    
    [window addSubview:shadowView];
    [window addSubview:self];
    
    self.center = CGPointMake(window.bounds.size.width/2, window.bounds.size.height + self.bounds.size.height/2);
    
    [UIView animateWithDuration:0.3 animations:^{
        if(window.bounds.size.width < window.bounds.size.height) {
            self.center = CGPointMake(window.bounds.size.width/2, window.bounds.size.height - self.bounds.size.height/2 - 6);
        }
        else {
            self.center = CGPointMake(window.bounds.size.width/2, window.bounds.size.height/2);

        }
        shadowView.alpha = 1;
    }];
    
    
    UITapGestureRecognizer *hideGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [shadowView addGestureRecognizer:hideGesture];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

    
}


-(void) hide {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for(UITapGestureRecognizer *g in gestures) {
        [g.view removeGestureRecognizer:g];
    }
    
    gestures = nil;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.center = CGPointMake(self.window.bounds.size.width/2, self.window.bounds.size.height + self.bounds.size.height/2);
        shadowView.alpha = 0;
    } completion:^(BOOL finished){
        [shadowView removeFromSuperview];
        [self removeFromSuperview];
        
    }];
    
}

-(void) orientationChanged {
    if(self.window.bounds.size.width < self.window.bounds.size.height) {
        self.center = CGPointMake(self.window.bounds.size.width/2, self.window.bounds.size.height - self.bounds.size.height/2 - 6);
    }
    else {
        self.center = CGPointMake(self.window.bounds.size.width/2, self.window.bounds.size.height/2);
        
    }

}




@end
