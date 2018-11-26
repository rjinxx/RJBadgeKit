//
//  UIView+RJBadge.m
//  RJBadgeKit
//
//  Created by Ryan Jin on 04/08/2017.
//
//

#import "UIView+RJBadge.h"
#import <objc/runtime.h>

#define kRJBadgeDefaultFont                ([UIFont boldSystemFontOfSize:9])
#define kRJBadgeDefaultMaximumBadgeNumber  99

static const CGFloat kRJBadgeDefaultRadius = 3.f;

@implementation UIView (RJBadge)

#pragma mark - RJBadgeView
- (void)showBadge
{
    CGFloat offsetX = CGRectGetWidth(self.frame) + 2 + self.badgeOffset.x;
    CGPoint center  = CGPointMake(offsetX, self.badgeOffset.y);

    if (self.badgeCustomView) {
        self.badgeCustomView.hidden   = NO;
        self.badge.hidden             = YES;
        self.badgeCustomView.center   = center;
    } else {
        CGFloat w = (self.badgeRadius ? : kRJBadgeDefaultRadius) * 2;
        CGRect  r = CGRectMake(CGRectGetWidth(self.frame), -w, w, w);
        
        self.badge.frame              = r;
        self.badge.text               = @"";
        self.badge.hidden             = NO;
        self.badge.layer.cornerRadius = w / 2;
        self.badge.center             = center;
    }
}

- (void)showBadgeWithValue:(NSUInteger)value
{
    self.badgeCustomView.hidden = YES;

    self.badge.hidden  = (value == 0);
    self.badge.font    = self.badgeFont;
    self.badge.text    = (value > kRJBadgeDefaultMaximumBadgeNumber ?
                         [NSString stringWithFormat:@"%@+", @(kRJBadgeDefaultMaximumBadgeNumber)] :
                         [NSString stringWithFormat:@"%@" , @(value)]);
    [self adjustLabelWidth:self.badge];
    
    CGRect frame       = self.badge.frame;
    frame.size.width  += 4;
    frame.size.height += 4;
    
    if(CGRectGetWidth(frame) < CGRectGetHeight(frame)) {
        frame.size.width     = CGRectGetHeight(frame);
    }
    self.badge.frame  = frame;
    CGFloat offsetX   = CGRectGetWidth(self.frame) + 2 + self.badgeOffset.x;
    self.badge.center = CGPointMake(offsetX, self.badgeOffset.y);
    
    self.badge.layer.cornerRadius = CGRectGetHeight(self.badge.frame) / 2.f;
}

- (void)hideBadge
{
    if (self.badgeCustomView) {
        self.badgeCustomView.hidden = YES;
    }
    self.badge.hidden = YES;
}

#pragma mark - private methods
- (void)adjustLabelWidth:(UILabel *)label
{
    [label setNumberOfLines:0];
    
    NSString *s      = label.text;
    UIFont *font     = [label font];
    CGSize size      = CGSizeMake(320,2000);
    
    CGSize labelsize = CGSizeZero;
    
    if (![s respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        labelsize = [s sizeWithFont:font
                  constrainedToSize:size
                      lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    } else {
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByWordWrapping];
        
        labelsize = [s boundingRectWithSize:size
                                    options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                 attributes:@{NSFontAttributeName: font, NSParagraphStyleAttributeName: style}
                                    context:nil].size;
    }
    CGRect frame = label.frame;
    frame.size   = CGSizeMake(ceilf(labelsize.width), ceilf(labelsize.height));
    [label setFrame:frame];
}

#pragma mark - setter/getter
- (UILabel *)badge
{
    UILabel *bLabel   = objc_getAssociatedObject(self, _cmd);
    if (!bLabel) {
        CGFloat width = kRJBadgeDefaultRadius * 2;
        CGRect rect   = CGRectMake(CGRectGetWidth(self.frame), -width, width, width);
        bLabel                 = [[UILabel alloc] initWithFrame:rect];
        bLabel.textAlignment   = NSTextAlignmentCenter;
        bLabel.backgroundColor = [UIColor colorWithRed:  1.f
                                                 green: 93.f/225.f
                                                  blue:165.f/255.f
                                                 alpha:1.f];
        bLabel.textColor       = [UIColor whiteColor];
        bLabel.text            = @"";
        // CGFloat offsetX     = CGRectGetWidth(self.frame) + 2 + self.badgeOffset.x;
        // bLabel.center       = CGPointMake(offsetX, self.badgeOffset.y);

        bLabel.layer.cornerRadius  = kRJBadgeDefaultRadius;
        bLabel.layer.masksToBounds = YES;
        bLabel.hidden              = YES;
        
        objc_setAssociatedObject(self,
                                 _cmd,
                                 bLabel,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self addSubview:bLabel];
        [self bringSubviewToFront:bLabel];
    }
    return bLabel;
}

- (void)setBadge:(UILabel *)badge {
    objc_setAssociatedObject(self,
                             @selector(badge),
                             badge,
                             OBJC_ASSOCIATION_RETAIN);
}

- (UIFont *)badgeFont {
    return objc_getAssociatedObject(self, _cmd) ?: kRJBadgeDefaultFont;
}

- (void)setBadgeFont:(UIFont *)badgeFont
{
    objc_setAssociatedObject(self,
                             @selector(badgeFont),
                             badgeFont,
                             OBJC_ASSOCIATION_RETAIN);
    self.badge.font = badgeFont;
}

- (UIColor *)badgeBgColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBadgeBgColor:(UIColor *)badgeBgColor
{
    objc_setAssociatedObject(self,
                             @selector(badgeBgColor),
                             badgeBgColor,
                             OBJC_ASSOCIATION_RETAIN);
    self.badge.backgroundColor = badgeBgColor;
}

- (UIColor *)badgeTextColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBadgeTextColor:(UIColor *)badgeTextColor
{
    objc_setAssociatedObject(self,
                             @selector(badgeTextColor),
                             badgeTextColor,
                             OBJC_ASSOCIATION_RETAIN);
    self.badge.textColor = badgeTextColor;
}

- (CGFloat)badgeRadius {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setBadgeRadius:(CGFloat)badgeRadius {
    objc_setAssociatedObject(self,
                             @selector(badgeRadius),
                             @(badgeRadius),
                             OBJC_ASSOCIATION_RETAIN);
}

- (CGPoint)badgeOffset
{
    NSValue *offset = objc_getAssociatedObject(self, _cmd);
    
    if (!offset)      return CGPointZero;
    
    return [offset CGPointValue];
}

- (void)setBadgeOffset:(CGPoint)badgeOffset {
    objc_setAssociatedObject(self,
                             @selector(badgeOffset),
                             [NSValue valueWithCGPoint:badgeOffset],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)badgeImage {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBadgeImage:(UIImage *)badgeImage
{
    if (!badgeImage) {
        [self.badgeCustomView removeFromSuperview];
        [self setBadgeCustomView:nil];
    } else {
        self.badgeCustomView = [[UIImageView alloc] initWithImage:badgeImage];
        objc_setAssociatedObject(self,
                                 @selector(badgeImage),
                                 badgeImage,
                                 OBJC_ASSOCIATION_RETAIN);
    }
}

- (UIView *)badgeCustomView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBadgeCustomView:(UIView *)badgeCustomView
{
    if (self.badgeCustomView == badgeCustomView) return;
    
    if (self.badgeCustomView) [self.badgeCustomView removeFromSuperview];
    if (badgeCustomView)      [self addSubview:badgeCustomView];
    
    objc_setAssociatedObject(self,
                             @selector(badgeCustomView),
                             badgeCustomView,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.badgeCustomView) {
        CGRect bound   = badgeCustomView.bounds;
        bound.origin.x = CGRectGetWidth(self.frame);
        bound.origin.y = -bound.size.height;
        
        self.badgeCustomView.frame     = bound;
        self.badgeCustomView.hidden    = YES;
        // CGFloat offsetX             = CGRectGetWidth(self.frame) + 2 + self.badgeOffset.x;
        // self.badgeCustomView.center = CGPointMake(offsetX, self.badgeOffset.y);
    }
    // [self showBadge]; // refresh - in case of setting custom view after show badge
}

@end
