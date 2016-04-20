//
//  MFPRequest.m
//  MFP
//
//  Created by Todd Roman on 2/25/14.
//  Copyright (c) 2014 MyFitnessPal, LLC. All rights reserved.
//

#import "MFPAdHocRequest.h"
#import "MFPResponse.h"
#import "MFPSettings.h"
#import "MFPAccessTokenData.h"
#import "MFPConnection.h"

@implementation MFPAdHocRequest


- (void)sendRequestForActionName:(NSString *)actionName withParams:(NSDictionary *)params {
  
  [self sendRequestForActionName:actionName withParams:params onSuccess:nil onFailure:nil];
  
}


- (void)sendRequestForActionName:(NSString *)actionName
                      withParams:(NSDictionary *)params
                       onSuccess:(MFPAdHocRequestSuccessCallback)onSuccess
                       onFailure:(MFPAdHocRequestFailureCallback)onFailure {
  
  
  MFPConnectionSuccessCallback successInternalCallback = ^(MFPResponse *response) {
    
    if (onSuccess)
      onSuccess(response.data);
    
  };
  
  MFPConnectionFailureCallback failureInternalCallback = ^(MFPResponse *response, NSError **error) {
    
    if (onFailure)
      onFailure(error);
    
  };

  [MFPConnection sendRequestWithPath:actionName // Ignored in API 1.x
                          httpMethod:@"POST"
                              action:actionName
                            encoding:nil
                          parameters:params
                           onSuccess:successInternalCallback
                           onFailure:failureInternalCallback];
  
}



@end
