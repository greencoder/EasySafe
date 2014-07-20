//
//  AlarmButtonsView.m
//  SimpliSafe
//
//  Created by Scott Newman on 7/16/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import "AlarmButtonsView.h"
#import "SSLocation.h"

#define paleBlueColor [UIColor colorWithRed:0.31 green:0.46 blue:0.63 alpha:1]

@interface AlarmButtonsView ()

@property (nonatomic, weak) IBOutlet UIButton *offButton;
@property (nonatomic, weak) IBOutlet UIButton *homeButton;
@property (nonatomic, weak) IBOutlet UIButton *awayButton;

@property (nonatomic, weak) IBOutlet UILabel *offButtonLabel;
@property (nonatomic, weak) IBOutlet UILabel *homeButtonLabel;
@property (nonatomic, weak) IBOutlet UILabel *awayButtonLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;

@end

@implementation AlarmButtonsView

- (void)updateForLocation:(SSLocation *)location
{
    // By default, all of our buttons should be un-selected and the labels gray
    
    self.offButtonLabel.textColor = [UIColor lightGrayColor];
    self.offButton.selected = NO;
    
    self.homeButtonLabel.textColor = [UIColor lightGrayColor];
    self.homeButton.selected = NO;
    
    self.awayButtonLabel.textColor = [UIColor lightGrayColor];
    self.awayButton.selected = NO;
    
    // Check the state and make the appropriate button and label blue
    switch (location.systemState)
    {
        case SSSystemStateOff:
            self.offButton.selected = YES;
            self.offButtonLabel.textColor = paleBlueColor;
            break;
        case SSSystemStateHome:
            self.homeButton.selected = YES;
            self.homeButtonLabel.textColor = paleBlueColor;
            break;
        case SSSystemStateAway:
            self.awayButton.selected = YES;
            self.awayButtonLabel.textColor = paleBlueColor;
            break;
        case SSSystemStateUnknown:
            break;
    }
    
    // Set the location label to the current location
    self.locationLabel.text = location.street1;

}


@end
