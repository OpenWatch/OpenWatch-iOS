//
//  OWTagEditViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/10/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWTagEditViewController.h"
#import "OWManagedRecording.h"
#import "OWRecordingController.h"
#import "OWRecordingTag.h"
#import "OWStrings.h"
#import "OWAutocompletionView.h"

@interface OWTagEditViewController ()
@property (nonatomic, strong) UITableView *tagTableView;
@property (nonatomic, strong) UILabel *tagLabel;
@property (nonatomic, strong) UITextField *tagTextField;
@property (nonatomic, strong) NSMutableArray *tagsArray;
@property (nonatomic, strong) UIButton *addTagButton;
@property (nonatomic, strong) OWAutocompletionView *autocompletionView;
@end

@implementation OWTagEditViewController
@synthesize recordingObjectID, tagTableView, tagLabel, tagTextField, tagsArray, addTagButton, autocompletionView;

- (id)init
{
    self = [super init];
    if (self) {
        self.tagTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tagTableView.delegate = self;
        self.tagTableView.dataSource = self;
        self.tagLabel = [[UILabel alloc] init];
        self.tagLabel.text = TAG_STRING;
        self.title = TAGS_STRING;
        self.tagTextField = [[UITextField alloc] init];
        self.tagTextField.delegate = self;
        self.addTagButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [addTagButton addTarget:self action:@selector(addTagButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:SAVE_STRING style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed:)];
        self.autocompletionView = [[OWAutocompletionView alloc] init];
        self.autocompletionView.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:tagTableView];
    [self.view addSubview:tagTextField];
    [self.view addSubview:tagLabel];
    [self.view addSubview:addTagButton];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat labelWidth = 80.0f;
    CGFloat labelHeight = 40.0f;
    CGFloat buttonWidth = 30.0f;
    self.tagTextField.frame = CGRectMake(labelWidth, 0, self.view.frame.size.width - labelWidth - buttonWidth, labelHeight);
    self.tagLabel.frame = CGRectMake(0, 0, labelWidth, labelHeight);
    self.tagTableView.frame = CGRectMake(0, labelHeight, self.view.frame.size.width, self.view.frame.size.height-labelHeight);
    self.addTagButton.frame = CGRectMake(self.view.frame.size.width-buttonWidth, 0, buttonWidth, labelHeight);
}

- (void) setRecordingObjectID:(NSManagedObjectID *)newRecordingObjectID {
    recordingObjectID = newRecordingObjectID;
    [self refreshTags];
}

- (void) refreshTags {
    OWLocalRecording *recording = [OWRecordingController recordingForObjectID:self.recordingObjectID];
    NSSet *tags = recording.tags;
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    self.tagsArray = [NSMutableArray arrayWithArray:[tags sortedArrayUsingDescriptors:@[sortDescriptor]]];
    [self.tagTableView reloadData];
    
    NSArray *allTags = [OWRecordingTag MR_findAll];
    NSMutableArray *suggestionStrings = [NSMutableArray arrayWithCapacity:[allTags count]];
    for (OWRecordingTag *tag in allTags) {
        [suggestionStrings addObject:[tag.name lowercaseString]];
    }
    self.autocompletionView.suggestionStrings = suggestionStrings;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tagsArray.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    OWRecordingTag *tag = [tagsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [tag.name lowercaseString];
    return cell;
}

- (void) saveButtonPressed:(id)sender {
    NSSet *tagSet = [NSSet setWithArray:tagsArray];
    OWLocalRecording *recording = [OWRecordingController recordingForObjectID:self.recordingObjectID];
    recording.tags = tagSet;
    [recording saveMetadata];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) addTagButtonPressed:(id)sender {
    if (self.tagTextField.text.length == 0) {
        return;
    }
    NSString *newTagString = [self.tagTextField.text lowercaseString];
    [self addTagForName:newTagString];
}

- (void) addTagForName:(NSString*)tagName {
    self.tagTextField.text = @"";
    OWRecordingTag *tag = [OWRecordingTag MR_findFirstByAttribute:@"name" withValue:tagName];
    if (!tag) {
        tag = [OWRecordingTag MR_createEntity];
        tag.name = tagName;
    }
    [self.tagsArray addObject:tag];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [self.tagsArray sortUsingDescriptors:@[sortDescriptor]];
    [self.tagTableView reloadData];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == self.tagTextField) {
        [autocompletionView showSuggestionsForTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.tagTextField) {
        [autocompletionView showAllSuggestionsForTextField:self.tagTextField];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tagsArray removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
    }
}

- (void) didSelectString:(NSString *)string forTextField:(UITextField *)textField {
    [self addTagForName:string];
}

@end
