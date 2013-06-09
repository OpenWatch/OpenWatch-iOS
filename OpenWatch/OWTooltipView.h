//
//  OWTooltipView.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 6/8/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OWTooltipView;

@protocol OWTooltipViewDelegate <NSObject>
@optional
- (void) tooltipViewWillDismiss:(OWTooltipView*)tooltipView;
- (void) tooltipViewDidDismiss:(OWTooltipView*)tooltipView;
@end

@interface OWTooltipView : UIView <UIAlertViewDelegate>

@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, weak) id<OWTooltipViewDelegate> delegate;

- (id) initWithFrame:(CGRect)frame descriptionText:(NSString*)descriptionText;

@end

