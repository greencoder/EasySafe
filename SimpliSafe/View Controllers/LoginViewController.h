//
//  LoginViewController.h
//  SimpliSafe
//
//  Created by Scott Newman on 7/12/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSUser;

@protocol LoginDelegate <NSObject>
- (void)didFinishAuthentication:(SSUser *)user;
@end

@interface LoginViewController : UIViewController

@property (nonatomic, weak) id<LoginDelegate> delegate;

@end
