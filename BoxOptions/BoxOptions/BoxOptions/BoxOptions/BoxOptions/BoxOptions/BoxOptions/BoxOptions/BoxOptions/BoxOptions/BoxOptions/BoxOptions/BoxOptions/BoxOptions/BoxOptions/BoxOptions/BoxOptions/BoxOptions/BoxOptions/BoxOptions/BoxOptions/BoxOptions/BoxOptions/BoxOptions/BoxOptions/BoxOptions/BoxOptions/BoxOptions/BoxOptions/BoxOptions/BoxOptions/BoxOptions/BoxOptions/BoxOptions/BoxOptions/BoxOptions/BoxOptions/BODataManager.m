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

@import UIKit;

@interface BODataManager() <MDWampClientDelegate, MDWampTransportDelegate>
{
    MDWamp *wamp;
    
    NSString *token;
    UIAlertView *alertDisconnected;
}

@end

@implementation BODataManager

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
 //   MDWampTransportWebSocket *websocket = [[MDWampTransportWebSocket alloc] initWithServer:[NSURL URLWithString:@"ws://lke-mt-dev-api.azurewebsites.net:80/ws"] protocolVersions:@[kMDWampProtocolWamp2msgpack, kMDWampProtocolWamp2json]];
    
    MDWampTransportWebSocket *websocket = [[MDWampTransportWebSocket alloc] initWithServer:[NSURL URLWithString:@"ws://boxoptions-api.lykke.com:5000/ws"] protocolVersions:@[kMDWampProtocolWamp2msgpack, kMDWampProtocolWamp2json]];
    
    wamp = [[MDWamp alloc] initWithTransport:websocket realm:@"box-options" delegate:self];
    
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
        [alertDisconnected show];
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
//    [wamp subscribe:@"prices.update" onEvent:^(MDWampEvent *payload){} result:nil];
    
    
    
    
    [wamp subscribe:@"prices.update" onEvent:^(MDWampEvent *payload) {
        
//    [wamp subscribe:@"prices.update" options:nil onEvent:^(MDWampEvent *payload) {
        
        NSLog(@"received an event %@", payload.arguments);

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
                NSDate *date = [dict[@"Date"] toDateWithMilliSeconds];
                rate.timestamp=[date timeIntervalSinceReferenceDate];

                
                BOOL flagFound = false;
                @synchronized (self) {

                for(BOAsset *asset in _assets)
                {
                    if([asset.identity isEqualToString:dict[@"Instrument"]])
                    {
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
            _flagConnected = true;
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

-(void) sendParametersForAsset:(NSString *) assetId timeToGraph:(double) timeToGraph boxPriceWidth:(double) priceWidth boxTimeLength:(double) timeLength columns:(int) columns rows:(int)rows withCompletion:(void (^)(BOOL result)) completion {

    if(!token) {
        token = [[NSUUID UUID] UUIDString];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // http://13.94.249.22:8800/change?pair=EURUSD&timeToFirstOption=40000&optionLen=40000&priceSize=0.0005&nPriceIndex=20&nTimeIndex=20
        NSString *urlString = [NSString stringWithFormat:@"http://13.94.249.22:8800/change?pair=%@&timeToFirstOption=%d&optionLen=%d&priceSize=%@&nPriceIndex=%d&nTimeIndex=%d&userId=%@", assetId, (int)(timeToGraph*1000), (int)(timeLength*1000), [@(priceWidth) stringValue], columns, rows, token];
//        NSString *urlString = [NSString stringWithFormat:@"http://boxoptions-api.lykke.com:5000/change?pair=%@&timeToFirstOption=%d&optionLen=%d&priceSize=%@&nPriceIndex=%d&nTimeIndex=%d&userId=%@", assetId, (int)(timeToGraph*1000), (int)(timeLength*1000), [@(priceWidth) stringValue], columns, rows, token];
       
        
        
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(true);
        });
    
    
    });
}

//{
//    Ask = "121.426";
//    Bid = "121.426";
//    Date = "2017-03-17T11:31:41.379336Z";
//    Instrument = EURJPY;
//}


-(void) requestCoeffsForPair:(NSString *) assetId withCompletion:(void (^)(NSArray *result)) completion {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // http://13.94.249.22:8800/change?pair=EURUSD&timeToFirstOption=40000&optionLen=40000&priceSize=0.0005&nPriceIndex=20&nTimeIndex=20
        NSString *urlString = [NSString stringWithFormat:@"http://13.94.249.22:8800/request?pair=%@&userId=%@", assetId, token];
//        NSString *urlString = [NSString stringWithFormat:@"http://boxoptions-api.lykke.com/request?pair=%@&userId=%@", assetId, token];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        
        NSHTTPURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSInteger status = response.statusCode;
        if(data == nil || data.length == 0) {
            return;
        }
        NSArray *ddd = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        
        for(NSArray *rows in ddd) {
            for(NSDictionary *d in rows) {
                [arr addObject:d[@"hitCoeff"]];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(arr);
        });
        
        
    });

    
}

+(void) sendLogEvent:(BOEvent)event message:(NSString *)message {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
//        NSString *urlString =  @"http://boxoptions-dev-api.azurewebsites.net/api/Log";
        NSString *urlString =  @"http://boxoptions-api.lykke.com:5000/api/Log";
        
        
        
        NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        
            [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        NSString *clientId = [[NSUserDefaults standardUserDefaults] objectForKey:@"ClientId"];
        if(!clientId) {
            clientId = [[NSUUID UUID] UUIDString];
            [[NSUserDefaults standardUserDefaults] setObject:clientId forKey:@"ClientId"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        NSString *eventMessage = message;
        
        if(!eventMessage) {
            eventMessage = @"";
        }
        
        NSDictionary *params = @{
                                 @"ClientId": clientId,
                                 @"EventCode":@(event),
                                 @"Message": eventMessage
                                 };
        
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
            
            request.HTTPBody = jsonData;
            
        

        
        NSURLResponse *responce;
        NSError *error;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:&error];
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) responce;
        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
        
        if(data) {
            NSArray *ddd = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@", ddd);
        }
    
    
    });
}




@end
