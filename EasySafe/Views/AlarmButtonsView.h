//
//  AlarmButtonsView.h
//  SimpliSafe
//
//  Created by Scott Newman on 7/16/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSLocation;

@interface AlarmButtonsView : UIView

- (void)updateForLocation:(SSLocation *)location;

@end
