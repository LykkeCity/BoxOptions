//
//  BODataManager.h
//  BoxOptions
//
//  Created by Andrey Snetkov on 09/02/2017.
//  Copyright © 2017 Andrey Snetkov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {BOEventLaunch = 1,
                BOEventWake = 2,
               BOEventSleep = 3,
         BOEventGameStarted = 4,
          BOEventGameClosed = 5,
           BOEventChangeBet = 6,
         BOEventChangeScale = 7,
           BOEventBetPlaced = 8,
              BOEventBetWon = 9,
             BOEventBetLost = 10} BOEvent;

@class BOBetBox;
@class BOAsset;

@interface BODataManager : NSObject


+ (instancetype)shared;

-(void) start;

@property (strong, nonatomic) NSMutableArray *assets;
@property BOOL flagConnected;

-(void) sendParametersForAsset:(NSString *) assetId timeToGraph:(double) timeToGraph boxPriceWidth:(double) priceWidth boxTimeLength:(double) timeLength columns:(int) columns rows:(int)rows withCompletion:(void (^)(BOOL result)) completion;

-(void) requestCoeffsForPair:(NSString *) assetId withCompletion:(void (^)(NSArray *result)) completion;

-(void) sendLogEvent:(BOEvent) event message:(NSString *) message;

-(void) sendBetEventForBox:(BOBetBox *) box;

-(void) sendGameStartedEvent:(BOAsset *) asset;
-(void) sendSetBalance:(double) newBalance;

@end
