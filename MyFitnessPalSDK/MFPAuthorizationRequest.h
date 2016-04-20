//
//  MFPAuthorization.h
//  MFPSDK
//
//  Created by Todd Roman on 2/25/14.
//  Copyright (c) 2014 MyFitnessPal, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFPSession.h"
#import "MFPConnection.h"

static const NSString *MFPAuthorizationResponseTypeToken = @"token";
static const NSString *MFPAuthorizationResponseTypeCode = @"code";
static const NSString *MFPAuthorizationScopeDiary = @"diary";

@interface MFPAuthorizationRequest : NSObject

- (void)revokeAccessOnSuccess:(MFPConnectionSuccessCallback)onSuccess
                    onFailure:(MFPConnectionFailureCallback)onFailure
                   forSession:(MFPSession *)activeSession;

- (void)authorizeWithPermissions:(NSArray *)permissions
                           state:(NSString *)state
                    responseType:(NSString *)responseType
                       onFailure:(MFPFailureCallback)onFailure;

- (void)refreshAccessToken:(MFPAccessTokenData *)accessTokenData
                 onSuccess:(MFPConnectionSuccessCallback)onSuccess
                 onFailure:(MFPConnectionFailureCallback)onFailure;

- (void)installApp;

@end
