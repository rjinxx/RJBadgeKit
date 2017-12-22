//
//  RJBadgeInfo.h
//  RJBadgeKit
//
//  Created by Ryan Jin on 06/12/2017.
//

#import <Foundation/Foundation.h>
#import "RJBadgeController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RJBadgeInfo : NSObject

@property (nonatomic, copy,   readonly) NSString                 *keyPath;
@property (nonatomic, weak,   readonly) RJBadgeController        *controller;
@property (nonatomic, copy,   readonly) RJBadgeNotificationBlock block;

@property (nonatomic, strong, readonly) id<RJBadgeView>          badgeView;

- (instancetype)initWithController:(RJBadgeController *)controller keyPath:(NSString *)keyPath;

- (instancetype)initWithController:(RJBadgeController *)controller keyPath:(NSString *)keyPath
                             block:(nullable RJBadgeNotificationBlock)block;

- (instancetype)initWithController:(RJBadgeController *)controller
                           keyPath:(NSString *)keyPath
                         badgeView:(nullable id<RJBadgeView>)badgeView
                             block:(nullable RJBadgeNotificationBlock)block;

@end

NS_ASSUME_NONNULL_END
