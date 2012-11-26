//
//  OWGroupedTableViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/26/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWGroupedTableViewController.h"
#import "OWInLineTextEditTableViewCell.h"


@interface OWGroupedTableViewController ()

@end

@implementation OWGroupedTableViewController
@synthesize groupedTableView, tableViewArray, scrollView;

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        groupedTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"fabric.jpeg"]];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.scrollView];
    
    [self.scrollView addSubview:self.groupedTableView];
    groupedTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    groupedTableView.delegate = self;
    groupedTableView.dataSource = self;
    groupedTableView.backgroundColor = [UIColor clearColor];
    groupedTableView.backgroundView = nil;
    groupedTableView.scrollEnabled = NO;
    
    // Listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)addCellInfoWithSection:(NSInteger)section row:(NSInteger)row labelText:(id)text cellType:(NSString *)type userInputView:(UIView *)inputView
{
    if (!tableViewArray) {
        self.tableViewArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < section; i++) {
            [self.tableViewArray setObject:[[NSMutableArray alloc] init] atIndexedSubscript:i];
        }
    }
    if ([self.tableViewArray count]<(section+1)) {
        [self.tableViewArray setObject:[[NSMutableArray alloc] init] atIndexedSubscript:section];
    }
    
    NSDictionary * cellDictionary = [NSDictionary dictionaryWithObjectsAndKeys:text,kTextLabelTextKey,type,kCellTypeKey,inputView,kUserInputViewKey, nil];
    
    [[tableViewArray objectAtIndex:section] insertObject:cellDictionary atIndex:row];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary * cellDictionary = [[self.tableViewArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString * cellType = [cellDictionary objectForKey:kCellTypeKey];
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellType];
    
    if([cellType isEqualToString:kCellTypeTextField])
    {
        if(cell == nil)
        {
            cell = [[OWInLineTextEditTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellType];
        }
        cell.textLabel.text = [cellDictionary objectForKey:kTextLabelTextKey];
        [cell layoutIfNeeded];
        ((OWInLineTextEditTableViewCell *)cell).textField = [cellDictionary objectForKey:kUserInputViewKey];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


@end
