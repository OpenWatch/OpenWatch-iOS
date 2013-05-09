//
//  OWFeedSelectionViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWFeedSelectionViewController.h"
#import "OWStrings.h"
#import "OWUtilities.h"
#import "OWUser.h"
#import "OWAccount.h"
#import "OWSettingsController.h"
#import "OWTag.h"

@interface OWFeedSelectionViewController ()
@end

#define FEED_SECTION 0

@implementation OWFeedSelectionViewController
@synthesize tagNames, feedNames, selectionTableView, delegate, popOver, popoverSize;

- (id)init
{
    self = [super init];
    if (self) {
        self.feedNames = @[FEATURED_STRING, FOLLOWING_STRING, LOCAL_STRING, RAW_STRING];
        [self refreshTags];
        self.popoverSize = CGSizeMake(220, 350);
        self.selectionTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, popoverSize.width, popoverSize.height) style:UITableViewStylePlain];
        //self.selectionTableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:selectionTableView];
        self.selectionTableView.dataSource = self;
        self.selectionTableView.delegate = self;
        //self.view.backgroundColor = [OWUtilities fabricBackgroundPattern];
        self.popOver = [[WEPopoverController alloc] initWithContentViewController:self];
        self.popOver.containerViewProperties = [OWUtilities improvedContainerViewProperties];
    }
    return self;
}

- (void) refreshTags {
    NSSet *unsortedTags = [[[[OWSettingsController sharedInstance] account] user] tags];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray *sortedTags = [unsortedTags sortedArrayUsingDescriptors:@[sortDescriptor]];
    NSMutableArray *mutableTagNames = [NSMutableArray arrayWithCapacity:[sortedTags count]];
    for (OWTag *tag in sortedTags) {
        [mutableTagNames addObject:[tag.name lowercaseString]];
    }
    self.tagNames = mutableTagNames;
    [self.selectionTableView reloadData];
}

- (void) presentPopoverFromBarButtonItem:(UIBarButtonItem *)buttonItem {
    self.popOver.popoverContentSize = self.popoverSize;
    self.selectionTableView.frame = CGRectMake(0, 0, popoverSize.width, popoverSize.height);
    UIPopoverArrowDirection arrowDirection = UIPopoverArrowDirectionUp;
    if(!popOver.isPopoverVisible){
        [popOver presentPopoverFromBarButtonItem:buttonItem permittedArrowDirections:arrowDirection animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case FEED_SECTION:
            return feedNames.count;
            break;
        default:
            return 0;
            break;
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case FEED_SECTION:
            return FEEDS_STRING;
            break;
        default:
            return @"";
            break;
    }
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    switch (indexPath.section) {
        case FEED_SECTION:
            cell.textLabel.text = [feedNames objectAtIndex:indexPath.row];
            if (delegate.feedType == kOWFeedTypeFeed && [cell.textLabel.text isEqualToString:delegate.selectedFeedString]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
        default:
            break;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case FEED_SECTION:
            [self.delegate didSelectFeedWithName:[feedNames objectAtIndex:indexPath.row] type:kOWFeedTypeFeed];
            break;
        default:
            break;
    }
    [tableView reloadData];
    [popOver dismissPopoverAnimated:YES];
}

@end
