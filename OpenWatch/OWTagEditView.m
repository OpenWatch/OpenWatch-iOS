//
//  OWTagEditView.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 1/23/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWTagEditView.h"
#import "OWStrings.h"
#import "OWUtilities.h"

@interface OWTagEditView()
@property (nonatomic) CGSize contentSize;
@end

@implementation OWTagEditView
@synthesize tagNamesArray, tagList, tagCreationView, contentSize, delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupTagView];
        [self setupTagCreationView];
        [self refreshFrames];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void) setupTagView {
    self.tagList = [[DWTagList alloc] initWithFrame:CGRectZero];
    self.tagList.delegate = self;
    self.tagList.userInteractionEnabled = YES;
    [self addSubview:tagList];
}

- (void) setupTagCreationView {
    self.tagCreationView = [[OWTagCreationView alloc] initWithFrame:CGRectZero];
    self.tagCreationView.delegate = self;
    self.tagCreationView.textField.placeholder = TAGS_STRING;
    [self addSubview:tagCreationView];
}

- (void) refreshFrames {
    CGFloat padding = 10.0f;
    CGFloat itemHeight = 30.0f;
    self.tagCreationView.frame = CGRectMake(0, 0, self.frame.size.width, itemHeight);
    self.tagList.frame = CGRectMake(0, [OWUtilities bottomOfView:tagCreationView] + padding, self.frame.size.width, itemHeight);
    [self.tagList display];
    [self refreshTaglistFrame];
    self.contentSize = CGSizeMake(self.frame.size.width, self.tagCreationView.frame.size.height + self.tagList.fittedSize.height + padding);
}

- (void) setTagNamesArray:(NSMutableArray *)newTagNamesArray {
    tagNamesArray = newTagNamesArray;
    [self refreshTagListItems];
}

- (void) refreshTagListItems {
    [tagList setTags:tagNamesArray];
    [self refreshFrames];
}

- (void) refreshTaglistFrame {
    CGRect tagListFrame = self.tagList.frame;
    tagListFrame.size.height = self.tagList.fittedSize.height;
    self.tagList.frame = tagListFrame;
}

- (void) selectedTagName:(NSString *)tagName atIndex:(NSUInteger)index {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:DELETE_TAG_TITLE_STRING message:[NSString stringWithFormat:DELETE_TAG_MESSAGE_STRING, tagName] delegate:self cancelButtonTitle:NO_STRING otherButtonTitles:YES_STRING, nil];
    alertView.delegate = self;
    alertView.tag = index;
    [alertView show];
    NSLog(@"selected %d, %@", index, tagName);
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex != buttonIndex) {
        [tagNamesArray removeObjectAtIndex:alertView.tag];
        [self refreshTagListItems];
    }
}

- (void) tagCreationView:(OWTagCreationView*)tagCreationView didSelectTags:(NSArray*)tagListArray {
    NSMutableSet *mutableTagNamesSet = [NSMutableSet setWithArray:tagList.textArray];
    for (NSString *tagName in tagListArray) {
        [mutableTagNamesSet addObject:tagName];
        NSLog(@"added tag: %@", tagName);
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
    NSArray *sortedArray = [mutableTagNamesSet sortedArrayUsingDescriptors:@[sortDescriptor]];
    [tagList setTags:sortedArray];
    [self refreshTaglistFrame];
}

- (void) tagCreationViewDidBeginEditing:(OWTagCreationView *)_tagCreationView {
    if (delegate && [delegate respondsToSelector:@selector(tagEditViewDidBeginEditing:)]) {
        [delegate tagEditViewDidBeginEditing:self];
    }
}

@end
