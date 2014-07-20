//  LocationsListViewController.m
//  SimpliSafe
//
//  Created by Scott Newman on 7/14/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import "LocationsListViewController.h"

#import "SSLocation.h"
#import "SSUser.h"
#import "SSUserManager.h"

@interface LocationsListViewController ()

@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, weak) SSLocation *currentLocation;

@end

@implementation LocationsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SSUserManager *userManager = [SSUserManager sharedManager];
    
    // Locations is the array that will populate the table view cells
    self.locations = userManager.user.locations;
    
    // Current location is used to check the appropriate table view cell
    self.currentLocation = userManager.currentLocation;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    SSLocation *location = self.locations[indexPath.row];
    cell.textLabel.text = location.street1;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@, %@", location.city, location.state, location.postalCode];
    
    // Show a checkmark if this row represents the current location
    if (location.locationID == self.currentLocation.locationID)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (UITableViewCell *cell in [tableView visibleCells]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    // Set the current location in the user manager to what was tapped
    [[SSUserManager sharedManager] setCurrentLocation:self.locations[indexPath.row]];
    
    // Call the delegate to let them know we changed the location. This will let the
    // dashboard update for the new location
    [self.delegate didChangeLocation];
    
    // Close the window
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
