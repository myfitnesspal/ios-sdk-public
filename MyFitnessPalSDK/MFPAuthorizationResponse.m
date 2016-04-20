//
//  MFPAuthorizationResponse.m
//  MFP
//
//  Created by Todd Roman on 3/3/14.
//  Copyright (c) 2014 MyFitnessPal, LLC. All rights reserved.
//

#import "MFPAuthorizationResponse.h"
#import "MFPAccessTokenData.h"
#import "MFPSession.h"
#import "MFPErrorFactory.h"
#import "MFPError.h"
#import "NSError+MFPError.h"

@interface MFPAuthorizationResponse ()

@property (nonatomic, strong) MFPAccessTokenData *accessTokenData;
@property (nonatomic, copy) NSArray *permissions;

@end


@implementation MFPAuthorizationResponse


- (id)initWithData:(NSDictionary *)data
             error:(NSError **)error
        statusCode:(NSInteger)statusCode
       permissions:(NSArray *)permissions {

  
  if ([data objectForKey:@"error"])
    statusCode = 400;
  else
    statusCode = 200;
  
  self = [super initWithData:data error:error statusCode:statusCode];

  if (self) {
    
    if ([self error]) {
      
      if ([[[self error] domain] isEqualToString:@"MFPErrorDomainInternal"]) {
      
        [self setError:[MFPErrorFactory errorWithDomain:MFPErrorDomainAuthorization
                                              errorName:[[self error] errorName]
                                       errorDescription:[[self error] errorDescription]]];
        
      }
      
    }
    [self setPermissions:permissions];
    [self readAuthorizationResponse];
    
  }
  
  return self;
  
}

- (void)readAuthorizationResponse {
  
  // Read MFPResponse data and set auth properties
  
  NSString *accessToken = [[self data] objectForKey:@"access_token"];
  NSString *refreshToken = [[self data] objectForKey:@"refresh_token"];

  NSString *authorizationCode = [[self data] objectForKey:@"code"];
  NSString *tokenType = [[self data] objectForKey:@"token_type"];
  NSString *expiresIn = [[self data] objectForKey:@"expires_in"];
  
  NSString *userId = [[self data] objectForKey:@"user"];
  
  NSString *scope = [[self data] objectForKey:@"scope"];
  
  _state = [[self data] objectForKey:@"state"];
  
  if (scope)
    _permissions = [scope componentsSeparatedByString:@" "]; // Different than what was requested
  
  NSDate *expirationDate;
  
  if (expiresIn) {
  
    expirationDate = [[NSDate date] dateByAddingTimeInterval:[expiresIn integerValue]];

  } else {
    
    if (! authorizationCode) // authorization code is expected to be short-lived
      expirationDate = [[NSDate date] dateByAddingTimeInterval:24*60*60*365*5]; // Currently, these do not expire
    else
      expirationDate = nil;
    
  }
  
  if ([[tokenType lowercaseString] isEqualToString:@"bearer"]) {
    
    _accessTokenData = [[MFPAccessTokenData alloc] initWithAccessToken:[accessToken copy]
                                                          refreshToken:[refreshToken copy]
                                                             tokenType:[tokenType copy]
                                                                userId:userId
                                                           permissions:_permissions
                                                        expirationDate:expirationDate];
    
  } else if (authorizationCode) {
   
    _accessTokenData = [[MFPAccessTokenData alloc] initWithAuthorizationCode:authorizationCode
                                                                 permissions:_permissions
                                                                      userId:userId
                                                              expirationDate:nil];
    
  }
  

  

}


- (id)initTokenRefreshResponseWithData:(NSDictionary *)data
                                 error:(NSError **)error
                            statusCode:(NSInteger)statusCode
           withExistingAccessTokenData:(MFPAccessTokenData *)accessTokenData {
  
  self = [[MFPAuthorizationResponse alloc] initWithData:data
                                                  error:error
                                             statusCode:statusCode
                                            permissions:accessTokenData.permissions];
  
  if (self) {

    if (_accessTokenData) {

      MFPAccessTokenData *token = [MFPAccessTokenData refreshFromExistingAccessTokenData:accessTokenData
                                                                   refreshedAcccessToken:_accessTokenData.accessToken
                                                                      refreshedTokenType:_accessTokenData.tokenType
                                                                          expirationDate:_accessTokenData.expirationDate];
      
      _accessTokenData = token;
      
    }

  }
  return self;
  
}

- (MFPAccessTokenData *)accessTokenData {
  
  return _accessTokenData;
  
}


- (NSString *)description {

  if (_accessTokenData) {
  
    return [NSString stringWithFormat:@"\nAccess token: %@\n"
                                       "Refresh token: %@\n"
                                       "Expiration:%@\n"
                                       "Auth code: %@\n"
                                       "User: %@\n"
                                       "Permissions: %@\n",
            _accessTokenData.accessToken, _accessTokenData.refreshToken,
            _accessTokenData.expirationDate, _accessTokenData.authorizationCode,
            _accessTokenData.userId, _accessTokenData.permissions];
    
  }
  
  return NSStringFromClass([self class]);
  
}

@end
