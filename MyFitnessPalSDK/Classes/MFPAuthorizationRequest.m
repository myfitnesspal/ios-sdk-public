//
//  MFPAuthorization.m
//
//  Created by Todd Roman on 2/25/14.
//  Copyright (c) 2014 MyFitnessPal, LLC. All rights reserved.
//

#import "MFPAuthorizationRequest.h"
#import "MFPConnection.h"
#import "MFPAccessTokenData.h"
#import "MFPErrorFactory.h"
#import "MFPError.h"
#import "NSError+MFPError.h"
#import "MFPResponse.h"

#import <UIKit/UIKit.h>
#import "MFPSettings.h"
#import "MFPUtilities.h"

@interface MFPAuthorizationRequest ()

@property (nonatomic, strong) MFPSession *session;

@end

@implementation MFPAuthorizationRequest

- (void)revokeAccessOnSuccess:(MFPConnectionSuccessCallback)onSuccess
                    onFailure:(MFPConnectionFailureCallback)onFailure
                   forSession:(MFPSession *)activeSession {
  
  NSString *path = @"/oauth2/revoke/";
  NSDictionary *params = @{ @"refresh_token" : [[activeSession accessTokenData] refreshToken] };
  
  [MFPConnection sendRequestWithPath:path
                          httpMethod:@"GET"
                              action:nil
                            encoding:nil
                          parameters:params
                           onSuccess:^(MFPResponse *response) {
                             
                             if (onSuccess)
                               onSuccess(response);
                             
                           }
                           onFailure:^(MFPResponse *response, NSError **error){
                             
                             NSError *authError = [MFPErrorFactory errorWithDomain:MFPErrorDomainAuthorization
                                                                         errorCode:MFPAuthErrorTokenRefreshFailed
                                                                  errorDescription:[*error errorDescription]];
                             if (onFailure)
                               onFailure(response, &authError);
                             
                           }];
  
}


- (void)refreshAccessToken:(MFPAccessTokenData *)accessTokenData
                 onSuccess:(MFPConnectionSuccessCallback)onSuccess
                 onFailure:(MFPConnectionFailureCallback)onFailure {
  
  NSString *path = @"/oauth2/token";
  NSDictionary *params = @{ @"refresh_token" : [accessTokenData refreshToken],
                            @"grant_type" : @"refresh_token"};

  [MFPConnection sendRequestWithPath:path
                          httpMethod:@"POST"
                              action:nil
                            encoding:@"application/x-www-form-urlencoded"
                          parameters:params
                           onSuccess:^(MFPResponse *response) {
                             
                             if ([response error]) {
                               
                               NSError *error = [response error];
                               
                               if (onFailure)
                                 onFailure(response, &error);
                               
                             }
                             if (onSuccess)
                               onSuccess(response);
                             
                           }
                           onFailure:^(MFPResponse *response, NSError **error){
                             
                             if (onFailure)
                               onFailure(response, error);
                             
                           }];

}


- (void)authorizeWithPermissions:(NSArray *)permissions
                           state:(NSString *)state
                    responseType:(NSString *)responseType
                       onFailure:(MFPFailureCallback)onFailure {
  
  [self installApp];
  
  MFPAppType apps = [MFPSettings mfpAppsAvailable];
  
  NSString *urlBase = nil;
  
  if (apps & MFPiPadApp)
    urlBase = @"mfphd://oauth2/authorize?";
  else if (apps & MFPiPhoneApp)
    urlBase = @"mfp://oauth2/authorize?";
  
  NSDictionary *parameters = @{
                               @"display":@"mobile",
                               @"access_type":@"offline",
                               @"response_type":responseType,
                               @"client_id":[MFPSettings clientId],
                               @"scope":[permissions componentsJoinedByString:@" "],
                               @"state":state,
                               @"redirect_uri":[self redirectUri]
                               };
  
  NSString *urlString = [urlBase stringByAppendingString:[MFPUtilities dictionaryToQueryString:parameters]];

  @autoreleasepool {
  
    if (! [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]]) {
      
      if (onFailure) {
        
        NSError *error = [MFPErrorFactory errorWithDomain:MFPErrorDomainClient
                                                errorCode:MFPClientErrorOpenAppUrl
                                         errorDescription:nil];

        onFailure(&error);
        
      }
      
    }
    
  }
  
}

- (NSString *)redirectUri {

  return [NSString stringWithFormat:@"%@://%@%@", [MFPSettings clientRedirectUri],
          [MFPSettings mfpHostname], [MFPSettings authRedirectUriPath]];
 
}

- (void)installApp {
  
  if ([MFPSettings mfpAppIsInstalled])
    return;
  
  @autoreleasepool {
  
    UIApplication *app = [UIApplication sharedApplication];
    [app openURL:[NSURL URLWithString:[MFPSettings appInstallUrl]]];
  
  }
  
}


@end
