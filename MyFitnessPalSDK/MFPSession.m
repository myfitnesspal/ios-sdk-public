
#import "MFPSession.h"
#import "MFPAccessTokenData.h"
#import "MFPConnection.h"
#import "MFPSettings.h"
#import "MFPUtilities.h"
#import "MFPAuthorizationRequest.h"
#import "MFPAuthorizationResponse.h"
#import "MFPResponse.h"
#import "MFPError.h"
#import "MFPErrorFactory.h"
#import "NSError+MFPError.h"
#import "MFPFXKeychain.h"

#define kRNKey @"RqnZ8dSBHSpmWX8U6W3fxgNs"

MFPSession *activeSession = nil;
MFPSuccessCallback onSuccessCallback = nil;
MFPFailureCallback onFailureCallback = nil;

const NSString *MFPSessionCacheKey = @"MFPSessionData";

NSString *const MFPPermissionTypeDiary = @"diary";
NSString *const MFPPermissionTypeDiaryReadOnly = @"diary_readonly";
NSString *const MFPAuthorizationTypeAccessToken = @"token";
NSString *const MFPAuthorizationTypeCode = @"code";

@interface MFPSession ()

@property(nonatomic) BOOL isOpen;
@property(nonatomic, strong) NSString *cacheKey;
@property(nonatomic, strong) NSString *authorizationType;
@property(nonatomic, strong) NSArray *permissions;
@property(nonatomic, strong) NSString *state;
@property(nonatomic, strong) NSString *clientId;
@property(nonatomic, strong) MFPFXKeychain *keychain;

@end

@implementation MFPSession

- (NSString *)clientId {

  return _clientId;
  
}

- (id)initWithClientId:(NSString *)clientId
       urlSchemeSuffix:(NSString *)urlSchemeSuffix
          responseType:(NSString *)responseType
              cacheKey:(NSString *)cacheKey {
  
  static dispatch_once_t token = 0;
  
  dispatch_once(&token, ^{
  
    activeSession = [super init];
    
    if (activeSession) {
      
      _clientId = [clientId copy];
      [MFPSettings setClientId:[clientId copy]];
      [MFPSettings setClientUrlSchemeSuffix:urlSchemeSuffix];
      [activeSession setAuthorizationType:responseType];
      
      if (cacheKey)
        [activeSession setCacheKey:cacheKey];
      else
        [activeSession setCacheKey:[MFPSessionCacheKey copy]];
      
      _keychain = [[MFPFXKeychain alloc] initWithService:[self keychainService] accessGroup:nil accessibility:MFPFXKeychainAccessibleAfterFirstUnlock];
      
    }
    
  });

  
  [self openActiveSession]; // Try and find a valid, existing access token
  
  return self;
  
}


- (void)openActiveSession {

  // Check and see if we have a valid token already and open the session
  MFPAccessTokenData *accessTokenData = [self fetchAccessTokenDataForCacheKey:_cacheKey];
  
  if (accessTokenData) {
    
    _accessTokenData = accessTokenData;
    // Need some validation - i.e. method on accessTokenData to indicate if it's valid or not
    [self setIsOpen:YES];
    
  }
  
}


- (void)openActiveSessionWithScope:(NSArray *)permissions
                         onSuccess:(MFPSuccessCallback)onSuccess
                         onFailure:(MFPFailureCallback)onFailure {

  onSuccessCallback = onSuccess;
  onFailureCallback = onFailure;
  
  _permissions = permissions;

  MFPAccessTokenData *accessTokenData = [self fetchAccessTokenDataForCacheKey:_cacheKey];
  
  if (accessTokenData && ! [accessTokenData accessTokenIsExpired]) {
    
    if (onSuccessCallback) {
      
      [self setIsOpen:YES];
      
      _accessTokenData = [accessTokenData copy];
      
      onSuccessCallback();
      
    }
    
  } else {
  
    _state = [[NSUUID UUID] UUIDString];

    MFPAuthorizationRequest *authorizationRequest = [[MFPAuthorizationRequest alloc] init];
    
    [authorizationRequest authorizeWithPermissions:permissions
                                             state:_state
                                      responseType:MFPAuthorizationTypeAccessToken
                                         onFailure:onFailureCallback];
  }
  
  activeSession = self;

}

- (void)getAuthorizationCodeWithScope:(NSArray *)permissions
                            onSuccess:(MFPSuccessCallback)onSuccess
                            onFailure:(MFPFailureCallback)onFailure {
  
  onSuccessCallback = onSuccess;
  onFailureCallback = onFailure;
  
  _state = [[NSUUID UUID] UUIDString];
  
  MFPAuthorizationRequest *authorizationRequest = [[MFPAuthorizationRequest alloc] init];
  
  [authorizationRequest authorizeWithPermissions:permissions
                                           state:_state
                                    responseType:MFPAuthorizationTypeCode
                                       onFailure:onFailureCallback];

}


- (void)close {
  
  // Removes accessTokenData and sets isOpen flag off
  _accessTokenData = nil;
  
  [self setIsOpen:NO];
  
}


- (void)openActiveSessionWithScope:(NSArray *)permissions
                   accessTokenData:(MFPAccessTokenData *)accessTokenData
                         onSuccess:(MFPSuccessCallback)onSuccess
                         onFailure:(MFPFailureCallback)onFailure {

  _permissions = permissions;

  activeSession = self;
  
  _accessTokenData = accessTokenData;
  
  if ([_accessTokenData accessTokenIsExpired]) {
    
    [self refreshAccessTokenOnSuccess:onSuccess onFailure:onFailure];
    
  } else {
    
    if (onSuccess)
      onSuccess();
    
  }
  
}


+ (MFPSession *)activeSession {
  
  return activeSession;
  
}

- (BOOL)hasNewPermissions:(NSArray *)permissions {
  
  if (_accessTokenData) {
    
    for (NSString *permission in permissions) {
      
      if (! [[_accessTokenData permissions] containsObject:permission])
        return YES;
      
    }
    
    return NO;
    
  }
    
  return YES;

}

- (NSString *)keychainService {
  NSString *service = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
  service = [service stringByAppendingFormat:@":%@", self.clientId];
  return service;
}

- (NSString *)keychainKeyWithCacheKey:(NSString *)cacheKey {
  NSString *key = (cacheKey != nil)? cacheKey : @"tokenData";
  key = [key stringByAppendingFormat:@"%@:%@", [self keychainService], key];
  return key;
}

- (void)storeAccessTokenData:(MFPAccessTokenData *)accessTokenData
                 forCacheKey:(NSString *)cacheKey {
  
  // Read MFPResponse data and set auth properties
  NSMutableDictionary *data = [NSMutableDictionary new];
  
  if (! [accessTokenData accessToken] || ! [accessTokenData refreshToken])
    return;
  
  data[@"access_token"] = [accessTokenData accessToken];
  
  data[@"refresh_token"] = [accessTokenData refreshToken];

  data[@"token_type"] = [accessTokenData tokenType] ? [accessTokenData tokenType] : @"Bearer";
  
  if ([accessTokenData expirationDate])
    data[@"expiration_date"] = [accessTokenData expirationDate];
  else
    data[@"expiration_date"] = [[NSDate date] dateByAddingTimeInterval:24*60*60*365*5];
  
  data[@"scope"] = [accessTokenData permissions] ? [accessTokenData permissions] : @[];

  data[@"user"] = [accessTokenData userId] ? [accessTokenData userId] : @"";
  
  // Store the json object in the keychain
  NSData *serialized = [NSKeyedArchiver archivedDataWithRootObject:data];
  NSString *key = [self keychainKeyWithCacheKey:cacheKey];
  if (![self.keychain setObject:serialized forKey:key]) {
    NSLog(@"%s: Error saving tokenData to keychain!", __FUNCTION__);
    return;
  }
  
}

- (MFPAccessTokenData *)fetchAccessTokenDataForCacheKey:(NSString *)cacheKey {
  NSString *key = [self keychainKeyWithCacheKey:cacheKey];
  NSData *serialized = [self.keychain objectForKey:key];
  if (serialized == nil || ![serialized isKindOfClass:[NSData class]]) {
    NSLog(@"%s: Error retrieving tokenData form keychain!", __FUNCTION__);
    return nil;
  }
  NSDictionary *data = [NSKeyedUnarchiver unarchiveObjectWithData:serialized];
  
  if (! data)
    return nil;
  
  NSString *accessToken, *refreshToken;
  
  if (data[@"access_token"]) {
    accessToken = data[@"access_token"];
  }

  if (data[@"refresh_token"]) {
    refreshToken = data[@"refresh_token"];
  }

  NSString *tokenType = data[@"token_type"];
  
  NSArray *permissions = data[@"scope"] ? data[@"scope"] : @[];
  
  NSDate *expirationDate = data[@"expiration_date"];
  
  NSString *user = data[@"user"];
  
  if (refreshToken && accessToken && tokenType) {

    MFPAccessTokenData *accessTokenData = [[MFPAccessTokenData alloc] initWithAccessToken:accessToken
                                                                             refreshToken:refreshToken
                                                                                tokenType:tokenType
                                                                                   userId:user
                                                                              permissions:permissions
                                                                           expirationDate:expirationDate];
    
    // Will convert the access and refresh tokens to be encrypted
    if ([[data[@"access_token"] class] isSubclassOfClass:[NSString class]]) {
      
      [self storeAccessTokenData:accessTokenData forCacheKey:cacheKey];
      
    }
    
    return accessTokenData;
    
  }

  return nil;
  
}


- (BOOL)handleOpenURL:(NSURL *)url {

  if (! [[url scheme] isEqualToString:[MFPSettings clientRedirectUri]])
    return NO;
  
  NSString *path = [url path];
  
  if ([path isEqualToString:[MFPSettings authRedirectUriPath]]) {
    
    NSDictionary *params =  [MFPUtilities queryStringToDictionary:[url query]];
    
    MFPAuthorizationResponse *response = [[MFPAuthorizationResponse alloc] initWithData:params error:nil
                                                                             statusCode:0 // Is overridden in constructor
                                                                            permissions:_permissions];
    
    // First check and make sure state matches
    if (! [[response state] isEqualToString:_state]) {
      
      // Possible cross-site forgery
      NSError *error = [MFPErrorFactory errorWithDomain:MFPErrorDomainAuthorization
                                              errorCode:MFPAuthErrorInvalidState
                                       errorDescription:nil];
      
      if (onFailureCallback) {
        
        onFailureCallback(&error);
        
      }
                                                                                   
    } else if ([response accessTokenData]) {

      _accessTokenData = [[response accessTokenData] copy];
      
      if ([_accessTokenData accessToken]) {
        
        [self storeAccessTokenData:_accessTokenData forCacheKey:_cacheKey];
        [self setIsOpen:YES];
        
      } else if ([_accessTokenData authorizationCode]) {
        
        // For authorization code, we set it in _accessTokenData but the session is not live
        [self setIsOpen:NO];
        
      }

      
      if (onSuccessCallback)
        onSuccessCallback();
      
    } else if ([response error]) {
      
      if (onFailureCallback) {
        
        NSError *error = [response error];
        
        onFailureCallback(&error);
      
      }
      
    }
    
    
    return YES;
    
  }
  
  return NO;
  
}

- (BOOL)removeAccessTokenData {
  
  _accessTokenData = nil;
  NSString *key = [self keychainKeyWithCacheKey:self.cacheKey];
  if ([self.keychain objectForKey:key]) {
    
    [self.keychain removeObjectForKey:key];
    
  }
  
  return YES;
  
}


- (void)refreshAccessTokenOnSuccess:(MFPSuccessCallback)onSuccess
                          onFailure:(MFPFailureCallback)onFailure {
  
  // Can't refresh if the session isn't open already
  if (!_isOpen) {
    if (onFailure) {
      NSError *err = [MFPErrorFactory errorWithDomain:MFPErrorDomainAuthorization
                                              errorCode:MFPInvalidSessionState
                                       errorDescription:NSLocalizedString(@"Error while refreshing access token: Invalid or closed session", nil)];
      onFailure(&err);
    }
    return;
  }
  
  MFPAuthorizationRequest *request = [[MFPAuthorizationRequest alloc] init];
  
  MFPSession __weak *me = self;
  
  MFPConnectionSuccessCallback onSuccessCallback = ^(MFPResponse *response) {
    
    NSDictionary *responseData = [response data];
    
    MFPAuthorizationResponse *authResponse;
    
    NSError *error = [response error];
    
    authResponse = [[MFPAuthorizationResponse alloc] initTokenRefreshResponseWithData:responseData
                                                                                error:&error
                                                                           statusCode:[response statusCode]
                                                          withExistingAccessTokenData:_accessTokenData];

    if ([authResponse accessTokenData]) {
      
      _accessTokenData = [[authResponse accessTokenData] copy];

      [me storeAccessTokenData:_accessTokenData forCacheKey:_cacheKey];
      [me setIsOpen:YES];

      if (onSuccess)
        onSuccess();
      
    } else {
      
      if (! error) {
        
        // Invalid response, unknown error - response body errors get handled in the call to
        // refreshAccessToken in MFPAuthorizationRequest
        
        error = [MFPErrorFactory errorWithDomain:MFPErrorDomainAuthorization
                                       errorCode:MFPAuthErrorTokenRefreshFailed
                                errorDescription:NSLocalizedString(@"Error while refreshing access token", nil)];
      }
      
      if ([_accessTokenData accessTokenIsExpired])
        [me setIsOpen:NO];
      
      if (onFailure)
        onFailure(&error);
      
    }
    
    
  };
  
  MFPConnectionFailureCallback onFailureCallback = ^(MFPResponse *response, NSError **error) {
    
    if (onFailure)
      onFailure(error);
    
    [me setIsOpen:NO];
    
  };
  
  [request refreshAccessToken:_accessTokenData onSuccess:onSuccessCallback onFailure:onFailureCallback];

}


- (void)revokeAccessOnSuccess:(MFPSuccessCallback)onSuccess
                    onFailure:(MFPFailureCallback)onFailure {

  // Can't revoke if the session isn't open already
  if (!_isOpen) {
    if (onFailure) {
      NSError *err = [MFPErrorFactory errorWithDomain:MFPErrorDomainAuthorization
                                            errorCode:MFPInvalidSessionState
                                     errorDescription:NSLocalizedString(@"Error while revoking access token: Invalid or closed session", nil)];
      onFailure(&err);
    }
    return;
  }
  
  MFPAuthorizationRequest *request = [[MFPAuthorizationRequest alloc] init];

  MFPSession __weak *me = self;
  
  MFPConnectionSuccessCallback onSuccessCallback = ^(MFPResponse *response) {
    
    [me setIsOpen:NO];
    
    [me removeAccessTokenData];
    
    if (onSuccess)
      onSuccess();
    
  };

  MFPConnectionFailureCallback onFailureCallback = ^(MFPResponse *response, NSError **error) {
  
    if (onFailure)
      onFailure(error);
    
    [me setIsOpen:NO];
    [me removeAccessTokenData];
    
    
  };
  
  [request revokeAccessOnSuccess:onSuccessCallback
                       onFailure:onFailureCallback
                      forSession:self];
  
}


@end
