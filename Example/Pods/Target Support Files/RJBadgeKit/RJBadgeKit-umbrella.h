#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSObject+RJBadgeController.h"
#import "RJBadgeController.h"
#import "RJBadgeManager.h"
#import "RJBadge.h"
#import "RJBadgeInfo.h"
#import "RJBadgeModel.h"
#import "RJBadgeView.h"
#import "UIBarButtonItem+RJBadge.h"
#import "UITabBarItem+RJBadge.h"
#import "UIView+RJBadge.h"
#import "NSString+RJBadge.h"
#import "RJBadgeKit.h"

FOUNDATION_EXPORT double RJBadgeKitVersionNumber;
FOUNDATION_EXPORT const unsigned char RJBadgeKitVersionString[];

