//
//  OWOnboardingView.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/2/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWOnboardingView.h"
#import "OWUtilities.h"
#import "OWLocationController.h"
#import "BButton.h"

@implementation OWOnboardingView
@synthesize scrollView, images, displayIndex, continueButton, agentSwitch;

- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        self.displayIndex = 0;
        self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
        self.scrollView.scrollEnabled = NO;
        
        [self addSubview:scrollView];
        
        self.images = @[[UIImage imageNamed:@"onboarding_1.png"], [UIImage imageNamed:@"onboarding_2.png"], [UIImage imageNamed:@"onboarding_3.png"], [UIImage imageNamed:@"onboarding_4.png"]];
        
        self.continueButton = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypeSuccess];
        [continueButton setTitle:@"Continue →" forState:UIControlStateNormal];
        [self.continueButton addTarget:self action:@selector(continueButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:continueButton];
        [self setFrame:frame];

    }

    return self;
}

- (void) toggleSecretAgentMode:(id)sender {
    if (self.agentSwitch.on) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
}

- (void) setImages:(NSArray *)newImages {
    images = newImages;
    int i = 0;
    for (UIImage *image in images) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.backgroundColor = [OWUtilities stoneBackgroundPattern];
        imageView.contentMode = UIViewContentModeTop;
        imageView.frame = CGRectMake(self.frame.size.width * i, 0, self.frame.size.width, self.frame.size.height);
        imageView.userInteractionEnabled = YES;
        
        [self.scrollView addSubview:imageView]; 
        
        if (i == 2) { // this is a bad hack
            self.agentSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(230, 260, 80, 30)];
            [agentSwitch addTarget:self action:@selector(toggleSecretAgentMode:) forControlEvents:UIControlEventValueChanged];
            [imageView addSubview:agentSwitch];
        }
        
        i++;
    }
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width * i, self.frame.size.height);
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.scrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    CGFloat padding = 20.0f;
    CGFloat buttonHeight = 50.0f;
    self.continueButton.frame = CGRectMake(padding, frame.size.height - padding - buttonHeight, frame.size.width - padding * 2, buttonHeight);
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
