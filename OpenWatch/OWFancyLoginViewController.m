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

@interface OWFancyLoginViewController ()

@end

@implementation OWFancyLoginViewController
@synthesize backgroundImageView, logoView, blurbLabel, emailField, startButton, scrollView, passwordField, activityIndicatorView, processingLogin;


- (id)init
{
    self = [super init];
    if (self) {
        self.emailField = [[UITextField alloc] init];
        self.emailField.delegate = self;
        self.blurbLabel = [[UILabel alloc] init];
        self.logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"openwatch-light.png"]];
        self.scrollView = [[UIScrollView alloc] init];
        self.startButton = [OWUtilities bigGreenButton];
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.processingLogin = NO;
    }
    return self;
}

- (void) loadView {
    [super loadView];
    self.backgroundImageView = [[OWKenBurnsView alloc] initWithFrame:self.view.frame];
    self.activityIndicatorView.layer.opacity = 0.0f;
    self.logoView.contentMode = UIViewContentModeScaleAspectFit;
    self.blurbLabel.text = @"Welcome to OpenWatch, a social muckraking platform. Enter your email address to get started.";
    self.blurbLabel.backgroundColor = [UIColor clearColor];
    self.blurbLabel.textColor = [UIColor whiteColor];
    self.blurbLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    self.blurbLabel.shadowColor = [UIColor blackColor];
    self.blurbLabel.shadowOffset = CGSizeMake(0, -1);
    self.blurbLabel.numberOfLines = 0;
    self.emailField.placeholder = @"Email Address";
    self.emailField.returnKeyType = UIReturnKeyGo;
    self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailField.borderStyle = UITextBorderStyleRoundedRect;
    [self.startButton setTitle:@"Get Started →" forState:UIControlStateNormal];
    [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startButton setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.startButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [self.startButton addTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:scrollView];
    
    [self.scrollView addSubview:backgroundImageView];
    [self.scrollView addSubview:logoView];
    [self.scrollView addSubview:blurbLabel];
    [self.scrollView addSubview:emailField];
    [self.scrollView addSubview:startButton];
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
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = self.view.bounds.size;
    CGFloat xPadding = 20.0f;
    CGFloat yPadding = 20.0f;
    CGFloat logoWidth = self.view.frame.size.width - xPadding * 2;
    self.logoView.frame = CGRectMake(xPadding, yPadding, logoWidth, 100.0f);
    self.blurbLabel.frame = CGRectMake(xPadding, [OWUtilities bottomOfView:logoView] + 20, logoWidth, 100);
    self.emailField.frame = CGRectMake(xPadding, [OWUtilities bottomOfView:blurbLabel] + 20, logoWidth, 30);
    self.startButton.frame = CGRectMake(xPadding, [OWUtilities bottomOfView:emailField] + 20, logoWidth, 50);
    
    self.activityIndicatorView.frame = CGRectMake(floorf(logoWidth * .75), startButton.frame.size.height / 2 - activityIndicatorView.frame.size.height/2, self.activityIndicatorView.frame.size.width, self.activityIndicatorView.frame.size.height);
    
    self.backgroundImageView.frame = self.view.bounds;
    [backgroundImageView zoomImageView:backgroundImageView.currentImageView];
    [backgroundImageView startTimer];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [self.scrollView setContentOffset:CGPointMake(0, 145) animated:YES];
}

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
        self.passwordField.delegate = self;
        self.passwordField.placeholder = @"Password";
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
            startButtonFrame.origin.y = [OWUtilities bottomOfView:passwordField] + 20;
            self.startButton.frame = startButtonFrame;
            [self.startButton setTitle:@"Login →" forState:UIControlStateNormal];
        }];
        [UIView animateWithDuration:0.5 delay:0.2 options:nil animations:^{
            self.passwordField.layer.opacity = 1.0f;
        } completion:nil];
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
    
    if ([email rangeOfString:@"@"].location == NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Please enter a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self setProcessingLogin:YES];
    
    if (password.length > 0) {
        account.email = email;
        account.password = password;
        [[OWAccountAPIClient sharedClient] loginWithAccount:account success:^{
            [self.navigationController pushViewController:OW_APP_DELEGATE.homeScreen animated:YES];
            [self setProcessingLogin:NO];
        } failure:^(NSString *reason) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Please check your username and password and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self setProcessingLogin:NO];
        }];
    } else {
        [[OWAccountAPIClient sharedClient] checkEmailAvailability:email callback:^(BOOL available) {
            if (available) {
                NSLog(@"Not available!");
                [self setProcessingLogin:NO];
            } else {
                [self showPasswordField];
                [self setProcessingLogin:NO];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
