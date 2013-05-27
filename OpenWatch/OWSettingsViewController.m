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
#import "OWShareController.h"

#define ACCOUNT_ROW 0
#define SHARE_ROW 1
#define GITHUB_ROW 2
#define OPENWATCH_WEB 3

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
    [self addCellInfoWithSection:0 row:SHARE_ROW labelText:@"Share this App!" cellType:kCellTypeNone userInputView:nil];
    [self addCellInfoWithSection:0 row:GITHUB_ROW labelText:@"OpenWatch on GitHub" cellType:kCellTypeNone userInputView:nil];
    [self addCellInfoWithSection:0 row:OPENWATCH_WEB labelText:@"Visit OpenWatch.net" cellType:kCellTypeNone userInputView:nil];
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
        [self presentViewController:navController animated:YES completion:nil];
    } else if (indexPath.row == SHARE_ROW) {
        [OWShareController shareURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/openwatch-social-muckraking/id642680756?ls=1&mt=8"] title:@"Defend your rights! Get the @OpenWatch app!" fromViewController:self];
    } else if (indexPath.row == GITHUB_ROW) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/OpenWatch/OpenWatch-iOS"]];
    } else if (indexPath.row == OPENWATCH_WEB) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://openwatch.net/"]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
