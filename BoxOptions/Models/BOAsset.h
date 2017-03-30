//
//  LWMarginalWalletAsset.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BORate.h"

@interface BOAsset : NSObject



@property (strong, nonatomic) NSString *identity;

@property (strong, nonatomic) BORate *rate;
@property (strong, nonatomic) BORate *previousRate;
@property int accuracy;

@property BOOL askRaising;
@property BOOL bidRaising;


@property (strong, nonatomic) NSMutableArray *changes;

@property (strong, nonatomic) NSArray *graphValues;


-(BOOL) rateChanged:(BORate *) newRate;

@end
