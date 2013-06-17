//
//  OWStoryViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 1/14/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWStoryViewController.h"
#import "OWStory.h"
#import "OWUtilities.h"
#import "OWAccountAPIClient.h"
#import "NSString+HTML.h"
#import "BrowserViewController.h"
#import "OWAppDelegate.h"
#import "MBProgressHUD.h"
#import "OWStrings.h"

#define PADDING 10.0f

@interface OWStoryViewController ()

@end

@implementation OWStoryViewController
@synthesize blurbLabel, bodyWebView, titleLabel, scrollView, authorLabel, dateLabel;

- (void) dealloc {
    if ([bodyWebView isLoading]) {
        [bodyWebView stopLoading];
    }
    self.bodyWebView.delegate = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.scrollView = [[UIScrollView alloc] init];
        [self.view addSubview:scrollView];
        [self setupLabels];
        [self setupTextView];
    }
    return self;
}

- (void) setupLabels {
    self.titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:@"Palatino-Bold" size:28.0f];

    self.blurbLabel = [[UILabel alloc] init];
    blurbLabel.backgroundColor = [UIColor clearColor];
    blurbLabel.font = [UIFont fontWithName:@"Palatino-BoldItalic" size:18.0f];
    
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.font = [UIFont fontWithName:@"Palatino-Roman" size:18.0f];
    self.dateLabel.backgroundColor = [UIColor clearColor];
    self.dateLabel.textAlignment = NSTextAlignmentRight;
    self.authorLabel = [[UILabel alloc] init];
    self.authorLabel.font = [UIFont fontWithName:@"Palatino-Bold" size:18.0f];
    self.authorLabel.backgroundColor = [UIColor clearColor];
    self.authorLabel.textAlignment = NSTextAlignmentLeft;
    
    [self.scrollView addSubview:titleLabel];
    [self.scrollView addSubview:blurbLabel];
    [self.scrollView addSubview:dateLabel];
    [self.scrollView addSubview:authorLabel];
}


- (void) setupTextView {
    self.bodyWebView = [[UIWebView alloc] init];
    self.bodyWebView.scrollView.scrollEnabled = NO;
    self.bodyWebView.delegate = self;
    self.bodyWebView.backgroundColor = [UIColor clearColor];
    self.bodyWebView.opaque = NO;
    [self.scrollView addSubview:bodyWebView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self refreshFields];
}

- (void) resizeFrames {
    self.scrollView.frame = self.view.bounds;
    CGFloat width = self.view.frame.size.width;
    CGFloat labelHeight = 30.0f;
    //CGFloat height = self.view.frame.size.height;
    self.titleLabel.frame = CGRectMake(PADDING, PADDING, width-PADDING, labelHeight);
    [self resizeLabel:titleLabel];
    self.blurbLabel.frame = CGRectMake(PADDING, [OWUtilities bottomOfView:titleLabel]+PADDING, width-PADDING, labelHeight);
    [self resizeLabel:blurbLabel];
    CGRect blurbFrame = blurbLabel.frame;
    self.blurbLabel.frame = CGRectMake(blurbFrame.origin.x, blurbFrame.origin.y, blurbFrame.size.width, blurbFrame.size.height+20);
    
    CGFloat dateAndBylineYOrigin = [OWUtilities bottomOfView:blurbLabel]+5;
    CGFloat dateAndBylineWidth = (width-PADDING)/2;
    self.authorLabel.frame = CGRectMake(PADDING, dateAndBylineYOrigin, dateAndBylineWidth, labelHeight);
    self.dateLabel.frame = CGRectMake(dateAndBylineWidth, dateAndBylineYOrigin, dateAndBylineWidth, labelHeight);
    
    CGFloat bodyTextViewYOrigin = [OWUtilities bottomOfView:dateLabel];
    self.bodyWebView.frame = CGRectMake(0, bodyTextViewYOrigin, width, self.bodyWebView.scrollView.contentSize.height);
    self.scrollView.contentSize = CGSizeMake(width, titleLabel.frame.size.height+blurbLabel.frame.size.height+bodyWebView.frame.size.height);
}

//http://stackoverflow.com/questions/1054558/vertically-align-text-within-a-uilabel/1054681#1054681
- (void) resizeLabel:(UILabel*)myLabel {
    myLabel.textAlignment = NSTextAlignmentLeft;
    
    [myLabel setNumberOfLines: 0];
    [myLabel sizeToFit];
    
    CGRect myFrame = myLabel.frame;
    // Resize the frame's width to 280 (320 - margins)
    // width could also be myOriginalLabelFrame.size.width
    myFrame = CGRectMake(myFrame.origin.x, myFrame.origin.y, self.view.frame.size.width-PADDING*2, myFrame.size.height);
    myLabel.frame = myFrame;
}

- (void) refreshFields {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWStory *story = (OWStory*)[context existingObjectWithID:self.mediaObjectID error:nil];
    self.title = story.title;
    self.titleLabel.text = story.title;
    self.authorLabel.text = [NSString stringWithFormat:@"%@ %@.",BY_STRING, story.user.username];
    if (story.blurb) {
        self.blurbLabel.text = story.blurb;
    }
    if (story.firstPostedDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        self.dateLabel.text = [dateFormatter stringFromDate:story.firstPostedDate];
    }
    if (story.body) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSString *decodedString = [story.body stringByDecodingHTMLEntities];
        NSString *bodyHTML = [NSString stringWithFormat:@"<html><body><div style=\"font-family: Palatino, Georgia, 'Times New Roman', serif; font-size:18px; line-height: 22px;\">%@</div></body></html>", decodedString];
        [self.bodyWebView loadHTMLString:bodyHTML baseURL:[NSURL URLWithString:@"file:///body.html"]];
    }
    [self resizeFrames];
}

- (void) setMediaObjectID:(NSManagedObjectID *)newMediaObjectID {
    [super setMediaObjectID:newMediaObjectID];
    [self refreshFields];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWStory *story = (OWStory*)[context existingObjectWithID:self.mediaObjectID error:nil];
    if (!story.body) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [[OWAccountAPIClient sharedClient] getObjectWithObjectID:self.mediaObjectID success:^(NSManagedObjectID *objectID) {
        [self refreshFields];
    } failure:^(NSString *reason) {
        
    } retryCount:kOWAccountAPIClientDefaultRetryCount];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    if (navigationType == UIWebViewNavigationTypeOther) {
        if ([[url scheme] isEqualToString:@"file"]) {
            return YES;
        }
    }
    [OW_APP_DELEGATE openURL:url];
    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *output = [webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"];
    CGFloat contentHeight = [output floatValue]+10;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, contentHeight + bodyWebView.frame.origin.y);
    CGRect fr = bodyWebView.frame;
    fr.size = CGSizeMake(bodyWebView.frame.size.width, contentHeight);
    bodyWebView.frame = fr;
    //NSLog(@"height: %@", output);
}

@end
