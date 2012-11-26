//
//  OWGroupedTableViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/26/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTextLabelTextKey @"textLabelTextKey"
#define kCellTypeKey @"cellTypeKey"
#define kUserInputViewKey @"userInputViewKey"
#define kCellTypeTextField @"cellTypeTextField"
#define kCellTypeSwitch @"cellTypeSwitch"
#define KCellTypeHelp @"cellTypeHelp"

@interface OWGroupedTableViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray * tableViewArray;
@property (nonatomic, strong) UITableView *groupedTableView;

-(void)addCellInfoWithSection:(NSInteger)section row:(NSInteger)row labelText:(id)text cellType:(NSString *)type userInputView:(UIView *)inputView;

@end
