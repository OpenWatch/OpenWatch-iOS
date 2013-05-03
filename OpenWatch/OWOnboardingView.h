//
//  OWOnboardingView.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/2/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OWOnboardingView;

@protocol OWOnboardingViewDelegate <NSObject>
@optional
- (void) onboardingView:(OWOnboardingView*)onboardingView didAdvanceToIndex:(NSUInteger)index;
- (void) onboardingViewDidComplete:(OWOnboardingView*)onboardingView;
@end

@interface OWOnboardingView : UIView

@property (nonatomic) NSUInteger displayIndex;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) UIButton *continueButton;

@property (nonatomic, weak) id<OWOnboardingViewDelegate> delegate;

@end
