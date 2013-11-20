//
//  FeedViewController.h
//  ChatterCheckin
//
//  Created by John Gifford on 10/8/12.
//  Copyright (c) 2012 Model Metrics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"

@interface FeedTableViewController : UITableViewController <SFRestDelegate> {
    NSMutableArray *_dataRows;
}

@end
