//
//  EventsTableViewCell.h
//  SimpliSafe
//
//  Created by Scott Newman on 7/18/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSEvent;

@interface EventsTableViewCell : UITableViewCell

+ (CGFloat)heightForEvent:(SSEvent *)event width:(CGFloat)cellWidth;

@end
