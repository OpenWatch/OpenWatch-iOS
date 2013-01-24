//
//  OWTagCreationView.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 1/23/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWAutocompletionViewController.h"
#import "OWPastelessTextField.h"

@class OWTagCreationView;
@protocol OWTagCreationViewDelegate <NSObject>
@required
- (void) tagCreationView:(OWTagCreationView*)tagCreationView didCreateTags:(NSArray*)tagListArray;
@optional
- (void) tagCreationViewDidBeginEditing:(OWTagCreationView*)tagCreationView;
- (void) tagCreationViewDidEndEditing:(OWTagCreationView*)tagCreationView;
@end

@interface OWTagCreationView : UIView <UITextFieldDelegate, OWAutocompletionDelegate>

@property (nonatomic, weak) id<OWTagCreationViewDelegate> delegate;
@property (nonatomic, strong) OWPastelessTextField *textField;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) OWAutocompletionViewController *autocompletionView;


@end
