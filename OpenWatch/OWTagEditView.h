//
//  OWTagEditView.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 1/23/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWTagList.h"
#import "OWTagCreationView.h"

@class OWTagEditView;
@protocol OWTagEditViewDelegate <NSObject>
@optional
- (void) tagEditViewDidBeginEditing:(OWTagEditView*)tagEditView;
@end

@interface OWTagEditView : UIView <DWTagListDelegate, OWTagCreationViewDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) id<OWTagEditViewDelegate> delegate;
@property (nonatomic, strong) DWTagList *tagList;
@property (nonatomic, strong) OWTagCreationView *tagCreationView;
@property (nonatomic, readonly) CGSize contentSize;
@property (nonatomic, strong) NSSet *tags; // Array of OWTags
@property (nonatomic, weak) UIView *viewForAutocompletionPopover;

@end
