//
//  ViewController.m
//  BoxOptions
//
//  Created by Andrey Snetkov on 09/02/2017.
//  Copyright © 2017 Andrey Snetkov. All rights reserved.
//

#import "ViewController.h"
#import "BODataManager.h"
#import "BoxOptions-Swift.h"
#import "BONavigationController.h"
#import "BOBetBox.h"
#import "BOAsset.h"
//#import <LOTAnimationView.h>
#import "Lottie.h"

@interface ViewController ()
{
    int count;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    count = 0;
    
    [[BODataManager shared] start];
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self sendEvent];
//     });
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void) sendEvent {
    if(count < 100) {
        BOBetBox *bb = [[BOBetBox alloc] init];
        bb.identity = @"kjdskjsd";
        BOAsset *aaa = [[BOAsset alloc] init];
        aaa.identity = @"EURUSD";
        bb.assetPair = aaa;
        [BODataManager.shared sendBetEventForBox:bb];
        count++;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendEvent];
        });
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    
    LOTAnimationView *animation = [LOTAnimationView animationNamed:@"data"];
    animation.frame = self.view.bounds;
    
//    animation.frame = CGRectMake(0, 0, 320, 320);
    animation.contentMode = UIViewContentModeScaleAspectFit;
    
    
    [self.view addSubview:animation];
    [animation playWithCompletion:^(BOOL animationFinished) {
        
        
        BOAssetsTablePresenter *presenter = [[BOAssetsTablePresenter alloc] initWithNibName:@"BOAssetsTablePresenter" bundle:[NSBundle mainBundle]];
//        [self presentViewController:presenter animated:YES completion:nil];
        
        
        BONavigationController *navController = [[BONavigationController alloc] initWithRootViewController:presenter];
        [navController setNavigationBarHidden:YES];
        [self presentViewController:navController animated:NO completion:nil];

//        [self pushViewController:presenter animated:YES];

    }];
}

-(UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


@end
