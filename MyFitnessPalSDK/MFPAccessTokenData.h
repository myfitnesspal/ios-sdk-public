/*
 * Copyright (c) 2014 MyFitnessPal, Inc. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


#import <Foundation/Foundation.h>

/**
 * @class MFPAccessTokenData
 *
 * @brief Stores and retrieves access and refresh tokens
 *
 * Manages oAuth access and refresh tokens, authorization codes
 *
 */

@interface MFPAccessTokenData : NSObject <NSCopying>

/** Access token */
@property (readonly, nonatomic, copy) NSString *accessToken;

/** Refresh token */
@property (readonly, nonatomic, copy) NSString *refreshToken;

/** Array of permission strings, granted along with the OAuth access tokens */
@property (readonly, nonatomic, copy) NSArray *permissions;

/** Access token expiration - does not apply to the authorization code */
@property (readonly, nonatomic, copy) NSDate *expirationDate;

/** Authorization code - to be exchanged for access/refresh token pair */
@property (readonly, nonatomic, copy) NSString *authorizationCode;

/** Type of access token (i.e. Bearer) */
@property (readonly, nonatomic, copy) NSString *tokenType;

/** User ID of the resource owner account */
@property (readonly, nonatomic, copy) NSString *userId;


/**
 *
 *  Constructor for access and refresh token data
 *
 *  @param accessToken OAuth access token
 *
 *  @param refreshToken OAuth refresh token - can be used to get an updated access token
 *
 *  @param tokenType OAuth token type (i.e. Bearer)
 *
 *  @param userId User ID of the resource owner account
 *
 *  @param permissions Array of permissions granted to this token
 *
 *  @param expirationDate Date the access and refresh tokens expire
 *
 *  @return MFPAccessTokenData object
 */
- (MFPAccessTokenData *)initWithAccessToken:(NSString *)accessToken
                               refreshToken:(NSString *)refreshToken
                                  tokenType:(NSString *)tokenType
                                     userId:(NSString *)userId
                                permissions:(NSArray *)permissions
                             expirationDate:(NSDate *)expirationDate;

/**
 *
 *  Constructor for authorization code data
 *
 *  @param authorizationCode The authorization code returned from the oAuth request
 *
 *  @param permissions Array of permissions granted to this token
 *
 *  @param userId User ID of the resource owner account
 *
 *  @param expirationDate Date when the authorization code expires - default is 10 minutes from time of issuance
 *
 *  @return MFPAccessTokenData object
 */
- (MFPAccessTokenData *)initWithAuthorizationCode:(NSString *)authorizationCode
                                      permissions:(NSArray *)permissions
                                           userId:(NSString *)userId
                                   expirationDate:(NSDate *)expirationDate;


/**
 *
 *  Instance method to create a new, refreshed accessTokenData object from an existing one
 *
 *  @param existingAccessTokenData Original accessTokenData object
 *
 *  @param refreshedAccessToken Updated access token
 *
 *  @param tokenType Refreshed access token type (i.e. Bearer)
 *
 *  @param expirationDate Date when the authorization code expires - default is 10 minutes from time of issuance
 *
 *  @return MFPAccessTokenData object
 */
+ (MFPAccessTokenData *)refreshFromExistingAccessTokenData:(MFPAccessTokenData *)existingAccessTokenData
                                     refreshedAcccessToken:(NSString *)refreshedAccessToken
                                        refreshedTokenType:(NSString *)tokenType
                                            expirationDate:(NSDate *)expirationDate;

/**
 *
 *  Checks to verify if the access token is expired
 *
 *  @return Returns YES is token is expired, NO otherwise
 */
- (BOOL)accessTokenIsExpired;

@end
