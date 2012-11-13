//
//  OWInLineTextEditTableViewCell.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/12/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWInLineTextEditTableViewCell.h"

#define textLeftFieldBuffer 100

@implementation OWInLineTextEditTableViewCell

@synthesize textField = _textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

-(id)initWithTextField:(UITextField *)cellTextField textLabeltext:(NSString *)name reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    self.textField = cellTextField;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.backgroundColor = [UIColor whiteColor];
    self.textField.tag = 999;
    
    self.textLabel.text = name;
    
    return self;
}

-(void)setTextField:(UITextField *)newTextField
{
    [[self.contentView viewWithTag:999] removeFromSuperview];
    _textField = newTextField;
    [self layoutIfNeeded];
    self.textField.frame = CGRectMake(textLeftFieldBuffer, self.textLabel.frame.origin.y, self.contentView.frame.size.width-textLeftFieldBuffer-5, self.contentView.frame.size.height-20);
    self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.textField.tag = 999;
    [self.contentView addSubview:self.textField];
}

-(void)dealloc {
    self.textField = nil;
}

@end
