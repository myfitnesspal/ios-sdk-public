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

#import "MFPSession.h"

/**
 *
 * @class MFPEcho
 * @brief Implements a basic ping test of the MyFitnessPal API service
 *
 * The MFPEcho object is used as a utility class to test authentication
 * and API availability by sending a text value and having the same text
 * returned, if successful.
 *
 */

@interface MFPEcho : NSObject

/** @memberof MFPEcho Readonly string representing the server response - should match requestText */
@property (nonatomic, strong, readonly) NSString *responseText;

/** @memberof MFPEcho Text being sent to the API endpoint */
@property (nonatomic, strong) NSString *requestText;

/**
 *
 * Constructor for creating an instance of MFPEcho, initialized with a text
 * value that can later be sent with sendRequestOnSucess:onFailure.
 *
 * @param text An NSString that will be sent if sendRequestOnSucess:onFailure is
 * later called.
 *
 * @return An instance of MFPEcho
 *
 */
- (MFPEcho *)initWithRequestText:(NSString *)text;

/**
 *
 * Sends the value of [self requestText] to the server. On success, the response
 * text will be stored in [self responseText].
 *
 * @param onSuccess  MFPSuccessCallback block, which will be executed if the
 * API call returns without any errors.
 *
 * @param onFailure  MFPFailureCallback block, which will be executed if the
 * API call returns with an error or if the call fails to reach the server. The
 * error will be passed to the block as an NSError object.
 *
 */
- (void)sendRequestOnSuccess:(MFPSuccessCallback)onSuccess
                   onFailure:(MFPFailureCallback)onFailure;

/**
 *
 * Sends the value of the text parameter to the server. On success, the response
 * text will be stored in [self responseText].
 *
 * @param text  NSString with a length >= 1. An empty string will result in an
 * error, which will be passed to the onFailure code block.
 *
 * @param onSuccess  MFPSuccessCallback block, which will be executed if the
 * API call returns without any errors.
 *
 * @param onFailure  MFPFailureCallback block, which will be executed if the
 * API call returns with an error or if the call fails to reach the server. The
 * error will be passed to the block as an NSError object.
 *
 */

- (void)sendRequestText:(NSString *)text
              onSuccess:(MFPSuccessCallback)onSuccess
              onFailure:(MFPFailureCallback)onFailure;

@end
