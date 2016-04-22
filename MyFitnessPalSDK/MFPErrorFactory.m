//
//  MFPErrorFactory.m
//  MyFitnessPalSDK
//
//  Created by Todd Roman on 4/24/14.
//  Copyright (c) 2014 MyFitnessPal. All rights reserved.
//

#import "MFPErrorFactory.h"
#import "MFPError.h"

static NSString *const MFPErrorName = @"error";
static NSString *const MFPErrorDescription = @"error_description";

@implementation MFPErrorFactory


+ (NSError *)errorWithDomain:(NSString *)domain
                   errorCode:(NSInteger)errorCode
            errorDescription:(NSString *)errorDescription {
  
  if ([domain isEqualToString:MFPErrorDomainClient]) {
    
    return [self createClientErrorWithErrorCode:errorCode
                                    description:errorDescription];
    
  } else if ([domain isEqualToString:MFPErrorDomainAuthorization]) {
   
    return [self createAuthErrorWithErrorName:[self authErrorNameForErrorCode:errorCode]
                                  description:errorDescription];
    
  } else if ([domain isEqualToString:MFPErrorDomainServer]) {
    
    return [self createServerErrorWithErrorCode:errorCode description:errorDescription];
    
  }
  
  return nil;
  
}

+ (NSError *)errorWithDomain:(NSString *)domain
                   errorName:(NSString *)errorName
            errorDescription:(NSString *)errorDescription {
  
  if ([domain isEqualToString:MFPErrorDomainAuthorization])
    return [self createAuthErrorWithErrorName:errorName description:errorDescription];
  
  return nil;
  
}

+ (NSInteger)authErrorCodeForErrorName:(NSString *)errorName {
  
  static NSDictionary *authErrorCodeMap;
  
  if (! authErrorCodeMap) {
    authErrorCodeMap = @{@"unknown_error" : @(MFPAuthErrorUnknown),
                         @"invalid_request" : @(MFPAuthErrorInvalidRequest),
                         @"invalid_scope" : @(MFPAuthErrorInvalidScope),
                         @"server_error" : @(MFPAuthErrorServerError),
                         @"temporarily_unavailable" : @(MFPAuthErrorTemporarilyUnavailable),
                         @"unauthorized_client" : @(MFPAuthErrorUnauthorizedClient),
                         @"unsupported_response_type" : @(MFPAuthErrorUnsupportedResponseType),
                         @"invalid_state" : @(MFPAuthErrorInvalidState),
                         @"user_cancel" : @(MFPAuthErrorUserCanceled),
                         @"access_denied" : @(MFPAuthErrorAccessDenied)
                        };
    
  }

  return authErrorCodeMap[errorName] ? [(NSNumber *)authErrorCodeMap[errorName] longValue] : MFPAuthErrorUnknown;
  
}


+ (NSString *)authErrorNameForErrorCode:(NSInteger)errorCode {
  
  static NSDictionary *authErrorNameMap;
  
  if (! authErrorNameMap) {
    authErrorNameMap = @{@(MFPAuthErrorUnknown) : @"unknown_error",
                         @(MFPAuthErrorInvalidRequest) : @"invalid_request",
                         @(MFPAuthErrorInvalidScope) : @"invalid_scope",
                         @(MFPAuthErrorServerError) : @"server_error",
                         @(MFPAuthErrorTemporarilyUnavailable) : @"temporarily_unavailable",
                         @(MFPAuthErrorUnauthorizedClient) : @"unauthorized_client",
                         @(MFPAuthErrorUnsupportedResponseType) : @"unsupported_response_type",
                         @(MFPAuthErrorInvalidState) : @"invalid_state",
                         @(MFPAuthErrorUserCanceled) : @"user_cancel",
                         @(MFPAuthErrorAccessDenied) : @"access_denied"
                         };
    
  }
  
  NSString *errorName = authErrorNameMap[@(errorCode)];
  
  return errorName ? errorName : (NSString *)authErrorNameMap[@(MFPAuthErrorUnknown)];
  
}


+ (NSError *)createAuthErrorWithErrorName:(NSString *)errorName
                              description:(NSString *)description {
  
  if (! errorName)
    errorName = @"unknown_error";
  
  NSString *errorDescription;
  
  NSInteger errorCode = [self authErrorCodeForErrorName:errorName];
  
  switch (errorCode) {
      
    case (MFPAuthErrorInvalidRequest):
      errorDescription = @"Invalid request";
      break;
    case (MFPAuthErrorInvalidScope):
      errorDescription = @"Invalid scope";
      break;
    case (MFPAuthErrorServerError):
      errorDescription = @"Server error";
      break;
    case (MFPAuthErrorTemporarilyUnavailable):
      errorDescription = @"Temporarily unavailable";
      break;
    case (MFPAuthErrorUnauthorizedClient):
      errorDescription = @"Unauthorized client";
      break;
    case (MFPAuthErrorUnknown):
      errorDescription = @"Unknown error";
      break;
    case (MFPAuthErrorUnsupportedResponseType):
      errorDescription = @"Unsupported response type";
      break;
    case (MFPAuthErrorInvalidState):
      errorDescription = @"Cross-site forgery warning: invalid state received during open request";
      break;
    case (MFPAuthErrorUserCanceled):
      errorDescription = @"User canceled authorization";
      break;
    case (MFPAuthErrorAccessDenied):
      errorDescription = @"Access denied";
    default:
      errorDescription = @"Unknown error";

  }

  NSDictionary *userInfo = @{ MFPErrorName : errorName,
                              MFPErrorDescription : description ? description : errorDescription };
  
  NSError *error = [NSError errorWithDomain:MFPErrorDomainAuthorization
                                       code:errorCode
                                   userInfo:userInfo];
  return error;
  
}

+ (NSError *)createClientErrorWithErrorCode:(NSInteger)errorCode description:(NSString *)description {
  
  NSString *errorName;
  NSString *errorDescription;
  
  switch (errorCode) {
    case (MFPClientErrorOpenAppUrl):
      errorName = @"open_app_url";
      errorDescription = @"Failed to open app";
      break;
    case (MFPClientErrorInvalidInput):
      errorName = @"invalid_input";
      errorDescription = @"Invalid input";
      break;
    case (MFPClientErrorUnknown):
      errorName = @"unknown_error";
      errorDescription = @"Unknown error";
      break;
    default:
      errorName = @"unknown_error";
      errorDescription = @"Unknown error";
  }
  
  NSDictionary *userInfo = @{ MFPErrorName : errorName,
                              MFPErrorDescription : description ? description : errorDescription };
  
  NSError *error = [NSError errorWithDomain:MFPErrorDomainClient
                                       code:errorCode
                                   userInfo:userInfo];
  return error;

}

+ (NSError *)createServerErrorWithErrorCode:(NSInteger)errorCode description:(NSString *)description {
  
  NSString *errorName;
  NSString *errorDescription;
  
  switch (errorCode) {
    case (MFPServerErrorInvalidRequest):
      errorName = @"invalid_request";
      errorDescription = @"Invalid request";
      break;
    case (MFPServerErrorInternalServerError):
      errorName = @"internal_error";
      errorDescription = @"Internal server error";
      break;
    default:
      errorName = @"unknown_error";
      errorDescription = @"Unknown error";
  }
  
  NSDictionary *userInfo = @{ MFPErrorName : errorName,
                              MFPErrorDescription : description ? description : errorDescription };
  
  NSError *error = [NSError errorWithDomain:MFPErrorDomainServer
                                       code:errorCode
                                   userInfo:userInfo];
  return error;
  
}

@end
