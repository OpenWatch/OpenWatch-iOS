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

@property (atomic, retain) AVAssetWriter *queuedAssetWriter;
@property (atomic, retain) AVAssetWriterInput *queuedAudioEncoder;
@property (atomic, retain) AVAssetWriterInput *queuedVideoEncoder;
@property (atomic) BOOL shouldBeRecording;
@property (atomic) NSUInteger segmentCount;

@property (atomic) int videoBPS; // bits/sec
@property (atomic) int audioBPS; // bits/sec

@property (atomic, retain) NSTimer *segmentationTimer;

- (id) initWithURL:(NSURL *)url segmentationInterval:(NSTimeInterval)timeInterval;

@end
