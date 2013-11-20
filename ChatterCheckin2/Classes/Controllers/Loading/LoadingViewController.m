//
//  LoadingViewController.m
//  ChatterCheckin
//
//  Created by John Gifford on 10/31/12.
//  Copyright (c) 2012 Model Metrics. All rights reserved.
//

#import "LoadingViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface LoadingViewController ()

@end

@implementation LoadingViewController

static LoadingViewController * _sharedLoadingViewController = nil;

+ (LoadingViewController *)sharedController
{
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedLoadingViewController = [[[self class] alloc] init];
	});
	
	return _sharedLoadingViewController;
}

- (void)addLoadingView:(UIView *)view
{
    [_loadingLabel setText:@"Loading..."];
	self.view.frame = view.bounds;
    [view addSubview:self.view];
}

- (void)addLoadingView:(UIView *)view withLabel:(NSString *)label
{
    [_loadingLabel setText:label];
	self.view.frame = view.bounds;
    [view addSubview:self.view];
}

- (void)removeLoadingView
{
    [self.view removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _loadingBox.layer.cornerRadius = 10.0;
    [_loadingIndicator startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	
}

- (void)viewDidUnload {
    [self setLoadingBox:nil];
    [self setLoadingIndicator:nil];
    [self setLoadingLabel:nil];
    [super viewDidUnload];
}
@end
