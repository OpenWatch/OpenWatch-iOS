//
//  OWAppleEncoder.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWAppleEncoder.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMBufferQueue.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "OWCaptureAPIClient.h"
#import "OWRecordingController.h"

@implementation OWAppleEncoder
@synthesize assetWriter, audioEncoder, videoEncoder, movieURL, readyToRecordAudio, readyToRecordVideo, referenceOrientation, videoOrientation;
@synthesize watchOutputFile, recordingID;

- (id) init {
    if (self = [super init]) {
    }
    return self;
}

- (id) initWithURL:(NSURL *)url movieFragmentInterval:(CMTime)fragmentInterval {
    if (self = [self init]) {
        self.movieURL = url;
        NSError *error = nil;
        self.assetWriter = [[AVAssetWriter alloc] initWithURL:movieURL fileType:(NSString *)kUTTypeMPEG4 error:&error];
        if (error) {
            [self showError:error];
        }
        assetWriter.movieFragmentInterval = fragmentInterval;
        referenceOrientation = UIDeviceOrientationLandscapeRight;
        fileOffset = 0;
        fileNumber = 0;
        source = NULL;
    }
    return self;
}

- (id) initWithURL:(NSURL *)url {
    if (self = [self initWithURL:url movieFragmentInterval:kCMTimeInvalid]) {
        
    }
    return self;
}

// Modified from
// http://www.davidhamrick.com/2011/10/13/Monitoring-Files-With-GCD-Being-Edited-With-A-Text-Editor.html
- (void)watchOutputFileHandle
{
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	int fildes = open([[movieURL path] UTF8String], O_EVTONLY);
    
	source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE,fildes,
															  DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_ATTRIB | DISPATCH_VNODE_LINK | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE,
															  queue);
	dispatch_source_set_event_handler(source, ^
                                      {
                                          unsigned long flags = dispatch_source_get_data(source);
                                          if(flags & DISPATCH_VNODE_DELETE)
                                          {
                                              dispatch_source_cancel(source);
                                              //[blockSelf watchStyleSheet:path];
                                          }
                                          if(flags & DISPATCH_VNODE_EXTEND)
                                          {
                                              //NSLog(@"File size changed");
                                              NSError *error = nil;
                                              NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingFromURL:movieURL error:&error];
                                              if (error) {
                                                  [self showError:error];
                                              }
                                              [fileHandle seekToFileOffset:fileOffset];
                                              NSData *newData = [fileHandle readDataToEndOfFile];
                                              if ([newData length] > 0) {
                                                  NSLog(@"newData (%lld): %d bytes", fileOffset, [newData length]);
                                                  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                                  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
                                                  NSString *movieName = [NSString stringWithFormat:@"%d.%lld.%d.mp4", fileNumber, fileOffset, [newData length]];
                                                  NSString *path = [NSString stringWithFormat:@"%@/%@", basePath, movieName];
                                                  [newData writeToFile:path atomically:NO];
                                                  fileNumber++;
                                                  fileOffset = [fileHandle offsetInFile];
                                              }
                                          }
                                      });
	dispatch_source_set_cancel_handler(source, ^(void) 
                                       {
                                           close(fildes);
                                       });
	dispatch_resume(source);
}



- (AVAssetWriterInput*) setupVideoEncoderWithAssetWriter:(AVAssetWriter*)currentAssetWriter formatDescription:(CMFormatDescriptionRef)formatDescription bitsPerSecond:(int)bps
{
	CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
    CGFloat width = dimensions.width;
    CGFloat height = dimensions.height;
    AVAssetWriterInput *currentVideoEncoder = nil;
	
	NSDictionary *videoCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
											  AVVideoCodecH264, AVVideoCodecKey,
											  [NSNumber numberWithInteger:width], AVVideoWidthKey,
											  [NSNumber numberWithInteger:height], AVVideoHeightKey,
											  [NSDictionary dictionaryWithObjectsAndKeys:
											   [NSNumber numberWithInteger:bps], AVVideoAverageBitRateKey,
											   [NSNumber numberWithInteger:300], AVVideoMaxKeyFrameIntervalKey,
											   nil], AVVideoCompressionPropertiesKey,
											  nil];
	if ([currentAssetWriter canApplyOutputSettings:videoCompressionSettings forMediaType:AVMediaTypeVideo]) {
		currentVideoEncoder = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
		currentVideoEncoder.expectsMediaDataInRealTime = YES;
		//currentVideoEncoder.transform = [self transformFromCurrentVideoOrientationToOrientation:self.referenceOrientation];
		if ([currentAssetWriter canAddInput:currentVideoEncoder]) {
            @try {
                [currentAssetWriter addInput:currentVideoEncoder];
            }
            @catch (NSException *exception) {
                NSLog(@"Couldn't add input: %@", [exception description]);
                [self handleException:exception];
            }
        } else {
			NSLog(@"Couldn't add asset writer video input.");
		}
	}
	else {
		NSLog(@"Couldn't apply video output settings.");
	}
    return currentVideoEncoder;
}

- (void) setupVideoEncoderWithFormatDescription:(CMFormatDescriptionRef)formatDescription bitsPerSecond:(int)bps {
    videoFormatDescription = formatDescription;
    videoEncoder = [self setupVideoEncoderWithAssetWriter:assetWriter formatDescription:formatDescription bitsPerSecond:bps];
    self.readyToRecordVideo = YES;
}

- (void) setupVideoEncoderWithFormatDescription:(CMFormatDescriptionRef)formatDescription;
{
    float bitsPerPixel;
    
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
    CGFloat width = dimensions.width;
    CGFloat height = dimensions.height;
    
    int numPixels = width * height;
	int bitsPerSecond;
	
    bitsPerPixel = 4.05;
	
	bitsPerSecond = numPixels * bitsPerPixel;
    [self setupVideoEncoderWithFormatDescription:formatDescription bitsPerSecond:bitsPerSecond];
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

- (void) setupAudioEncoderWithFormatDescription:(CMFormatDescriptionRef)formatDescription {
    [self setupAudioEncoderWithFormatDescription:formatDescription bitsPerSecond:64000];
}
- (void) setupAudioEncoderWithFormatDescription:(CMFormatDescriptionRef)formatDescription bitsPerSecond:(int)bps {
    audioFormatDescription = formatDescription;
    audioEncoder = [self setupAudioEncoderWithAssetWriter:assetWriter formatDescription:formatDescription bitsPerSecond:bps];
    self.readyToRecordAudio = YES;
}

- (AVAssetWriterInput*) setupAudioEncoderWithAssetWriter:(AVAssetWriter*)currentAssetWriter formatDescription:(CMFormatDescriptionRef)formatDescription bitsPerSecond:(int)bps
{
	const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription);
    AVAssetWriterInput *currentAudioEncoder = nil;
    
	size_t aclSize = 0;
	const AudioChannelLayout *currentChannelLayout = CMAudioFormatDescriptionGetChannelLayout(formatDescription, &aclSize);
	NSData *currentChannelLayoutData = nil;
	
	// AVChannelLayoutKey must be specified, but if we don't know any better give an empty data and let AVAssetWriter decide.
	if ( currentChannelLayout && aclSize > 0 )
		currentChannelLayoutData = [NSData dataWithBytes:currentChannelLayout length:aclSize];
	else
		currentChannelLayoutData = [NSData data];
	
	NSDictionary *audioCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
											  [NSNumber numberWithInteger:kAudioFormatMPEG4AAC], AVFormatIDKey,
											  [NSNumber numberWithFloat:currentASBD->mSampleRate], AVSampleRateKey,
											  [NSNumber numberWithInt:64000], AVEncoderBitRatePerChannelKey,
											  [NSNumber numberWithInteger:currentASBD->mChannelsPerFrame], AVNumberOfChannelsKey,
											  currentChannelLayoutData, AVChannelLayoutKey,
											  nil];
	if ([currentAssetWriter canApplyOutputSettings:audioCompressionSettings forMediaType:AVMediaTypeAudio]) {
		currentAudioEncoder = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:audioCompressionSettings];
		currentAudioEncoder.expectsMediaDataInRealTime = YES;
		if ([currentAssetWriter canAddInput:currentAudioEncoder]) {
            @try {
                [currentAssetWriter addInput:currentAudioEncoder];
            }
            @catch (NSException *exception) {
                NSLog(@"Couldn't add audio input: %@", [exception description]);
                [self handleException:exception];
            }
        } else {
			NSLog(@"Couldn't add asset writer audio input.");
		}
	}
	else {
		NSLog(@"Couldn't apply audio output settings.");
	}
    return currentAudioEncoder;
}

- (void) writeSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(NSString *)mediaType
{
	if ( assetWriter.status == AVAssetWriterStatusUnknown ) {
		
        if ([assetWriter startWriting]) {
			[assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
            OWLocalRecording *recording = [OWRecordingController localRecordingForObjectID:recordingID];
            [recording setUploadState:OWFileUploadStateRecording forFileAtURL:assetWriter.outputURL];
		}
		else {
			[self showError:[assetWriter error]];
		}
	}
	
	if ( assetWriter.status == AVAssetWriterStatusWriting ) {
        if (watchOutputFile && !source) {
            [self watchOutputFileHandle];
        }
		
		if (mediaType == AVMediaTypeVideo) {
			if (videoEncoder.readyForMoreMediaData) {
                @try {
                    if (![videoEncoder appendSampleBuffer:sampleBuffer]) {
                        [self showError:[assetWriter error]];
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"Couldn't append video sample buffer: %@", [exception description]);
                    [self handleException:exception];
                }
			}
		}
		else if (mediaType == AVMediaTypeAudio) {
			if (audioEncoder.readyForMoreMediaData) {
                @try {
                    if (![audioEncoder appendSampleBuffer:sampleBuffer]) {
                        [self showError:[assetWriter error]];
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"Couldn't append audio sample buffer: %@", [exception description]);
                    [self handleException:exception];
                }
			}
		}
	}
}

- (void) handleException:(NSException *)exception {
    
}

- (void) finishEncoding {
    self.readyToRecordAudio = NO;
    self.readyToRecordVideo = NO;
    if (assetWriter.status == AVAssetWriterStatusWriting) {
        @try {
            [self.audioEncoder markAsFinished];
            [self.videoEncoder markAsFinished];
            [assetWriter finishWritingWithCompletionHandler:^{
                if (assetWriter.status == AVAssetWriterStatusFailed) {
                    [self showError:[assetWriter error]];
                }
            }];
        }
        @catch (NSException *exception) {
            NSLog(@"Caught exception: %@", [exception description]);
            [self handleException:exception];
        }

    }
    if(source) {
        dispatch_source_cancel(source);
        source = NULL;
    }
    if (self.assetWriter.status == AVAssetWriterStatusCompleted) {
        [self uploadFileURL:self.assetWriter.outputURL];
    }
}

- (void) uploadFileURL:(NSURL*)url {
    OWCaptureAPIClient *captureClient = [OWCaptureAPIClient sharedClient];
    OWLocalRecording *recording = [OWRecordingController localRecordingForObjectID:recordingID];
    [captureClient uploadFileURL:url recording:recording.objectID priority:NSOperationQueuePriorityNormal];
    [recording saveMetadata];
}

- (void) showError:(NSError*)error {
    NSLog(@"Error: %@%@", [error localizedDescription], [error userInfo]);
}

@end
