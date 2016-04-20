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

#import <Foundation/Foundation.h>

/**
 *
 * @typedef MFPAdHocRequestSuccessCallback
 * Block type used for success callbacks
 *
 */
typedef void(^MFPAdHocRequestSuccessCallback)(id responseData);

/**
 *
 * @typedef MFPAdHocRequestFailureCallback
 * Block type used for failure callbacks
 *
 */
typedef void(^MFPAdHocRequestFailureCallback)(NSError **error);

/**
 *
 * @class MFPAdHocRequest
 * @brief A pass-through handler that allows for querying the MyFitnessPal
 *        API directly (version 1.x only).
 *
 * The MFPAdHocRequest object is meant to be used as a wrapper, for mobile
 * clients where no backend server-to-server communication exists.
 *
 * Requests made with MFPAdHocRequest will provide basic authentication and
 * error handling along with JSON request parameter encoding and response
 * decoding.
 *
 *
 */

@interface MFPAdHocRequest : NSObject

/**
 *
 * Send an ad-hoc request to the MyFitnessPal API. Note that you do not
 * need to include the access token or the action name in the request parameters.
 * These are inlucded in every API request, by the connection handler in the SDK.
 *
 * @param actionName String that defines the specific action within the API.
 *
 * @param params Dictionary of request parameters (excluding action_name and access_token)
 *
 * @param onSuccess sucess block, type MFPAdHocRequestSuccessCallback
 *
 * @param onFailure failure block, type MFPAdHocRequestFailureCallback
 *
 */
- (void)sendRequestForActionName:(NSString *)actionName
                      withParams:(NSDictionary *)params
                       onSuccess:(MFPAdHocRequestSuccessCallback)onSuccess
                       onFailure:(MFPAdHocRequestFailureCallback)onFailure;

@end
