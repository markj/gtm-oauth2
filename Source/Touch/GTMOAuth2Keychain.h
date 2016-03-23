//
//  GTMOAuth2Keychain.h
//  GTLCore
//
//  Created by Mark Johnson on 23/03/2016.
//
//

#if GTM_INCLUDE_OAUTH2 || !GDATA_REQUIRE_SERVICE_INCLUDES

//#if TARGET_OS_IPHONE || TARGET_OS_TV

#import <Foundation/Foundation.h>

extern NSString *const kGTMOAuth2KeychainErrorDomain;


// To function, GTMOAuth2ViewControllerTouch needs a certain amount of access
// to the iPhone's keychain. To keep things simple, its keychain access is
// broken out into a helper class. We declare it here in case you'd like to use
// it too, to store passwords.

typedef NS_ENUM(NSInteger, GTMOAuth2KeychainError) {
    GTMOAuth2KeychainErrorBadArguments = -1301,
    GTMOAuth2KeychainErrorNoPassword = -1302
};

#if !GTMOAUTH2AUTHENTICATION_DEPRECATE_OLD_ENUMS
#define kGTMOAuth2KeychainErrorBadArguments GTMOAuth2KeychainErrorBadArguments
#define kGTMOAuth2KeychainErrorNoPassword   GTMOAuth2KeychainErrorNoPassword
#endif


@interface GTMOAuth2Keychain : NSObject

+ (GTMOAuth2Keychain *)defaultKeychain;

// OK to pass nil for the error parameter.
- (NSString *)passwordForService:(NSString *)service
                         account:(NSString *)account
                           error:(NSError **)error;

// OK to pass nil for the error parameter.
- (BOOL)removePasswordForService:(NSString *)service
                         account:(NSString *)account
                           error:(NSError **)error;

// OK to pass nil for the error parameter.
//
// accessibility should be one of the constants for kSecAttrAccessible
// such as kSecAttrAccessibleWhenUnlocked
- (BOOL)setPassword:(NSString *)password
         forService:(NSString *)service
      accessibility:(CFTypeRef)accessibility
            account:(NSString *)account
              error:(NSError **)error;

// For unit tests: allow setting a mock object
+ (void)setDefaultKeychain:(GTMOAuth2Keychain *)keychain;

@end

//#endif // TARGET_OS_IPHONE

#endif // #if GTM_INCLUDE_OAUTH2 || !GDATA_REQUIRE_SERVICE_INCLUDES
