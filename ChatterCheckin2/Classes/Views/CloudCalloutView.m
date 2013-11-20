//
//  CloudCalloutView.m
//  CloudsMap
//
//  Created by Jason Barker on 11/9/13.
//  Copyright (c) 2013 Jason Barker. All rights reserved.
//

#import "CloudCalloutView.h"
#import "CAAnimation+Blocks.h"



static CGFloat  CLOUD_OUTLINE_WIDTH         = 3.0;
static CGSize   CLOUD_SIZE                  = {182.0, 128.0};
static CGPoint  CLOUD_ANIMATION_ORIGIN      = {91.0, 120.0};
static float    CLOUD_ANIMATION_DURATION    = 0.6;
static float    TITLE_ANIMATION_DURATION    = 0.19;
static CGFloat  DEFAULT_CALLOUT_FONT_SIZE   = 15.0;
static int      TITLE_MAX_NUMBER_OF_LINES   = 3;
static CGRect   TITLE_LABEL_FRAME           = {{27.0, 32.0}, {135.0, 61.0}};



@interface CloudCalloutView ()

@property (nonatomic, strong) NSMutableArray *outlineLayers;        //  blue circles that make up the outlines around the cloud
@property (nonatomic, strong) NSMutableArray *circleLayers;         //  white circles around perimeter of the cloud
@property (nonatomic, strong) UILabel *titleLabel;

@end



@implementation CloudCalloutView


/**
 *
 */
+ (CGFloat) calloutFontSize {
    
    return DEFAULT_CALLOUT_FONT_SIZE;
}


/**
 *
 */
+ (int) calloutTitleMaxNumberOfLines {
    
    return TITLE_MAX_NUMBER_OF_LINES;
}


/**
 *
 */
+ (CGFloat) calloutTitleLabelWidth {
    
    return TITLE_LABEL_FRAME.size.width;
}


/**
 *
 */
- (id) init {
    
    return [self initWithFrame: CGRectZero];
}


/**
 *
 */
- (id) initWithFrame: (CGRect) frame {
    
    CGRect f = CGRectMake(frame.origin.x, frame.origin.y, CLOUD_SIZE.width, CLOUD_SIZE.height);
    
    self = [super initWithFrame: f];
    
    if (self) {
        
        [self setOutlineLayers: [NSMutableArray array]];
        [self setCircleLayers: [NSMutableArray array]];
        
        [self setHidden: YES];
        [self buildCloud];
    }
    
    return self;
}


/**
 *
 */
- (CGPoint) anchorPoint {
    
    return CLOUD_ANIMATION_ORIGIN;
}


/**
 *
 */
- (void) buildCloud {
    
    //  Build circles for cloud
    
    NSArray *centerPoints = [NSArray arrayWithObjects:
                             [NSValue valueWithCGPoint: CGPointMake( 49.0, 37.0)],
                             [NSValue valueWithCGPoint: CGPointMake( 99.0, 38.0)],
                             [NSValue valueWithCGPoint: CGPointMake(143.0, 58.0)],
                             [NSValue valueWithCGPoint: CGPointMake(111.0, 82.0)],
                             [NSValue valueWithCGPoint: CGPointMake( 68.0, 95.0)],
                             [NSValue valueWithCGPoint: CGPointMake( 32.0, 76.0)],
                             [NSValue valueWithCGPoint: CGPointMake( 72.0, 65.0)],
                             [NSValue valueWithCGPoint: CGPointMake(110.0, 58.0)],
                             nil];
    
    NSArray *radii = @[@(32.5), @(29.0), @(36.0), @(26.5), @(29.5), @(28.0), @36.0, @24.0];
    
    UIColor *blueColor = [UIColor colorWithRed: (100.0 / 255.0) green: (178.0 / 255.0) blue: (217.0 / 255.0) alpha: 1];
    
    for (int i = 0; i < centerPoints.count; i++) {
        
        CGPoint center = ((NSValue *) [centerPoints objectAtIndex: i]).CGPointValue;
        CGFloat radius = ((NSNumber *) [radii objectAtIndex: i]).floatValue;
        CGRect  rect   = CGRectMake(center.x - radius, center.y - radius, radius * 2.0, radius * 2.0);
        
        CAShapeLayer *circle = [CAShapeLayer layer];
        [circle setBounds: self.bounds];
        [circle setPath: [UIBezierPath bezierPathWithOvalInRect: rect].CGPath];
        [circle setPosition: CLOUD_ANIMATION_ORIGIN];
        [circle setFillColor: [UIColor whiteColor].CGColor];
        [circle setAnchorPoint: CGPointMake(0.5, 0.9375)];
        [self.circleLayers addObject: circle];
        
        rect = CGRectMake(center.x - radius - CLOUD_OUTLINE_WIDTH, center.y - radius - CLOUD_OUTLINE_WIDTH, (radius + CLOUD_OUTLINE_WIDTH) * 2.0, (radius + CLOUD_OUTLINE_WIDTH) * 2.0);
        circle = [CAShapeLayer layer];
        [circle setBounds: self.bounds];
        [circle setPath: [UIBezierPath bezierPathWithOvalInRect: rect].CGPath];
        [circle setPosition: CLOUD_ANIMATION_ORIGIN];
        [circle setFillColor: blueColor.CGColor];
        [circle setAnchorPoint: CGPointMake(0.5, 0.9375)];
        [self.outlineLayers addObject: circle];
    }
    
    for (CALayer *layer in self.outlineLayers)
        [self.layer addSublayer: layer];
    
    for (CALayer *layer in self.circleLayers)
        [self.layer addSublayer: layer];
    
    
    //  Content Label
    
    UILabel *label = [[UILabel alloc] initWithFrame: TITLE_LABEL_FRAME];
    [label setBackgroundColor: [UIColor clearColor]];
    [label setFont: [UIFont systemFontOfSize: DEFAULT_CALLOUT_FONT_SIZE]];
    [label setTextColor: [UIColor colorWithRed: (75.0 / 255.0) green: (133.0 / 255.0) blue: (162.0 / 255.0) alpha: 1]];
    [label setTextAlignment: NSTextAlignmentCenter];
    [label setAdjustsFontSizeToFitWidth: YES];
    [label setMinimumScaleFactor: 0.75];
    [label setNumberOfLines: 0];
    [label setAlpha: 0];
    [self addSubview: label];
    [self setTitleLabel: label];
}


/**
 *
 */
- (void) show {
    
    [self setHidden: NO];
    [self.titleLabel setAlpha: 0];
    
    [self animateCloud];
    [self animateTitle];
    [self performSelector: @selector(didAnimateCallout:) withObject: self afterDelay: (CLOUD_ANIMATION_DURATION + TITLE_ANIMATION_DURATION)];
}


/**
 *
 */
- (void) animateCloud {
    
    float minScale = 1.05;
    float maxScale = 1.15;
    NSString *animationKey = @"bounceAnimation";
    CAMediaTimingFunction *easeInOut = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    for (int i = 0; i < self.circleLayers.count; i++) {
        
        float scale = (((float) (arc4random() % ((unsigned) RAND_MAX + 1)) / RAND_MAX) * (maxScale - minScale)) + minScale;
        float delay = (((float) (arc4random() % ((unsigned) RAND_MAX + 1)) / RAND_MAX) * 0.2);
        
        CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath: @"transform.scale"];
        [bounceAnimation setValues: @[@0.05, @(1.24902 * scale), @(0.8474 - (scale - 1.0)), @(1.08834 * scale), @(0.95985 - (scale - 1.0)), @1.0]];
        [bounceAnimation setKeyTimes: @[@(0 + delay), @(0.285714 + delay*4.0/5.0), @(0.464285 + delay*3.0/5.0), @(0.642857 + delay*2.0/5.0), @(0.821428 + delay/5.0), @1.0]];
        [bounceAnimation setDuration: CLOUD_ANIMATION_DURATION];
        [bounceAnimation setTimingFunctions: @[easeInOut, easeInOut, easeInOut, easeInOut]];
        [bounceAnimation setBeginTime: CACurrentMediaTime()];
        
        CAShapeLayer *circle = [self.circleLayers objectAtIndex: i];
        [circle addAnimation: bounceAnimation forKey: animationKey];
        
        CAShapeLayer *outline = [self.outlineLayers objectAtIndex: i];
        [outline addAnimation: bounceAnimation forKey: animationKey];
    }
}


/**
 *
 */
- (void) animateTitle {
    
    [self.titleLabel setAttributedText: self.title];
    
    [UIView animateWithDuration: TITLE_ANIMATION_DURATION
                          delay: CLOUD_ANIMATION_DURATION * 0.9     //  Start this animation just before the cloud bounce animation finishes.
                        options: 0
                     animations: ^{
                         [self.titleLabel setAlpha: 1];
                     }
                     completion: ^(BOOL finished) {
                     }];
}


/**
 *
 */
- (void) didAnimateCallout: (id) sender {
    
}


@end
