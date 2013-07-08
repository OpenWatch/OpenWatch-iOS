//
//  OWTwitterAccountViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 7/5/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@class OWTwitterAccountViewController;

typedef void(^OWTwitterAccountSelectionCallback)(ACAccount *selectedAccount, NSError *error);


@interface OWTwitterAccountViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *accountsTableView;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, strong) NSMutableDictionary *profileImages;
@property (nonatomic, strong) ACAccount *selectedAccount;
@property (nonatomic, copy) OWTwitterAccountSelectionCallback callbackBlock;

- (id) initWithAccounts:(NSArray*)accounts callbackBlock:(OWTwitterAccountSelectionCallback)callbackBlock;

@end
