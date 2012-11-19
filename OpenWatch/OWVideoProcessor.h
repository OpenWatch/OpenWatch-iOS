//
//  OWVideoProcessor.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMBufferQueue.h>
#include <math.h>
#import "OWAppleEncoder.h"
#import "OWSegmentingAppleEncoder.h"

@protocol OWVideoProcessorDelegate <NSObject>
@required
- (void)recordingWillStart;
- (void)recordingDidStart;
- (void)recordingWillStop;
- (void)recordingDidStop;
@end

@interface OWVideoProcessor : NSObject <AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> 
{  
    id <OWVideoProcessorDelegate> __weak delegate;
	
	NSMutableArray *previousSecondTimestamps;
	Float64 videoFrameRate;
	CMVideoDimensions videoDimensions;
	CMVideoCodecType videoType;

	AVCaptureConnection *audioConnection;
	AVCaptureConnection *videoConnection;
	
	dispatch_queue_t movieWritingQueue;
    
    CMFormatDescriptionRef videoFormatDescription;
    CMFormatDescriptionRef audioFormatDescription;
    
	// Only accessed on movie writing queue
	BOOL recordingWillBeStarted;
	BOOL recordingWillBeStopped;

	BOOL recording;
}

@property (readwrite, weak) id <OWVideoProcessorDelegate> delegate;

@property (readonly) Float64 videoFrameRate;
@property (readonly) CMVideoDimensions videoDimensions;
@property (readonly) CMVideoCodecType videoType;
@property (nonatomic, strong) OWAppleEncoder *appleEncoder1;
@property (nonatomic, strong) OWSegmentingAppleEncoder *appleEncoder2;
@property (nonatomic, strong) OWRecording *currentRecording;
@property (nonatomic, strong) AVCaptureSession *captureSession;

@property (nonatomic) AVCaptureVideoOrientation referenceOrientation;
@property (nonatomic) AVCaptureVideoOrientation videoOrientation;

- (void) showError:(NSError*)error;

- (void) setupAndStartCaptureSession;
- (void) stopAndTearDownCaptureSession;

- (void) startRecording;
- (void) stopRecording;

- (void) pauseCaptureSession; // Pausing while a recording is in progress will cause the recording to be stopped and saved.
- (void) resumeCaptureSession;

- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation;

@property(readonly, getter=isRecording) BOOL recording;

@end


