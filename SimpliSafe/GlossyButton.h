//
//  GlossyButton.h
//  SimpliSafe
//
//  Created by Scott Newman on 5/31/13.
//  Copyright (c) 2013 Newman Creative. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GlossyButton : UIButton
- (id)initWithFrame:(CGRect)frame withBackgroundColor:(UIColor*)backgroundColor;
- (void)makeButtonShiny:(GlossyButton*)button withBackgroundColor:(UIColor*)backgroundColor;
@end
