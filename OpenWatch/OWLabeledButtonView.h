//
//  OWButtonView.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWLabeledButtonView : UIView

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIButton *button;

- (id) initWithFrame:(CGRect)frame defaultImageName:(NSString*)imageName highlightedImageName:(NSString*)highlightedImageName labelName:(NSString*)labelName;

@end
