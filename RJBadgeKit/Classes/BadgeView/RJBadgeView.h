//
//  RJBadgeView.h
//  RJBadgeKit
//
//  Created by Ryan Jin on 04/08/2017.
//
//

#import <Foundation/Foundation.h>

/**
 priority: number > custom view > red dot
 */

@protocol RJBadgeView <NSObject>

@required

@property (nonatomic, strong) UILabel *badge;
@property (nonatomic, strong) UIFont  *badgeFont;      // default bold size 9
@property (nonatomic, strong) UIColor *badgeTextColor; // default white color
@property (nonatomic, strong) UIColor *badgeBgColor;
@property (nonatomic, assign) CGFloat  badgeRadius;    // for red dot mode
@property (nonatomic, assign) CGPoint  badgeOffset;    // offset from right-top

- (void)showBadge; // badge with red dot
- (void)hideBadge;

// badge with number, pass zero to hide badge
- (void)showBadgeWithValue:(NSUInteger)value;

@optional

@property (nonatomic, strong) UIView  *badgeCustomView;
/**
 convenient interface:
 create 'cusomView' (UIImageView) using badgeImage
 view's size would simply be set as half of image.
 */
@property (nonatomic, strong) UIImage *badgeImage;

@end
