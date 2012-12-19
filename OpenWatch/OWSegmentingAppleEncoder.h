//
//  OWSegmentingAppleEncoder.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWAppleEncoder.h"

@interface OWSegmentingAppleEncoder : OWAppleEncoder {
    dispatch_queue_t segmentingQueue;
    NSTimeInterval segmentationInterval;
}

@property (nonatomic, retain) AVAssetWriter *queuedAssetWriter;
@property (nonatomic, retain) AVAssetWriterInput *queuedAudioEncoder;
@property (nonatomic, retain) AVAssetWriterInput *queuedVideoEncoder;
@property (nonatomic) BOOL shouldBeRecording;
@property (nonatomic) NSUInteger segmentCount;

@property (nonatomic) int videoBPS; // bits/sec
@property (nonatomic) int audioBPS; // bits/sec

@property (nonatomic, retain) NSTimer *segmentationTimer;

- (id) initWithURL:(NSURL *)url segmentationInterval:(NSTimeInterval)timeInterval;

@end
