//
//  ViewController.m
//  SimpliSafe
//
//  Created by Scott Newman on 5/31/13.
//  Copyright (c) 2013 Newman Creative. All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "AFSimplisafeClient.h"
#import "MBProgressHUD.h"

@implementation ViewController

@synthesize httpClient = _httpClient;
@synthesize stateLabel = _stateLabel;
@synthesize stateControl = _stateControl;
@synthesize systemState = _systemState;
@synthesize lid = _lid;
@synthesize sid = _sid;
@synthesize username = _username;
@synthesize password = _password;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Dashboard";
    self.tabBarItem.image = [UIImage imageNamed:@"81-dashboard.png"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    self.lid = [defaults objectForKey:@"lid_preference"];
    self.sid = [defaults objectForKey:@"sid_preference"];
    self.username = [defaults objectForKey:@"username_preference"];
    self.password = [defaults objectForKey:@"password_preference"];
    
    self.httpClient = [AFSimplisafeClient sharedClient];
    
    self.stateControl.enabled = NO;
    [self loginRequest];
    
    // When login completes, update the system status
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginDidSucceed)
                                                 name:@"loginSuccess"
                                               object:nil];

    // When the state changes, update the UI
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stateDidChange)
                                                 name:@"stateChangeSuccess"
                                               object:nil];

    // When the location call finishes, update the UI
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationDidSucceed)
                                                 name:@"locationSuccess"
                                               object:nil];
    
}

- (void)updateSystemStatusLabel
{
    NSString *newValue = [NSString stringWithFormat:@"Current System Mode: %@", self.systemState];
    self.stateLabel.text = newValue;
    
    if ([self.systemState isEqualToString:@"Off"]) {
        self.stateControl.selectedSegmentIndex = 0;
    }
    else if ([self.systemState isEqualToString:@"Home"]) {
        self.stateControl.selectedSegmentIndex = 1;
    }
    else if ([self.systemState isEqualToString:@"Away"]) {
        self.stateControl.selectedSegmentIndex = 2;
    }
    else {
        self.stateControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    }
}

- (void)stateDidChange
{
    NSLog(@"stateDidChange");
    [self updateSystemStatusLabel];
}

- (void)loginDidSucceed
{
    [self locationRequest];
}

- (void)locationDidSucceed
{
    [self updateSystemStatusLabel];
    self.stateControl.enabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)changeState:(id)sender
{
    NSString *newState;
    
    switch ([(UISegmentedControl *)sender selectedSegmentIndex])
    {
        case 0:
            newState = @"off";
            break;
        case 1:
            newState = @"home";
            break;
        case 2:
            newState = @"away";
            break;
        default:
            newState = @"off";
            break;
    }
    
    NSLog(@"New State: %@", newState);
    self.stateControl.enabled = NO;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = [NSString stringWithFormat:@"Setting Alarm to %@", newState];
    
    [self.httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSString *path = [NSString stringWithFormat:@"https://simplisafe.com/mobile/%@/sid/%@/set-state", self.lid, self.sid];
    
    NSMutableURLRequest *request = [self.httpClient requestWithMethod:@"POST"
                                                                 path:path
                                                           parameters:@{
                                                                @"state": newState,
                                                                @"mobile": @"1",
                                                                @"no_persist": @"0",
                                                                @"XDEBUG_SESSION_START": @"session_name",
                                                                }];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
        {
            NSLog(@"Change State: %@", JSON);
            NSNumber *stateNum = [JSON valueForKeyPath:@"result"];
            
            switch (stateNum.integerValue)
            {
                case 2:
                    self.systemState = @"Off";
                    break;
                case 4:
                    self.systemState = @"Home";
                    break;
                case 5:
                    self.systemState = @"Away";
                    break;
                default:
                    self.systemState = @"Unknown";
                    break;
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:@"stateChangeSuccess" object:self];
            self.stateControl.enabled = YES;
            [hud hide:YES];
        } failure:nil];
    
    //[self.operation start];
    [self.httpClient enqueueHTTPRequestOperation:operation];
    
}

- (void)loginRequest
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Logging In";
    
    [self.httpClient setParameterEncoding:AFFormURLParameterEncoding];
    NSMutableURLRequest *request = [self.httpClient requestWithMethod:@"POST"
                                                                 path:@"https://simplisafe.com/mobile/login/"
                                                           parameters:@{
                                    @"name": self.username,
                                    @"pass": self.password,
                                    @"device_name": [[UIDevice currentDevice] name],
                                    @"device_uuid": [[NSUUID UUID] UUIDString],
                                    @"version": @"1100",
                                    @"no_persist": @"1",
                                    @"XDEBUG_SESSION_START": @"session_name",
                                    }];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
        {
            NSLog(@"Login: %@", JSON);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:self];
            [hud hide:YES];
        } failure:nil];

    //[self.operation start];
    [self.httpClient enqueueHTTPRequestOperation:operation];
}

- (void)logoutRequest
{
    [self.httpClient setParameterEncoding:AFFormURLParameterEncoding];
    NSMutableURLRequest *request = [self.httpClient requestWithMethod:@"POST"
                                                                 path:@"https://simplisafe.com/mobile/logout"
                                                           parameters:@{
                                                                @"no_persist": @"0",
                                                                @"XDEBUG_SESSION_START": @"session_name",
                                                                }];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
        {
            NSLog(@"Logout Response: %@", JSON);
        } failure:nil];

    //[self.operation start];
    [self.httpClient enqueueHTTPRequestOperation:operation];
}

- (void)locationRequest
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Getting Current System State";
    
    [self.httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSString *path = [NSString stringWithFormat:@"https://simplisafe.com/mobile/%@/locations", self.lid];
    
    NSMutableURLRequest *request = [self.httpClient requestWithMethod:@"POST"
                                                                 path:path
                                                           parameters:@{
                                                                @"no_persist": @"0",
                                                                @"XDEBUG_SESSION_START": @"session_name",
                                                                }];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
        {
            NSLog(@"Location: %@", JSON);
            self.systemState = [[JSON valueForKeyPath:@"locations"] allValues][0][@"system_state"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"locationSuccess" object:self];
            [hud hide:YES];
        } failure:nil];
    
    //[self.operation start];
    [self.httpClient enqueueHTTPRequestOperation:operation];

}

@end
