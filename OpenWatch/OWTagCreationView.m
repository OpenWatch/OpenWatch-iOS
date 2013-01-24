//
//  OWTagCreationView.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 1/23/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWTagCreationView.h"
#import "OWTag.h"

@implementation OWTagCreationView
@synthesize delegate, textField, addButton, autocompletionView;

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
        [self setupAutocompletionView];
    }
    return self;
}


- (void) setupAutocompletionView {
    self.autocompletionView = [[OWAutocompletionViewController alloc] init];
    self.autocompletionView.delegate = self;
    NSArray *allTags = [OWTag MR_findAll];
    NSMutableSet *suggestionStrings = [NSMutableSet setWithCapacity:[allTags count]];
    for (OWTag *tag in allTags) {
        [suggestionStrings addObject:[tag.name lowercaseString]];
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
    NSArray *sortedArray = [suggestionStrings sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.autocompletionView.suggestionStrings = sortedArray;
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
    [autocompletionView showAllSuggestionsForTextField:self.textField];
    if (delegate && [delegate respondsToSelector:@selector(tagCreationViewDidBeginEditing:)]) {
        [delegate tagCreationViewDidBeginEditing:self];
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    [autocompletionView.popOver dismissPopoverAnimated:YES];
    if (delegate && [delegate respondsToSelector:@selector(tagCreationViewDidEndEditing:)]) {
        [delegate tagCreationViewDidEndEditing:self];
    }
}


- (BOOL)textField:(UITextField *)_textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (_textField == self.textField) {
        [autocompletionView showSuggestionsForTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return YES;
}


- (void) didSelectString:(NSString *)string forTextField:(UITextField *)_textField {
    [self.delegate tagCreationView:self didCreateTags:@[string]];
    textField.text = @"";
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
