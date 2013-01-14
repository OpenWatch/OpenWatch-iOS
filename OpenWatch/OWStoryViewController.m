//
//  OWStoryViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 1/14/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWStoryViewController.h"
#import "OWStory.h"
#import "OWUtilities.h"
#import "OWAccountAPIClient.h"

@interface OWStoryViewController ()

@end

@implementation OWStoryViewController
@synthesize storyObjectID, blurbLabel, bodyTextView, titleLabel;

- (id)init
{
    self = [super init];
    if (self) {
        self.titleLabel = [[UILabel alloc] init];
        self.blurbLabel = [[UILabel alloc] init];
        [self.view addSubview:titleLabel];
        [self.view addSubview:blurbLabel];
        [self setupTextView];
    }
    return self;
}

- (void) setupTextView {
    self.bodyTextView = [[UITextView alloc] init];
    self.bodyTextView.editable = NO;
    [self.view addSubview:bodyTextView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat width = self.view.frame.size.width;
    CGFloat labelHeight = 30.0f;
    CGFloat height = self.view.frame.size.height;
    self.titleLabel.frame = CGRectMake(0, 0, width, labelHeight);
    self.blurbLabel.frame = CGRectMake(0, [OWUtilities bottomOfView:titleLabel], width, labelHeight);
    CGFloat bodyTextViewYOrigin = [OWUtilities bottomOfView:blurbLabel];
    self.bodyTextView.frame = CGRectMake(0, bodyTextViewYOrigin, width, height-bodyTextViewYOrigin);
}

- (void) refreshFields {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWStory *story = (OWStory*)[context objectWithID:storyObjectID];
    self.title = story.title;
    self.titleLabel.text = story.title;
    self.blurbLabel.text = story.blurb;
    self.bodyTextView.text = story.body;
}

- (void) setStoryObjectID:(NSManagedObjectID *)newStoryObjectID {
    storyObjectID = newStoryObjectID;
    [self refreshFields];
    [[OWAccountAPIClient sharedClient] getStoryWithObjectID:storyObjectID success:^(NSManagedObjectID *recordingObjectID) {
        [self refreshFields];
    } failure:^(NSString *reason) {
        
    }];
}

@end
