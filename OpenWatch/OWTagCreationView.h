//
//  OWTagCreationView.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 1/23/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OWTagCreationView;
@protocol OWTagCreationViewDelegate <NSObject>
@required
- (void) tagCreationView:(OWTagCreationView*)tagCreationView didSelectTags:(NSArray*)tagListArray;
@optional
- (void) tagCreationViewDidBeginEditing:(OWTagCreationView*)tagCreationView;
- (void) tagCreationViewDidEndEditing:(OWTagCreationView*)tagCreationView;
@end

@interface OWTagCreationView : UIView <UITextFieldDelegate>

@property (nonatomic, weak) id<OWTagCreationViewDelegate> delegate;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *addButton;

@end
