//
//  MFPAuthorizationResponse.h
//
//  Created by Todd Roman on 3/3/14.
//  Copyright (c) 2014 MyFitnessPal, Inc. All rights reserved.
//

#import "MFPResponse.h"

@class MFPAccessTokenData;

@interface MFPAuthorizationResponse : MFPResponse

@property (nonatomic, strong, readonly) NSString *state;
@property (nonatomic, strong) NSError *error;

// Creates a new accessTokenData object
- (id)initWithData:(NSDictionary *)data
             error:(NSError **)error
        statusCode:(NSInteger)statusCode
       permissions:(NSArray *)permissions;

// Creates an updated accessTokenData object after a refresh
- (id)initTokenRefreshResponseWithData:(NSDictionary *)data
                                 error:(NSError **)error
                            statusCode:(NSInteger)statusCode
           withExistingAccessTokenData:(MFPAccessTokenData *)accessTokenData;

- (MFPAccessTokenData *)accessTokenData;



@end
