//
//  OWEditableMediaCell.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 7/8/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSTextView.h"
#import "OWPreviewView.h"

@interface OWEditableMediaCell : UITableViewCell

@property (nonatomic, strong) SSTextView *textView;
@property (nonatomic, strong) OWPreviewView *previewView;

+ (CGFloat) cellHeight;

@end
