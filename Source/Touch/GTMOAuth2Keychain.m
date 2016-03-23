//
//  GTMOAuth2Keychain.m
//  GTLCore
//
//  Created by Mark Johnson on 23/03/2016.
//
//

#import "GTMOAuth2Keychain.h"



static GTMOAuth2Keychain* gGTMOAuth2DefaultKeychain = nil;
NSString *const kGTMOAuth2KeychainErrorDomain = @"com.google.GTMOAuthKeychain";

#pragma mark Common Code

@implementation GTMOAuth2Keychain

+ (GTMOAuth2Keychain *)defaultKeychain {
    if (gGTMOAuth2DefaultKeychain == nil) {
        gGTMOAuth2DefaultKeychain = [[self alloc] init];
    }
    return gGTMOAuth2DefaultKeychain;
}


// For unit tests: allow setting a mock object
+ (void)setDefaultKeychain:(GTMOAuth2Keychain *)keychain {
    if (gGTMOAuth2DefaultKeychain != keychain) {
        [gGTMOAuth2DefaultKeychain release];
        gGTMOAuth2DefaultKeychain = [keychain retain];
    }
}

- (NSString *)keyForService:(NSString *)service account:(NSString *)account {
    return [NSString stringWithFormat:@"com.google.GTMOAuth.%@%@", service, account];
}

// The Keychain API isn't available on the iPhone simulator in SDKs before 3.0,
// so, on early simulators we use a fake API, that just writes, unencrypted, to
// NSUserDefaults.
#if TARGET_IPHONE_SIMULATOR && __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
#pragma mark Simulator

// Simulator - just simulated, not secure.
- (NSString *)passwordForService:(NSString *)service account:(NSString *)account error:(NSError **)error {
    NSString *result = nil;
    if (0 < [service length] && 0 < [account length]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *key = [self keyForService:service account:account];
        result = [defaults stringForKey:key];
        if (result == nil && error != NULL) {
            *error = [NSError errorWithDomain:kGTMOAuth2KeychainErrorDomain
                                         code:kGTMOAuth2KeychainErrorNoPassword
                                     userInfo:nil];
        }
    } else if (error != NULL) {
        *error = [NSError errorWithDomain:kGTMOAuth2KeychainErrorDomain
                                     code:kGTMOAuth2KeychainErrorBadArguments
                                 userInfo:nil];
    }
    return result;
    
}


// Simulator - just simulated, not secure.
- (BOOL)removePasswordForService:(NSString *)service account:(NSString *)account error:(NSError **)error {
    BOOL didSucceed = NO;
    if (0 < [service length] && 0 < [account length]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *key = [self keyForService:service account:account];
        [defaults removeObjectForKey:key];
        [defaults synchronize];
    } else if (error != NULL) {
        *error = [NSError errorWithDomain:kGTMOAuth2KeychainErrorDomain
                                     code:kGTMOAuth2KeychainErrorBadArguments
                                 userInfo:nil];
    }
    return didSucceed;
}

// Simulator - just simulated, not secure.
- (BOOL)setPassword:(NSString *)password
         forService:(NSString *)service
      accessibility:(CFTypeRef)accessibility
            account:(NSString *)account
              error:(NSError **)error {
    BOOL didSucceed = NO;
    if (0 < [password length] && 0 < [service length] && 0 < [account length]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *key = [self keyForService:service account:account];
        [defaults setObject:password forKey:key];
        [defaults synchronize];
        didSucceed = YES;
    } else if (error != NULL) {
        *error = [NSError errorWithDomain:kGTMOAuth2KeychainErrorDomain
                                     code:kGTMOAuth2KeychainErrorBadArguments
                                 userInfo:nil];
    }
    return didSucceed;
}

#else // ! TARGET_IPHONE_SIMULATOR
#pragma mark Device

+ (NSMutableDictionary *)keychainQueryForService:(NSString *)service account:(NSString *)account {
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  (id)kSecClassGenericPassword, (id)kSecClass,
                                  @"OAuth", (id)kSecAttrGeneric,
                                  account, (id)kSecAttrAccount,
                                  service, (id)kSecAttrService,
                                  nil];
    return query;
}

- (NSMutableDictionary *)keychainQueryForService:(NSString *)service account:(NSString *)account {
    return [[self class] keychainQueryForService:service account:account];
}



// iPhone
- (NSString *)passwordForService:(NSString *)service account:(NSString *)account error:(NSError **)error {
    OSStatus status = GTMOAuth2KeychainErrorBadArguments;
    NSString *result = nil;
    if (0 < [service length] && 0 < [account length]) {
        CFDataRef passwordData = NULL;
        NSMutableDictionary *keychainQuery = [self keychainQueryForService:service account:account];
        [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
        [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
        
        status = SecItemCopyMatching((CFDictionaryRef)keychainQuery,
                                     (CFTypeRef *)&passwordData);
        if (status == noErr && 0 < [(NSData *)passwordData length]) {
            result = [[[NSString alloc] initWithData:(NSData *)passwordData
                                            encoding:NSUTF8StringEncoding] autorelease];
        }
        if (passwordData != NULL) {
            CFRelease(passwordData);
        }
    }
    if (status != noErr && error != NULL) {
        *error = [NSError errorWithDomain:kGTMOAuth2KeychainErrorDomain
                                     code:status
                                 userInfo:nil];
    }
    return result;
}


// iPhone
- (BOOL)removePasswordForService:(NSString *)service account:(NSString *)account error:(NSError **)error {
    OSStatus status = GTMOAuth2KeychainErrorBadArguments;
    if (0 < [service length] && 0 < [account length]) {
        NSMutableDictionary *keychainQuery = [self keychainQueryForService:service account:account];
        status = SecItemDelete((CFDictionaryRef)keychainQuery);
    }
    if (status != noErr && error != NULL) {
        *error = [NSError errorWithDomain:kGTMOAuth2KeychainErrorDomain
                                     code:status
                                 userInfo:nil];
    }
    return status == noErr;
}

// iPhone
- (BOOL)setPassword:(NSString *)password
         forService:(NSString *)service
      accessibility:(CFTypeRef)accessibility
            account:(NSString *)account
              error:(NSError **)error {
    OSStatus status = GTMOAuth2KeychainErrorBadArguments;
    if (0 < [service length] && 0 < [account length]) {
        [self removePasswordForService:service account:account error:nil];
        if (0 < [password length]) {
            NSMutableDictionary *keychainQuery = [self keychainQueryForService:service account:account];
            NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
            [keychainQuery setObject:passwordData forKey:(id)kSecValueData];
            
            if (accessibility != NULL) {
                [keychainQuery setObject:(id)accessibility
                                  forKey:(id)kSecAttrAccessible];
            }
            status = SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
        }
    }
    if (status != noErr && error != NULL) {
        *error = [NSError errorWithDomain:kGTMOAuth2KeychainErrorDomain
                                     code:status
                                 userInfo:nil];
    }
    return status == noErr;
}

#endif // ! TARGET_IPHONE_SIMULATOR

@end

