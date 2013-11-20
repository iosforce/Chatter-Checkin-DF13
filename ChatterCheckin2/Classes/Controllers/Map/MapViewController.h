//
//  MapViewController.h
//  ChatterCheckin
//
//  Created by John Gifford on 10/9/12.
//  Copyright (c) 2012 Model Metrics. All rights reserved.
//

@class CheckinViewController;

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SFRestAPI.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, SFRestDelegate>
{
    MKMapView *_mapView;
    UIBarButtonItem *_checkinButton;
    CLLocationManager *_locationManager;
    CLLocationCoordinate2D _currentLocation;
    UIActivityIndicatorView *_spinner;
    NSString *_nextPageURL;
    NSDate *_startTime;
    NSDate *_endTime;
    int _counter;
    bool _geocoding;
    CheckinViewController *_cvc;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *checkinButton;

- (IBAction)performCoordinateGeocode:(id)sender;
- (void) showCheckinWithTitle: (NSAttributedString *) title;

@end

