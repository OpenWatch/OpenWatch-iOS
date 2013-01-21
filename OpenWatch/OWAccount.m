//
//  OWAccount.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWAccount.h"
#import "SSKeychain.h"

#define kServiceName @"net.OpenWatch.OpenWatch"
#define kAccountIDKey @"kAccountIDKey"
#define kEmailKey @"kEmailKey"
#define kPublicUploadTokenKey @"kPublicUploadTokenKey"
#define kPrivateUploadTokenKey @"kPrivateUploadTokenKey"
#define kPasswordKey @"kPasswordKey"
#define kUsernameKey @"kUsernameKey"

@implementation OWAccount

- (id) init {
    if (self = [super init]) {
        if ([self email] == nil && [self publicUploadToken] != nil) {
            [self clearAccountData];
        }
    }
    return self;
}

- (NSNumber*) accountID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kAccountIDKey];
}

- (void) setAccountID:(NSNumber *)accountID {
    [self setPreferencesValue:accountID forKey:kAccountIDKey];
}

- (NSString*) email {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kEmailKey];
}

- (void) setEmail:(NSString *)email {
    [self setPreferencesValue:email forKey:kEmailKey];
}

- (NSString*) username {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kUsernameKey];
}

- (void) setUsername:(NSString *)username {
    [self setPreferencesValue:username forKey:kUsernameKey];
}

- (NSString*) retreiveValueFromKeychainForKey:(NSString*)key {
    NSError *error = nil;
    NSString *password = [SSKeychain passwordForService:kServiceName account:key error:&error];
    if (error) {
        NSLog(@"Error retreiving %@: %@%@", key, [error localizedDescription], [error userInfo]);
    }
    return password;
}

- (void) setKeychainValue:(NSString*)value forKey:(NSString*)key {
    NSError *error = nil;
    if (value) {
        [SSKeychain setPassword:value forService:kServiceName account:key error:&error];
        if (error) {
            NSLog(@"Error storing value for %@: %@%@", key, [error localizedDescription], [error userInfo]);
        }
    } else {
        [SSKeychain deletePasswordForService:kServiceName account:key error:&error];
        if (error) {
            NSLog(@"Error deleting value for %@: %@%@", key, [error localizedDescription], [error userInfo]);
        }
    }

}

- (NSString*) password {
    return [self retreiveValueFromKeychainForKey:kPasswordKey];
}

- (void) setPassword:(NSString *)password {
    [self setKeychainValue:password forKey:kPasswordKey];
}

- (void) setPrivateUploadToken:(NSString *)privateUploadToken {
    [self setKeychainValue:privateUploadToken forKey:kPrivateUploadTokenKey];
}

- (NSString*) privateUploadToken {
    return [self retreiveValueFromKeychainForKey:kPrivateUploadTokenKey];
}

- (NSString*) publicUploadToken {
    return [self retreiveValueFromKeychainForKey:kPublicUploadTokenKey];
}

- (BOOL) isLoggedIn {
    return [self publicUploadToken] != nil && [self email] != nil;
}

- (void) setPublicUploadToken:(NSString *)publicUploadToken {
    [self setKeychainValue:publicUploadToken forKey:kPublicUploadTokenKey];
}

- (void) setPreferencesValue:(NSObject*)value forKey:(NSString*)key {
    if (!value) {
        NSLog(@"Preference value is nil!");
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    BOOL success = [defaults synchronize];
    if (!success) {
        NSLog(@"Preference value could not be written to disk!");
    }
}

- (OWUser*) user {
    if (![self accountID]) {
        return nil;
    }
    OWUser *user = [OWUser MR_findFirstByAttribute:@"serverID" withValue:[self accountID]];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];

    if (!user) {
        user = [OWUser MR_createEntity];
        user.serverID = [self accountID];
        user.username = [self username];
        NSError *error = nil;
        BOOL success = [context obtainPermanentIDsForObjects:@[user] error:&error];
        if (error || !success) {
            NSLog(@"Error convert to permanent ID: %@", [error userInfo]);
        }
        [context MR_saveToPersistentStoreAndWait];
        return user;
    }
    if (![user.username isEqualToString:[self username]]) {
        user.username = [self username];
        [context MR_saveToPersistentStoreAndWait];
    }
    return user;
}


- (void) clearAccountData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kAccountIDKey];
    [defaults removeObjectForKey:kUsernameKey];
    [defaults removeObjectForKey:kEmailKey];
    BOOL success = [defaults synchronize];
    if (!success) {
        NSLog(@"Error deleting objects from NSUserDefaults");
    }
    [self setKeychainValue:nil forKey:kPasswordKey];
    [self setKeychainValue:nil forKey:kPublicUploadTokenKey];
    [self setKeychainValue:nil forKey:kPrivateUploadTokenKey];
}

@end
