//
//  GTMOAuth2Helper.m
//  GTLCore
//
//  Created by Mark Johnson on 23/03/2016.
//
//

#if GTM_INCLUDE_OAUTH2 || !GDATA_REQUIRE_SERVICE_INCLUDES

#import "GTMOAuth2ViewControllerTV.h"

#import "GTMOAuth2SignIn.h"
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2Keychain.h"


static NSString * const kGTMOAuth2AccountName = @"OAuth";


@implementation GTMOAuth2ViewControllerTV


#if !GTM_OAUTH2_SKIP_GOOGLE_SUPPORT
+ (GTMOAuth2Authentication *)authForGoogleFromKeychainForName:(NSString *)keychainItemName
                                                     clientID:(NSString *)clientID
                                                 clientSecret:(NSString *)clientSecret {
    return [self authForGoogleFromKeychainForName:keychainItemName
                                         clientID:clientID
                                     clientSecret:clientSecret
                                            error:NULL];
}

+ (GTMOAuth2Authentication *)authForGoogleFromKeychainForName:(NSString *)keychainItemName
                                                     clientID:(NSString *)clientID
                                                 clientSecret:(NSString *)clientSecret
                                                        error:(NSError **)error {
    Class signInClass = [self signInClass];
    NSURL *tokenURL = [signInClass googleTokenURL];
    NSString *redirectURI = [signInClass nativeClientRedirectURI];
    
    GTMOAuth2Authentication *auth;
    auth = [GTMOAuth2Authentication authenticationWithServiceProvider:kGTMOAuth2ServiceProviderGoogle
                                                             tokenURL:tokenURL
                                                          redirectURI:redirectURI
                                                             clientID:clientID
                                                         clientSecret:clientSecret];
    [[self class] authorizeFromKeychainForName:keychainItemName
                                authentication:auth
                                         error:error];
    return auth;
}

#endif

+ (BOOL)authorizeFromKeychainForName:(NSString *)keychainItemName
                      authentication:(GTMOAuth2Authentication *)newAuth
                               error:(NSError **)error {
    newAuth.accessToken = nil;
    
    BOOL didGetTokens = NO;
    GTMOAuth2Keychain *keychain = [GTMOAuth2Keychain defaultKeychain];
    NSString *password = [keychain passwordForService:keychainItemName
                                              account:kGTMOAuth2AccountName
                                                error:error];

    if (password != nil) {
        [newAuth setKeysForResponseString:password];
        didGetTokens = YES;
    }
    return didGetTokens;
}



static Class gSignInClass = Nil;

+ (Class)signInClass {
    if (gSignInClass == Nil) {
        gSignInClass = [GTMOAuth2SignIn class];
    }
    return gSignInClass;
}

+ (void)setSignInClass:(Class)theClass {
    gSignInClass = theClass;
}


@end







#endif // #if GTM_INCLUDE_OAUTH2 || !GDATA_REQUIRE_SERVICE_INCLUDES
