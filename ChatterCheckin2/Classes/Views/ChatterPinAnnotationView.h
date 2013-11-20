//
//  ChatterPinAnnotationView.h
//  ChatterCheckin2
//
//  Created by Jason Barker on 11/1/13.
//  Copyright (c) 2013 Salesforce.com. All rights reserved.
//

#import <MapKit/MapKit.h>



@interface ChatterPinAnnotationView : MKAnnotationView

@property (nonatomic, strong) NSAttributedString *title;
@property (nonatomic, assign, getter = isCheckedIn) BOOL checkedIn;

@end
