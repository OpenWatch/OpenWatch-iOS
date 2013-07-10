//
//  OWTwitterAccountViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 7/5/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWTwitterAccountViewController.h"
#import "OWUtilities.h"
#import "OWStrings.h"
#import "OWSettingsController.h"
#import <Social/Social.h>
#import "UIImageView+AFNetworking.h"
#import "OWSocialController.h"

static NSString *cellIdentifier = @"CellIdentifier";

@interface OWTwitterAccountViewController ()

@end

@implementation OWTwitterAccountViewController
@synthesize accountsTableView, accounts, profileImages, callbackBlock;

- (id) initWithAccounts:(NSArray*)newAccounts callbackBlock:(OWTwitterAccountSelectionCallback)newCallbackBlock {
    if (self = [super init]) {
        self.view.backgroundColor = [OWUtilities stoneBackgroundPattern];
        self.callbackBlock = newCallbackBlock;
        self.accounts = newAccounts;
        self.accountsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        self.accountsTableView.delegate = self;
        self.accountsTableView.dataSource = self;
        self.accountsTableView.backgroundView = nil;
        self.accountsTableView.backgroundColor = [OWUtilities stoneBackgroundPattern];
        self.selectedAccount = [OWSocialController sharedInstance].twitterAccount;
        self.profileImages = [NSMutableDictionary dictionaryWithCapacity:newAccounts.count];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
        doneButton.tintColor = [OWUtilities doneButtonColor];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
        self.navigationItem.rightBarButtonItem = doneButton;
        self.title = CHOOSE_ACCOUNT_STRING;
        [self.view addSubview:accountsTableView];
        [self.accountsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.accountsTableView.frame = self.view.bounds;
}

- (void) doneButtonPressed:(id)sender {
    if (callbackBlock) {
        callbackBlock(self.selectedAccount, nil);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return accounts.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    ACAccount *account = [accounts objectAtIndex:indexPath.row];
    if ([account.identifier isEqualToString:self.selectedAccount.identifier]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = account.accountDescription;
    
    UIImage *image = [profileImages objectForKey:account.username];
    if (image) {
        cell.imageView.image = image;
    } else {
        cell.imageView.image = [UIImage imageNamed:@"210-twitterbird.png"];
        [self setImageForCell:cell account:account];
    }
    
    return cell;
}

- (void) setImageForCell:(UITableViewCell*)cell account:(ACAccount*)account {
    [[OWSocialController sharedInstance] profileForTwitterAccount:account callbackBlock:^(NSDictionary *profile, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                NSLog(@"Error setting profile image: %@", error.userInfo);
            } else {
                NSString *profileURL = [profile objectForKey:@"profile_image_url_https"];
                if (profileURL) {
                    __weak __typeof(&*self)weakSelf = self;
                    __weak UITableViewCell *weakCell = cell;
                    
                    [cell.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                        weakCell.imageView.image = image;
                        [weakSelf.profileImages setObject:image forKey:account.username];
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                        NSLog(@"Error setting twitter image: %@", error.userInfo);
                    }];
                }
            }
        });
    }];
    
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ACAccount *account = [accounts objectAtIndex:indexPath.row];
    self.selectedAccount = account;
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void) cancelButtonPressed:(id)sender {
    NSError *error = [NSError errorWithDomain:@"OWTwitterAccountSelectionError" code:100 userInfo:@{NSLocalizedDescriptionKey: @"User canceled account creation."}];
    if (callbackBlock) {
        callbackBlock(nil, error);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
