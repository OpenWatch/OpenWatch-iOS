//
//  OWLoginViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/12/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWLoginViewController.h"
#import "OWStrings.h"
#import "OWInLineTextEditTableViewCell.h"
#import "OWSettingsController.h"
#import "OWAccountAPIClient.h"

#define kTextLabelTextKey @"textLabelTextKey"
#define kCellTypeKey @"cellTypeKey"
#define kUserInputViewKey @"userInputViewKey"
#define kCellTypeTextField @"cellTypeTextField"
#define kCellTypeSwitch @"cellTypeSwitch"
#define KCellTypeHelp @"cellTypeHelp"

@interface OWLoginViewController ()

@end

@implementation OWLoginViewController
@synthesize emailTextField, passwordTextField, loginButton, tableViewArray, loginViewTableView, helpLabel;
@synthesize headerImageView, account, loginOrSignupSegmentedControl, logoutButton;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = LOGIN_STRING;
        OWSettingsController *settingsController = [OWSettingsController sharedInstance];
        self.account = settingsController.account;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"fabric.jpeg"]];
    
    self.loginOrSignupSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[LOGIN_STRING, SIGNUP_STRING]];
    [self.loginOrSignupSegmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.loginOrSignupSegmentedControl setWidth:150 forSegmentAtIndex:0];
    [self.loginOrSignupSegmentedControl setWidth:150 forSegmentAtIndex:1];
    self.loginOrSignupSegmentedControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:loginOrSignupSegmentedControl];
    
    [self setUpFields];

    self.helpLabel = [[UILabel alloc] init];
    self.helpLabel.textAlignment = UITextAlignmentCenter;
    self.helpLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.helpLabel.numberOfLines = 0;
    self.helpLabel.text = SIGNUP_HELP_STRING;
    self.helpLabel.shadowColor = [UIColor whiteColor];
    self.helpLabel.shadowOffset = CGSizeMake(0, 1);
    self.helpLabel.textColor = [UIColor darkGrayColor];
    self.helpLabel.backgroundColor = [UIColor clearColor];
    self.helpLabel.font = [UIFont systemFontOfSize:16.0f];
    
    loginViewTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    loginViewTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [loginViewTableView setDelegate:self];
    [loginViewTableView setDataSource:self];
    loginViewTableView.backgroundColor = [UIColor clearColor];
    loginViewTableView.backgroundView = nil;
    loginViewTableView.scrollEnabled = NO;
    [self.view addSubview:loginViewTableView];
    
    self.loginButton = [[UIBarButtonItem alloc] initWithTitle:SUBMIT_STRING style:UIBarButtonItemStyleDone target:self action:@selector(loginButtonPressed:)];
    self.navigationItem.rightBarButtonItem = loginButton;
    
    
    self.logoutButton = [[UIBarButtonItem alloc] initWithTitle:LOGOUT_STRING style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonPressed:)];
    self.navigationItem.leftBarButtonItem = logoutButton;
    
    self.headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"openwatch.png"]];
    self.headerImageView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:headerImageView];

}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat padding = 10.0f;
    self.headerImageView.frame = CGRectMake(padding, 0, self.view.frame.size.width-(padding*2), headerImageView.image.size.height+(padding*2));

    self.loginOrSignupSegmentedControl.frame = CGRectMake(padding, self.headerImageView.frame.size.height, self.view.frame.size.width-(padding*2), 35.0f);
    CGFloat loginTableViewYOrigin = loginOrSignupSegmentedControl.frame.size.height + loginOrSignupSegmentedControl.frame.origin.y;
    self.loginViewTableView.frame = CGRectMake(0, loginTableViewYOrigin, self.view.frame.size.width, self.view.frame.size.height-loginTableViewYOrigin);
}


- (UIColor*) textFieldTextColor {
    return [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
}

-(void)setUpFields
{
    self.emailTextField = [[UITextField alloc] init];
    self.emailTextField.delegate = self;
    self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.emailTextField.returnKeyType = UIReturnKeyDone;
    self.emailTextField.textColor = self.textFieldTextColor;
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTextField.placeholder = REQUIRED_STRING;
    NSString *email = account.email;
    if (email) {
        self.emailTextField.text = email;
    }
    
    [self addCellinfoWithSection:0 row:0 labelText:EMAIL_STRING cellType:kCellTypeTextField userInputView:self.emailTextField];
    
    
    self.passwordTextField = [[UITextField alloc] init];
    self.passwordTextField.delegate = self;
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
    self.passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordTextField.textColor = self.textFieldTextColor;
    self.passwordTextField.placeholder = REQUIRED_STRING;
    
    NSString *password = account.password;
    if (password) {
        self.passwordTextField.text = password;
    }
    
    [self addCellinfoWithSection:0 row:1 labelText:PASSWORD_STRING cellType:kCellTypeTextField userInputView:self.passwordTextField];
}

-(void)addCellinfoWithSection:(NSInteger)section row:(NSInteger)row labelText:(id)text cellType:(NSString *)type userInputView:(UIView *)inputView;
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
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tableViewArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[tableViewArray objectAtIndex:section] count];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary * cellDictionary = [[tableViewArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
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

- (void)loginButtonPressed:(id)sender {
    BOOL fields = [self checkFields];
    if(fields)
    {
        account.email = self.emailTextField.text;
        account.password = self.passwordTextField.text;
        
        [[OWAccountAPIClient sharedClient] loginWithAccount:account success:^{
            NSLog(@"Success");
            [self dismissViewControllerAnimated:YES completion:^{}];
        } failure:^(NSString *reason) {
            NSLog(@"Failure: %@", reason);
        }];
        

    }
}



- (void)logoutButtonPressed:(id)sender {
    [self.account clearAccountData];
    self.emailTextField.text = @"";
    self.passwordTextField.text = @"";
}


-(BOOL)checkFields
{
    BOOL fields = emailTextField.text && ![emailTextField.text isEqualToString:@""] && passwordTextField.text && ![passwordTextField.text isEqualToString:@""];
    
    if(!fields)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_STRING message:USER_PASS_BLANK_STRING delegate:nil cancelButtonTitle:nil otherButtonTitles:OK_STRING, nil];
        [alert show];
    }
    
    return fields;
}

- (UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return helpLabel;
    }
    return nil;
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 50.0f;
    }
    return 0.0f;
}

- (void) segmentedControlValueChanged:(id)sender {
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
