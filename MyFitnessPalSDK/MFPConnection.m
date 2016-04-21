//
//  MFPConnection.m
//
//  Created by Todd Roman on 2/18/14.
//  Copyright (c) 2014 MyFitnessPal, LLC. All rights reserved.
//

#import "MFPConnection.h"
#import "MFPResponse.h"
#import "MFPSettings.h"
#import "MFPSession.h"
#import "MFPAccessTokenData.h"
#import "MFPUtilities.h"
#import "MFPError.h"
#import "MFPErrorFactory.h"

@implementation MFPConnection

+ (void)sendRequestWithPath:(NSString *)path
                 httpMethod:(NSString *)method
                     action:(NSString *)action // API Version 1.0.0 only
                   encoding:(NSString *)encoding // default is JSON if nil and ignored if method is GET
                 parameters:(NSDictionary *)parameters
                  onSuccess:(MFPConnectionSuccessCallback)onConnectionSuccess
                  onFailure:(MFPConnectionFailureCallback)onConnectionFailure {

  if ([[MFPSettings apiVersion] isEqualToString:@"1.0.0"]) { // TODO - add methods to check version as a float/decimal value
    
    // In API V 1.0.0, path is ignored - everything is RPC

    if (action)
      path = [NSString stringWithFormat:@"/client_api/json/%@?client_id=%@", [MFPSettings apiVersion],
              [[MFPSession activeSession] clientId]];
            
  }
  
  NSMutableDictionary *requestParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    
  if (action) {
    [requestParameters addEntriesFromDictionary:@{@"action" : action }];
  }
  
  NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:[MFPSettings siteRootUrl]];
  urlComponents.path = path;
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlComponents.URL];
  [request setValue:encoding forHTTPHeaderField:@"Content-Type"];
  
  if ([method isEqualToString:@"POST"]) {
    
    request.HTTPMethod = @"POST";
    
    if (! encoding || [encoding isEqualToString:@"application/json"]) {
      
      NSError *error;
      request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
      if (error) {
        NSLog(@"%s: %@", __FUNCTION__, error);
        MFPResponse *resp = [[MFPResponse alloc] initWithData:nil error:&error statusCode:-1];
        onConnectionFailure(resp, &error);
        return;
      }

    } else if ([encoding isEqualToString:@"application/x-www-form-urlencoded"]) {
      
      request.HTTPBody = [MFPConnection formBodyForParameters:parameters];
      
    }
    
  } else if ([method isEqualToString:@"GET"]) {
    
    urlComponents.query = [MFPConnection queryStringForParameters:parameters];
    request = [NSMutableURLRequest requestWithURL:urlComponents.URL];
    [request setValue:encoding forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"GET";
    
  }
  
  [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    
    __block NSError *err = error;
    dispatch_async(dispatch_get_main_queue(), ^{
      // Get the status code
      NSInteger statusCode = -1;
      if(response != nil && [response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        statusCode = httpResponse.statusCode;
      }
      
      id respData = nil;
      if (response != nil && [response.MIMEType isEqualToString:@"application/json"]) {
        id jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (jsonData != nil) {
          respData = jsonData;
        }
      }
      
      if (!err && (statusCode < 200 || statusCode >= 300)) {
        NSString *message = @"Server error";
        if (respData && [respData isKindOfClass:[NSDictionary class]]) {
          NSDictionary *respDict = (NSDictionary *) respData;
          if (respDict[@"error"]) {
            NSDictionary *errorDict = respDict[@"error"];
            NSString *type = errorDict[@"type"];
            NSString *msg = errorDict[@"message"];
            message = [NSString stringWithFormat:@"%@: %@", type, msg];
            NSLog(@"%s: %@", __FUNCTION__, message);
          }
        }
        err = [NSError errorWithDomain:@"com.myfitnesspal.sdk" code:statusCode userInfo:@{NSLocalizedDescriptionKey: message}];
      }
      
      // Handle failures
      if (err) {
        MFPResponse *resp = [[MFPResponse alloc] initWithData:respData error:&err statusCode:statusCode];
        onConnectionFailure(resp, &err);
      }
      
      // Handle success
      MFPResponse *resp = [[MFPResponse alloc] initWithData:respData error:&err statusCode:statusCode];
      onConnectionSuccess(resp);
    });
    
  }] resume];
  
  return;
  
}

+ (NSString *)stringRepresentationForKey:(NSString *)key andValue:(NSString *)value {
  NSMutableString *string = [[NSMutableString alloc] init];
  [string appendString:[key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  [string appendString:@"="];
  [string appendString:[value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  return [string copy];
}

+ (NSString *)stringRepresentationForKey:(NSString *)key andValues:(NSArray *)values {
  NSMutableString *string = [[NSMutableString alloc] init];
  for (id obj in values) {
    if ([obj isKindOfClass:[NSString class]]) {
      NSString *value = obj;
      if (![string isEqual:@""]) {
        [string appendString:@"&"];
      }
      [string appendString:[key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
      [string appendString:@"[]="];
      [string appendString:[value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
  }
  return [string copy];
}

+ (NSString *)queryStringForParameters:(NSDictionary *)parameters {
  if (parameters == nil) {
    return @"";
  }
  
  NSMutableString *string = [[NSMutableString alloc] init];
  for (NSString *key in parameters.allKeys) {
    id obj = parameters[key];
    if ([obj isKindOfClass:[NSString class]]) {
      NSString *value = obj;
      if (![string isEqual:@""]) {
        [string appendString:@"&"];
      }
      [string appendString:[self stringRepresentationForKey:key andValue:value]];
    }
    else if([obj isKindOfClass:[NSArray class]]) {
      NSArray *array = obj;
      if (![string isEqual:@""]) {
        [string appendString:@"&"];
      }
      [string appendString:[self stringRepresentationForKey:key andValues:array]];
    }
  }
  return [string copy];
}

+ (NSData *)formBodyForParameters:(NSDictionary *)parameters {
  NSString *string = [self queryStringForParameters:parameters];
  NSData *result = [string dataUsingEncoding:NSUTF8StringEncoding];
  return result;
}


@end
