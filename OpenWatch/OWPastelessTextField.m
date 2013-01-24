//
//  OWPastelessTextField.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 1/23/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWPastelessTextField.h"

@implementation OWPastelessTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Disable paste
// http://stackoverflow.com/questions/6614465/how-do-you-really-remove-copy-from-uimenucontroller/7944656#7944656
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return NO;
}


@end
