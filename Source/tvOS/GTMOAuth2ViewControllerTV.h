//
//  GTMOAuth2ViewControllerTV.h
//  GTLCore
//
//  Created by Mark Johnson on 23/03/2016.
//
//


#if GTM_INCLUDE_OAUTH2 || !GDATA_REQUIRE_SERVICE_INCLUDES

#import <Foundation/Foundation.h>


#if TARGET_OS_TV


#import "GTMOAuth2Authentication.h"


@interface GTMOAuth2ViewControllerTV : UIViewController


// create an authentication object for Google services from the access
// token and secret stored in the keychain; if no token is available, return
// an unauthorized auth object. OK to pass NULL for the error parameter.
#if !GTM_OAUTH2_SKIP_GOOGLE_SUPPORT
+ (GTMOAuth2Authentication *)authForGoogleFromKeychainForName:(NSString *)keychainItemName
                                                     clientID:(NSString *)clientID
                                                 clientSecret:(NSString *)clientSecret
                                                        error:(NSError **)error;
// Equivalent to calling the method above with a NULL error parameter.
+ (GTMOAuth2Authentication *)authForGoogleFromKeychainForName:(NSString *)keychainItemName
                                                     clientID:(NSString *)clientID
                                                 clientSecret:(NSString *)clientSecret;
#endif


@end

#endif // #if TARGET_OS_TV

#endif // #if GTM_INCLUDE_OAUTH2 || !GDATA_REQUIRE_SERVICE_INCLUDES
