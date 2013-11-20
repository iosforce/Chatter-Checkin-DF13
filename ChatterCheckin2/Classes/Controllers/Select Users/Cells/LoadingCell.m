//
//  LoadingCell.m
//  ChatterCheckin2
//
//  Created by Steve Deren on 11/1/13.
//  Copyright (c) 2013 Salesforce.com. All rights reserved.
//

#import "LoadingCell.h"

@implementation LoadingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		
		UIActivityIndicatorView * ind = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
		ind.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
		[self.contentView addSubview:ind];
		self.indicator = ind;
		
		self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	self.indicator.center = self.contentView.center;
	
	if(![self.indicator isAnimating]) {
		[self.indicator startAnimating];
	}
}

- (NSString *)reuseIdentifier {
	return NSStringFromClass([self class]);
}

- (void)dealloc {
	self.indicator = nil;
}

@end
