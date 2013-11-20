//
//  CheckinViewController.m
//  ChatterCheckin2
//
//  Created by Jason Barker on 11/4/13.
//  Copyright (c) 2013 Salesforce.com. All rights reserved.
//

#import "CheckinViewController.h"
#import "CloudCalloutView.h"
#import "LoadingViewController.h"
#import "SelectUserViewControllerOrig.h"
#import "SelectUserViewController.h"
#import "User.h"



static CGFloat       TABLE_HEADER_HEIGHT    = 20;

static NSUInteger    LOCATION_ROW_INDEX     = 0;
static NSUInteger    STATUS_ROW_INDEX       = 1;
static NSUInteger    COWORKER_ROW_INDEX     = 2;

static CGFloat       STATUS_TEXTVIEW_VERTICAL_MARGIN    = 0;

static NSInteger     ERROR_ALERT_VIEW_TAG               = 111;



@interface CheckinViewController ()

@property (nonatomic, retain) NSArray *selectedUsers;
@property (nonatomic, retain) NSAttributedString *listOfCoworkers;

@end



@implementation CheckinViewController


/**
 *
 */
- (id) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        [self setTitle: @"Check-in"];
        
        UIBarButtonItem *postBtn = [[UIBarButtonItem alloc]initWithTitle:@"Post" style:UIBarButtonItemStyleBordered target:self action:@selector(post:)];
        [self.navigationItem setRightBarButtonItem:postBtn];
    }
    
    return self;
}


#pragma mark - View lifecycle


/**
 *
 */
- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, TABLE_HEADER_HEIGHT)];
    [view setBackgroundColor: [UIColor clearColor]];
    [self.detailsTableView setTableHeaderView: view];
    
    view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 1)];
    [view setBackgroundColor: [UIColor clearColor]];
    [self.detailsTableView setTableFooterView: view];
    
    [self configureStatusCell];
    
    CGRect frame = [self.statusTextView.layoutManager usedRectForTextContainer: self.statusTextView.textContainer];
    STATUS_TEXTVIEW_VERTICAL_MARGIN = self.statusTextView.frame.size.height - frame.size.height;
}


/**
 *
 */
- (void) viewWillAppear: (BOOL) animated {
    
    [super viewWillAppear: animated];
    
    [self.locationTextField setText: (self.location.length > 0 ? self.location : @"")];
    
    NSIndexPath *selectedIndexPath = self.detailsTableView.indexPathForSelectedRow;
    [self.detailsTableView reloadData];
    if (selectedIndexPath)
        [self.detailsTableView selectRowAtIndexPath: selectedIndexPath animated: NO scrollPosition: UITableViewScrollPositionNone];
    
}


/**
 *
 */
- (void) viewDidAppear: (BOOL) animated {
    
    [super viewDidAppear: animated];

    if (self.detailsTableView.indexPathForSelectedRow)
        [self.detailsTableView deselectRowAtIndexPath: self.detailsTableView.indexPathForSelectedRow animated: YES];
    else
        [self.statusTextView becomeFirstResponder];
    
}


#pragma mark -


/**
 *
 */
- (NSAttributedString *) buildCalloutTitle {
    
    UIFont          *boldFont   = [UIFont boldSystemFontOfSize: [CloudCalloutView calloutFontSize]];
    NSMutableArray  *boldRanges = [NSMutableArray array];
    CGFloat          maxHeight  = boldFont.lineHeight * [CloudCalloutView calloutTitleMaxNumberOfLines];
    NSMutableString *title      = [NSMutableString stringWithString: @"Me"];
    int              index      = 0;
    
    [boldRanges addObject: [NSValue valueWithRange: NSMakeRange(index, title.length - index)]];
    index += title.length;
    
    if (self.selectedUsers.count == 1) {
        
        User *user = [self.selectedUsers objectAtIndex: 0];
        NSString *string = [NSString stringWithFormat: @"%@ and %@", title, user.fullName];
        
        CGRect frame = [string boundingRectWithSize: CGSizeMake([CloudCalloutView calloutTitleLabelWidth], 1000)
                                            options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                         attributes: @{NSFontAttributeName : boldFont}
                                            context: nil];
        
        if (frame.size.height > maxHeight) {
            
            NSString *other = @"1 other";
            [title appendString: @" and "];
            index = title.length;
            [title appendString: other];
            [boldRanges addObject: [NSValue valueWithRange: NSMakeRange(index, other.length)]];
        }
        else {
            
            [title appendString: @" and "];
            index = title.length;
            [title appendString: user.fullName];
            [boldRanges addObject: [NSValue valueWithRange: NSMakeRange(index, user.fullName.length)]];
        }
    }
    else if (self.selectedUsers.count > 1) {
        
        for (int i = 0; i < self.selectedUsers.count; i++) {
            
            NSMutableString *string = [NSMutableString stringWithString: title];
            NSRange range = NSMakeRange(NSNotFound, 0);
            NSString *otherStr = nil;
            
            for (int j = 0; j <= i; j++) {
                
                if (j < (self.selectedUsers.count - 1))
                    [string appendString: @", "];
                else if (j > 0 && j == self.selectedUsers.count - 1)
                    [string appendString: @" and "];
                
                User *user = [self.selectedUsers objectAtIndex: j];
                range = NSMakeRange(string.length, user.fullName.length);
                [string appendString: user.fullName];
            }
            
            if (i < (self.selectedUsers.count - 1))
                otherStr = [NSString stringWithFormat: @" and %d %@", (self.selectedUsers.count - (i + 1)), (i == self.selectedUsers.count - 2 ? @"other" : @"others")];
            
            if (otherStr)
                [string appendString: otherStr];
            
            CGRect frame = [string boundingRectWithSize: CGSizeMake([CloudCalloutView calloutTitleLabelWidth], 1000)
                                                options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                             attributes: @{NSFontAttributeName : boldFont}
                                                context: nil];
            
            if (frame.size.height > maxHeight) {
                
                break;
            }
            else {
                
                title = [NSMutableString stringWithString: string];
                
                if (boldRanges.count > 1)
                    [boldRanges removeLastObject];      //  Remove the last range added for the previous otherStr.
                
                [boldRanges addObject: [NSValue valueWithRange: range]];
                
                if (otherStr)
                    [boldRanges addObject: [NSValue valueWithRange: NSMakeRange(string.length - otherStr.length + @" and ".length, otherStr.length - @" and ".length)]];
                
            }
        }
    }
    
    
    NSMutableAttributedString *listOfPeople = [[NSMutableAttributedString alloc] initWithString: title];
    for (NSValue *range in boldRanges)
        [listOfPeople addAttribute: NSFontAttributeName value: boldFont range: range.rangeValue];
    
    return listOfPeople;
}


/**
 *  This function builds an attributed string containing the full names of the users selected for
 *  inclusion in the post.
 */
- (void) buildListOfCoworkers {
    
    NSString        *coworkers  = nil;
    NSMutableArray  *boldRanges = [NSMutableArray array];
    UIFont          *boldFont   = [UIFont boldSystemFontOfSize: self.coworkerListLabel.font.pointSize];
    CGFloat          maxHeight  = self.coworkerListLabel.font.lineHeight * 2.125;
    
    for (int i = 0; i < self.selectedUsers.count; i++) {
        
        NSMutableString *listOfCoworkers = [NSMutableString stringWithFormat: @"With "];
        NSRange range = NSMakeRange(NSNotFound, 0);
        NSString *otherStr = nil;
        
        for (int j = 0; j <= i; j++) {
            
            if (j > 0 && j < (self.selectedUsers.count - 1))
                [listOfCoworkers appendString: @", "];
            else if (j > 0 && j == self.selectedUsers.count - 1)
                [listOfCoworkers appendString: @" and "];
            
            User *user = [self.selectedUsers objectAtIndex: j];
            range = NSMakeRange(listOfCoworkers.length, user.fullName.length);
            [listOfCoworkers appendString: user.fullName];
        }
        
        if (i < (self.selectedUsers.count - 1))
            otherStr = [NSString stringWithFormat: @" and %d %@", (self.selectedUsers.count - (i + 1)), (i == self.selectedUsers.count - 2 ? @"other" : @"others")];
        
        if (otherStr)
            [listOfCoworkers appendString: otherStr];
        
        CGRect frame = [listOfCoworkers boundingRectWithSize: CGSizeMake(self.coworkerListLabel.frame.size.width, 1000)
                                                     options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                  attributes: @{NSFontAttributeName : boldFont}
                                                     context: nil];
        
        if (frame.size.height > maxHeight) {
            
            break;
        }
        else {
            
            coworkers = [NSString stringWithString: listOfCoworkers];
            
            if (boldRanges.count > 0)
                [boldRanges removeLastObject];      //  Remove the last range added for the previous otherStr.
            
            [boldRanges addObject: [NSValue valueWithRange: range]];
            
            if (otherStr)
                [boldRanges addObject: [NSValue valueWithRange: NSMakeRange(listOfCoworkers.length - otherStr.length + @" and ".length, otherStr.length - @" and ".length)]];
            
        }
    }
    
    if (coworkers) {
        
        NSMutableAttributedString *listOfCoworkers = [[NSMutableAttributedString alloc] initWithString: coworkers];
        for (NSValue *range in boldRanges)
            [listOfCoworkers addAttribute: NSFontAttributeName value: boldFont range: range.rangeValue];
        
        [self setListOfCoworkers: listOfCoworkers];
        
        CGRect frame = [coworkers boundingRectWithSize: CGSizeMake(self.coworkerListLabel.frame.size.width, 1000)
                                               options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            attributes: @{NSFontAttributeName : boldFont}
                                               context: nil];
        
        CGRect labelFrame = self.coworkerListLabel.frame;
        labelFrame.size.height = ceilf(frame.size.height) + 4;
        [self.coworkerListLabel setFrame: labelFrame];
    }
    else {
        
        [self setListOfCoworkers: nil];
    }
}


/**
 *
 */
- (CGFloat) calculateHeightOfCoworkerCell {
    
    CGFloat height = (self.coworkerPlaceholderLabel.frame.origin.y * 2);
    
    if (self.selectedUsers.count == 0)
        height += self.coworkerPlaceholderLabel.font.lineHeight;
    else
        height += self.coworkerListLabel.frame.size.height;
    
    return height;
}


/**
 *
 */
- (void) configureStatusCell {
    
    BOOL isHidden = (self.statusTextView.text.length > 0);
    [self.statusPlaceholderLabel setHidden: isHidden];
}


/**
 *
 */
- (void) configureCoworkerCell {
    
    if (self.listOfCoworkers.length == 0) {
        
        [self.coworkerPlaceholderLabel setHidden: NO];
        [self.coworkerListLabel setHidden: YES];
    }
    else {
        
        [self.coworkerPlaceholderLabel setHidden: YES];
        [self.coworkerListLabel setHidden: NO];
        [self.coworkerListLabel setAttributedText: self.listOfCoworkers];
    }
}


#pragma mark - Actions


/**
 *
 */
- (IBAction) post: (id) sender {
    
    if ([self.statusTextView.text stringByReplacingOccurrencesOfString: @" " withString: @""].length > 0) {
        
        [self.locationTextField resignFirstResponder];
        [self.statusTextView resignFirstResponder];
        
        [[LoadingViewController sharedController] addLoadingView: self.navigationController.view withLabel: @"Posting..."];
        
        NSLog(@"_selectedUsers: %@", _selectedUsers);
        
        NSString *postString = nil;
        
        if ([self.locationTextField.text stringByReplacingOccurrencesOfString: @" " withString: @""].length > 0)
            postString = [NSString stringWithFormat: @"Checked in near %@ - %@", self.locationTextField.text, self.statusTextView.text];
        else
            postString = [NSString stringWithFormat: @"Checked in - %@",self.statusTextView.text];
        
        if (_selectedUsers.count > 0)
            postString = [postString stringByAppendingFormat:@" with: "];
        
        NSLog(@"%@", postString);
        
        SFRestRequest   *request    = [[SFRestAPI sharedInstance] requestForResources];
        NSString        *postUrl    = [NSString stringWithFormat:@"%@/chatter/feeds/news/me/feed-items",request.path];
        NSDictionary    *values     = [NSDictionary dictionaryWithObjectsAndKeys:@"Text", @"type", postString, @"text", nil];
        NSMutableArray  *segments   = [NSMutableArray arrayWithObject:values];
        
        for (User *user in _selectedUsers)
            [segments addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mention", @"type", user.userId, @"id", nil]];
        
        NSDictionary    *message    = [NSDictionary dictionaryWithObjectsAndKeys:segments, @"messageSegments", nil];
        NSDictionary    *params     = [NSDictionary dictionaryWithObjectsAndKeys:message, @"body", nil];
        SFRestRequest   *post       = [SFRestRequest requestWithMethod:SFRestMethodPOST path:postUrl queryParams:params];
        
        NSLog(@"post.path: %@",post.queryParams);
        
        [[SFRestAPI sharedInstance] send: post delegate: self];
        
    }
    else {
        
        [self displayError];
    }
}

- (void) displayError {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error!"
                                                    message: @"Please enter a status"
                                                   delegate: self
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];
    
    [alert setTag: ERROR_ALERT_VIEW_TAG];
    [alert show];
}

/**
 *
 */
- (IBAction) selectPeople: (id) sender {
    
	// Unoptimized user selection
//	SelectUserViewControllerOrig * msvc = [[SelectUserViewControllerOrig alloc] init];
	
	// Optimized user selection
    SelectUserViewController *msvc = [[SelectUserViewController alloc] init];
	
    [msvc setDelegate: self];
    [msvc setSelectedUsers: self.selectedUsers];
    [self.navigationController pushViewController: msvc animated: YES];
}


#pragma mark - UIAlertViewDelegate messages


/**
 *
 */
- (void) alertView: (UIAlertView *) alertView didDismissWithButtonIndex: (NSInteger) buttonIndex {
    
    if (alertView.tag == ERROR_ALERT_VIEW_TAG)
        [self.statusTextView becomeFirstResponder];
    
}


#pragma mark - UITableViewDataSource messages


/**
 *
 */
- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
    
    return 3;
}


/**
 *
 */
- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    
    CGFloat height = 0;
    
    if (indexPath.row == LOCATION_ROW_INDEX)
        height = self.locationCell.frame.size.height;
    else if (indexPath.row == STATUS_ROW_INDEX)
        height = self.statusCell.frame.size.height;
    else if (indexPath.row == COWORKER_ROW_INDEX)
        height = [self calculateHeightOfCoworkerCell];
    
    return height;
}


/**
 *
 */
- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    
    UITableViewCell *cell = nil;
    
    if (indexPath.row == LOCATION_ROW_INDEX) {
        
        cell = self.locationCell;
    }
    else if (indexPath.row == STATUS_ROW_INDEX) {
        
        cell = self.statusCell;
        [self configureStatusCell];
    }
    else if (indexPath.row == COWORKER_ROW_INDEX) {
        
        cell = self.coworkerCell;
        [self configureCoworkerCell];
    }
    
    return cell;
}


#pragma mark - UIScrollViewDelegate messages


/**
 *
 */
- (void) scrollViewDidScroll: (UIScrollView *) scrollView {
    
    if ([self.locationTextField isFirstResponder])
        [self.locationTextField resignFirstResponder];
    
}


#pragma mark - UITextViewDelegate messages


/**
 *
 */
- (void) textViewDidChange: (UITextView *) textView {
    
    if (textView == self.statusTextView) {
        
        [self configureStatusCell];
        
//          Allow status text field and table cell to grow or shrink vertically to accommodate text. (Get back to this if you have time.)
//          Currently, this has a bug where the last line of the text view will partially be missing on the left side when resizing the cell and text view.
//
//        CGRect frame = [self.statusTextView.layoutManager usedRectForTextContainer: self.statusTextView.textContainer];
//        CGFloat height = roundf(frame.size.height + STATUS_TEXTVIEW_VERTICAL_MARGIN) + (self.statusTextView.frame.origin.y * 2.0);
//        
//        if (self.statusCell.frame.size.height != height) {
//            
//            [self.detailsTableView beginUpdates];
//            frame = self.statusCell.frame;
//            frame.size.height = height;
//            [self.statusCell setFrame: frame];
//            [self.detailsTableView endUpdates];
//            
//            [self.statusTextView scrollRangeToVisible: NSMakeRange(0, self.statusTextView.text.length)];
//        }
    }
}


/**
 *
 */
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
    if (indexPath.row == COWORKER_ROW_INDEX) {
        
        if (self.locationTextField.isFirstResponder)
            [self.locationTextField resignFirstResponder];
        
        if (self.statusTextView.isFirstResponder)
            [self.statusTextView resignFirstResponder];
        
        [self selectPeople: self];
    }
}


#pragma mark - SelectUserControllerDelegate messages


/**
 *
 */
- (void) viewController: (UIViewController *) viewController didSelectUsers: (NSArray *) users {
    
    [self setSelectedUsers: users];
    [self buildListOfCoworkers];
}


#pragma mark - SFRestAPIDelegate messages


/**
 *
 */
- (void) request: (SFRestRequest *) request didLoadResponse: (id) jsonResponse {
    
    NSArray *records = [jsonResponse objectForKey: @"items"];
    NSLog(@"request:didLoadResponse: #records: %d", records.count);
    NSLog(@"%@", records);
    
    [[LoadingViewController sharedController] removeLoadingView];
    
    [self.mapViewController showCheckinWithTitle: [self buildCalloutTitle]];
    [self.navigationController popViewControllerAnimated: YES];
}


/**
 *
 */
- (void) request: (SFRestRequest *) request didFailLoadWithError: (NSError *) error {
    
    NSLog(@"request:didFailLoadWithError: %@", error);
    //add your failed error handling here
}


/**
 *
 */
- (void) requestDidCancelLoad: (SFRestRequest *) request {
    
    NSLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
}


/**
 *
 */
- (void) requestDidTimeout: (SFRestRequest *) request {
    
    NSLog(@"requestDidTimeout: %@", request);
    //add your failed error handling here
}


@end
