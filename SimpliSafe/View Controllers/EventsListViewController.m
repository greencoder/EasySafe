//
//  EventsListViewController.m
//  SimpliSafe
//
//  Created by Scott Newman on 7/13/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import "EventsListViewController.h"

#import "SSEvent.h"
#import "SSUser.h"
#import "SSAPIClient.h"

#import "SVProgressHUD.h"
#import "EventsTableViewCell.h"

@interface EventsListViewController ()

@property (nonatomic, strong) NSArray *events;

@end

@implementation EventsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load the events data (We use the same method call when someone
    // taps the refresh button in the nav bar
    [self loadData];
}

- (void)loadData
{
    SSAPIClient *client = [SSAPIClient sharedClient];

    // Start the progress spinner
    [SVProgressHUD setForegroundColor:kSSPaleBlueColor];
    [SVProgressHUD showWithStatus:@"Loading Events" maskType:SVProgressHUDMaskTypeBlack];
    
    [client fetchEventsForLocation:self.location
                              user:self.user
                        completion:^(NSArray *events, NSError *error)
    {
        // Hide the spinner
        [SVProgressHUD dismiss];

        if (error)
        {
            NSLog(@"Error: %@", error);
            [self showErrorAlert:@"An error occurred while loading events. Please check your network connection and try again."];
        }
        else
        {
            self.events = events;
            [self.tableView reloadData];
        }

    }];
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
    return self.events.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [EventsTableViewCell heightForEvent:self.events[indexPath.row] width:self.view.frame.size.width];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    SSEvent *event = self.events[indexPath.row];
    cell.textLabel.text = event.detail;
    cell.detailTextLabel.text = event.recorded;
    
    return cell;
}

#pragma mark - UI Methods

- (IBAction)refreshButtonPressed:(id)sender
{
    [self loadData];
}

- (void)showErrorAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:self cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
