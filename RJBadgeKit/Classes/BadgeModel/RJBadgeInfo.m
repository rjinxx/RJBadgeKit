//
//  RJBadgeInfo.m
//  RJBadgeKit
//
//  Created by Ryan Jin on 06/12/2017.
//

#import "RJBadgeInfo.h"

@interface RJBadgeInfo ()

@property (nonatomic,   copy) NSString                 *keyPath;
@property (nonatomic,   weak) RJBadgeController        *controller;
@property (nonatomic,   copy) RJBadgeNotificationBlock block;

@property (nonatomic, strong) id<RJBadgeView>          badgeView;

@end

@implementation RJBadgeInfo {
    NSUInteger _badgeHash;
}

#pragma mark - Initialize

- (instancetype)initWithController:(RJBadgeController *)controller
                           keyPath:(NSString *)keyPath
                         badgeView:(nullable id<RJBadgeView>)badgeView
                             block:(nullable RJBadgeNotificationBlock)block
                            action:(nullable SEL)action
{
    self = [super init];
    if (self) {
        self.controller = controller;
        self.keyPath    = keyPath;
        self.badgeView  = badgeView;
        self.block      = block;

        _badgeHash      = self.keyPath.hash ^ self.controller.hash;
    }
    return self;
}

- (instancetype)initWithController:(RJBadgeController *)controller keyPath:(NSString *)keyPath {
    return [self initWithController:controller keyPath:keyPath badgeView:NULL block:NULL action:NULL];
}

- (instancetype)initWithController:(RJBadgeController *)controller keyPath:(NSString *)keyPath
                             block:(nullable RJBadgeNotificationBlock)block {
    return [self initWithController:controller keyPath:keyPath badgeView:NULL block:block action:NULL];
}

- (instancetype)initWithController:(RJBadgeController *)controller
                           keyPath:(NSString *)keyPath
                         badgeView:(nullable id<RJBadgeView>)badgeView
                             block:(nullable RJBadgeNotificationBlock)block {
    return [self initWithController:controller keyPath:keyPath badgeView:badgeView block:block action:NULL];
}

#pragma mark - Properties

- (NSUInteger)hash {
    // hash must be consistent during the object's life time
    return _badgeHash/* [_keyPath hash] ^ [_controller hash] */;
}

- (BOOL)isEqual:(id)object
{
    if (nil == object) {
        return NO;
    }
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    RJBadgeInfo *badgeObj  = (RJBadgeInfo *)object;
    BOOL isEqualPath       = [_keyPath isEqualToString:badgeObj->_keyPath];
    BOOL isEqualController = (_controller == badgeObj->_controller);

    return isEqualPath && isEqualController;
}

- (NSString *)debugDescription
{
    NSMutableString *s = [NSMutableString stringWithFormat:@"<%@:%p keyPath:%@",
                                          NSStringFromClass([self class]), self, _keyPath];    
    if (NULL != _block) {
        [s appendFormat:@" block:%p", _block];
    }
    
    [s appendString:@">"];
    
    return s;
}

@end
