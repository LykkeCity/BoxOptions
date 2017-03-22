//
//  BODataManager.h
//  BoxOptions
//
//  Created by Andrey Snetkov on 09/02/2017.
//  Copyright © 2017 Andrey Snetkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BODataManager : NSObject


+ (instancetype)shared;

-(void) start;

@property (strong, nonatomic) NSMutableArray *assets;
@property BOOL flagConnected;

-(void) sendParametersForAsset:(NSString *) assetId timeToGraph:(double) timeToGraph boxPriceWidth:(double) priceWidth boxTimeLength:(double) timeLength columns:(int) columns rows:(int)rows withCompletion:(void (^)(BOOL result)) completion;

-(void) requestCoeffsForPair:(NSString *) assetId withCompletion:(void (^)(NSArray *result)) completion;

@end
