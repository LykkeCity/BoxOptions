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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[BODataManager shared] start];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    BOAssetsTablePresenter *presenter = [[BOAssetsTablePresenter alloc] initWithNibName:@"BOAssetsTablePresenter" bundle:[NSBundle mainBundle]];
    [self presentViewController:presenter animated:YES completion:nil];
    
}


@end