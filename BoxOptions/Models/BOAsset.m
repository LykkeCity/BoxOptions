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
//        if((newChanges.count>0 && (newRate.timestamp - [(BORate *)newChanges.lastObject timestamp]) < 0.2) == false) {
//            [newChanges addObject:newRate];
//        }
//        else if(newChanges.count > 0) {
//            [newChanges removeLastObject];
//            [newChanges addObject:newRate];
//        }

        [newChanges addObject:newRate];

        _previousRate=_rate;
        _rate=newRate;
        
        _askRaising = _rate.ask > _previousRate.ask;
        _bidRaising = _rate.bid > _previousRate.bid;
        
        
        if(newChanges.count>500)
            [newChanges removeObjectAtIndex:0];
        _changes=newChanges;
        NSArray *tempChanges = [_changes copy];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *g = [[NSMutableArray alloc] init];
            double max = 0;
            double min = MAXFLOAT;
            for(int i = (int)tempChanges.count-1; i>=0 && i>((int)tempChanges.count - 50); i--) {
                BORate *rate = tempChanges[i];
                double value = (rate.ask + rate.bid) / 2;
                [g insertObject:@(value) atIndex:0];
                if(value > max) {
                    max = value;
                }
                if(value < min) {
                    min = value;
                }
                
            }
            
            NSMutableArray *final = [NSMutableArray new];
            for(NSNumber *n in g) {
                double value = (n.doubleValue - min)/(max - min);
                [final addObject:@(value)];
            }
            
            _graphValues = final;
        
        });
        if(!_graphValues)
            _graphValues = @[@(0.3), @(0.5), @(0.7), @(0.1)];
        
    }
    return YES;
}


@end
