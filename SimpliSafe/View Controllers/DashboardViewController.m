//
//  DetailViewController.m
//  SimpliSafe
//
//  Created by Scott Newman on 7/12/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import "DashboardViewController.h"
#import "LoginViewController.h"
#import "LocationsListViewController.h"
#import "EventsListViewController.h"
#import "AccountViewController.h"

#import "SSUser.h"
#import "SSLocation.h"
#import "SSDashboard.h"
#import "SSEvent.h"

#import "SSAPIClient.h"
#import "SSUserManager.h"

#import "AlarmButtonsView.h"
#import "SVProgresshud.h"

@interface DashboardViewController () <LoginDelegate, LocationChangeDelegate>

@property (nonatomic, strong) SSLocation *location;
@property (nonatomic, strong) SSDashboard *dashboard;

@property (nonatomic, weak) IBOutlet AlarmButtonsView *alarmButtonsView;

@property (nonatomic, weak) IBOutlet UILabel *alarmStatusLabel;
@property (nonatomic, weak) IBOutlet UILabel *alarmTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *temperatureStatusLabel;
@property (nonatomic, weak) IBOutlet UILabel *temperatureTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *fireStatusLabel;
@property (nonatomic, weak) IBOutlet UILabel *fireTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *coStatusLabel;
@property (nonatomic, weak) IBOutlet UILabel *coTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *floodStatusLabel;
@property (nonatomic, weak) IBOutlet UILabel *floodTimeLabel;

@end

@implementation DashboardViewController

#pragma mark View Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];

//    NSTimer *t = [NSTimer scheduledTimerWithTimeInterval:1.0
//                                                  target:self
//                                                selector:@selector(checkReachability)
//                                                userInfo:nil
//                                                 repeats:YES];
    
    SSUserManager *userManager = [SSUserManager sharedManager];
    
    // If there is no session token, force the login screen. If there
    // is a session token, try to validate it

    if (!userManager.lastSessionToken) {
        [self showLoginScreen:nil];
    }
    else if (!userManager.user) {
        [self validateLogin];
    }

}

- (void)checkReachability
{
    NSLog(@"Reachable? %d", [[SSUserManager sharedManager] networkIsReachable]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Data Loading Methods

- (void)validateLogin
{
    SSAPIClient *apiClient = [SSAPIClient sharedClient];
    SSUserManager *userManager = [SSUserManager sharedManager];
    
    NSLog(@"User not validated. Checking session");
    
    // Show the progress hud
    [SVProgressHUD setForegroundColor:kSSPaleBlueColor];
    [SVProgressHUD showWithStatus:@"Loading Your Account" maskType:SVProgressHUDMaskTypeBlack];
    
    // Attempt a session validation
    [userManager validateSession:userManager.lastSessionToken withCompletion:^(SSUser *user, NSError *error)
     {
         // Errors happen when you can't reach the network
         if (error || !user)
         {
             // This case is better handled by the login page
             [SVProgressHUD dismiss];
             [self showLoginScreen:nil];
             return;
         }
         
         // No error, and we have a user. Continue on to get locations
         [apiClient fetchLocationsForUser:user completion:^(NSArray *locations, NSError *error)
          {
              // If there was an error, show the login page, it's a better place to handle errors
              if (error)
              {
                  [SVProgressHUD dismiss];
                  [self showLoginScreen:nil];
                  return;
              }
              
              // No error, so go forth
              user.locations = locations;
              userManager.user = user;
              
              // Set the current location
              [[SSUserManager sharedManager] setCurrentLocation:user.locations.firstObject];
              self.location = user.locations.firstObject;
              
              // Request the dashboard
              [apiClient fetchDashboardForLocation:self.location
                                              user:userManager.user
                                        completion:^(SSDashboard *dashboard, NSError *error)
               {
                   // If we got an error
                   if (error)
                   {
                       [SVProgressHUD dismiss];
                       [self showErrorAlert:@"An Error Occurred While Fetching Information. Some features may not work properly."];
                   }
                   // No Error
                   else
                   {
                       // We are done
                       self.dashboard = dashboard;
                       
                       // We can only get the account number from the dashboard
                       userManager.user.accountNumber = self.dashboard.accountNumber;
                       
                       [self updateDashboardLabels:dashboard];
                       [self.alarmButtonsView updateForLocation:self.location];
                       [SVProgressHUD dismiss];
                   }
                   
                   // Update the UI if an error happened or not
                   
               }];
              
          }];
         
     }];
}

#pragma mark - UI Methods


- (void)updateDashboardLabels:(SSDashboard *)dashboard
{
    // Dashboard
    if (dashboard != nil)
    {
        self.alarmStatusLabel.text = [NSString stringWithFormat:@"Burglar Status: %@", self.dashboard.alarmEvent.detail];
        self.alarmTimeLabel.text = self.dashboard.alarmEvent.recorded;
        
        self.temperatureStatusLabel.text = [NSString stringWithFormat:@"Home Temperature: %@", self.dashboard.temperature];
        self.temperatureTimeLabel.text = self.dashboard.temperatureRecorded;
        
        self.fireStatusLabel.text = [NSString stringWithFormat:@"Fire Alarm Status: %@", self.dashboard.fireEvent.detail];
        self.fireTimeLabel.text = self.dashboard.fireEvent.recorded;
        
        self.coStatusLabel.text = [NSString stringWithFormat:@"CO₂ Status: %@", self.dashboard.coEvent.detail];
        self.coTimeLabel.text = self.dashboard.coEvent.recorded;
        
        self.floodStatusLabel.text = [NSString stringWithFormat:@"Flood Status: %@", self.dashboard.floodEvent.detail];
        self.floodTimeLabel.text = self.dashboard.floodEvent.recorded;
    }
    else
    {
        self.alarmStatusLabel.text = @"Burglar Status: Loading";
        self.alarmTimeLabel.text = @"";
        
        self.temperatureStatusLabel.text = @"Home Temperature: Loading";
        self.temperatureTimeLabel.text = @"";
        
        self.fireStatusLabel.text = @"Fire Alarm Status: Loading";
        self.fireTimeLabel.text = @"";
        
        self.coStatusLabel.text = @"CO₂ Status: Loading";
        self.coTimeLabel.text = @"";
        
        self.floodStatusLabel.text = @"Flood Status: Loading";
        self.floodTimeLabel.text = @"";
    }
    
}

- (IBAction)stateButtonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSString *status;
    NSString *desiredStateName;
    
    switch (button.tag) {
        case SSSystemStateOff:
            status = @"Disarming System";
            desiredStateName = @"off";
            break;
        case SSSystemStateHome:
            status = @"Arming System: Home";
            desiredStateName = @"home";
            break;
        case SSSystemStateAway:
            status = @"Arming System: Away";
            desiredStateName = @"away";
            break;
        default:
            return;
    }
    
    // Show the progress hud while we change states
    [SVProgressHUD setForegroundColor:kSSPaleBlueColor];
    [SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeBlack];
 
    // Change the state
    SSAPIClient *client = [SSAPIClient sharedClient];
    SSUserManager *userManager = [SSUserManager sharedManager];
    
    [client changeStateForLocation:userManager.currentLocation
                              user:userManager.user
                             state:desiredStateName
                        completion:^(SSSystemState systemState, NSError *error)
    {
        if (error)
        {
            [SVProgressHUD dismiss];
            [self showErrorAlert:@"An Error Occurred Trying to Set the System. Please check your network connection and try again."];
        }
        else
        {
            // Update our location with the new state
            self.location.systemState = systemState;

            // Hide the hud and update the system
            [SVProgressHUD dismiss];
            [self.alarmButtonsView updateForLocation:self.location];
        }
        
    }];
}

- (void)showErrorAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:self cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)showLoginScreen:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"loginVC"];
    loginVC.delegate = self;
    
    // If we are showing the login b/c they hit the logout button, then animate the
    // modal presentation. (we don't want the initial load presentation animated)
    BOOL animate = sender != nil;
    [self presentViewController:loginVC animated:animate completion:nil];
}

- (IBAction)showLocationsScreen:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *locationsNavVC = [storyboard instantiateViewControllerWithIdentifier:@"locationsNavVC"];
    LocationsListViewController *locationsVC = (LocationsListViewController *)locationsNavVC.topViewController;
    locationsVC.delegate = self;
    [self presentViewController:locationsNavVC animated:YES completion:nil];
}

#pragma mark - Login and Validation Delegate methods

- (void)didFinishAuthentication:(SSUser *)user
{
    SSUserManager *userManager = [SSUserManager sharedManager];
    SSAPIClient *client = [SSAPIClient sharedClient];
    
    userManager.currentLocation = user.locations.firstObject;
    self.location = user.locations.firstObject;
    
    // Request the dashboard
    [client fetchDashboardForLocation:self.location
                                 user:userManager.user
                           completion:^(SSDashboard *dashboard, NSError *error)
    {
        // We will use the returned dashboard to populate the table
        self.dashboard = dashboard;
        
        // We can only get the account number from the dashboard
        userManager.user.accountNumber = self.dashboard.accountNumber;

        // Update the UI with info about the current location
        [self.alarmButtonsView updateForLocation:self.location];
        [self updateDashboardLabels:dashboard];
        
        // Hide the modal view controller
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
}

#pragma mark - Location Change Delegate

- (void)didChangeLocation
{
    SSUserManager *userManager = [SSUserManager sharedManager];
    SSAPIClient *client = [SSAPIClient sharedClient];

    self.location = userManager.currentLocation;

    // Request the dashboard
    [client fetchDashboardForLocation:self.location
                                 user:userManager.user
                           completion:^(SSDashboard *dashboard, NSError *error)
     {
         self.dashboard = dashboard;
         [self.alarmButtonsView updateForLocation:self.location];
         [self updateDashboardLabels:dashboard];
     }];

}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SSUserManager *userManager = [SSUserManager sharedManager];
    
    if ([segue.identifier isEqualToString:@"account"])
    {
        AccountViewController *accountVC = [segue destinationViewController];
        accountVC.user = userManager.user;        
    }
    else if ([segue.identifier isEqualToString:@"events"])
    {
        EventsListViewController *eventsVC = [segue destinationViewController];
        eventsVC.location = self.location;
        eventsVC.user = userManager.user;
    }
}


@end
