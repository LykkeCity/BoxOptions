//
//  LWMarginalWalletRate.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BORate : NSObject

@property double ask;
@property double bid;
@property double timestamp;

@property double middle;

@end
