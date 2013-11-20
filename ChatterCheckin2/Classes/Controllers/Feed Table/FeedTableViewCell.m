//
//  FeedTableViewCell.m
//  ChatterCheckin
//
//  Created by John Gifford on 10/23/12.
//  Copyright (c) 2012 Model Metrics. All rights reserved.
//

#import "FeedTableViewCell.h"

@implementation FeedTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)dealloc {
    self.feedText = nil;
}
@end
