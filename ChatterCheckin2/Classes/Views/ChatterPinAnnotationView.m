//
//  ChatterPinAnnotationView.m
//  ChatterCheckin2
//
//  Created by Jason Barker on 11/1/13.
//  Copyright (c) 2013 Salesforce.com. All rights reserved.
//

#import "ChatterPinAnnotationView.h"
#import "CloudCalloutView.h"



static CGPoint CHATTER_PIN_CENTER_OFFSET = {4.0, -18.0};
static CGPoint CHATTER_PIN_CALLOUT_OFFSET = {-4.0, 10.0};


@interface ChatterPinAnnotationView ()

@property (nonatomic, strong) CloudCalloutView *cloudCalloutView;

@end



@implementation ChatterPinAnnotationView

/**
 *
 */
- (id) initWithAnnotation: (id <MKAnnotation>) annotation reuseIdentifier: (NSString *) reuseIdentifier {
    
    self = [super initWithAnnotation: annotation reuseIdentifier: reuseIdentifier];
    
    if (self) {
        
        [self setImage: [UIImage imageNamed: @"chatterPin"]];
        [self setCenterOffset: CHATTER_PIN_CENTER_OFFSET];
        [self setCanShowCallout: YES];
        [self setCalloutOffset: CHATTER_PIN_CALLOUT_OFFSET];
    }
    
    return self;
}


/**
 *
 */
- (id) initWithFrame: (CGRect) frame {
    
    self = [super initWithFrame: frame];
    
    if (self) {
        
        [self setCheckedIn: NO];
    }
    
    return self;
}


/**
 *
 */
- (CloudCalloutView *) cloudCalloutView {
    
    if (!_cloudCalloutView)
        _cloudCalloutView = [[CloudCalloutView alloc] init];
    
    return _cloudCalloutView;
}


/**
 *
 */
- (void) setCheckedIn: (BOOL) checkedIn {
    
    _checkedIn = checkedIn;
    [self setCanShowCallout: !_checkedIn];
}


/**
 *
 */
- (void) setSelected: (BOOL) selected animated: (BOOL) animated {
    
    [super setSelected: selected animated: animated];
    
    if (selected && self.isCheckedIn) {
        
        [self.cloudCalloutView setHidden: YES];
        [self.cloudCalloutView setTitle: self.title];
        
        CGRect frame = self.cloudCalloutView.frame;
        frame.origin.x = (self.frame.size.width / 2.0) + self.calloutOffset.x - self.cloudCalloutView.anchorPoint.x;
        frame.origin.y = self.calloutOffset.y - self.cloudCalloutView.anchorPoint.y;
        [self.cloudCalloutView setFrame: frame];
        [self addSubview: self.cloudCalloutView];
        
        [self.cloudCalloutView show];
    }
    else {
        
        if (self.cloudCalloutView.superview) {
            
            [UIView animateWithDuration: 0.1
                             animations: ^{
                                 [self.cloudCalloutView setAlpha: 0];
                             }
                             completion: ^(BOOL finished) {
                                 [self.cloudCalloutView removeFromSuperview];
                                 [self.cloudCalloutView setAlpha: 1];
                             }];
        }
    }
}


@end
