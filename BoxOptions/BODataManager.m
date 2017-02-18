//
//  BODataManager.m
//  BoxOptions
//
//  Created by Andrey Snetkov on 09/02/2017.
//  Copyright © 2017 Andrey Snetkov. All rights reserved.
//

#import "BODataManager.h"
#import "MDWamp.h"
#import "BORate.h"
#import "BOAsset.h"
#import "NSString+Date.h"

@import UIKit;

@interface BODataManager() <MDWampClientDelegate, MDWampTransportDelegate>
{
    MDWamp *wamp;
}

@end

@implementation BODataManager

+ (instancetype)shared
{
    static BODataManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[BODataManager alloc] init];
        
    });
    return shared;
}

-(void) start {
    MDWampTransportWebSocket *websocket = [[MDWampTransportWebSocket alloc] initWithServer:[NSURL URLWithString:@"ws://13.93.116.252:5000/ws"] protocolVersions:@[kMDWampProtocolWamp2msgpack, kMDWampProtocolWamp2json]];
    
    
    wamp = [[MDWamp alloc] initWithTransport:websocket realm:@"mtcrossbar" delegate:self];
    
    [wamp connect];

}

- (void) mdwamp:(MDWamp*)wamp sessionEstablished:(NSDictionary*)info
{
    
    [self loadAssets];
    
    
}

-(void) loadAssets {
    
    [wamp call:@"init.chartdata" payload:@{} complete:^(MDWampResult *result, NSError *error){
        
        NSDictionary *dict=result.arguments[0];
        _assets = [[NSMutableArray alloc] init];
        
        for(NSString *key in dict.allKeys) {
            
            NSArray *changes = dict[key];
            
            BOAsset *newAsset = [BOAsset new];
            newAsset.identity = key;
            [_assets addObject:newAsset];


            for(NSDictionary *d in changes) {
                
                BORate *rate=[BORate new];
                rate.ask=[d[@"Ask"] doubleValue];
                rate.bid=[d[@"Bid"] doubleValue];
                NSDate *date = [d[@"Date"] toDateWithMilliSeconds];
                rate.timestamp=[date timeIntervalSinceReferenceDate];
                
                [newAsset rateChanged:rate];
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AssetsListChanged" object:nil];
        });

        
        [self startListeningForAssets];
        
    }];
}


-(void) startListeningForAssets
{
    
    [wamp subscribe:@"prices.update" options:nil onEvent:^(MDWampEvent *payload) {
        
//        NSLog(@"received an event %@", payload.arguments);

        // do something with the payload of the event
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString *changedAssetId=nil;
            
            BOOL flagWasChange = false;
            
            if(payload.arguments.count==1)
            {
                if(!_assets)
                {
                    _assets = [[NSMutableArray alloc] init];
                }
                
                NSDictionary *dict=payload.arguments[0];
                
                
                BORate *rate=[BORate new];
                rate.ask=[dict[@"Ask"] doubleValue];
                rate.bid=[dict[@"Bid"] doubleValue];
                NSDate *date = [dict[@"Date"] toDateWithMilliSeconds];
                rate.timestamp=[date timeIntervalSinceReferenceDate];

                
                BOOL flagFound = false;
                @synchronized (self) {

                for(BOAsset *asset in _assets)
                {
                    if([asset.identity isEqualToString:dict[@"Instrument"]])
                    {
                        flagWasChange = [asset rateChanged:rate];
                        
                        
                        
                        //                        if([asset.identity isEqualToString:@"BTCCHF"]) //testing
                        //                        {
                        //                            NSLog(@"received an event %@", payload.arguments);
                        //                        }
                        if(flagWasChange) {
                            changedAssetId=asset.identity;
                            
                            if([changedAssetId isEqualToString:@"CHFJPY"]) {
//                                NSLog(@"received an event %@", payload.arguments);

                            }
                        }
                        flagFound = YES;
                        break;
                    }
                }
                if(flagFound == false) {
                    BOAsset *newAsset = [BOAsset new];
                    newAsset.identity = dict[@"Instrument"];
                    
                    [newAsset rateChanged:rate];
                    [_assets addObject:newAsset];
                    
                }
            
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if(changedAssetId)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:[@"PricesChanged" stringByAppendingString:changedAssetId]  object:nil];
                }
                
            });
            
        });
        
    } result:^(NSError *error) {
        if(error)
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Failed to subscribe to prices update channel" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
        }
    }];
    
    
    
}



@end
