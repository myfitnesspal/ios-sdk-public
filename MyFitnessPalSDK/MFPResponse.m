//
//  MFPResponse.m
//  MFP
//
//  Created by Todd Roman on 2/25/14.
//  Copyright (c) 2014 MyFitnessPal, LLC. All rights reserved.
//

#import "MFPResponse.h"
#import "MFPErrorFactory.h"
#import "MFPError.h"

@interface MFPResponse ()

@property (nonatomic, strong) NSString *responseType;
@property (nonatomic, strong) NSString *errorName;
@property (nonatomic, strong) NSString *errorDescription;
@property (nonatomic) NSError *error;
@property (nonatomic, strong) id data;

@end

@implementation MFPResponse


- (id)initWithData:(id)data
             error:(NSError **)error
        statusCode:(NSInteger)statusCode {
  
  self = [super init];
  
  if (self) {
    
    if (data)
      [(MFPResponse *)self setData:[data copyWithZone:nil]];
    else
      [(MFPResponse *)self setData:[NSDictionary new]];
    
    if (error) {
      [self setError:*error];
    }
    
    if ([[data class] isSubclassOfClass:[NSDictionary class]])
      [(MFPResponse *)self processResponseData];
    
    [self setStatusCode:statusCode];
    
  }
  
  return self;
  
}

- (void)processResponseData {
  
  // Go through the dictionary and assign to instance properties
  
  id error = [_data objectForKey:@"error"];
  
  if (error) {
    
    if ([error isKindOfClass:[NSDictionary class]]) {

      _errorName = [error objectForKey:@"type"];
      _errorDescription = [error objectForKey:@"message"];
      
    } else if ([error isKindOfClass:[NSString class]]) {
      
      _errorName = error;
      _errorDescription = [_data objectForKey:@"error_description"];
      
    }
    
    // Fix this up to call an MFPErrorFactory method for an unknown error
    
    if (! _errorName) {
      _errorName = @"unknown_error";
    }
    
    if (! _errorDescription) {
      _errorDescription = @"Unknown error";
      
    }
    
    // Move this to be a class method in MFPErrorFactory
    NSError *error = [[NSError alloc] initWithDomain:@"MFPErrorDomainInternal"
                                                code:0
                                            userInfo:@{@"error_name" : _errorName,
                                                       @"error_description" : _errorDescription}];
  
    [self setError:error];
    
  }
  
}

- (NSError *)error {
  return _error;
}

- (NSDictionary *)data {
  return _data;
}

- (NSString *)errorName {
  return _errorName;
}

- (NSString *)errorDescription {
  return _errorDescription;
}


- (NSString *)description {
  
  return [_data description];
  
}


- (void)setStatusCode:(NSInteger)statusCode {
  _statusCode = statusCode;
}

@end
