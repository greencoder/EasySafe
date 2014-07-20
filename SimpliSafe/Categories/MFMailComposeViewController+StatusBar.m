//
//  MFMailComposeViewController+StatusBar.m
//  SimpliSafe
//
//  Created by Scott Newman on 7/18/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import "MFMailComposeViewController+StatusBar.h"

@implementation MFMailComposeViewController (StatusBar)

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return nil;
}

@end
