//
//  OWSegmentingAppleEncoder.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWAppleEncoder.h"

@interface OWSegmentingAppleEncoder : OWAppleEncoder

@property (nonatomic, retain) AVAssetWriter *queuedAssetWriter;
@property (nonatomic, retain) AVAssetWriterInput *queuedAudioEncoder;
@property (nonatomic, retain) AVAssetWriterInput *queuedVideoEncoder;

@property (atomic) int videoBPS; // bits/sec
@property (atomic) int audioBPS; // bits/sec

@property (nonatomic, retain) NSTimer *segmentationTimer;

- (id) initWithURL:(NSURL *)url segmentationInterval:(NSTimeInterval)timeInterval;

@end
