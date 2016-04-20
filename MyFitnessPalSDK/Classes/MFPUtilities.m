//
//  MFPUtilities.m
//  MFP
//
//  Created by Todd Roman on 2/25/14.
//  Copyright (c) 2014 MyFitnessPal, LLC. All rights reserved.
//

#import "MFPUtilities.h"

@implementation MFPUtilities


+ (NSString *)dictionaryToQueryString:(NSDictionary *)dictionary {
  NSMutableArray *components = [[NSMutableArray alloc] initWithCapacity:[dictionary count]];
  @autoreleasepool {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
      key = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      value = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      [components addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }];
  }
  return [components componentsJoinedByString:@"&"];
}



+ (NSDictionary *)queryStringToDictionary:(NSString *)queryString {
  NSArray *components = [queryString componentsSeparatedByString:@"&"];
  NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:[components count]];
  @autoreleasepool {
    for (NSString *component in components) {
      NSArray *keyValue = [component componentsSeparatedByString:@"="];
      NSString *key = [[keyValue objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      NSString *value = [[keyValue objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      [dictionary setValue:value forKey:key];
    }
  }
  return dictionary;
}

@end
