//
//  BOBetBox.m
//  BoxOptions
//
//  Created by Andrey Snetkov on 30/05/2017.
//  Copyright © 2017 Andrey Snetkov. All rights reserved.
//

#import "BOBetBox.h"
#import "BODataManager.h"
#import "BORate.h"
#import "BOAsset.h"

@interface BOBetBox() {
    BOOL flagWon;
    BOOL flagFinallyLose;
}

@end

@implementation BOBetBox

-(id) init {
    self = [super init];
    
    flagWon = false;
    flagFinallyLose = false;
    
    return self;
}


-(BOOL) isWon {
    if(flagWon || flagFinallyLose) {
        return flagWon;
    }
    double now = [NSDate timeIntervalSinceReferenceDate];

    if(_timeStamp + _timeToGraph > now) {
        return NO;
    }
    double rightNow = now;
    double price = _assetPair.rate.middle;
    for(int i=(int)_assetPair.changes.count-1; i>=0; i--) {
        if(price >= _startPrice && price <= _endPrice && (_timeStamp + _timeToGraph + _timeLength > now)) {
            flagWon = true;
            return true;
        }
        
        if(_timeStamp + _timeToGraph > now) {
            return NO;
        }

        
        BORate *prevRate = _assetPair.changes[i];
//        if(prevRate.timestamp < _timeStamp + _timeToGraph + _timeLength) {
//            return false;
//        }
        
        if(MIN(prevRate.middle, price) <= _startPrice && MAX(prevRate.middle, price) >= _endPrice && (_timeStamp + _timeToGraph < now && _timeStamp + _timeToGraph + _timeLength > now)) {
            flagWon = true;
            return true;
        }
        
        now = prevRate.timestamp;

        if(price >= _startPrice && price <= _endPrice && (_timeStamp + _timeToGraph < now && _timeStamp + _timeToGraph + _timeLength > now)) {
            flagWon = true;
            return true;
        }

        
//        if(_timeStamp + _timeToGraph > now && _timeStamp + _timeToGraph + _timeLength < rightNow) {
//            flagFinallyLose = true;
//            return false;
//        }
        
        price = prevRate.middle;
            
        
    }
    
    return false;
    
}

@end
