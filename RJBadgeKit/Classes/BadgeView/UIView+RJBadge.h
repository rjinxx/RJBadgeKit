//
//  UIView+RJBadge.h
//  RJBadgeKit
//
//  Created by Ryan Jin on 04/08/2017.
//
//

#import <UIKit/UIKit.h>
#import "RJBadgeView.h"

@interface UIView (RJBadge) <RJBadgeView>

- (void)showBadge; // badge with red dot
- (void)hideBadge;

// badge with number, pass zero to hide badge
- (void)showBadgeWithValue:(NSUInteger)value;

@end

