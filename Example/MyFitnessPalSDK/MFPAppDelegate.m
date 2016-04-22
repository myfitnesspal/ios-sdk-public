//
//  MFPAppDelegate.m
//  MyFitnessPalSDK
//
//  Created by Mujtaba Hassanpur on 04/20/2016.
//  Copyright (c) 2016 Mujtaba Hassanpur. All rights reserved.
//

#import <MyFitnessPalSDK/MyFitnessPalSDK.h>
#import "MFPAppDelegate.h"

@interface MFPAppDelegate ()
@property (nonatomic, strong) MFPSession *mfpSession;
@end

@implementation MFPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  
    NSString *clientId = @"sampleapiclient";
    NSString *urlSchemeSuffix = nil;
    
    self.mfpSession = [[MFPSession alloc] initWithClientId:clientId
                                           urlSchemeSuffix:urlSchemeSuffix
                                              responseType:MFPAuthorizationTypeAccessToken
                                                  cacheKey:nil];
  
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  
  if ([[MFPSession activeSession] handleOpenURL:url]) {
    if ([[MFPSession activeSession] isOpen]) {
      NSLog(@"Session opened");
    }
  }
  
  return TRUE;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
