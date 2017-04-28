//
//  LWCommonButton.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 19/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {BUTTON_TYPE_COLORED, BUTTON_TYPE_CLEAR, BUTTON_TYPE_GREEN, BUTTON_TYPE_YELLOW, BUTTON_TYPE_VIOLET, BUTTON_TYPE_GRAY} COMMON_BUTTON_TYPE;

@interface LWCommonButton : UIButton

@property COMMON_BUTTON_TYPE type;


@end
