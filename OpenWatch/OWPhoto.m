//
//  OWPhoto.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/7/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWPhoto.h"
#import "OWLocalMediaObject.h"

#define kPhotoName @"photo.jpeg"

@implementation OWPhoto

- (NSString*) localMediaPath {
    NSString *uuidPath = [OWPhoto pathForUUID:self.uuid];
    NSString *path = [uuidPath stringByAppendingPathComponent:kPhotoName];
    return path;
}

+ (OWPhoto*) photoWithImage:(UIImage*)image {
    NSData *jpegData = UIImageJPEGRepresentation(image, 0.85);
    NSLog(@"photo size: %d kB", jpegData.length / 1024);
    
    OWPhoto *photo = [OWPhoto photo];
    
    NSError *error = nil;

    [[NSFileManager defaultManager]
     createDirectoryAtPath:[photo dataDirectory]
     withIntermediateDirectories:YES
     attributes:nil
     error:&error];
    
    if (error) {
        NSLog(@"Error creating directory: %@", error.userInfo);
        error = nil;
    }
    
    [jpegData writeToFile:photo.localMediaPath options:NSDataWritingAtomic error:&error];
    
    if (error) {
        NSLog(@"Error writing file: %@", error.userInfo);
        error = nil;
    }
    return photo;
}

+ (NSString*) mediaDirectoryPath {
    return [self mediaDirectoryPathForMediaType:@"photos"];
}

+ (OWPhoto*) photoWithUUID:(NSString *)uuid {
    OWLocalMediaObject *mediaObject = [OWLocalMediaObject localMediaObjectWithUUID:uuid];
    return (OWPhoto*)mediaObject;
}

+ (OWPhoto*) photo {
    OWPhoto* photo = (OWPhoto*)[self localMediaObject];
    photo.uploaded = @(NO);
    return photo;
}

@end
