//
//  OWTagCreationView.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 1/23/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWTagCreationView.h"

@implementation OWTagCreationView
@synthesize delegate, textField, addButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.textField.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.textField.borderStyle = UITextBorderStyleRoundedRect;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.delegate = self;
        self.addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [self.addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.addButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.addButton.frame = CGRectMake(self.frame.size.width - self.addButton.frame.size.width, 1, self.addButton.frame.size.width, self.addButton.frame.size.height);
        [self addSubview:textField];
        [self addSubview:addButton];
    }
    return self;
}

- (void) addButtonPressed:(id)sender {
    [self sendTagNamesToDelegate];
}

- (BOOL) textFieldShouldReturn:(UITextField *)_textField {
    [self sendTagNamesToDelegate];
    return YES;
}

- (void) sendTagNamesToDelegate {
    [textField resignFirstResponder];
    if (delegate) {
        NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@", "];
        NSArray *components = [textField.text componentsSeparatedByCharactersInSet:characterSet];
        NSMutableArray *tagNames = [NSMutableArray arrayWithCapacity:components.count];
        for (NSString *component in components) {
            if (component.length > 0) {
                [tagNames addObject:[component lowercaseString]];
            }
        }
        [self.delegate tagCreationView:self didCreateTags:tagNames];
        self.textField.text = @"";
    }
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    if (delegate && [delegate respondsToSelector:@selector(tagCreationViewDidBeginEditing:)]) {
        [delegate tagCreationViewDidBeginEditing:self];
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    if (delegate && [delegate respondsToSelector:@selector(tagCreationViewDidEndEditing:)]) {
        [delegate tagCreationViewDidEndEditing:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
