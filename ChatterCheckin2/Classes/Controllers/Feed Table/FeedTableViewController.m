//
//  FeedViewController.m
//  ChatterCheckin
//
//  Created by John Gifford on 10/8/12.
//  Copyright (c) 2012 Model Metrics. All rights reserved.
//

#import "FeedTableViewController.h"
#import "LoadingViewController.h"

#import "SFRestAPI.h"
#import "SFRestRequest.h"
#import "FeedTableViewCell.h"
#import "NSString+JSON.h"


@interface FeedTableViewController ()

@end

@implementation FeedTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FeedTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getFeed];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Class Methods

- (void)getFeed
{
	SFRestRequest* request = [[SFRestAPI sharedInstance] requestForResources];

    request.path = [NSString stringWithFormat:@"%@/chatter/feeds/record/me/feed-items/", request.path];
    
    [[LoadingViewController sharedController]addLoadingView:self.navigationController.view];
    
    [[SFRestAPI sharedInstance] send:request delegate:self];
    
}

#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    NSArray *records = [jsonResponse objectForKey:@"items"];
    NSLog(@"request:didLoadResponse: #records: %d", records.count);
    NSLog(@"%@",records);
    _dataRows = [[NSMutableArray alloc]initWithArray:records];
    [self.tableView reloadData];
    [[LoadingViewController sharedController]removeLoadingView];
}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    NSLog(@"request:didFailLoadWithError: %@", error);
    //add your failed error handling here
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    NSLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    NSLog(@"requestDidTimeout: %@", request);
    //add your failed error handling here
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _dataRows == nil ? 0 : [_dataRows count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *feedItem = [_dataRows objectAtIndex:indexPath.row];
    NSDictionary *body = [feedItem objectForKey:@"body"];
    NSString *bodyString = [body objectForKey:@"text"];
    
    UIFont *font = [UIFont systemFontOfSize:14.0];

    CGSize maxLabelSize = CGSizeMake(self.tableView.frame.size.width, 1000);
    
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:font forKey: NSFontAttributeName];
    
    CGSize labelSize = [bodyString boundingRectWithSize:maxLabelSize
                                                options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                             attributes:stringAttributes context:nil].size;
    return labelSize.height + 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    FeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSDictionary *feedItem = [_dataRows objectAtIndex:indexPath.row];
    //NSLog(@"feedItem: %@",feedItem);
    
    NSDictionary *body = [feedItem objectForKey:@"body"];
    //NSLog(@"body: %@",body);
    
    NSString *string = [body objectForKey:@"text"];
    cell.feedText.text = [string stringByReplacingAsciiCodes];
    //NSLog(@"text: %@",[body objectForKey:@"text"]);
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
}

@end
