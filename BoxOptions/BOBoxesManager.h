//
//  BOBoxesManager.h
//  BoxOptions
//
//  Created by Andrey Snetkov on 08/06/2017.
//  Copyright © 2017 Andrey Snetkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOBetBox.h"

@interface BOBoxesManager : NSObject

-(NSArray *) activeBoxesForAsset:(NSString *) assetId;

-(void) addBox:(BOBetBox *) box;

+ (instancetype)shared;

@end
