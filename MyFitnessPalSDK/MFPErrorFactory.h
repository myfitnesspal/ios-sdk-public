//
//  MFPErrorStrings.h
//  MyFitnessPalSDK
//
//  Created by Todd Roman on 4/24/14.
//  Copyright (c) 2014 MyFitnessPal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFPErrorFactory : NSObject


+ (NSError *)errorWithDomain:(NSString *)domain
                   errorCode:(NSInteger)errorCode
            errorDescription:(NSString *)errorDescription;

+ (NSError *)errorWithDomain:(NSString *)domain
                   errorName:(NSString *)errorName
            errorDescription:(NSString *)errorDescription;

@end
