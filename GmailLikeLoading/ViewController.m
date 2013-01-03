//
//  ViewController.m
//  GmailLikeLoading
//
//  Created by Nikhil Gohil on 02/01/13.
//  Copyright (c) 2013 Nikhil Gohil. All rights reserved.
//

#import "ViewController.h"
#import "GmailLikeLoadingView.h"

@interface ViewController (){
    GmailLikeLoadingView *view;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clickButton setFrame:CGRectMake(35, 10, 250, 30)];
    [clickButton setBackgroundColor:[UIColor orangeColor]];
    [self.view addSubview:clickButton];
    [clickButton setTitle:@"Stop Animating" forState:UIControlStateNormal];
    [clickButton addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clickButton];
    
    view = [[GmailLikeLoadingView alloc] initWithFrame:CGRectMake(135, 150, 50, 50)];
    [self.view addSubview:view];
    
    [view startAnimating];
}

- (void)click:(UIButton*)btn{
    if (view.isAnimating) {
        [btn setTitle:@"Start Animating" forState:UIControlStateNormal];
        [view stopAnimating];
    }else{
        [btn setTitle:@"Stop Animating" forState:UIControlStateNormal];
        [view startAnimating];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
