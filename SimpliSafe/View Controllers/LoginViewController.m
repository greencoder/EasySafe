//
//  LoginViewController.m
//  SimpliSafe
//
//  Created by Scott Newman on 7/12/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import "LoginViewController.h"

#import "SSUserManager.h"
#import "SSAPIClient.h"
#import "SSUser.h"

#import "SVProgresshud.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *loginLabel;
@property (nonatomic, weak) IBOutlet UITextField *usernameField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIButton *clearInfoButton;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the background and button colors
    [self.loginButton setTitleColor:kSSPaleBlueColor forState:UIControlStateNormal];
    self.view.backgroundColor = kSSGrayBGColor;
    
    // Clear any session token that might exist
    [[SSUserManager sharedManager] clearSessionToken];
    
    // See if the username and password are in the keychain
    NSString *username = [[SSUserManager sharedManager] savedUsername];
    NSString *password = [[SSUserManager sharedManager] savedPassword];
    
    // If we have a saved username and password, assign them to the text fields
    if (username != nil)
        self.usernameField.text = username;
    
    if (password != nil)
        self.passwordField.text = password;
    
    // The login button should only be enabled when the
    // username and password text fields have values
    self.loginButton.enabled = [self loginButtonShouldBeEnabled];
    
    // Add a single tap gesture recognizer to this view controller's view so that taps not handled by any login field or button will close the keyboard
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark User Interface Methods

- (void)closeKeyboard
{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (IBAction)usernameNextButtonPressed:(id)sender
{
    [self.passwordField becomeFirstResponder];
}

- (IBAction)clearButtonPressed:(id)sender
{
    SSUserManager *userManager = [SSUserManager sharedManager];

    // Delete the last login token, username, and password from the keychain
    // (via the user manager, the implementation details don't belong here
    [userManager clearSessionToken];
    [userManager clearSavedPassword];
    [userManager clearSavedUsername];
    
    // Set the username and password fields to blank and disable the login button
    self.usernameField.text = nil;
    self.passwordField.text = nil;
    self.loginButton.enabled = [self loginButtonShouldBeEnabled];
}

- (BOOL)loginButtonShouldBeEnabled
{
    return (self.usernameField.text.length > 0 && self.passwordField.text.length > 0);
}

- (void)showErrorAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:self cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)loginButtonPressed:(id)sender
{
    [self closeKeyboard];
    
    SSUserManager *userManager = [SSUserManager sharedManager];
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;

    // Show the progress hud
    [SVProgressHUD setForegroundColor:[UIColor colorWithRed:0.31 green:0.46 blue:0.63 alpha:1]];
    [SVProgressHUD showWithStatus:@"Logging In" maskType:SVProgressHUDMaskTypeBlack];
    
    [userManager loginWithUsername:(NSString *)username
                          password:(NSString *)password
                        completion:^(SSUser *user, NSError *error)
    {
        // Errors can happen when we can't reach the server
        if (error)
        {
            [SVProgressHUD dismiss];
            self.loginLabel.text = @"An error occurred.";
            [self showErrorAlert:@"Could not complete login. Please check your network connection and try again."];
        }

        // Good login
        else if (user != nil)
        {
            // Save the values to the keychain (via the user manager)
            userManager.savedUsername = username;
            userManager.savedPassword = password;
            userManager.lastSessionToken = user.sessionToken;
            
            // Now that we have a user, get their locations
            SSAPIClient *client = [SSAPIClient sharedClient];
            [client fetchLocationsForUser:user completion:^(NSArray *locations, NSError *error)
            {
                if (error) {
                    [SVProgressHUD showErrorWithStatus:@"Login Error"];
                    self.loginLabel.text = @"A failure occurred during login. Please try again later.";
                    self.usernameField.enabled = YES;
                    self.passwordField.enabled = YES;
                    self.loginButton.enabled = YES;
                }
                else {
                    [SVProgressHUD dismiss];
                    user.locations = locations;
                    userManager.user = user;
                    [self.delegate didFinishAuthentication:user];
                }
            }];

        }

        // No User
        else
        {
            // Hide the hud
            [SVProgressHUD showErrorWithStatus:@"Login Failed"];
            self.loginLabel.text = @"Invalid Username or Password.";
        }

    }];

}

# pragma mark UITextField Delegate

- (IBAction)textFieldsChanged:(id)sender
{
    self.loginButton.enabled = [self loginButtonShouldBeEnabled];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // When the password field's Go button is tapped, attempt to login
    if (textField == self.passwordField) {
        [self loginButtonPressed:textField];
    }
    return YES;
}

@end
