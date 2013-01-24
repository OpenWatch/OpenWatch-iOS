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
#import "OWTag.h"

@interface OWTagEditView()
@property (nonatomic) CGSize contentSize;
@property (nonatomic, strong) NSMutableArray *tagNames;
@end

@implementation OWTagEditView
@synthesize tagNames, tagList, tagCreationView, contentSize, delegate, viewForAutocompletionPopover;

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

- (void) setTagNames:(NSMutableArray *)newTagNamesArray {
    tagNames = newTagNamesArray;
    [self refreshTagListItems];
}

- (void) refreshTagListItems {
    [tagList setTags:tagNames];
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
        [tagNames removeObjectAtIndex:alertView.tag];
        [self refreshTagListItems];
    }
}

- (void) tagCreationView:(OWTagCreationView*)tagCreationView didCreateTags:(NSArray*)tagListArray {
    NSMutableSet *mutableTagNamesSet = [NSMutableSet setWithArray:tagList.textArray];
    for (NSString *tagName in tagListArray) {
        [mutableTagNamesSet addObject:tagName];
        NSLog(@"added tag: %@", tagName);
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
    NSArray *sortedArray = [mutableTagNamesSet sortedArrayUsingDescriptors:@[sortDescriptor]];
    NSMutableArray *mutableSortedTags = [NSMutableArray arrayWithArray:sortedArray];
    self.tagNames = mutableSortedTags;
}

- (void) tagCreationViewDidBeginEditing:(OWTagCreationView *)_tagCreationView {
    if (delegate && [delegate respondsToSelector:@selector(tagEditViewDidBeginEditing:)]) {
        [delegate tagEditViewDidBeginEditing:self];
    }
}

- (NSSet*) tags {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSMutableSet *tagSet = [[NSMutableSet alloc] initWithCapacity:tagNames.count];
    for (NSString *tagName in tagNames) {
        OWTag *tag = [OWTag MR_findFirstByAttribute:@"name" withValue:tagName inContext:context];
        if (!tag) {
            tag = [OWTag MR_createEntity];
            tag.name = tagName;
            [context obtainPermanentIDsForObjects:@[tag] error:nil];
        }
        [tagSet addObject:tag];
    }
    [context MR_saveToPersistentStoreAndWait];
    return tagSet;
}

- (void) setTags:(NSSet *)tagSet {
    NSMutableArray *tagNameArray = [[NSMutableArray alloc] initWithCapacity:tagSet.count];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray *tagObjectArray = [tagSet sortedArrayUsingDescriptors:@[sortDescriptor]];
    for (OWTag *tag in tagObjectArray) {
        [tagNameArray addObject:tag.name];
    }
    self.tagNames = tagNameArray;
}

- (void) setViewForAutocompletionPopover:(UIView *)_viewForAutocompletionPopover {
    viewForAutocompletionPopover = _viewForAutocompletionPopover;
    self.tagCreationView.autocompletionView.viewForAutocompletionPopover = viewForAutocompletionPopover;
}

@end
