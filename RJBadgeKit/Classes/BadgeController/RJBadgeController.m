//
//  RJBadgeController.m
//  RJBadgeKit
//
//  Created by Ryan Jin on 06/12/2017.
//

#import "RJBadgeController.h"
#import "RJBadgeInfo.h"
#import <pthread/pthread.h>
#import "RJBadgeManager.h"

@interface RJBadgeController ()

@property (nullable, nonatomic, weak) id observer;

@end

@implementation RJBadgeController {
    NSHashTable<RJBadgeInfo *> *_infos;
    pthread_mutex_t             _lock;
}

#pragma mark - Lifecycle

- (instancetype)initWithObserver:(nullable id)observer
{
    self = [super init];
    if (self) {
        _infos = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsStrongMemory |
                                                      NSPointerFunctionsObjectPersonality
                                             capacity:0];
        pthread_mutex_init(&_lock, NULL);
        self.observer         = observer;
    }
    return self;
}

+ (instancetype)controllerWithObserver:(nullable id)observer {
    return [[self alloc] initWithObserver:observer];
}

- (void)dealloc
{
    [self unobserveAll];
    pthread_mutex_destroy(&_lock);
}

#pragma mark - Observe

- (void)observePath:(NSString *)keyPath block:(RJBadgeNotificationBlock)block
{
    NSAssert(0 != keyPath.length && NULL != block, @"missing required parameters: keyPath:%@ block:%p", keyPath, block);

    if (0 == keyPath.length || NULL == block) return;
    
    // create info
    RJBadgeInfo *info = [[RJBadgeInfo alloc] initWithController:self keyPath:keyPath block:block];
    
    // observe object with info
    [self _observeWithInfo:info];
}

- (void)observePath:(NSString *)keyPath badgeView:(nullable id<RJBadgeView>)badgeView block:(nullable RJBadgeNotificationBlock)block
{
    NSAssert(0 != keyPath.length, @"missing required parameters: keyPath:%@", keyPath);

    if (0 == keyPath.length) return;

    // create info
    RJBadgeInfo *info = [[RJBadgeInfo alloc] initWithController:self keyPath:keyPath badgeView:badgeView block:block];
    
    // observe object with info
    [self _observeWithInfo:info];
}

- (void)observePaths:(NSArray<NSString *> *)keyPaths block:(RJBadgeNotificationBlock)block
{
    NSAssert(0 != keyPaths.count && NULL != block, @"missing required parameters: keyPaths:%@ block:%p", keyPaths, block);

    if (0 == keyPaths.count || NULL == block) return;
    
    for (NSString *keyPath in keyPaths) {
        [self observePath:keyPath block:block];
    }
}

#pragma mark - Unobserve

- (void)unobservePath:(NSString *)keyPath
{
    // create representative info
    RJBadgeInfo *info = [[RJBadgeInfo alloc] initWithController:self keyPath:keyPath];
    
    // unobserve object property
    [self _unobserveWithInfo:info];
}

- (void)unobserveAll {
    [self _unobserveAll];
}

#pragma mark - Utilities

- (void)_observeWithInfo:(RJBadgeInfo *)info
{
    pthread_mutex_lock(&_lock);
    
    // check for info existence
    RJBadgeInfo *existingInfo = [_infos member:info];
    
    if (existingInfo) {
        // aleady exists, don't observe again
        pthread_mutex_unlock(&_lock); return;
    }

    // add info and oberve
    [_infos addObject:info];
    
    // unlock prior to callout
    pthread_mutex_unlock(&_lock);
    
    [[RJBadgeManager sharedManager] observeWithInfo:info];
}

- (void)_unobserveWithInfo:(RJBadgeInfo *)info
{
    pthread_mutex_lock(&_lock);
    
    // lookup registered info instance
    RJBadgeInfo *registeredInfo = [_infos member:info];
    
    if (registeredInfo) {
        [_infos removeObject:registeredInfo];
    }
    
    pthread_mutex_unlock(&_lock);
    
    [[RJBadgeManager sharedManager] unobserveWithInfo:info];
}

- (void)_unobserveAll
{
    pthread_mutex_lock(&_lock);
    
    NSHashTable *infos = [_infos copy];
    
    // clear table and map
    [_infos removeAllObjects];
    
    // unlock
    pthread_mutex_unlock(&_lock);
    
    [[RJBadgeManager sharedManager] unobserveWithInfos:infos];
}

#pragma mark - Properties

- (NSString *)debugDescription
{
    NSMutableString *s = [NSMutableString stringWithFormat:@"<%@:%p", NSStringFromClass([self class]), self];
    [s appendFormat:@" observer:<%@:%p>", NSStringFromClass([_observer class]), _observer];
    
    pthread_mutex_lock(&_lock);
    
    if (0 != _infos.count) {
        [s appendString:@"\n  "];
    }
    
    NSMutableArray *infoDescriptions = [NSMutableArray arrayWithCapacity:_infos.count];
    
    for (RJBadgeInfo *info in _infos) {
        [infoDescriptions addObject:info.debugDescription];
    }
    
    [s appendFormat:@"-> %@", infoDescriptions];

    pthread_mutex_unlock(&_lock);
    
    [s appendString:@">"];
    
    return s;
}

#pragma mark - Operation

- (void)refreshBadgeView {
    [[RJBadgeManager sharedManager] refreshBadgeWithInfos:_infos];
}

+ (void)setBadgeForKeyPath:(NSString *)keyPath
{
    if (![keyPath length]) return;
    
    [[RJBadgeManager sharedManager] setBadgeForKeyPath:keyPath];
}

+ (void)setBadgeForKeyPath:(NSString *)keyPath count:(NSUInteger)count
{
    if (![keyPath length]) return;
    
    [[RJBadgeManager sharedManager] setBadgeForKeyPath:keyPath count:count];
}

+ (void)clearBadgeForKeyPath:(NSString *)keyPath {
    [self clearBadgeForKeyPath:keyPath forced:NO];
}

+ (void)clearBadgeForKeyPath:(NSString *)keyPath forced:(BOOL)forced
{
    if (![keyPath length]) return;
    
    [[RJBadgeManager sharedManager] clearBadgeForKeyPath:keyPath forced:forced];
}

+ (BOOL)statusForKeyPath:(NSString *)keyPath
{
    if (![keyPath length]) return NO;
    
    return [[RJBadgeManager sharedManager] statusForKeyPath:keyPath];
}

+ (NSUInteger)countForKeyPath:(NSString *)keyPath
{
    if (![keyPath length]) return 0;
    
    return [[RJBadgeManager sharedManager] countForKeyPath:keyPath];
}

@end
