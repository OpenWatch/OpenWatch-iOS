//
//  OWUtilities.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/29/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWUtilities.h"
#import <QuartzCore/QuartzCore.h>
#import "OWStrings.h"

@implementation OWUtilities

+ (UIColor*) oldColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    CGFloat max = 255.0f;
    return [UIColor colorWithRed:red/max green:green/max blue:blue/max alpha:alpha];
}

+ (UIColor*) stoneBackgroundPattern {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"stone.png"]];
}

+ (UIImage*) navigationBarBackgroundImage {
    return [UIImage imageNamed:@"navbar.png"];
}

+ (void) applyShadowToView:(UIView *)view {
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOpacity = 1;
    view.layer.shadowOffset = CGSizeMake(0,1);
    CGRect shadowPath = CGRectMake(view.layer.bounds.origin.x, view.layer.bounds.size.height - 6, view.layer.bounds.size.width, 4);
    view.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowPath].CGPath;
    view.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    view.layer.shouldRasterize = YES;
}

+ (void) styleNavigationController:(UINavigationController*)navigationController {
    UINavigationBar *navigationBar = navigationController.navigationBar;
    UIImage *image = [self navigationBarBackgroundImage];
    [navigationBar setBackgroundImage:image forBarMetrics: UIBarMetricsDefault];
    navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    navigationController.navigationBar.tintColor = [OWUtilities navigationBarColor];
}

+ (UIColor*) navigationBarColor {
    //238	207	161
    //return [UIColor brownColor];
    return [OWUtilities oldColorWithRed:220 green:220 blue:220 alpha:1.0];
}

+ (UIColor*) doneButtonColor {
    return [UIColor colorWithRed:0.0f green:0.8f blue:0.0f alpha:1.0f];
}

+ (UIColor*) textFieldTextColor {
    return [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
}

+ (NSDateFormatter*) utcDateFormatter {
    static NSDateFormatter *utcDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        utcDateFormatter = [[NSDateFormatter alloc] init];
        utcDateFormatter.dateFormat = @"yyyy-MM-dd' 'HH:mm:ss";
        utcDateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    });
    return utcDateFormatter;
}

+ (TTTTimeIntervalFormatter*) timeIntervalFormatter {
    static TTTTimeIntervalFormatter *timeFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
    });
    return timeFormatter;
}

+ (TTTTimeIntervalFormatter*) timeLeftIntervalFormatter {
    static TTTTimeIntervalFormatter *timeLeftFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeLeftFormatter = [[TTTTimeIntervalFormatter alloc] init];
        timeLeftFormatter.futureDeicticExpression = LEFT_STRING;
    });
    return timeLeftFormatter;
}

+ (void) styleLabel:(UILabel*) label {
    label.textColor = [UIColor darkTextColor];
    label.shadowColor = [UIColor lightGrayColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.backgroundColor = [UIColor clearColor];
}

+ (NSDateFormatter*) humanizedDateFormatter {
    static NSDateFormatter *humanizedDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        humanizedDateFormatter = [[NSDateFormatter alloc] init];
        humanizedDateFormatter.dateStyle = NSDateFormatterMediumStyle;
        humanizedDateFormatter.timeStyle = NSDateFormatterShortStyle;
        humanizedDateFormatter.timeZone = [NSTimeZone localTimeZone];
        humanizedDateFormatter.locale = [NSLocale currentLocale];
    });
    return humanizedDateFormatter;
}

+ (UIColor*) greyTextColor {
    return [OWUtilities greyColorWithGreyness:0.3];
}

+ (UIColor*) greyColorWithGreyness:(CGFloat)greyness {
    return [UIColor colorWithRed:greyness green:greyness blue:greyness alpha:1.0f];
}

+ (NSString*) websiteBaseURLString {
    return @"https://openwatch.net";
}

+ (NSString*) apiBaseURLString { 
    //return @"http://10.0.1.30:8000/";
    //return @"https://openwatch.net/";
    return @"https://staging.openwatch.net/";
}

+ (NSString*) captureBaseURLString {
    //return @"https://capture.openwatch.net/";
    return @"https://capture-staging.openwatch.net/";
}

+ (CGFloat) bottomOfView:(UIView *)view {
    return view.frame.origin.y + view.frame.size.height;
}

+ (CGFloat) rightOfView:(UIView *)view {
    return view.frame.origin.x + view.frame.size.width;
}

/**
 Thanks to Paul Solt for supplying these background images and container view properties
 */
+ (WEPopoverContainerViewProperties *)improvedContainerViewProperties {
	
	WEPopoverContainerViewProperties *props = [[WEPopoverContainerViewProperties alloc] init];
	NSString *bgImageName = nil;
	CGFloat bgMargin = 0.0;
	CGFloat bgCapSize = 0.0;
	CGFloat contentMargin = 4.0;
	
	bgImageName = @"popoverBg.png";
	
	// These constants are determined by the popoverBg.png image file and are image dependent
	bgMargin = 13; // margin width of 13 pixels on all sides popoverBg.png (62 pixels wide - 36 pixel background) / 2 == 26 / 2 == 13
	bgCapSize = 31; // ImageSize/2  == 62 / 2 == 31 pixels
	
	props.leftBgMargin = bgMargin;
	props.rightBgMargin = bgMargin;
	props.topBgMargin = bgMargin;
	props.bottomBgMargin = bgMargin;
	props.leftBgCapSize = bgCapSize;
	props.topBgCapSize = bgCapSize;
	props.bgImageName = bgImageName;
	props.leftContentMargin = contentMargin;
	props.rightContentMargin = contentMargin - 1; // Need to shift one pixel for border to look correct
	props.topContentMargin = contentMargin;
	props.bottomContentMargin = contentMargin;
	
	props.arrowMargin = 4.0;
	
	props.upArrowImageName = @"popoverArrowUp.png";
	props.downArrowImageName = @"popoverArrowDown.png";
	props.leftArrowImageName = @"popoverArrowLeft.png";
	props.rightArrowImageName = @"popoverArrowRight.png";
	return props;
}

+ (void) logFrame:(CGRect)frame {
    NSLog(@"frame: (%f, %f, %f, %f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
}

//http://stackoverflow.com/a/447065/805882
+ (CGRect) constrainedFrameForLabel:(UILabel*)label width:(CGFloat)width origin:(CGPoint)origin {
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    
    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    newFrame.size.width = width;
    newFrame.origin.x = origin.x;
    newFrame.origin.y = origin.y;
    return newFrame;
}

+(UIBarButtonItem *)barItemWithImage:(UIImage *)image target:(id)target action:(SEL)action
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake(0, 0, 45, 40);
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:button];
    return item;
}

@end
