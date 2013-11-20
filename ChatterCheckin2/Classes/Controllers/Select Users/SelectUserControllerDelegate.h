//
//  SelectUserControllerDelegate.h
//  ChatterCheckin2
//
//  Created by Jason Barker on 11/5/13.
//  Copyright (c) 2013 Salesforce.com. All rights reserved.
//

#ifndef ChatterCheckin2_SelectUserControllerDelegate_h
#define ChatterCheckin2_SelectUserControllerDelegate_h


@protocol SelectUserControllerDelegate <NSObject>

- (void) viewController: (UIViewController *) viewController didSelectUsers: (NSArray *) users;

@end


#endif
