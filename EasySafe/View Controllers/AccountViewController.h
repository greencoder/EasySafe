//
//  AccountViewController.h
//  SimpliSafe
//
//  Created by Scott Newman on 7/15/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSUser;

@interface AccountViewController : UITableViewController

@property (nonatomic, strong) IBOutlet SSUser *user;

@end
