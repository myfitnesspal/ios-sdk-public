//
//  MFPSettings.m
//  MFP
//
//  Created by Todd Roman on 2/25/14.
//  Copyright (c) 2014 MyFitnessPal, LLC. All rights reserved.
//

#import "MFPSettings.h"
#import "MyFitnessPalSDK.h"
#import <UIKit/UIKit.h>

//#warning TODO: make the urls localizable
static NSString *appInstallUrl = @"http://itunes.apple.com/us/app/calorie-counter-diet-tracker/id341232718?mt=8&uo=4";
static NSString *mfpHostname = @"mfp";
static NSString *authRedirectUriPath = @"/authorize/response";
static NSString *openAppPath = @"/open";
static NSString *connectPath = @"/connect";
static NSString *baseURL = @"https://api.myfitnesspal.com";

static NSString *clientId;
static NSString *authorizationResponseType;
static NSString *clientRedirectUri;
static NSString *clientUrlSchemeSuffix;

@interface MFPSettings ()
@end

@implementation MFPSettings

+ (NSString *)sdkVersion {
  return MFP_IOS_SDK_VERSION_STRING;
}

+ (NSString *)apiVersion {
  return MFP_API_VERSION_STRING;
}

+ (NSString *)appInstallUrl {
  return appInstallUrl;
}

+ (NSString *)mfpHostname {
  return mfpHostname;
}

+ (NSString *)openAppPath {
  return openAppPath;
}

+ (NSString *)authRedirectUriPath {
  return authRedirectUriPath;
}

+ (NSString *)siteRootUrl {
  // Maintaining consistency with current MFP app
  return baseURL;
}

+ (NSURL *)baseURL {
  static NSURL *url = nil;
  
  if (! url) {
    url = [NSURL URLWithString:baseURL];
  }
  return url;
}

+ (NSString *)clientId {

  return clientId;
  
}

+ (void)setClientId:(NSString *)identifier {

  clientId = identifier;
  
}


+ (BOOL)mfpAppIsInstalled {

  @autoreleasepool {
    MFPAppType apps = [self mfpAppsAvailable];
    if (apps & MFPiPadApp || apps & MFPiPhoneApp)
      return YES;
  }
  
  return NO;
}

+ (NSString *)mfpScheme {
  return @"mfp";
}

+ (NSURL *)oAuthUrl {
  // @"mfp://oauth2/authorize?"
  static NSURL *url;
  
  if (! url) {
    
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://oauth2/authorize?", [self mfpScheme]]];
    
  }
  
  return url;
  
}


+ (MFPAppType)mfpAppsAvailable {
  
  MFPAppType apps = 0;
  
  @synchronized (self) {
    @autoreleasepool {
      UIApplication *app = [UIApplication sharedApplication];
      if ([app canOpenURL:[NSURL URLWithString:@"mfphd://oauth2/authorize"]])
        apps |= MFPiPadApp;
      if ([app canOpenURL:[NSURL URLWithString:@"mfp://oauth2/authorize"]])
        apps |= MFPiPhoneApp;
    }
  }
  return apps;
}


+ (NSString *)clientUrlSchemeSuffix {

  return clientUrlSchemeSuffix;
  
}


+ (void)setClientUrlSchemeSuffix:(NSString *)urlSchemeSuffix {
  
  clientUrlSchemeSuffix = urlSchemeSuffix;
  
  [self setClientRedirectUriWithUrlSchemeSuffix:clientUrlSchemeSuffix];
  
}


+ (void)setClientRedirectUriWithUrlSchemeSuffix:(NSString *)urlSchemeSuffix {
  
  if (! clientId)
    return;
  
  NSMutableArray *parts = [NSMutableArray arrayWithCapacity:3];
  
  [parts addObject:@"mfp"];
  [parts addObject:clientId];
  
  if (urlSchemeSuffix)
    [parts addObject:urlSchemeSuffix];
  
  clientRedirectUri = [parts componentsJoinedByString:@"-"];
  
}


+ (NSString *)clientRedirectUri {
  
  return clientRedirectUri;
  
}

@end
