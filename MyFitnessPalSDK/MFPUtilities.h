//
//  MFPUtilities.h
//  MFP
//
//  Created by Todd Roman on 2/25/14.
//  Copyright (c) 2014 MyFitnessPal, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFPUtilities : NSObject

+ (NSDictionary *)queryStringToDictionary:(NSString *)queryString;
+ (NSString *)dictionaryToQueryString:(NSDictionary *)dictionary;

@end
