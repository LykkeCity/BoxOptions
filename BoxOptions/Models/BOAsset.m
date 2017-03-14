//
//  LWMarginalWalletAsset.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 14/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "BOAsset.h"



@implementation BOAsset

-(id) init
{
    self=[super init];
    
    _changes=[[NSMutableArray alloc] init];
    _accuracy = 5;
    return self;
}


-(BOOL) rateChanged:(BORate *)newRate
{
    if(_rate && newRate.ask == _rate.ask && newRate.bid == _rate.bid) {
        return NO;
    }
    @synchronized (@"AssetChanges") {

    NSMutableArray *newChanges=[_changes mutableCopy];
        if((newChanges.count>0 && (newRate.timestamp - [(BORate *)newChanges.lastObject timestamp]) < 0.2) == false) {
            [newChanges addObject:newRate];
        }
        _previousRate=_rate;
        _rate=newRate;
        
        
        if(newChanges.count>500)
            [newChanges removeObjectAtIndex:0];
        _changes=newChanges;


        
    }
    return YES;
}


@end
