//
//  BOBoxesManager.m
//  BoxOptions
//
//  Created by Andrey Snetkov on 08/06/2017.
//  Copyright © 2017 Andrey Snetkov. All rights reserved.
//

#import "BOBoxesManager.h"
#import "BODataManager.h"
#import "BOAsset.h"

#define BOX_LIFE_TIME 120

@interface BOBoxesManager()
{
    NSMutableArray *boxes;
    NSTimer *timer;
}

@end

@implementation BOBoxesManager

-(id) init {
    self = [super init];
    boxes = [[NSMutableArray alloc] init];
    
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"ActiveBoxes"];
    
    
    double balance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"UserBalance"];
    double now = [NSDate timeIntervalSinceReferenceDate];
    for(NSDictionary *d in arr) {
        BOBetBox *box = [self boxFromDict:d];
        if(!box || box.timeStamp + BOX_LIFE_TIME < now) {
            continue;
        }
        if(box.isWon) {
            balance += box.coeff;
            continue;
        }
        [boxes addObject:box];
        
    }
    [self saveBoxes];
    [[NSUserDefaults standardUserDefaults] setDouble:balance forKey:@"UserBalance"];
    
    [self performSelectorInBackground:@selector(checkBoxes) withObject:nil];
    
    return self;
}

-(void) checkBoxes {
    while(1) {
        @autoreleasepool {
            
            [NSThread sleepForTimeInterval:0.03];
            double now = [NSDate timeIntervalSinceReferenceDate];

            BOOL flagChanged = false;
            for(int i=0; i<boxes.count; i++) {
                BOBetBox *b = boxes[i];
                if(b.isWon) {
                    flagChanged = true;
                    if(b.delegate) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [b.delegate betBoxWon:b];
                            double balance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"UserBalance"];
                            balance += b.coeff;
                            [[NSUserDefaults standardUserDefaults] setDouble:balance forKey:@"UserBalance"];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"BalanceChanged" object:nil];
                        });
                    }
                    [boxes removeObject:b];
                    i--;
                }
                else if(b.timeStamp + BOX_LIFE_TIME < now) {
                    flagChanged = true;
                    [boxes removeObject:b];
                    i--;
                }
            }
            if(flagChanged) {
                [self saveBoxes];
            }
            
        }
    }
}

-(BOBetBox *) boxFromDict:(NSDictionary *) d {
    BOBetBox *b = [[BOBetBox alloc] init];
    for(BOAsset *a in [BODataManager shared].assets) {
        if([a.identity isEqualToString:d[@"Asset"]]) {
            b.assetPair = a;
            break;
        }
    }
    if(!b.assetPair) {
        return nil;
    }
    b.betAmount = [d[@"BetAmount"] doubleValue];
    b.coeff = [d[@"Coeff"] doubleValue];
    b.startPrice = [d[@"StartPrice"] doubleValue];
    b.endPrice = [d[@"EndPrice"] doubleValue];
    b.identity = d[@"Id"];
    b.timeToGraph = [d[@"TimeToGraph"] doubleValue];
    b.timeLength = [d[@"TimeLenght"] doubleValue];
    b.timeStamp = [d[@"TimeStamp"] doubleValue];
    b.timeNeeded = [d[@"TimeNeeded"] doubleValue];
    return b;
}

-(NSDictionary *) dictFromBox:(BOBetBox *) box {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"Asset"] = box.assetPair.identity;
    dict[@"BetAmount"] = @(box.betAmount);
    dict[@"Coeff"] = @(box.coeff);
    dict[@"StartPrice"] = @(box.startPrice);
    dict[@"EndPrice"] = @(box.endPrice);
    dict[@"Id"] = box.identity;
    dict[@"TimeToGraph"] = @(box.timeToGraph);
    dict[@"TimeStamp"] = @(box.timeStamp);
    dict[@"TimeLength"] = @(box.timeLength);
    dict[@"TimeNeeded"] = @(box.timeNeeded);
    return dict;
}

+ (instancetype)shared
{
    static BOBoxesManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[BOBoxesManager alloc] init];
        
    });
    return shared;
}

-(void) addBox:(BOBetBox *)box {
    [boxes addObject:box];
    [self saveBoxes];
}

-(void) saveBoxes {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for(BOBetBox *b in boxes) {
            [arr addObject:[self dictFromBox:b]];
        }
        [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"ActiveBoxes"];
    });
}

-(NSArray *) activeBoxesForAsset:(NSString *)assetId {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for(BOBetBox *b in boxes) {
        if([b.assetPair.identity isEqualToString:assetId]) {
            [arr addObject:b];
        }
    }
    return arr;
}


@end
