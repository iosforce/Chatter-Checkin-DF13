//
//  MentionSelectorViewController.m
//  ChatterCheckin
//
//  Created by John Gifford on 10/9/12.
//  Copyright (c) 2012 Model Metrics. All rights reserved.
//

#import "SelectUserViewController.h"
#import "User.h"
#import "LoadingViewController.h"
#import "PlaceholderRow.h"
#import "LoadingCell.h"
#import "SFRestAPI+Blocks.h"

@interface SelectUserViewController ()
{
	BOOL _reloading;
}

@property (nonatomic, retain) NSMutableArray *selectedUsersInfo;

@end

@implementation SelectUserViewController

@synthesize selectedUsers = _selectedUsers;

- (id)init
{
    self = [super init];
    if (self) {
        [self setSelectedUsersInfo: [NSMutableArray array]];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self setSelectedUsersInfo: [NSMutableArray array]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle: @"Cancel" style: UIBarButtonItemStyleBordered target: self action: @selector(cancel:)];
    [self.navigationItem setLeftBarButtonItem: cancelButton];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style: UIBarButtonItemStyleBordered target: self action: @selector(done:)];
    [self.navigationItem setRightBarButtonItem: doneButton];

	if (_dataRows == nil) {
		_dataRows = [[NSMutableArray alloc] init];
	}
	
    if (_selectedUsers == nil) {
        _selectedUsers = [[NSMutableArray alloc] init];
    }

    [self setTitle:@"Users"];

    [self getUsers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tracking Selected Users

- (void)getUsers
{
	_reloading = YES;
	
	SFRestRequest* request = [[SFRestAPI sharedInstance] requestForResources];

    NSString *pathString = _nextPageURL != nil ? _nextPageURL : [NSString stringWithFormat:@"%@/chatter/users?pageSize=20",request.path];
    
    request.path = pathString;
    
	[self addLoadingCell];	
	[[SFRestAPI sharedInstance] send:request delegate:self];
}

- (void) setSelectedUsers:(NSArray *)selectedUsers {
    
    NSMutableArray *userIdentifiers = [[NSMutableArray alloc] init];
    for (User *user in selectedUsers)
        [userIdentifiers addObject: user.userId];
    
    _selectedUsers = userIdentifiers;
    
    if (selectedUsers)
        _selectedUsersInfo = [[NSMutableArray alloc] initWithArray: selectedUsers];
        
}

- (BOOL) isUserSelected: (User *) user {
    
    return [_selectedUsers containsObject: user.userId];
}

- (void) selectUser: (User *) user {
    
    if (![_selectedUsers containsObject: user.userId]) {
        [_selectedUsers addObject: user.userId];
        [_selectedUsersInfo addObject: user];
    }
}

- (void) deselectUser: (User *) user {
    
    NSUInteger index = [_selectedUsers indexOfObject: user.userId];
    
    [_selectedUsers removeObject: user.userId];
    [_selectedUsersInfo removeObjectAtIndex: index];
}

- (void) toggleSelectionForUser: (User *) user {
    
    if ([self isUserSelected: user])
        [self deselectUser: user];
    else
        [self selectUser: user];
    
}

#pragma mark -

- (void)processJson:(id)json {
	_nextPageURL = [json objectForKey:@"nextPageUrl"];
	
	int lastCount = _dataRows.count;
	
	// Process the new data
	_dataRows = [self processUsers:json];
	
	// Update the table
	[self updateTable:self.tableView
			 withData:_dataRows
	   sinceLastCount:lastCount];
	
	_reloading = NO;
}

#pragma mark - Actions

- (IBAction) cancel: (id) sender {
    
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction) done: (id) sender {
    
    if (self.delegate)
        [self.delegate viewController: self didSelectUsers: self.selectedUsersInfo];
    
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - Loading Cell Updates

// Add loading cell at the last position in the table
- (void)addLoadingCell {
	
	// Create a spot in the data source for the cell
	[_dataRows addObject:[[PlaceholderRow alloc] init]];
	
	// Update the table to display the cell
	if(_dataRows.count == 1) {
		[self.tableView reloadData];
	} else {
		[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_dataRows.count-1 inSection:0]]
							  withRowAnimation:UITableViewRowAnimationFade];
	}
}

// UIScrollView Deletegate used here to help with getting the next page
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	// If the user scrolls near the end of the table, start getting the next page of records
	NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
	BOOL shouldGetNextPage = (maximumOffset - scrollView.contentOffset.y) <= 240.0;
	
	if (shouldGetNextPage && !_reloading) {
		if ((NSNull *)_nextPageURL != [NSNull null]) {
			NSLog(@"getting next page: %@", _nextPageURL);
			[self getUsers];
		}
	}
}

// Inserts the new page of data into the table, removing and loading cells in the process
- (void)updateTable:(UITableView *)table withData:(NSMutableArray *)array sinceLastCount:(int)lastCount {
	
	int deleteIndex;
	NSMutableArray * newPaths = [NSMutableArray array];
	NSMutableArray * deletePaths = [NSMutableArray array];
	
	// Find and remove the loading cell, if existing
	for (int x = 0; x < array.count; x++) {
		if ([[array objectAtIndex:x] isKindOfClass:[PlaceholderRow class]]) {
			[deletePaths addObject:[NSIndexPath indexPathForRow:x inSection:0]];
			deleteIndex = x;
			break;
		}
	}
	
	if(deletePaths.count) {
		[array removeObjectAtIndex:deleteIndex];
		lastCount -= 1;
	}
	
	// Insert new indexes
	for (int x = lastCount; x < array.count; x++) {
		[newPaths addObject:[NSIndexPath indexPathForRow:x inSection:0]];
	}
	
	// Finally perform batch updates
	[table beginUpdates];
	if(deletePaths.count) {
		[table deleteRowsAtIndexPaths:deletePaths withRowAnimation:UITableViewRowAnimationFade];
	}
    [table insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationFade];
	[table endUpdates];
}


#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    
	// Grab URL to next page of records
	_nextPageURL = [jsonResponse objectForKey:@"nextPageUrl"];
	
    NSLog(@"Got Response: %@",jsonResponse);
	int lastCount = _dataRows.count;
	
	// Process the new data
	_dataRows = [self processUsers:jsonResponse];
	
	// Update the table
	[self updateTable:self.tableView
			 withData:_dataRows
	  sinceLastCount:lastCount];
	
    _reloading = NO;
}

//TODO: error handling
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

- (NSDictionary *)getUserForIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *following = [_dataRows objectAtIndex:indexPath.row];
    NSLog(@"following: %@",following);
    
    NSDictionary *user = [following objectForKey:@"subject"];
    NSLog(@"user: %@",user);
    
    return user;
}


#pragma mark - Response Parsing

- (NSMutableArray *)processUsers:(id)jsonResponse {
    NSArray *records = [jsonResponse objectForKey:@"users"];
    
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES];
    for (NSDictionary *user in [records sortedArrayUsingDescriptors:@[sortDescriptor]]) {
        
        User *newUser = [[User alloc] init];
        newUser.fullName = [user objectForKey:@"name"];
        newUser.userId = [user objectForKey:@"id"];
        
        [_dataRows addObject:newUser];
	}
	
	return _dataRows;
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	id object = [_dataRows objectAtIndex:indexPath.row];
	UITableViewCell * cell = nil;
	if ([object isKindOfClass:[PlaceholderRow class]]) {
		static NSString *LoadingCellIdentifier = @"LoadingCell";
		cell = (LoadingCell*)[tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier];
		if (cell == nil) {
			cell = (LoadingCell*)[[LoadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadingCellIdentifier];
		}
	} else {
		static NSString *CellIdentifier = @"Cell";
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
		
		User * user = [_dataRows objectAtIndex:indexPath.row];
		
		if ([self isUserSelected: user]) {
			[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
		} else {
			[cell setAccessoryType:UITableViewCellAccessoryNone];
		}
		
		cell.textLabel.text = user.fullName;
	}
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    User * user = [_dataRows objectAtIndex:indexPath.row];
    [self toggleSelectionForUser: user];
    
    [self.tableView reloadData];
}

#pragma mark - Search Query

- (void)performSearchFor:(NSString *)searchString {
	_reloading = YES;
	
	SFRestRequest* request = [[SFRestAPI sharedInstance] requestForResources];
    
    NSString *pathString = [NSString stringWithFormat:@"%@/chatter/users?q=%@&pageSize=50",request.path,searchString];
    
    request.path = pathString;
    
    NSLog(@"Search Path: %@",request.path);
	
	[self addLoadingCell];
	[[SFRestAPI sharedInstance] send:request delegate:self];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	searchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	searchBar.showsCancelButton = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	NSLog(@"Search bar clicked: %@",searchBar.text);
	_nextPageURL = nil;
	[_dataRows removeAllObjects];
	[self.tableView reloadData];
	[self performSearchFor:searchBar.text];
	[searchBar resignFirstResponder];

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	_nextPageURL = nil;
	[_dataRows removeAllObjects];
	[self.tableView reloadData];
	[self getUsers];
}

@end
