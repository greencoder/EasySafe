//
//  AccountViewController.m
//  SimpliSafe
//
//  Created by Scott Newman on 7/15/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

@import MessageUI;

#import "AccountViewController.h"
#import "SSUser.h"

#import "MFMailComposeViewController+StatusBar.h"

@interface AccountViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *accountNumberLabel;

@end

@implementation AccountViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Assign the account number to the label
    self.accountNumberLabel.text = self.user.accountNumber;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // We are only checking to see if the first row the first section gets tapped so we can
    // show the mail compose sheet. I wanted to use data detectors on the UITextViews like the
    // other cells, but MFMailComposeViewController doesn't honor the UIAppearanceProxy so you
    // have to manually instantiate and color the nav bar appropriately. What a pain.
    
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
            mailViewController.mailComposeDelegate = self;
            
            // Set to, subject
            [mailViewController setSubject:[NSString stringWithFormat:@"Customer %@", self.user.accountNumber]];
            [mailViewController setToRecipients:@[@"customer-support@simplisafe.com"]];
            
            // Customize the appearance
            [mailViewController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
            [mailViewController.navigationBar setTintColor:[UIColor whiteColor]];
            [mailViewController.navigationBar setBarTintColor:kSSPaleBlueColor];
            
            // Present the view controller and make the status bar white
            [self presentViewController:mailViewController animated:YES completion:^{
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            }];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

# pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    // This is needed, otherwise the mail compose vc won't close when you tap the button
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
