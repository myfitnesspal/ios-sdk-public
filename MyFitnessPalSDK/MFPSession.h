/*
 * Copyright (c) 2014 MyFitnessPal, Inc. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

/** 
 *  @file
 *
 *  MFPSession globals
 */

/**
 * 
 * @typedef MFPSuccessCallback
 * Block type used for success callbacks
 *
 */
typedef void (^MFPSuccessCallback)(void);

/**
 *
 * @typedef MFPFailureCallback
 * Block type used for failure callbacks
 *
 */
typedef void (^MFPFailureCallback)(NSError **error);

/**
 *
 * @class MFPSession
 *
 * @brief MyFitnessPal API session and access token management
 *
 * MFPSession is the primary interface to creating and managing a session
 * with the MyFitnessPal API service.
 *
 */

#import <Foundation/Foundation.h>
@class MFPAccessTokenData;


/*
 * Constants
 */

/**
 * @memberof MFPSession
 *
 * Diary permission, used when request an access token or authorization code
 */
extern NSString *const MFPPermissionTypeDiary;

/**
 *  @memberof MFPSession
 *
 * Ready-only diary permission, used when request an access token or authorization code
 */
extern NSString *const MFPPermissionTypeDiaryReadOnly;

/**
 * @memberof MFPSession
 *
 * Used when making an oAuth request - indicates request is for an access token
 */
extern NSString *const MFPAuthorizationTypeAccessToken;

/**
 * @memberof MFPSession
 *
 * Used when making an oAuth request - indicates request is for an authorization code
 */
extern NSString *const MFPAuthorizationTypeCode;


@interface MFPSession : NSObject


/**
 *  @memberof MFPSession
 *
 *  Stores access and refresh token data
 */
@property(readonly, nonatomic) MFPAccessTokenData *accessTokenData;

/**
 *
 * Constructor for creating a session
 *
 * @param clientId This is a string value that would have been assigned to you when you created your partner account.
 *
 * @param urlSchemeSuffix Used to enable using multiple apps with the same clientId. An example would be `testclient` as the clientId and `app1` as the urlSchemeSuffix. The resulting scheme, for handling oAuth redirects, would be `mfp-testclient-app1`.
 *
 * @param responseType This should be one of: MFPAuthorizationTypeAccessToken, MFPAuthorizationTypeCode.
 *
 * @param cacheKey If nil, access token data will be stored in NSUserDefaults using a default key, defined in the SDK. Otherwise, will store and retrieve access token data using the supplied cacheKey.
 *
 * @return An instance of MFPSession
 *
 */
- (MFPSession *)initWithClientId:(NSString *)clientId
                 urlSchemeSuffix:(NSString *)urlSchemeSuffix
                    responseType:(NSString *)responseType
                        cacheKey:(NSString *)cacheKey;

/**
 *
 * Returns the activeSession singleton
 *
 * @return An MFPSession shared instance
 */
+ (MFPSession *)activeSession;


/**
 *
 *
 * Open a session, given a set of permissions
 *
 * @param permissions Array of strings, representing individual permissions. Currently, only `diary` and `diary_readonly` are supported. Should use constants MFPPermissionTypeDiary and MFPPermissionTypeDiaryReadOnly.
 *
 * @param onSuccess sucess block, type MFPSuccessCallback
 *
 * @param onFailure failure block, type MFPFailureCallback
 *
 */
- (void)openActiveSessionWithScope:(NSArray *)permissions
                         onSuccess:(MFPSuccessCallback)onSuccess
                         onFailure:(MFPFailureCallback)onFailure;

/**
 *
 * Open a session with existing token data
 *
 * @param permissions Array of strings, representing individual permissions. Currently, only `diary` and `diary_readonly` are supported. Should use constants MFPPermissionTypeDiary and MFPPermissionTypeDiaryReadOnly.
 *
 * @param accessTokenData Instance of MFPAccessTokenData containing access and refresh tokens
 *
 * @param onSuccess sucess block, type MFPSuccessCallback
 *
 * @param onFailure failure block, type MFPFailureCallback
 *
 */
- (void)openActiveSessionWithScope:(NSArray *)permissions
                   accessTokenData:(MFPAccessTokenData *)accessTokenData
                         onSuccess:(MFPSuccessCallback)onSuccess
                         onFailure:(MFPFailureCallback)onFailure;


/**
 *
 * Use oAuth to retrieve an authorization code
 *
 * @param permissions Array of strings, representing individual permissions. Currently, only `diary` and `diary_readonly` are supported. Should use constants MFPPermissionTypeDiary and MFPPermissionTypeDiaryReadOnly.
 *
 * @param onSuccess sucess block, type MFPSuccessCallback
 *
 * @param onFailure failure block, type MFPFailureCallback
 *
 */
- (void)getAuthorizationCodeWithScope:(NSArray *)permissions
                            onSuccess:(MFPSuccessCallback)onSuccess
                            onFailure:(MFPFailureCallback)onFailure;

/**
 *
 * Requires valid refresh token. Request is made directly to the API host, as opposed to opening the MyFitnessPal native application.
 *
 * @param onSuccess success block, type MFPSuccessCallback
 *
 * @param onFailure failure block, type MFPFailureCallback
 *
 */
- (void)revokeAccessOnSuccess:(MFPSuccessCallback)onSuccess
                    onFailure:(MFPFailureCallback)onFailure;

/**
 *
 * Refresh an existing access token. Requires valid refresh token. Request is made directly to the API host, as opposed to opening the MyFitnessPal native application.
 *
 * @param onSuccess success block, type MFPSuccessCallback
 *
 * @param onFailure failure block, type MFPFailureCallback
 *
 */

- (void)refreshAccessTokenOnSuccess:(MFPSuccessCallback)onSuccess
                          onFailure:(MFPFailureCallback)onFailure;


/**
 *
 * URL open handler when app is being opened by an another, external app (i.e. the MyFitnessPal native app for iOS). Checks the [url scheme] and [url path] to ensure it is the correct handler. You can optionally check [url scheme] to see that it matches the pattern of `mfp-[client ID]-[url scheme suffix]` and then invoke this method.
 *
 * @param url Instance of NSURL, received by application:openURL:sourceApplication:annotation:
 *            in AppDelegate
 *
 */
- (BOOL)handleOpenURL:(NSURL *)url;

/**
 *
 * Convenience method that returns the current client ID
 *
 */
- (NSString *)clientId;

/**
 *
 * Checks the state of the session. If session is open, there are valid access and refresh tokens. Otherwise, the session needs to be opened with one of the openActiveSession:* methods above.
 *
 */
- (BOOL)isOpen;

/**
 *
 * Closes the current, active session. Removes the reference to mfpAccessTokenData and sets status to closed.
 *
 */
- (void)close;

@end
