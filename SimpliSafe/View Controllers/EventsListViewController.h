//
//  EventsListViewController.h
//  SimpliSafe
//
//  Created by Scott Newman on 7/13/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSLocation;
@class SSUser;

@interface EventsListViewController : UITableViewController

@property (nonatomic, strong) SSLocation *location;
@property (nonatomic, strong) SSUser *user;

@end
