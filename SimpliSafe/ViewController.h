//
//  ViewController.h
//  SimpliSafe
//
//  Created by Scott Newman on 5/31/13.
//  Copyright (c) 2013 Newman Creative. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AFSimplisafeClient;
@class MBProgressHUD;
@class AFJSONRequestOperation;

@interface ViewController : UIViewController
{
    AFSimplisafeClient *httpClient;
    NSString *systemState;
    IBOutlet UILabel *stateLabel;
    IBOutlet UISegmentedControl *stateControl;
    NSString *lid;
    NSString *sid;
    NSString *username;
    NSString *password;
}

@property (nonatomic, retain) AFSimplisafeClient *httpClient;
@property (nonatomic, retain) UILabel *stateLabel;
@property (nonatomic, retain) UISegmentedControl *stateControl;
@property (nonatomic, retain) NSString *systemState;
@property (nonatomic, retain) NSString *lid;
@property (nonatomic, retain) NSString *sid;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;

- (void)loginRequest;
- (void)logoutRequest;
- (void)locationRequest;
- (void)updateSystemStatusLabel;
- (void)loginDidSucceed;
- (void)locationDidSucceed;
- (IBAction)changeState:(id)sender;

@end
