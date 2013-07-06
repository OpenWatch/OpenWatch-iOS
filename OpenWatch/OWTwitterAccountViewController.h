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

@protocol OWTwitterAccountSelectionDelegate <NSObject>

- (void) twitterAccountSelected:(ACAccount*)account accountSelector:(OWTwitterAccountViewController*)accountSelector;
- (void) twitterAccountSelectionCanceled:(OWTwitterAccountViewController*)accountSelector;

@end

@interface OWTwitterAccountViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *accountsTableView;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, strong) NSMutableDictionary *profileImages;
@property (nonatomic, strong) ACAccount *selectedAccount;
@property (nonatomic, weak) id<OWTwitterAccountSelectionDelegate> delegate;

- (id) initWithAccounts:(NSArray*)accounts delegate:(id<OWTwitterAccountSelectionDelegate>) delegate;

@end
