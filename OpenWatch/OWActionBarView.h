//
//  OWActionBarView.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/2/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OWActionBarView;

@protocol OWActionBarViewDelegate <NSObject>
@optional
- (void) actionBarView:(OWActionBarView*)actionBarView didSelectButtonAtIndex:(NSUInteger)buttonIndex;
@end

@interface OWActionBarView : UIView

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, weak) id<OWActionBarViewDelegate> delegate;

@end
