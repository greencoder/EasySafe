//
//  EventsTableViewCell.m
//  SimpliSafe
//
//  Created by Scott Newman on 7/18/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import "EventsTableViewCell.h"
#import "SSEvent.h"

@implementation EventsTableViewCell

+ (CGFloat)heightForEvent:(SSEvent *)event width:(CGFloat)cellWidth
{
    CGFloat leftMargin = 15.0;
    CGFloat rightMargin = 15.0;
    CGFloat topMargin = 12.0;
    CGFloat btmMargin = 12.0;
    CGFloat detailTextHeight = 17.0;
    
    UIFont *font = [UIFont systemFontOfSize:17.0];
    
    CGFloat labelWidth = cellWidth - leftMargin - rightMargin;
    CGSize constraint = CGSizeMake(labelWidth, CGFLOAT_MAX);
    
    CGRect textRect = [event.detail boundingRectWithSize:constraint
                                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                              attributes:@{NSFontAttributeName:font}
                                                 context:nil];
    
    CGFloat calculatedHeight = ceil(topMargin + textRect.size.height + detailTextHeight + btmMargin);
    
    return MAX(calculatedHeight, 54.0);
}

@end
