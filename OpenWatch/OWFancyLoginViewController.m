//
//  OWFancyLoginViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 4/4/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWFancyLoginViewController.h"
#import "OWUtilities.h"
#import <QuartzCore/QuartzCore.h>
#import "OWSettingsController.h"
#import "OWAccountAPIClient.h"
#import "OWAppDelegate.h"
#import "OWCheckpoints.h"
#import "BButton.h"
#import "OWConstants.h"
#import "OWStrings.h"
#import "OWFeedViewController.h"

#define kOffsetWithPassword 208
#define kOffset 145

@interface OWFancyLoginViewController ()

@end

@implementation OWFancyLoginViewController
@synthesize backgroundImageView, logoView, blurbLabel, emailField, startButton, scrollView, passwordField, activityIndicatorView, processingLogin, keyboardControls, forgotPasswordButton;


- (id)init
{
    self = [super init];
    if (self) {
        self.emailField = [[UITextField alloc] init];
        self.emailField.delegate = self;
        self.blurbLabel = [[UILabel alloc] init];
        self.logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"openwatch-light.png"]];
        self.scrollView = [[UIScrollView alloc] init];
        self.startButton = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypeSuccess];
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.processingLogin = NO;
        self.forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.forgotPasswordButton setTitle:FORGOT_PASSWORD_STRING forState:UIControlStateNormal];
        self.forgotPasswordButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        self.forgotPasswordButton.titleLabel.textColor = [UIColor whiteColor];
        self.forgotPasswordButton.titleLabel.shadowColor = [UIColor blackColor];
        self.forgotPasswordButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        self.forgotPasswordButton.titleLabel.textAlignment = NSTextAlignmentRight;
        [self.forgotPasswordButton addTarget:self action:@selector(forgotPassword:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void) forgotPassword:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kPasswordResetURL] forceOpenInSafari:YES];
}

- (void) loadView {
    [super loadView];
    self.backgroundImageView = [[OWKenBurnsView alloc] initWithFrame:self.view.frame];
    self.activityIndicatorView.layer.opacity = 0.0f;
    self.logoView.contentMode = UIViewContentModeScaleAspectFit;
    self.blurbLabel.text = OPENWATCH_WELCOME_STRING;
    self.blurbLabel.backgroundColor = [UIColor clearColor];
    self.blurbLabel.textColor = [UIColor whiteColor];
    self.blurbLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    self.blurbLabel.shadowColor = [UIColor blackColor];
    self.blurbLabel.shadowOffset = CGSizeMake(0, -1);
    self.blurbLabel.numberOfLines = 0;
    self.emailField.placeholder = EMAIL_ADDRESS_STRING;
    self.emailField.returnKeyType = UIReturnKeyGo;
    self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailField.borderStyle = UITextBorderStyleRoundedRect;
    self.emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    NSString *getStarted = [NSString stringWithFormat:@"%@ →", GET_STARTED_STRING];
    [self.startButton setTitle:getStarted forState:UIControlStateNormal];
    [self.startButton addTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSArray *fields = @[emailField];
    
    self.keyboardControls = [[BSKeyboardControls alloc] initWithFields:fields];
    self.keyboardControls.delegate = self;
    
    [self.view addSubview:scrollView];
    
    [self.scrollView addSubview:backgroundImageView];
    [self.scrollView addSubview:logoView];
    [self.scrollView addSubview:blurbLabel];
    [self.scrollView addSubview:emailField];
    [self.scrollView addSubview:startButton];
    [self.scrollView addSubview:forgotPasswordButton];
    [self.startButton addSubview:activityIndicatorView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.view addSubview:self.scrollView];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [TestFlight passCheckpoint:FANCY_LOGIN_CHECKPOINT];

    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = self.view.bounds.size;
    CGFloat xPadding = 20.0f;
    CGFloat yPadding = 20.0f;
    CGFloat logoWidth = self.view.frame.size.width - xPadding * 2;
    self.logoView.frame = CGRectMake(xPadding, yPadding, logoWidth, 100.0f);
    self.blurbLabel.frame = CGRectMake(xPadding, [OWUtilities bottomOfView:logoView] + 25, logoWidth, 65);
    self.emailField.frame = CGRectMake(xPadding, [OWUtilities bottomOfView:blurbLabel] + 20, logoWidth, 27);
    self.startButton.frame = CGRectMake(xPadding, [OWUtilities bottomOfView:emailField] + 20, logoWidth, 50);
    CGFloat forgotWidth = 120;
    self.forgotPasswordButton.frame = CGRectMake([OWUtilities rightOfView:startButton] - forgotWidth, [OWUtilities bottomOfView:startButton] + 20, forgotWidth, 30);
    
    self.activityIndicatorView.frame = CGRectMake(floorf(logoWidth * .75), startButton.frame.size.height / 2 - activityIndicatorView.frame.size.height/2, self.activityIndicatorView.frame.size.width, self.activityIndicatorView.frame.size.height);
    
    self.backgroundImageView.frame = self.view.bounds;
    [backgroundImageView zoomImageView:backgroundImageView.currentImageView];
    [backgroundImageView startTimer];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    CGFloat offset = kOffset;
    if (self.passwordField) {
        offset = kOffsetWithPassword;
    }
    [self.scrollView setContentOffset:CGPointMake(0, offset) animated:YES];
    [self.keyboardControls setActiveField:textField];
}

/*
- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
}
*/

- (void) textFieldDidEndEditing:(UITextField *)textField {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [self startButtonPressed:nil];
    return YES;
}

- (void) showPasswordField {
    if (!self.passwordField) {
        self.passwordField = [[UITextField alloc] init];
        self.keyboardControls.fields = @[emailField, passwordField];
        self.passwordField.delegate = self;
        self.passwordField.placeholder = PASSWORD_STRING;
        self.passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.passwordField.secureTextEntry = YES;
        self.passwordField.returnKeyType = UIReturnKeyGo;
        self.passwordField.borderStyle = UITextBorderStyleRoundedRect;
        [self.scrollView addSubview:passwordField];
        self.passwordField.layer.opacity = 0.0f;
        CGRect passwordFrame = self.emailField.frame;
        passwordFrame.origin.y = [OWUtilities bottomOfView:emailField] + 20;
        self.passwordField.frame = passwordFrame;
        [UIView animateWithDuration:0.5 animations:^{
            CGRect startButtonFrame = self.startButton.frame;
            CGRect forgotFrame = self.forgotPasswordButton.frame;
            startButtonFrame.origin.y = [OWUtilities bottomOfView:passwordField] + 20;
            self.startButton.frame = startButtonFrame;
            forgotFrame.origin.y = [OWUtilities bottomOfView:startButton] + 20;
            self.forgotPasswordButton.frame = forgotFrame;
            NSString *login = [NSString stringWithFormat:@"%@ →", LOGIN_STRING];
            [self.startButton setTitle:login forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            [self.scrollView setContentOffset:CGPointMake(0, kOffsetWithPassword) animated:YES];
        }];
        [UIView animateWithDuration:0.5 delay:0.2 options:nil animations:^{
            self.passwordField.layer.opacity = 1.0f;
        } completion:^(BOOL finished) {
            [self.passwordField becomeFirstResponder];
            self.keyboardControls.activeField = passwordField;
        }];
    }
}

- (void) startButtonPressed:(id)sender {
    [self processLogin];
    //[self.emailField resignFirstResponder];
}

- (void) setProcessingLogin:(BOOL)isProcessingLogin {
    processingLogin = isProcessingLogin;
    
    [self showActivityIndicator:processingLogin];
}

- (void) showActivityIndicator:(BOOL)enabled {
    CGFloat newAlpha = 0.0f;
    if (enabled) {
        newAlpha = 1.0f;
        [self.activityIndicatorView startAnimating];
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.activityIndicatorView.layer.opacity = newAlpha;
    } completion:^(BOOL finished) {
        if (!enabled) {
            [self.activityIndicatorView stopAnimating];
        }
    }];
}

- (void) processLogin {
    if (processingLogin) {
        return;
    }
    OWSettingsController *settingsController = [OWSettingsController sharedInstance];
    OWAccount *account = settingsController.account;
    [account clearAccountData];

    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    account.email = email;

    if (email.length == 0 || [email rangeOfString:@"@"].location == NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LOGIN_ERROR_STRING message:ENTER_VALID_EMAIL_STRING delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self setProcessingLogin:YES];
    
    if (password.length > 0) {
        account.password = password;
        [[OWAccountAPIClient sharedClient] loginWithAccount:account success:^{
            [self setProcessingLogin:NO];
            [self showHomeScreen];
        } failure:^(NSString *reason) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LOGIN_ERROR_STRING message:CHECK_CREDENTIALS_STRING delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil];
            [alert show];
            [self setProcessingLogin:NO];
        }];
    } else {
        [[OWAccountAPIClient sharedClient] checkEmailAvailability:email callback:^(BOOL available) {
            if (available) {
                [[OWAccountAPIClient sharedClient] quickSignupWithAccount:account callback:^(BOOL success) {
                    [self setProcessingLogin:NO];
                    if (success) {
                        [self showHomeScreen];
                    }
                }];
            } else {
                [self showPasswordField];
                [self setProcessingLogin:NO];
            }
        }];
    }
}

- (void) showHomeScreen {
    OWFeedViewController *feedView = OW_APP_DELEGATE.feedViewController;
    [self.navigationController setViewControllers:@[feedView] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyControls
{
    //[self processLogin];
    [keyControls.activeField resignFirstResponder];
}

@end
