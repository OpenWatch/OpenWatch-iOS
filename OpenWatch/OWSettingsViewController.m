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
    [self addCellInfoWithSection:0 row:0 labelText:ACCOUNT_STRING cellType:kCellTypeNone userInputView:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        OWLoginViewController *loginView = [[OWLoginViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginView];
        [self presentViewController:navController animated:YES completion:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
