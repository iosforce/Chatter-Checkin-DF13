//
//  CheckinViewController.h
//  ChatterCheckin2
//
//  Created by Jason Barker on 11/4/13.
//  Copyright (c) 2013 Salesforce.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"
#import "SelectUserControllerDelegate.h"
#import "MapViewController.h"



@interface CheckinViewController : UIViewController <UIAlertViewDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, SelectUserControllerDelegate, SFRestDelegate>

@property (nonatomic, copy) NSString *location;

@property (weak, nonatomic) IBOutlet UITableView *detailsTableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *locationCell;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (strong, nonatomic) IBOutlet UITableViewCell *statusCell;
@property (weak, nonatomic) IBOutlet UILabel *statusPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UITextView *statusTextView;
@property (strong, nonatomic) IBOutlet UITableViewCell *coworkerCell;
@property (weak, nonatomic) IBOutlet UILabel *coworkerPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UILabel *coworkerListLabel;
@property (weak, nonatomic) MapViewController *mapViewController;

@end
