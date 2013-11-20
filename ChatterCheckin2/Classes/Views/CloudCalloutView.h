//
//  CloudCalloutView.h
//  CloudsMap
//
//  Created by Jason Barker on 11/9/13.
//  Copyright (c) 2013 Jason Barker. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface CloudCalloutView : UIView

@property (nonatomic, strong) NSAttributedString *title;

+ (CGFloat) calloutFontSize;
+ (int) calloutTitleMaxNumberOfLines;
+ (CGFloat) calloutTitleLabelWidth;

- (void) show;
- (CGPoint) anchorPoint;

@end
