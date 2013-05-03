//
//  OWOnboardingView.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/2/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWOnboardingView.h"
#import "OWUtilities.h"

@implementation OWOnboardingView
@synthesize scrollView, images, displayIndex, continueButton;

- (id) initWithFrame:(CGRect)frame scrollViewYOffset:(CGFloat)offset {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        self.displayIndex = 0;
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y + offset, frame.size.width, frame.size.height)];
        self.scrollView.userInteractionEnabled = NO;
        
        UIImage *firstImage = [UIImage imageNamed:@"ow_space1.jpg"];
        UIImage *secondImage = [UIImage imageNamed:@"ow_space2.jpg"];
        
        self.images = @[firstImage, secondImage];
        
        int i = 0;
        for (UIImage *image in images) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.contentMode = UIViewContentModeTop;
            imageView.frame = CGRectMake(frame.size.width * i, 0, frame.size.width, frame.size.height);
            [self.scrollView addSubview:imageView];
            i++;
        }
        
        self.scrollView.contentSize = CGSizeMake(frame.size.width * i, frame.size.height);
        
        [self addSubview:scrollView];
        
        self.continueButton = [OWUtilities bigGreenButton];
        [continueButton setTitle:@"Continue →" forState:UIControlStateNormal];
        CGFloat xPadding = 20.0f;
        CGFloat bottomPadding = 100.0f;
        self.continueButton.frame = CGRectMake(xPadding, frame.size.height - bottomPadding, frame.size.width - xPadding * 2, 50);
        [self.continueButton addTarget:self action:@selector(continueButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:continueButton];
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [self initWithFrame:frame scrollViewYOffset:0]) {
        
    }
    return self;
}

- (void) continueButtonPressed:(id)sender {
    self.displayIndex++;
    if (displayIndex >= self.images.count) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onboardingViewDidComplete:)]) {
            [self.delegate onboardingViewDidComplete:self];
        }
        //NSLog(@"Done!");
    } else {
        [self.scrollView setContentOffset:CGPointMake(displayIndex * self.scrollView.frame.size.width, 0) animated:YES];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(onboardingView:didAdvanceToIndex:)]) {
        [self.delegate onboardingView:self didAdvanceToIndex:displayIndex];
    }
}


@end
