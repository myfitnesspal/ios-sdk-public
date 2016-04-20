//
//  MFPEcho.m
//  MFP
//
//  Created by Todd Roman on 4/15/14.
//  Copyright (c) 2014 MyFitnessPal, LLC. All rights reserved.
//

#import "MFPEcho.h"
#import "MFPSession.h"
#import "MFPConnection.h"
#import "MFPResponse.h"
#import "MFPError.h"
#import "NSError+MFPError.h"
#import "MFPErrorFactory.h"

@implementation MFPEcho

- (MFPEcho *)initWithRequestText:(NSString *)text {
  
  self = [super init];
  
  if (self) {
    _requestText = text;
  }
  
  return self;
}


- (void)sendRequestOnSuccess:(MFPSuccessCallback)onSuccess
                   onFailure:(MFPFailureCallback)onFailure {
  
  [self sendRequestText:_requestText onSuccess:onSuccess onFailure:onFailure];
  
}

- (void)sendRequestText:(NSString *)text
              onSuccess:(MFPSuccessCallback)onSuccess
              onFailure:(MFPFailureCallback)onFailure {
  
  if (! text || [text length] == 0) {
    
    NSError *error = [MFPErrorFactory errorWithDomain:MFPErrorDomainClient
                                            errorCode:MFPClientErrorInvalidInput
                                     errorDescription:@"Text length must be > 0"];
    
    if (onFailure)
      onFailure(&error);

    return;
    
  }
  
  // Unset responseString before we make the request
  _responseText = nil;
  
  MFPConnectionSuccessCallback successInternalCallback = ^(MFPResponse *response) {
  
    if ([[response data] objectForKey:@"test_content"]) {
    
      _responseText = [[response data] objectForKey:@"test_content"];
      
    }
    
    if (onSuccess)
      onSuccess();
    
  };
  
  MFPConnectionFailureCallback failureInternalCallback = ^(MFPResponse *response, NSError **error) {
  
    NSError *apiError = [response error] ? [response error] : *error;
    
    if (onFailure)
      onFailure(&apiError);
    
  };
  
  NSDictionary *parameters = @{ @"test_content" : text };
  
  // Sends test_content to the backend API and expects a response that is the same as what was sent
  [MFPConnection sendRequestWithPath:@"/echo" // Gets ignored in API 1.0.0
                          httpMethod:@"POST"
                              action:@"echo"
                            encoding:nil
                          parameters:parameters
                           onSuccess:successInternalCallback
                           onFailure:failureInternalCallback];
}
@end
