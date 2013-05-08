//
//  OWPreviewView.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/8/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface OWPreviewView : UIView

@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSManagedObjectID *objectID;

@end
