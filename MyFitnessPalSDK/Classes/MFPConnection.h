//
//  MFPConnection.h
//
//  Created by Todd Roman on 2/18/14.
//  Copyright (c) 2014 MyFitnessPal, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFPSession.h"

@class MFPResponse;


/* 
   Success and failure callback definitions - these are for internal use only.
   We currently do not expose the MFPResponse object to the client apps.
   It is up to the caller to process the MFPResponse object before returning to the
   caller or invoking the caller's success block.
 
*/

typedef void (^MFPConnectionSuccessCallback)(MFPResponse *response);
typedef void (^MFPConnectionFailureCallback)(MFPResponse *response, NSError **error);


@interface MFPConnection : NSObject

+ (void)sendRequestWithPath:(NSString *)url
                 httpMethod:(NSString *)method
                     action:(NSString *)action   // API Version 1.x (action is added to the parameters)
                   encoding:(NSString *)encoding // default is JSON if nil and ignored if method is GET
                 parameters:(NSDictionary *)parameters
                 onSuccess:(MFPConnectionSuccessCallback)onSuccess
                 onFailure:(MFPConnectionFailureCallback)onFailure;

@end
