//
//  MFPAccessTokenData.m
//
//  Created by Todd Roman on 2/25/14.
//  Copyright (c) 2014 MyFitnessPal, LLC. All rights reserved.
//

#import "MFPAccessTokenData.h"

@implementation MFPAccessTokenData

- (MFPAccessTokenData *)initWithAccessToken:(NSString *)accessToken
                               refreshToken:(NSString *)refreshToken
                                  tokenType:(NSString *)tokenType
                                     userId:(NSString *)userId
                                permissions:(NSArray *)permissions
                             expirationDate:(NSDate *)expirationDate {
  
  self = [super init];
  
  if (self) {
    
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _tokenType = tokenType;
    _permissions = [permissions copy];
    _expirationDate = expirationDate;
    _userId = userId;
    
  }
  
  return self;
  
}

- (MFPAccessTokenData *)initWithAuthorizationCode:(NSString *)authorizationCode
                                      permissions:(NSArray *)permissions
                                           userId:(NSString *)userId
                                   expirationDate:(NSDate *)expirationDate {

  self = [super init];
  
  if (self) {
    
    _authorizationCode = authorizationCode;
    _permissions = [permissions copy];
    _expirationDate = expirationDate;
    _userId = userId;
    
  }
  
  return self;
  
}

- (id)copyWithZone:(NSZone *)zone {
  
  if (_authorizationCode) {
    
    return [[MFPAccessTokenData alloc] initWithAuthorizationCode:[_authorizationCode copy]
                                                     permissions:[_permissions copy]
                                                          userId:[_userId copy]
                                                  expirationDate:[_expirationDate copy]];

  } else {
    
    return [[MFPAccessTokenData alloc] initWithAccessToken:[_accessToken copy]
                                              refreshToken:[_refreshToken copy]
                                                 tokenType:[_tokenType copy]
                                                    userId:[_userId copy]
                                               permissions:[_permissions copy]
                                            expirationDate:[_expirationDate copy]];
  
  }
  
  
}

- (BOOL)accessTokenIsExpired {
  
  if (! _accessToken || [_expirationDate timeIntervalSinceNow] <= 0)
    return YES;
  
  return NO;
  
}

+ (MFPAccessTokenData *)refreshFromExistingAccessTokenData:(MFPAccessTokenData *)existingAccessTokenData
                                     refreshedAcccessToken:(NSString *)refreshedAccessToken
                                        refreshedTokenType:(NSString *)tokenType
                                            expirationDate:(NSDate *)expirationDate {
  
  return [[MFPAccessTokenData alloc] initWithAccessToken:refreshedAccessToken
                                            refreshToken:existingAccessTokenData.refreshToken
                                               tokenType:tokenType
                                                  userId:existingAccessTokenData.userId
                                             permissions:existingAccessTokenData.permissions
                                          expirationDate:expirationDate];
}

@end
