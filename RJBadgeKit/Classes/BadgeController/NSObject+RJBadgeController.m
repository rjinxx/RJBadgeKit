//
//  NSObject+RJBadgeController.m
//  RJBadgeKit
//
//  Created by Ryan Jin on 06/12/2017.
//

#import "NSObject+RJBadgeController.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN

static void * NSObjectBadgeControllerKey = &NSObjectBadgeControllerKey;

@implementation NSObject (RJBadgeController)

- (RJBadgeController *)badgeController
{
    id controller = objc_getAssociatedObject(self, NSObjectBadgeControllerKey);
    // lazily create the badgeController
    if (nil == controller) {
        controller           = [RJBadgeController controllerWithObserver:self];
        self.badgeController = controller;
    }
    return controller;
}

- (void)setBadgeController:(RJBadgeController *)badgeController {
    objc_setAssociatedObject(self, NSObjectBadgeControllerKey, badgeController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

NS_ASSUME_NONNULL_END
