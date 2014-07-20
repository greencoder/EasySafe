//
//  LocationsListViewController.h
//  SimpliSafe
//
//  Created by Scott Newman on 7/14/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LocationChangeDelegate <NSObject>
- (void)didChangeLocation;
@end

@interface LocationsListViewController : UITableViewController

@property (nonatomic, weak) id<LocationChangeDelegate> delegate;

@end
