//
//  BOBetBox.h
//  BoxOptions
//
//  Created by Andrey Snetkov on 30/05/2017.
//  Copyright © 2017 Andrey Snetkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BOAsset;
@class BOBetBox;

@protocol BOBetBoxDelegate

-(void) betBoxWon:(BOBetBox *) box;

@end

@interface BOBetBox : NSObject

@property double startPrice;
@property double endPrice;
@property double timeToGraph;
@property double timeLength;
@property (strong, nonatomic) BOAsset *assetPair;
@property double betAmount;
@property double coeff;

@property double timeNeeded; //for drawing

@property double timeStamp;

@property (strong, nonatomic) NSString *identity;

@property (weak, nonatomic) id <BOBetBoxDelegate> delegate;

-(BOOL) isWon;

@end
