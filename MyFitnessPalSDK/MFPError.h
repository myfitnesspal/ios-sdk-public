/*
 *
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

/**
 * @class MFPError
 *
 * @brief Enums and constants to simplify error handing
 *
 * Defines error domains and codes that can be used to handle errors returned
 * by the SDK.
 */

#import <Foundation/Foundation.h>

/**
 * Code assigned to NSError for MFPErrorDomainAuthorization errors
 */
typedef enum : NSInteger {
  
  /** Error code used when no other valid code can be found */
  MFPAuthErrorUnknown = 0,
  /** Client not authorized to get an authorization code */
  MFPAuthErrorUnauthorizedClient = 1,
  /** The resource owner or authorization server denied the request */
  MFPAuthErrorAccessDenied = 2,
  /** The authorization server does not support obtaining an authorization code using this method */
  MFPAuthErrorUnsupportedResponseType = 3,
  /** The requested scope is invalid, unknown, or malformed */
  MFPAuthErrorInvalidScope = 4,
  /** The authorization server encountered an unexpected condition that prevented it from fulfilling the request */
  MFPAuthErrorServerError = 5,
  /** The authorization server is currently unable to handle the request due to a temporary overloading or maintenance of the server */
  MFPAuthErrorTemporarilyUnavailable = 6,
  /** The request is missing a required parameter, includes an invalid parameter value, or is otherwise malformed */
  MFPAuthErrorInvalidRequest = 7,
  /** Potential cross-site forgery issue. State is a UID used to verify the origin of the request when the app is opened as part of the response from an initial oAuth request */
  MFPAuthErrorInvalidState = 8,
  /** User does not explicitly deny access - cancels out of the oAuth flow */
  MFPAuthErrorUserCanceled = 9,
  /** Failed to refresh the access token */
  MFPAuthErrorTokenRefreshFailed = 10,
  /** Invalid session state (ie closed session) */
  MFPInvalidSessionState = 11
  
} MFPAuthErrorCode;

/**
 *
 * Code assigned to NSError for MFPErrorDomainClient errors
 *
 */
typedef enum : NSInteger {
  
  /** Error code used when no other valid code can be found */
  MFPClientErrorUnknown = 0,
  /** Client-side input validation error */
  MFPClientErrorInvalidInput = 1,
  /** Failed to open an external app, i.e. MyFitnessPal during oAuth */
  MFPClientErrorOpenAppUrl = 2,
  
} MFPClientErrorCode;

/**
 *
 * Code assigned to NSError for MFPErrorDomainServer errors - these correspond
 * to HTTP error codes.
 *
 */
typedef enum : NSInteger {
  /** HTTP 400 error responses */
  MFPServerErrorInvalidRequest = 400,
  /** HTTP 500 error responses */
  MFPServerErrorInternalServerError = 500
} MFPServerErrorCode;


@interface MFPError : NSObject

/**
 * @memberof MFPError
 *
 * NSError domain for authorization errors 
 */
extern NSString *const MFPErrorDomainAuthorization;

/** @memberof MFPError
 *  NSError domain for client errors 
 */
extern NSString *const MFPErrorDomainClient;

/** @memberof MFPError
 *  NSError domain for server errors - 400s and 500s
 */
extern NSString *const MFPErrorDomainServer;

@end
