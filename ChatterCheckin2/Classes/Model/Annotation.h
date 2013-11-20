//
//  AddressAnnotation.h
//  ChatterCheckin
//
//  Created by John Gifford on 10/15/13.
//  Copyright (c) 2013 Model Metrics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Annotation : NSObject <MKAnnotation> {
    NSString *_title;
    NSString *_subtitle;
    
    CLLocationCoordinate2D _coordinate;
}

- (void)setTitle:(NSString *)title;
- (void)setSubtitle:(NSString *)subtitle;
- (id)initWithCoordinate:(CLLocationCoordinate2D)c;

@end
