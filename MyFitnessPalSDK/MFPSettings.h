//
//  MFPSettings.h
//
//  Created by Todd Roman on 2/25/14.
//  Copyright (c) 2014 MyFitnessPal, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MFP_API_VERSION_STRING @"1.0.0"
#define MFP_IOS_SDK_VERSION_STRING @"1.3.1"

typedef enum MFPAppType : uint16_t {
  MFPiPadApp = 1 << 0,
  MFPiPhoneApp = 1 << 1
} MFPAppType;


@interface MFPSettings : NSObject


+ (NSString *)appInstallUrl;
+ (NSString *)mfpHostname;
+ (NSString *)openAppPath;
+ (NSString *)authRedirectUriPath;
+ (NSString *)mfpScheme;
+ (NSString *)sdkVersion;
+ (NSString *)apiVersion;

+ (NSURL *)baseURL;

+ (NSString *)siteRootUrl;

+ (NSURL *)oAuthUrl;

+ (NSString *)clientUrlSchemeSuffix;

+ (NSString *)clientId;
+ (NSString *)clientRedirectUri;

+ (void)setClientId:(NSString *)identifier;
+ (void)setClientUrlSchemeSuffix:(NSString *)urlSchemeSuffix;

+ (BOOL)mfpAppIsInstalled;
+ (MFPAppType)mfpAppsAvailable;

@end
