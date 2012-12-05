//
//  OWSegmentingAppleEncoder.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWSegmentingAppleEncoder.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "OWCaptureAPIClient.h"
#import "OWRecordingController.h"

#define kMinVideoBitrate 100000
#define kMaxVideoBitrate 400000

@implementation OWSegmentingAppleEncoder
@synthesize segmentationTimer, queuedAssetWriter;
@synthesize queuedAudioEncoder, queuedVideoEncoder;
@synthesize audioBPS, videoBPS;

- (void) dealloc {
    if (self.segmentationTimer) {
        [self performSelectorOnMainThread:@selector(invalidateTimer) withObject:nil waitUntilDone:NO];
    }
    dispatch_release(segmentingQueue);
}

- (void) finishEncoding {
    if (self.segmentationTimer) {
        [self performSelectorOnMainThread:@selector(invalidateTimer) withObject:nil waitUntilDone:NO];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super finishEncoding];
    //[[OWCaptureAPIClient sharedClient] finishedRecording:self.recording];
}

- (void) invalidateTimer {
    [self.segmentationTimer invalidate];
    self.segmentationTimer = nil;
}

- (void) createAndScheduleTimer {
    self.segmentationTimer = [NSTimer timerWithTimeInterval:segmentationInterval target:self selector:@selector(segmentRecording:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:segmentationTimer forMode:NSDefaultRunLoopMode];
}

- (id) initWithURL:(NSURL *)url segmentationInterval:(NSTimeInterval)timeInterval {
    if (self = [super init]) {
        segmentationInterval = timeInterval;
        [self performSelectorOnMainThread:@selector(createAndScheduleTimer) withObject:nil waitUntilDone:NO];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedBandwidthUpdateNotification:) name:kOWCaptureAPIClientBandwidthNotification object:nil];
        segmentingQueue = dispatch_queue_create("Segmenting Queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void) receivedBandwidthUpdateNotification:(NSNotification*)notification {
    double bps = [[[notification userInfo] objectForKey:@"bps"] doubleValue];
    double vbps = (bps*0.5) - audioBPS;
    if (vbps < kMinVideoBitrate) {
        vbps = kMinVideoBitrate;
    }
    if (vbps > kMaxVideoBitrate) {
        vbps = kMaxVideoBitrate;
    }
    self.videoBPS = vbps;
    //self.videoBPS = videoBPS * 0.75;
    NSLog(@"bps: %f\tvideoBPS: %d\taudioBPS: %d", bps, videoBPS, audioBPS);
}



- (void) segmentRecording:(NSTimer*)timer {
    AVAssetWriter *tempAssetWriter = self.assetWriter;
    AVAssetWriterInput *tempAudioEncoder = self.audioEncoder;
    AVAssetWriterInput *tempVideoEncoder = self.videoEncoder;
    self.assetWriter = queuedAssetWriter;
    self.audioEncoder = queuedAudioEncoder;
    self.videoEncoder = queuedVideoEncoder;
    //NSLog(@"Switching encoders");
    
    dispatch_async(segmentingQueue, ^{
        OWLocalRecording *recording = [OWRecordingController recordingForObjectID:self.recordingID];
        if (tempAssetWriter.status == AVAssetWriterStatusWriting) {
            [tempAudioEncoder markAsFinished];
            [tempVideoEncoder markAsFinished];
            if(![tempAssetWriter finishWriting]) {
                [self showError:[tempAssetWriter error]];
            } else {
                [self uploadFileURL:tempAssetWriter.outputURL];
            }
        }
        if (self.readyToRecordAudio && self.readyToRecordVideo) {
            NSError *error = nil;
            self.queuedAssetWriter = [[AVAssetWriter alloc] initWithURL:[recording urlForNextSegment] fileType:(NSString *)kUTTypeMPEG4 error:&error];
            if (error) {
                [self showError:error];
            }
            self.queuedVideoEncoder = [self setupVideoEncoderWithAssetWriter:self.queuedAssetWriter formatDescription:videoFormatDescription bitsPerSecond:videoBPS];
            self.queuedAudioEncoder = [self setupAudioEncoderWithAssetWriter:self.queuedAssetWriter formatDescription:audioFormatDescription bitsPerSecond:audioBPS];
            //NSLog(@"Encoder switch finished");

        }
    });
}



- (void) setupVideoEncoderWithFormatDescription:(CMFormatDescriptionRef)formatDescription bitsPerSecond:(int)bps {
    OWLocalRecording *recording = [OWRecordingController recordingForObjectID:self.recordingID];
    videoFormatDescription = formatDescription;
    videoBPS = bps;
    if (!self.assetWriter) {
        NSError *error = nil;
        self.assetWriter = [[AVAssetWriter alloc] initWithURL:[recording urlForNextSegment] fileType:(NSString *)kUTTypeMPEG4 error:&error];
        if (error) {
            [self showError:error];
        }
    }
    self.videoEncoder = [self setupVideoEncoderWithAssetWriter:self.assetWriter formatDescription:formatDescription bitsPerSecond:bps];
    
    if (!queuedAssetWriter) {
        NSError *error = nil;
        self.queuedAssetWriter = [[AVAssetWriter alloc] initWithURL:[recording urlForNextSegment] fileType:(NSString *)kUTTypeMPEG4 error:&error];
        if (error) {
            [self showError:error];
        }
    }
    self.queuedVideoEncoder = [self setupVideoEncoderWithAssetWriter:self.queuedAssetWriter formatDescription:formatDescription bitsPerSecond:bps];
    self.readyToRecordVideo = YES;
}

- (void) setupAudioEncoderWithFormatDescription:(CMFormatDescriptionRef)formatDescription bitsPerSecond:(int)bps {
    OWLocalRecording *recording = [OWRecordingController recordingForObjectID:self.recordingID];
    audioFormatDescription = formatDescription;
    audioBPS = bps;
    if (!self.assetWriter) {
        NSError *error = nil;
        self.assetWriter = [[AVAssetWriter alloc] initWithURL:[recording urlForNextSegment] fileType:(NSString *)kUTTypeMPEG4 error:&error];
        if (error) {
            [self showError:error];
        }
    }
    self.audioEncoder = [self setupAudioEncoderWithAssetWriter:self.assetWriter formatDescription:formatDescription bitsPerSecond:bps];
    
    if (!queuedAssetWriter) {
        NSError *error = nil;
        self.queuedAssetWriter = [[AVAssetWriter alloc] initWithURL:[recording urlForNextSegment] fileType:(NSString *)kUTTypeMPEG4 error:&error];
        if (error) {
            [self showError:error];
        }
    }
    self.queuedAudioEncoder = [self setupAudioEncoderWithAssetWriter:self.queuedAssetWriter formatDescription:formatDescription bitsPerSecond:bps];
    self.readyToRecordAudio = YES;
}

- (void) uploadFileURL:(NSURL*)url {
    OWLocalRecording *recording = [OWRecordingController recordingForObjectID:self.recordingID];
    OWCaptureAPIClient *captureClient = [OWCaptureAPIClient sharedClient];
    [captureClient uploadFileURL:url recording:recording.objectID priority:NSOperationQueuePriorityVeryHigh];
    [recording saveMetadata];
}



@end
