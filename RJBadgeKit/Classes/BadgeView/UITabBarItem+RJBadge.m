//
//  UITabBarItem+RJBadge.m
//  RJBadgeKit
//
//  Created by Ryan Jin on 04/08/2017.
//
//

#import "UITabBarItem+RJBadge.h"
#import <objc/runtime.h>
#import "UIView+RJBadge.h"

@implementation UITabBarItem (RJBadge)

#pragma mark - RJBadgeView
- (void)showBadge {
    [[self badgeView] showBadge];
}
- (void)hideBadge {
    [[self badgeView] hideBadge];
}

- (void)showBadgeWithValue:(NSUInteger)value {
    [[self badgeView] showBadgeWithValue:value];
}

#pragma mark - private method
- (UIView *)badgeView
{
    UIView *bottomView = [self valueForKeyPath:@"_view"]; // UITabbarButtion
    UIView *parentView = nil; // UIImageView
    if (bottomView) {
        parentView     = [self find:bottomView
              firstSubviewWithClass:NSClassFromString(@"UITabBarSwappableImageView")];
    }
    return parentView;
}

- (UIView *)find:(UIView *)view firstSubviewWithClass:(Class)cls
{
    __block UIView *targetView = nil;
    [view.subviews enumerateObjectsUsingBlock:^(UIView     *subview,
                                                NSUInteger idx,
                                                BOOL       *stop) {
        if ([subview isKindOfClass:cls]) {
            targetView = subview; *stop = YES;
        }
    }];
    return targetView;
}

#pragma mark - setter/getter
- (UILabel *)badge {
    return [self badgeView].badge;
}

- (void)setBadge:(UILabel *)label {
    [[self badgeView] setBadge:label];
}

- (UIFont *)badgeFont {
    return [self badgeView].badgeFont;
}

- (void)setBadgeFont:(UIFont *)badgeFont {
    [[self badgeView] setBadgeFont:badgeFont];
}

- (UIColor *)badgeTextColor {
    return [[self badgeView] badgeTextColor];
}

- (void)setBadgeTextColor:(UIColor *)badgeTextColor {
    [[self badgeView] setBadgeTextColor:badgeTextColor];
}

- (CGFloat)badgeRadius {
    return [[self badgeView] badgeRadius];
}

- (void)setBadgeRadius:(CGFloat)badgeRadius {
    [[self badgeView] setBadgeRadius:badgeRadius];
}

- (CGPoint)badgeOffset {
    return [[self badgeView] badgeOffset];
}

- (void)setBadgeOffset:(CGPoint)badgeOffset {
    [[self badgeView] setBadgeOffset:badgeOffset];
}

- (UIColor *)badgeBgColor {
    return [[self badgeView] badgeBgColor];
}

- (void)setBadgeBgColor:(UIColor *)badgeBgColor {
    [[self badgeView] setBadgeBgColor:badgeBgColor];
}

@end
