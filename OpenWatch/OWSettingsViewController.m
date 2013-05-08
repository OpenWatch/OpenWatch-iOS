//
//  OWSettingsViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/12/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWSettingsViewController.h"
#import "OWStrings.h"
#import "OWLoginViewController.h"
#import "OWLocalMediaObjectListViewController.h"
#import "OWUtilities.h"

#define ACCOUNT_ROW 0
#define FEEDBACK_ROW 1

@interface OWSettingsViewController ()

@end

@implementation OWSettingsViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = SETTINGS_STRING;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self addCellInfoWithSection:0 row:ACCOUNT_ROW labelText:ACCOUNT_STRING cellType:kCellTypeNone userInputView:nil];
    [self addCellInfoWithSection:0 row:FEEDBACK_ROW labelText:SEND_FEEDBACK_STRING cellType:kCellTypeNone userInputView:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [TestFlight passCheckpoint:VIEW_SETTINGS_CHECKPOINT];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == ACCOUNT_ROW) {
        OWLoginViewController *loginView = [[OWLoginViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginView];
        [OWUtilities styleNavigationController:navController];
        [self presentViewController:navController animated:YES completion:nil];
    } else if (indexPath.row == FEEDBACK_ROW) {
        [TestFlight openFeedbackView];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
