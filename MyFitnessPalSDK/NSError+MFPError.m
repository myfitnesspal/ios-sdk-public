//
//  NSError+MFPError.m
//  MyFitnessPalSDK
//
//  Created by Todd Roman on 4/22/14.
//  Copyright (c) 2014 MyFitnessPal. All rights reserved.
//

#import "NSError+MFPError.h"

@implementation NSError (MFPError)


- (NSString *)errorName {
  
  return [[self userInfo] objectForKey:@"error_name"];
  
}

- (NSString *)errorDescription {
  
  return [[self userInfo] objectForKey:@"error_description"];
  
}

@end
