//
//  OWInvestigationTableViewCell.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/2/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWInvestigationTableViewCell.h"

@implementation OWInvestigationTableViewCell
@synthesize blurbLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.blurbLabel = [[UILabel alloc] init];
        [self addSubview:blurbLabel];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
