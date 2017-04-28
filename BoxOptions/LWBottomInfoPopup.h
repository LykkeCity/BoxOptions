//
//  LWBottomInfoPopup.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 24/04/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWBottomInfoPopup : UIView

+(id) popupWithText:(NSString *)text;

-(void) show;

@end
