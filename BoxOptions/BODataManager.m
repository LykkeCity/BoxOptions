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
#import "BoxOptions-Swift.h"
#import "BOBetBox.h"

#define kProductionServer @"boxoptions-api.lykke.com:5000"
#define kDevelopmentServer @"13.93.116.252:5050"



@import UIKit;

@interface BODataManager() <MDWampClientDelegate, MDWampTransportDelegate>
{
    MDWamp *wamp;
    
    
    UIAlertView *alertDisconnected;
    NSString *serverUrl;
    NSString *clientId;
}

@end

@implementation BODataManager

-(id) init {
    self = [super init];
    
    serverUrl = kDevelopmentServer;
    
    clientId = [[NSUserDefaults standardUserDefaults] objectForKey:@"ClientId"];
    if(!clientId) {
        clientId = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:clientId forKey:@"ClientId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }


    
    return self;
}

+ (instancetype)shared
{
    static BODataManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[BODataManager alloc] init];
        shared.flagConnected = false;
    });
    return shared;
}

-(void) start {
    
    MDWampTransportWebSocket *websocket = [[MDWampTransportWebSocket alloc] initWithServer:[NSURL URLWithString:[NSString stringWithFormat:@"ws://%@/ws", serverUrl]] protocolVersions:@[kMDWampProtocolWamp2msgpack, kMDWampProtocolWamp2json]];
//    
    wamp = [[MDWamp alloc] initWithTransport:websocket realm:@"box-options" delegate:self];

//    wamp = [[MDWamp alloc] initWithTransport:websocket realm:@"mtcrossbar" delegate:self];

    [wamp connect];
    
//    [self sendParameters:@{@"pair":@"EURUSD", @"timeToFirstOption":@(4000), @"optionLen":@(4000), @"priceSize":@(0.005), @"nPriceIndex":@(10), @"nTimeIndex":@(5)} withCompletion:^(BOOL result){
//        [self requestCoeffsWithCompletion:^(NSArray *finished){
//        
//        
//        }];
//    }];
    

}

- (void) mdwamp:(MDWamp*)wamp sessionEstablished:(NSDictionary*)info
{
    
    [self loadAssets];
    
    
}

// Called when client disconnect from the server
- (void) mdwamp:(MDWamp *)wamp closedSession:(NSInteger)code reason:(NSString*)reason details:(NSDictionary *)details
{
    NSLog(@"WAMP disconnected!!!");
    _flagConnected = false;
    
    if(alertDisconnected == nil) {
        alertDisconnected = [[UIAlertView alloc] initWithTitle:@"PLEASE WAIT" message:@"Connecting to server" delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
//        [alertDisconnected show];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WampDisconnected" object:nil];
    
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self start];
        });
    
}


-(void) loadAssets {
    
    [wamp call:@"init.chartdata" payload:@{} complete:^(MDWampResult *result, NSError *error){
        
        NSDictionary *dict=result.arguments[0];
        _assets = [[NSMutableArray alloc] init];
        
        NSArray *allowedAssets = @[@"EURUSD", @"EURAUD", @"EURCHF", @"EURGBP", @"EURJPY", @"USDCHF"];
        for(NSString *key in dict.allKeys) {
            
            if([allowedAssets containsObject:key] == NO) {
                continue;
            }
            
            NSArray *changes = dict[key];
            
            if([key isEqualToString:@"EURUSD"]) {
                NSLog(@"%@", changes);
            }
            
            BOAsset *newAsset = [BOAsset new];
            newAsset.identity = key;
            [_assets addObject:newAsset];


            for(NSDictionary *d in changes) {
                
                BORate *rate=[BORate new];
                rate.ask=[d[@"Ask"] doubleValue];
                rate.bid=[d[@"Bid"] doubleValue];
                rate.middle = (rate.ask + rate.bid) / 2;
                NSDate *date = [d[@"Date"] toDateWithMilliSeconds];
                rate.timestamp=[date timeIntervalSinceReferenceDate];
                
                [newAsset rateChanged:rate];
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AssetsListChanged" object:nil];
        });

        [self sendInitUser];
        [self startListeningForAssets];
        _flagConnected = true;

        
    }];
}


-(void) startListeningForAssets
{
//    [wamp subscribe:@"prices.update" onEvent:^(MDWampEvent *payload){} result:nil];
    
    
    
    
    [wamp subscribe:@"prices.update" onEvent:^(MDWampEvent *payload) {
        
//    [wamp subscribe:@"prices.update" options:nil onEvent:^(MDWampEvent *payload) {
        
//        NSLog(@"received an event %@", payload.arguments);

        // do something with the payload of the event
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
//            NSLog(@"received an event %@", payload.arguments);

            BOAsset *changedAsset=nil;
            
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
                rate.middle = (rate.ask + rate.bid) / 2;

                NSDate *date = [dict[@"Date"] toDateWithMilliSeconds];
                rate.timestamp=[date timeIntervalSinceReferenceDate];
//                rate.timestamp = [[NSDate date] timeIntervalSinceReferenceDate];
                
                BOOL flagFound = false;
                @synchronized (self) {

                for(BOAsset *asset in _assets)
                {
                    if([asset.identity isEqualToString:dict[@"Instrument"]])
                    {
//                        if([asset.identity isEqualToString:@"EURUSD"]) {
//                            NSLog(@"received an event %@", payload.arguments);
//                        }
                        flagWasChange = [asset rateChanged:rate];
                        
                        if(flagWasChange) {
                            changedAsset = asset;
                            
                        }
                        flagFound = YES;
                        break;
                    }
                }
            
                }
            }
//            _flagConnected = true;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [alertDisconnected dismissWithClickedButtonIndex:0 animated:true];
                alertDisconnected = nil;
                if(changedAsset)
                {
                    
                    if(changedAsset.previousRate) {
                        CGPoint point = CGPointMake((changedAsset.previousRate.ask + changedAsset.previousRate.bid)/2, (changedAsset.rate.ask + changedAsset.rate.bid)/2);
                        [[NSNotificationCenter defaultCenter] postNotificationName:[@"PricesChanged" stringByAppendingString:changedAsset.identity]  object:[NSValue valueWithCGPoint:point]];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"PricesChanged" object:nil];

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

//-(void) sendParameters111ForAsset:(NSString *) assetId timeToGraph:(double) timeToGraph boxPriceWidth:(double) priceWidth boxTimeLength:(double) timeLength columns:(int) columns rows:(int)rows withCompletion:(void (^)(BOOL result)) completion {
//
//    if(!token) {
//        token = [[NSUUID UUID] UUIDString];
//    }
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        NSString *urlString = [NSString stringWithFormat:@"http://%@/api/Coef/change?pair=%@&timeToFirstOption=%d&optionLen=%d&priceSize=%@&nPriceIndex=%d&nTimeIndex=%d&userId=%@", serverUrl, assetId, (int)(timeToGraph*1000), (int)(timeLength*1000), [@(priceWidth) stringValue], columns, rows, token];
//       
//        
//        NSURLResponse *responce;
//        NSError *error;
//        
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:&error];
//        
//        
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) responce;
//        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            completion(true);
//        });
//    
//    
//    });
//}

-(void) sendParametersForAsset:(NSString *) assetId timeToGraph:(double) timeToGraph boxPriceWidth:(double) priceWidth boxTimeLength:(double) timeLength columns:(int) columns rows:(int)rows withCompletion:(void (^)(BOOL result)) completion {
    
    
    NSDictionary *params = @{@"userId":clientId,
                             @"pair":assetId,
                             @"timeToFirstOption":@(timeToGraph*1000),
                             @"optionLen":@(timeLength*1000),
                             @"priceSize":@(priceWidth),
                             @"nPriceIndex": @(columns),
                             @"nTimeIndex": @(rows)};
                             
    
    
    [wamp call:@"coeffapi.changeparameters" payload:params complete:^(MDWampResult *result, NSError *error){
        NSLog(@"%@", result.arguments);
  
        completion(true);
    }];
    
    
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        NSString *urlString = [NSString stringWithFormat:@"http://%@/api/Coef/change?pair=%@&timeToFirstOption=%d&optionLen=%d&priceSize=%@&nPriceIndex=%d&nTimeIndex=%d&userId=%@", serverUrl, assetId, (int)(timeToGraph*1000), (int)(timeLength*1000), [@(priceWidth) stringValue], columns, rows, token];
//        
//        
//        NSURLResponse *responce;
//        NSError *error;
//        
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:&error];
//        
//        
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) responce;
//        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            completion(true);
//        });
//        
//        
//    });
}


//{
//    Ask = "121.426";
//    Bid = "121.426";
//    Date = "2017-03-17T11:31:41.379336Z";
//    Instrument = EURJPY;
//}

-(void) requestCoeffsForPair:(NSString *) assetId withCompletion:(void (^)(NSArray *result)) completion {
    NSDictionary *params = @{@"userId":clientId,
                             @"pair":assetId
                             };
    
    
    
    [wamp call:@"coeffapi.requestcoeff" payload:params complete:^(MDWampResult *result, NSError *error){
//        NSLog(@"%@", result.arguments);
                NSMutableArray *arr = [[NSMutableArray alloc] init];
        
        NSString *resString = result.arguments[0];
        NSData *data = [resString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSArray *resArr = [NSJSONSerialization JSONObjectWithData:data  options:0 error:nil];
        
                for(NSArray *rows in resArr) {
                    for(NSDictionary *d in rows) {
                        [arr addObject:d[@"hitCoeff"]];
                    }
                }

        completion(arr);
    }];

}

-(void) sendGameStartedEvent:(BOAsset *) asset {
    return;
    NSDictionary *params = @{@"userId":clientId,
                             @"assetPair":asset.identity };
    
    [wamp call:@"game.start" payload:params complete:^(MDWampResult *result, NSError *error){
        NSLog(@"%@", result.arguments);
    }];
}

-(void) sendInitUser {
    NSDictionary *params = @{@"userId":clientId};
    
    [wamp call:@"user.init" payload:params complete:^(MDWampResult *result, NSError *error){
        NSLog(@"%@", result.arguments);
        NSData *data = [result.arguments[0] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        for(NSDictionary *dict in arr) {
            NSLog(@"%@", dict);
            for(BOAsset *a in _assets) {
                if([a.identity isEqualToString:dict[@"AssetPair"]]) {
                    a.boxWidth = [dict[@"BoxWidth"] doubleValue];
                    
//                    a.boxWidth = 0.00001429;
                    
//                    a.boxWidth = a.boxWidth / 3;
                    
                    a.boxHeight = [dict[@"BoxHeight"] doubleValue];
                    a.boxesPerRow = [dict[@"BoxesPerRow"] intValue];
                    a.timeToFirstBox = [dict[@"TimeToFirstBox"] doubleValue];
                    break;
                }
            }
        }
        [self subscribeForUserTopic];
    }];
}

-(void) subscribeForUserTopic {
    
    [wamp subscribe:[@"game.events." stringByAppendingString:clientId] onEvent:^(MDWampEvent *payload) {
        NSString *boxId = payload.arguments[0][@"BoxId"];
        NSLog(@"%@", payload.arguments);
        NSArray *aaa = _assets;
        NSLog(@"%f", [NSDate timeIntervalSinceReferenceDate]);
        BOOL isWin = [payload.arguments[0][@"IsWin"] boolValue];
        int state = [payload.arguments[0][@"BetState"] intValue];
        if(isWin) {
            [[NSNotificationCenter defaultCenter] postNotificationName:[@"BoxWinWithId" stringByAppendingString:boxId] object:nil];
        }
        else if(state == 2) {
             [[NSNotificationCenter defaultCenter] postNotificationName:[@"BoxLoseWithId" stringByAppendingString:boxId] object:nil];
        }
        
    } result:^(NSError *error) {
        if(error)
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Failed to subscribe to user channel" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
        }
    }];
}

-(void) sendBetEventForBox:(BOBetBox *)box {
    
    
//    @{
//                                           @"Id":box.identity,
//                                           @"MinPrice":@(box.startPrice),
//                                           @"MaxPrice":@(box.endPrice),
//                                           @"TimeToGraph":@(box.timeToGraph),
//                                           @"TimeLength":@(box.timeLength),
//                                           @"Coefficient":@(box.coeff)
//                                           }
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{
                                                             @"Id":box.identity,
                                                             @"MinPrice":@(box.startPrice),
                                                             @"MaxPrice":@(box.endPrice),
                                                             @"TimeToGraph":@(box.timeToGraph),
                                                             @"TimeLength":@( box.timeLength),
                                                             @"Coefficient":@(box.coeff)
                                                             } options:0 error:nil];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSDictionary *params = @{@"userId":clientId,
                             @"betValue":@(box.betAmount),
                             @"assetPair":box.assetPair.identity,
                             @"box": string//@{
//                                     @"Id":box.identity,
//                                     @"MinPrice":@(box.startPrice),
//                                     @"MaxPrice":@(box.endPrice),
//                                     @"TimeToGraph":@(box.timeToGraph),
//                                     @"TimeLength":@(box.timeLength),
//                                     @"Coefficient":@(box.coeff)
//                                     }
                             };
    
//    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
//    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"Sending bet");
    [wamp call:@"game.placebet" payload:params complete:^(MDWampResult *result, NSError *error){
        NSLog(@"%@", result.arguments);
        NSDate *date = [result.arguments[0][@"BetTimeStamp"] toDateWithMilliSeconds];
        double timestamp=[date timeIntervalSinceReferenceDate];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:[@"BoxPlacedWithId" stringByAppendingString:box.identity] object:@(timestamp)];

    }];
    
}

-(void) sendSetBalance:(double) newBalance {
    [wamp call:@"user.setbalance" payload:@{@"userId": clientId,
                                          @"balance": @(newBalance)}
      complete:^(MDWampResult *result, NSError *error){
        NSLog(@"%@", result.arguments);
    }];
}


//-(void) requestCoeffsForPair:(NSString *) assetId withCompletion:(void (^)(NSArray *result)) completion {
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        NSString *urlString = [NSString stringWithFormat:@"http://%@/api/Coef/request?pair=%@&userId=%@", serverUrl, assetId, token];
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//        
//        NSHTTPURLResponse *response;
//        NSError *error;
//        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//        
//        NSInteger status = response.statusCode;
//        if(data == nil || data.length == 0) {
//            return;
//        }
//        NSArray *ddd = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        
//        NSMutableArray *arr = [[NSMutableArray alloc] init];
//        
//        for(NSArray *rows in ddd) {
//            for(NSDictionary *d in rows) {
//                [arr addObject:d[@"hitCoeff"]];
//            }
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            completion(arr);
//        });
//        
//        
//    });
//
//    
//}

-(void) sendLogEvent:(BOEvent)event message:(NSString *)message {
    if(!_flagConnected) {
        return;
    }
        NSString *eventMessage = message;
        
        if(!eventMessage) {
            eventMessage = @"";
        }
        
        NSDictionary *params = @{
                                 @"userId": clientId,
                                 @"eventCode":@(event),
                                 @"message": eventMessage
                                 };
    [wamp call:@"game.savelog" payload:params complete:^(MDWampResult *result, NSError *error){
          NSLog(@"%@", result.arguments);
      }];

}




@end
