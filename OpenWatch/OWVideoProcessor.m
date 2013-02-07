//
//  OWVideoProcessor.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "OWVideoProcessor.h"
#import "OWCaptureAPIClient.h"
#import "OWRecordingController.h"

@interface OWVideoProcessor ()
@property (readwrite) Float64 videoFrameRate;
@property (readwrite) CMVideoDimensions videoDimensions;
@property (readwrite) CMVideoCodecType videoType;
@property (readwrite, getter=isRecording) BOOL recording;
@end

@implementation OWVideoProcessor

@synthesize delegate;
@synthesize videoFrameRate, videoDimensions, videoType;
@synthesize videoOrientation;
@synthesize recording;
@synthesize appleEncoder1, appleEncoder2;
@synthesize recordingID;
@synthesize captureSession;

- (id) init
{
    if (self = [super init]) {
        previousSecondTimestamps = [[NSMutableArray alloc] init];
    }
    return self;
}

- (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
	CGFloat angle = 0.0;
	
	switch (orientation) {
		case AVCaptureVideoOrientationPortrait:
			angle = 0.0;
			break;
		case AVCaptureVideoOrientationPortraitUpsideDown:
			angle = M_PI;
			break;
		case AVCaptureVideoOrientationLandscapeRight:
			angle = -M_PI_2;
			break;
		case AVCaptureVideoOrientationLandscapeLeft:
			angle = M_PI_2;
			break;
		default:
			break;
	}
    
	return angle;
}

- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
	CGAffineTransform transform = CGAffineTransformIdentity;
    
	// Calculate offsets from an arbitrary reference orientation (portrait)
	CGFloat orientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:orientation];
	CGFloat videoOrientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:self.videoOrientation];
	
	// Find the difference in angle between the passed in orientation and the current video orientation
	CGFloat angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
	transform = CGAffineTransformMakeRotation(angleOffset);
	
	return transform;
}

#pragma mark Utilities

- (void) calculateFramerateAtTimestamp:(CMTime) timestamp
{
	[previousSecondTimestamps addObject:[NSValue valueWithCMTime:timestamp]];
    
	CMTime oneSecond = CMTimeMake( 1, 1 );
	CMTime oneSecondAgo = CMTimeSubtract( timestamp, oneSecond );
    
	while( CMTIME_COMPARE_INLINE( [[previousSecondTimestamps objectAtIndex:0] CMTimeValue], <, oneSecondAgo ) )
		[previousSecondTimestamps removeObjectAtIndex:0];
    
	Float64 newRate = (Float64) [previousSecondTimestamps count];
	self.videoFrameRate = (self.videoFrameRate + newRate) / 2;
}

- (void)removeFile:(NSURL *)fileURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [fileURL path];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
		if (!success)
			[self showError:error];
    }
}



#pragma mark Recording







- (void) startRecording
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSDate *date = [NSDate date];
    NSString *directoryName = [NSString stringWithFormat:@"%f.recording", [date timeIntervalSince1970]];
    NSString *recordingPath = [basePath stringByAppendingPathComponent:directoryName];
    
	dispatch_async(movieWritingQueue, ^{
        OWLocalRecording *currentRecording = [OWLocalRecording recordingWithPath:recordingPath];
        self.recordingID = currentRecording.objectID;
        NSLog(@"setting objectID: %@", [self.recordingID description]);

		if ( recordingWillBeStarted || self.recording )
			return;

		recordingWillBeStarted = YES;

		// recordingDidStart is called from captureOutput:didOutputSampleBuffer:fromConnection: once the asset writer is setup
		[self.delegate recordingWillStart];
			
        [self initializeAssetWriters];
        [currentRecording startRecording];
	});
}



- (void) initializeAssetWriters {
    NSLog(@"getting objectID: %@", [self.recordingID description]);

    if (self.recordingID.isTemporaryID) {
        NSLog(@"Recording ID is temporary!");
    }
    OWLocalRecording *localRecording = [OWRecordingController localRecordingForObjectID:self.recordingID];
    
    NSLog(@"Starting asset writer for: %@", localRecording.localRecordingPath);
    // Create an asset writer
    self.appleEncoder1 = [[OWAppleEncoder alloc] initWithURL:[localRecording highQualityURL] movieFragmentInterval:CMTimeMakeWithSeconds(5, 30)];
    self.appleEncoder1.recordingID = localRecording.objectID;
    self.appleEncoder2 = [[OWSegmentingAppleEncoder alloc] initWithURL:[localRecording urlForNextSegmentWithCount:0] segmentationInterval:5.0f];
    self.appleEncoder2.recordingID = localRecording.objectID;
}

- (void) stopRecording
{

	dispatch_async(movieWritingQueue, ^{
		if ( recordingWillBeStopped || self.recording == NO)
			return;
        OWLocalRecording *localRecording = [OWRecordingController localRecordingForObjectID:self.recordingID];

		
		recordingWillBeStopped = YES;
		
		// recordingDidStop is called from saveMovieToCameraRoll
		[self.delegate recordingWillStop];
        [appleEncoder1 finishEncoding];
        recordingWillBeStopped = NO;
        self.recording = NO;
        [self.delegate recordingDidStop];
        [appleEncoder2 finishEncoding];
        [localRecording stopRecording];
        self.appleEncoder1 = nil;
        self.appleEncoder2 = nil;
	});
}

#pragma mark Capture

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection 
{	
	CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    
	if ( connection == videoConnection ) {
		
		// Get framerate
		CMTime timestamp = CMSampleBufferGetPresentationTimeStamp( sampleBuffer );
		[self calculateFramerateAtTimestamp:timestamp];
        
		// Get frame dimensions (for onscreen display)
		if (self.videoDimensions.width == 0 && self.videoDimensions.height == 0)
			self.videoDimensions = CMVideoFormatDescriptionGetDimensions( formatDescription );
		
		// Get buffer type
		if ( self.videoType == 0 )
			self.videoType = CMFormatDescriptionGetMediaSubType( formatDescription );
	}
    //
    CFRetain(sampleBuffer);
	CFRetain(formatDescription);
    
	dispatch_async(movieWritingQueue, ^{
		if ( appleEncoder1 && (self.recording || recordingWillBeStarted)) {
		
			BOOL wasReadyToRecord = (appleEncoder1.readyToRecordAudio && appleEncoder1.readyToRecordVideo);
			
			if (connection == videoConnection) {
				
				// Initialize the video input if this is not done yet
				if (!appleEncoder1.readyToRecordVideo) {
					[appleEncoder1 setupVideoEncoderWithFormatDescription:formatDescription];
                }
				
				// Write video data to file
				if (appleEncoder1.readyToRecordVideo && appleEncoder1.readyToRecordAudio) {
					[appleEncoder1 writeSampleBuffer:sampleBuffer ofType:AVMediaTypeVideo];
                }
			}
			else if (connection == audioConnection) {
				
				// Initialize the audio input if this is not done yet
				if (!appleEncoder1.readyToRecordAudio) {
                    [appleEncoder1 setupAudioEncoderWithFormatDescription:formatDescription];
                }
				
				// Write audio data to file
				if (appleEncoder1.readyToRecordAudio && appleEncoder1.readyToRecordVideo)
					[appleEncoder1 writeSampleBuffer:sampleBuffer ofType:AVMediaTypeAudio];
			}
			
			BOOL isReadyToRecord = (appleEncoder1.readyToRecordAudio && appleEncoder1.readyToRecordVideo);
			if ( !wasReadyToRecord && isReadyToRecord ) {
				recordingWillBeStarted = NO;
				self.recording = YES;
				[self.delegate recordingDidStart];
			}
		}
        if ( appleEncoder2 && (self.recording || recordingWillBeStarted)) {
            
            BOOL wasReadyToRecord = (appleEncoder2.readyToRecordAudio && appleEncoder2.readyToRecordVideo);
            
            if (connection == videoConnection) {
                
                // Initialize the video input if this is not done yet
                if (!appleEncoder2.readyToRecordVideo) {
                    [appleEncoder2 setupVideoEncoderWithFormatDescription:formatDescription bitsPerSecond:400000];
                }
                
                // Write video data to file
                if (appleEncoder2.readyToRecordVideo && appleEncoder2.readyToRecordAudio) {
                    [appleEncoder2 writeSampleBuffer:sampleBuffer ofType:AVMediaTypeVideo];
                }
            }
            else if (connection == audioConnection) {
                
                // Initialize the audio input if this is not done yet
                if (!appleEncoder2.readyToRecordAudio) {
                    [appleEncoder2 setupAudioEncoderWithFormatDescription:formatDescription];
                }
                
                // Write audio data to file
                if (appleEncoder2.readyToRecordAudio && appleEncoder2.readyToRecordVideo)
                    [appleEncoder2 writeSampleBuffer:sampleBuffer ofType:AVMediaTypeAudio];
            }
            
            BOOL isReadyToRecord = (appleEncoder2.readyToRecordAudio && appleEncoder2.readyToRecordVideo);
            if ( !wasReadyToRecord && isReadyToRecord ) {
                recordingWillBeStarted = NO;
                self.recording = YES;
                [self.delegate recordingDidStart];
            }
        }

		CFRelease(sampleBuffer);
		CFRelease(formatDescription);
	});
}

- (AVCaptureDevice *)videoDeviceWithPosition:(AVCaptureDevicePosition)position 
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
        if ([device position] == position)
            return device;
    
    return nil;
}

- (AVCaptureDevice *)audioDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if ([devices count] > 0)
        return [devices objectAtIndex:0];
    
    return nil;
}

- (BOOL) setupCaptureSession 
{
    /*
	 * Create capture session
	 */
    captureSession = [[AVCaptureSession alloc] init];
    captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    
    /*
	 * Create audio connection
	 */
    AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice] error:nil];
    if ([captureSession canAddInput:audioIn])
        [captureSession addInput:audioIn];
	
	AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
	dispatch_queue_t audioCaptureQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
	[audioOut setSampleBufferDelegate:self queue:audioCaptureQueue];
	dispatch_release(audioCaptureQueue);
	if ([captureSession canAddOutput:audioOut])
		[captureSession addOutput:audioOut];
	audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
    
	/*
	 * Create video connection
	 */
    AVCaptureDeviceInput *videoIn = [[AVCaptureDeviceInput alloc] initWithDevice:[self videoDeviceWithPosition:AVCaptureDevicePositionBack] error:nil];
    if ([captureSession canAddInput:videoIn])
        [captureSession addInput:videoIn];
    
	AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];

	[videoOut setAlwaysDiscardsLateVideoFrames:YES];

	[videoOut setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
	dispatch_queue_t videoCaptureQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
	[videoOut setSampleBufferDelegate:self queue:videoCaptureQueue];
	dispatch_release(videoCaptureQueue);
	if ([captureSession canAddOutput:videoOut])
		[captureSession addOutput:videoOut];
	videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
    // TODO FIXME iOS 6:
    self.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    videoConnection.videoOrientation = self.videoOrientation;
	return YES;
}

- (void) setupAndStartCaptureSession
{
	// Create serial queue for movie writing
	movieWritingQueue = dispatch_queue_create("Movie Writing Queue", DISPATCH_QUEUE_SERIAL);

    if ( !captureSession )
		[self setupCaptureSession];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureSessionStoppedRunningNotification:) name:AVCaptureSessionDidStopRunningNotification object:captureSession];
	
	if ( !captureSession.isRunning ) {
        [captureSession startRunning];
    }
}

- (void) pauseCaptureSession
{
	if ( captureSession.isRunning )
		[captureSession stopRunning];
}

- (void) resumeCaptureSession
{
	if ( !captureSession.isRunning ) {
        [captureSession startRunning];
    }
}

- (void)captureSessionStoppedRunningNotification:(NSNotification *)notification
{
	dispatch_async(movieWritingQueue, ^{
		if ( [self isRecording] ) {
			[self stopRecording];
		}
	});
}

- (void) stopAndTearDownCaptureSession
{
    [captureSession stopRunning];
	if (captureSession)
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionDidStopRunningNotification object:captureSession];
	captureSession = nil;
	if (movieWritingQueue) {
		dispatch_release(movieWritingQueue);
		movieWritingQueue = NULL;
	}
}

#pragma mark Error Handling

- (void)showError:(NSError *)error
{
    NSLog(@"Error: %@%@",[error localizedDescription], [error userInfo]);
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    });
}

@end
