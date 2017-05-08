//
//  BONavigationController.m
//  BoxOptions
//
//  Created by Andrey Snetkov on 08/05/2017.
//  Copyright © 2017 Andrey Snetkov. All rights reserved.
//

#import "BONavigationController.h"
#import "BoxOptions-Swift.h"

@interface BONavigationController ()

@end

@implementation BONavigationController

-(UIInterfaceOrientationMask) supportedInterfaceOrientations {
    if([self.viewControllers.lastObject isKindOfClass:[BOGamePresenter class]]) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;
}

@end
