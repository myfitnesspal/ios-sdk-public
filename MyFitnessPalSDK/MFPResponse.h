//
//  MFPResponse.h
//  MFP
//
//  Created by Todd Roman on 2/25/14.
//  Copyright (c) 2014 MyFitnessPal, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MFPResponse;

@interface MFPResponse : NSObject

@property (readonly) NSInteger statusCode; // HTTP status code

- (id)data;

- (id)initWithData:(NSDictionary *)data error:(NSError **)error statusCode:(NSInteger)statusCode;

- (NSError *)error;

@end
