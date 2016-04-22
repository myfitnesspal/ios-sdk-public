//
//  MFPViewController.m
//  MyFitnessPalSDK
//
//  Created by Mujtaba Hassanpur on 04/20/2016.
//  Copyright (c) 2016 Mujtaba Hassanpur. All rights reserved.
//

#import <MyFitnessPalSDK/MyFitnessPalSDK.h>
#import "MFPViewController.h"

@interface MFPViewController ()

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *openActiveSessionButton;
@property (nonatomic, strong) UIButton *refreshAccessTokenButton;
@property (nonatomic, strong) UIButton *revokeAccessButton;

@end

@implementation MFPViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 220, 320)];
  self.textView.font = [UIFont fontWithName:@"Courier" size:12.0];
  self.textView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
  [self.view addSubview:self.textView];
  
  self.openActiveSessionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [self.openActiveSessionButton setTitle:@"openActiveSession" forState:UIControlStateNormal];
  [self.openActiveSessionButton addTarget:self action:@selector(openActiveSession:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.openActiveSessionButton];
  
  self.refreshAccessTokenButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [self.refreshAccessTokenButton setTitle:@"refreshAccessToken" forState:UIControlStateNormal];
  [self.refreshAccessTokenButton addTarget:self action:@selector(refreshActiveToken:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.refreshAccessTokenButton];
  
  //  self.getAuthorizationCodeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  //  [self.getAuthorizationCodeButton setTitle:@"getAuthorizationCode" forState:UIControlStateNormal];
  //  [self.getAuthorizationCodeButton addTarget:self action:@selector(getAuthorizationCode:) forControlEvents:UIControlEventTouchUpInside];
  //  [self.view addSubview:self.getAuthorizationCodeButton];
  
  self.revokeAccessButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [self.revokeAccessButton setTitle:@"revokeAccess" forState:UIControlStateNormal];
  [self.revokeAccessButton addTarget:self action:@selector(revokeAccess:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.revokeAccessButton];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  
  const CGFloat margin = 10.0;
  const CGFloat buttonHeight = 50;
  
  CGFloat y = 2*margin;
  self.textView.frame = CGRectMake(margin, y, self.view.frame.size.width - 2*margin, 320);
  y = self.textView.frame.origin.y + self.textView.frame.size.height + margin;
  
  self.openActiveSessionButton.frame = CGRectMake(margin, y, self.view.frame.size.width - 2*margin, buttonHeight);
  y = self.openActiveSessionButton.frame.origin.y + self.openActiveSessionButton.frame.size.height + margin;
  
  self.refreshAccessTokenButton.frame = CGRectMake(margin, y, self.view.frame.size.width - 2*margin, buttonHeight);
  y = self.refreshAccessTokenButton.frame.origin.y + self.refreshAccessTokenButton.frame.size.height + margin;
  
  //  self.getAuthorizationCodeButton.frame = CGRectMake(margin, y, self.view.frame.size.width - 2*margin, buttonHeight);
  //  y = self.getAuthorizationCodeButton.frame.origin.y + self.getAuthorizationCodeButton.frame.size.height + margin;
  
  self.revokeAccessButton.frame = CGRectMake(margin, y, self.view.frame.size.width - 2*margin, buttonHeight);
  
  [self updateUI];
}

- (void)updateUI {
  MFPSession *activeSession = [MFPSession activeSession];
  if ([activeSession isOpen]) {
    NSString *txt = [NSString stringWithFormat:@"Active Session:\nOPEN\n\naccessToken:\n%@\n\nrefreshToken:\n%@\n\nexpirationDate:\n%@",
                     activeSession.accessTokenData.accessToken,
                     activeSession.accessTokenData.refreshToken,
                     activeSession.accessTokenData.expirationDate];
    self.textView.text = txt;
  }
  else {
    self.textView.text = @"Active Session: CLOSED";
  }
  //NSLog(@"\nNSUserDefaults: \n%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
}

- (void)openActiveSession:(id)sender {
  [[MFPSession activeSession] openActiveSessionWithScope:@[MFPPermissionTypeDiary] onSuccess:^{
    NSLog(@"Open active session success");
    [self updateUI];
  } onFailure:^(NSError *__autoreleasing *error) {
    NSLog(@"Failed to open active session");
    [self updateUI];
  }];
}

- (void)refreshActiveToken:(id)sender {
  [[MFPSession activeSession] refreshAccessTokenOnSuccess:^{
    NSLog(@"Acess token refreshed");
    [self updateUI];
  } onFailure:^(NSError *__autoreleasing *error) {
    NSLog(@"Failed to refresh access token with error: \n%@", *error);
    [self updateUI];
  }];
}

- (void)revokeAccess:(id)sender {
  [[MFPSession activeSession] revokeAccessOnSuccess:^{
    NSLog(@"Access revoked");
    [self updateUI];
  } onFailure:^(NSError *__autoreleasing *error) {
    NSLog(@"Failed to revoke access token with error: \n%@", *error);
    [self updateUI];
  }];
}

//- (void)getAuthorizationCode:(id)sender {
//  [[MFPSession activeSession] getAuthorizationCodeWithScope:@[MFPPermissionTypeDiary] onSuccess:^{
//    NSLog(@"Authorization code success");
//    [self updateUI];
//  } onFailure:^(NSError *__autoreleasing *error) {
//    NSLog(@"Failed to get authorization code");
//    [self updateUI];
//  }];
//}

@end
