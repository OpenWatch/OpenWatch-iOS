//
//  OWCharacterCountdownView.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/10/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWCharacterCountdownView : UIView

@property (nonatomic) NSUInteger maxCharacters;
@property (nonatomic, strong) UILabel *countLabel;

- (BOOL) updateText:(NSString*)text; // returns true if you can type more characters

@end
