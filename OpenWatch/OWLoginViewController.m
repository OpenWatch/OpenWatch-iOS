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

#define kTextLabelTextKey @"textLabelTextKey"
#define kCellTypeKey @"cellTypeKey"
#define kUserInputViewKey @"userInputViewKey"
#define kCellTypeTextField @"cellTypeTextField"
#define kCellTypeSwitch @"cellTypeSwitch"
#define KCellTypeHelp @"cellTypeHelp"

@interface OWLoginViewController ()

@end

@implementation OWLoginViewController
@synthesize emailTextField, passwordTextField, loginButton, cancelButton, tableViewArray, loginViewTableView;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = REGISTER_STRING;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setUpFields];
    
    
    loginViewTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    loginViewTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [loginViewTableView setDelegate:self];
    [loginViewTableView setDataSource:self];
    [self.view addSubview:loginViewTableView];
}

- (UIColor*) textFieldTextColor {
    return [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
}

-(void)setUpFields
{
    //tableViewArray = [[NSMutableArray alloc] init];
    
    
    self.emailTextField = [[UITextField alloc] init];
    self.emailTextField.delegate = self;
    //self.usernameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.emailTextField.returnKeyType = UIReturnKeyDone;
    self.emailTextField.textColor = self.textFieldTextColor;
    self.emailTextField.placeholder = REQUIRED_STRING;
    
    [self addCellinfoWithSection:0 row:0 labelText:EMAIL_STRING cellType:kCellTypeTextField userInputView:self.emailTextField];
    
    
    self.passwordTextField = [[UITextField alloc] init];
    self.passwordTextField.delegate = self;
    //self.passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
    self.passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordTextField.textColor = self.textFieldTextColor;
    self.passwordTextField.placeholder = REQUIRED_STRING;
    
    [self addCellinfoWithSection:0 row:1 labelText:PASSWORD_STRING cellType:kCellTypeTextField userInputView:self.passwordTextField];
    
    
    self.loginButton = [[UIBarButtonItem alloc] initWithTitle:LOGIN_STRING style:UIBarButtonItemStyleDone target:self action:@selector(loginButtonPressed:)];
    self.navigationItem.rightBarButtonItem = loginButton;
    
    self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:CANCEL_STRING style:UIBarButtonItemStyleBordered target:self action:@selector(cancelPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
}

-(void)addCellinfoWithSection:(NSInteger)section row:(NSInteger)row labelText:(id)text cellType:(NSString *)type userInputView:(UIView *)inputView;
{
    if (!tableViewArray) {
        self.tableViewArray = [[NSMutableArray alloc] init];
        //[self.tableViewArray setObject:[[NSMutableArray alloc] init] atIndexedSubscript:section];
        
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

    }
}

- (void)cancelPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
