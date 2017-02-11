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



@end
