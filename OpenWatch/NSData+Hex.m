//
//  NSData+Hex.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/13/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//  http://stackoverflow.com/a/9084784/805882

#import "NSData+Hex.h"

@implementation NSData (Hex)
- (NSString *)hexadecimalString {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = [self length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendFormat:@"%02lx", (unsigned long)dataBuffer[i]];
    
    return hexString;
}
@end
