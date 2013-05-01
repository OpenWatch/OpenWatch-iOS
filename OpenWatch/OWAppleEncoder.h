//
//  OWAppleEncoder.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "OWLocalRecording.h"

@interface OWAppleEncoder : NSObject {
    unsigned long long fileOffset;
    __block dispatch_source_t source;
    int fileNumber;
    
    CMFormatDescriptionRef videoFormatDescription;
    CMFormatDescriptionRef audioFormatDescription;
}

@property (nonatomic, retain) NSURL *movieURL;

@property (atomic, retain) AVAssetWriterInput *audioEncoder;
@property (atomic, retain) AVAssetWriterInput *videoEncoder;
@property (atomic, retain) AVAssetWriter *assetWriter;

@property (atomic) BOOL readyToRecordAudio;
@property (atomic) BOOL readyToRecordVideo;
@property (nonatomic) AVCaptureVideoOrientation referenceOrientation;
@property (nonatomic) AVCaptureVideoOrientation videoOrientation;
@property (nonatomic, strong) NSManagedObjectID *recordingID;

- (id) initWithURL:(NSURL*)url;
- (id) initWithURL:(NSURL *)url movieFragmentInterval:(CMTime)fragmentInterval;
- (void) writeSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(NSString *)mediaType;
- (void) setupAudioEncoderWithFormatDescription:(CMFormatDescriptionRef)formatDescription;
- (void) setupAudioEncoderWithFormatDescription:(CMFormatDescriptionRef)formatDescription bitsPerSecond:(int)bps;
- (void) setupVideoEncoderWithFormatDescription:(CMFormatDescriptionRef)formatDescription;
- (void) setupVideoEncoderWithFormatDescription:(CMFormatDescriptionRef)formatDescription bitsPerSecond:(int)bps;

- (AVAssetWriterInput*) setupVideoEncoderWithAssetWriter:(AVAssetWriter*)currentAssetWriter formatDescription:(CMFormatDescriptionRef)formatDescription bitsPerSecond:(int)bps;
- (AVAssetWriterInput*) setupAudioEncoderWithAssetWriter:(AVAssetWriter*)currentAssetWriter formatDescription:(CMFormatDescriptionRef)formatDescription bitsPerSecond:(int)bps;

@property (nonatomic) BOOL watchOutputFile;

- (void) uploadLocalURL:(NSURL*)url;

- (void) finishEncoding;
- (void) showError:(NSError*)error;
- (void) handleException:(NSException*)exception;

@end
