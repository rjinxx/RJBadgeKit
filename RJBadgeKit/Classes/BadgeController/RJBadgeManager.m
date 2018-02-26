//
//  RJBadgeManager.m
//  RJBadgeKit
//
//  Created by Ryan Jin on 06/12/2017.
//

#import "RJBadgeManager.h"
#import <pthread/pthread.h>
#import "NSString+RJBadge.h"
#import "UIBarButtonItem+RJBadge.h"
#import "UITabBarItem+RJBadge.h"
#import "UIView+RJBadge.h"
#import "RJBadgeController.h"

#ifndef dispatch_queue_async_rjbk
#define dispatch_queue_async_rjbk(queue, block)\
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) { \
        block(); \
    } else { \
        dispatch_async(queue, block); \
    }
#endif

#ifndef dispatch_main_async_rjbk
#define dispatch_main_async_rjbk(block) dispatch_queue_async_rjbk(dispatch_get_main_queue(), block)
#endif

NS_ASSUME_NONNULL_BEGIN

@implementation RJBadgeManager {
    NSMutableDictionary<NSString *, NSMutableSet<RJBadgeInfo *> *> *_objectInfosMap;
    RJBadgeModel *_root;
    pthread_mutex_t  _mutex;
    dispatch_queue_t _badgeQueue;
}

#pragma mark - Lifecycle

+ (RJBadgeManager *)sharedManager
{
    static RJBadgeManager *_badgeMgr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _badgeMgr = [RJBadgeManager new];
    });
    
    return _badgeMgr;
}

- (instancetype)init
{
    self = [super init];
    if (nil != self) {
        // recursive lock
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(&_mutex, &attr);
        pthread_mutexattr_destroy(&attr);
        
        _objectInfosMap = [[NSMutableDictionary alloc] initWithCapacity:0];
        _badgeQueue     = dispatch_queue_create("com.badge.RJBadgeKit.queue", DISPATCH_QUEUE_CONCURRENT);
        
        [self setupRootBadge];
    }
    return self;
}

- (void)dealloc {
    pthread_mutex_destroy(&_mutex);
}

#pragma mark - Observe

- (void)observeWithInfo:(nullable RJBadgeInfo *)info
{
    if (nil == info) return;
    
    pthread_mutex_lock(&_mutex);
    
    NSString *keyPath = info.keyPath;
    
    // get observation infos
    NSMutableSet *infos = [_objectInfosMap objectForKey:keyPath];

    // lazilly create set of infos
    if (!infos) {
        infos = [NSMutableSet set];
        [_objectInfosMap setObject:infos forKey:keyPath];
    }

    // add info and oberve
    [infos addObject:info];
    
    // unlock prior to callout
    pthread_mutex_unlock(&_mutex);
    
    // case where need to show badge while adding the observer
    id<RJBadge> badge = [self badgeForKeyPath:keyPath];
    if (badge && [badge needShow]) {
        [self statusChangeForBadges:@[badge]];
    }
}

#pragma mark - Unobserve

- (void)unobserveWithInfo:(nullable RJBadgeInfo *)info
{
    if (nil == info) return;
    
    pthread_mutex_lock(&_mutex);
    
    NSString *keyPath = info.keyPath;
    
    // get observation infos
    NSMutableSet *infos = [_objectInfosMap objectForKey:keyPath];
    
    // lookup registered info instance
    RJBadgeInfo *registeredInfo = [infos member:info];
    id<RJBadgeView> badgeView   = registeredInfo.badgeView;
    
    if (nil != registeredInfo) {
        [infos removeObject:registeredInfo];
        
        // remove no longer used infos
        if (0 == infos.count) {
            [_objectInfosMap removeObjectForKey:keyPath];
        }
    }
    
    // unlock
    pthread_mutex_unlock(&_mutex);
    
    if (badgeView && [badgeView conformsToProtocol:@protocol(RJBadgeView)]) {
        dispatch_main_async_rjbk(^{ [badgeView hideBadge]; });
    }
}

- (void)unobserveWithInfos:(nullable NSHashTable<RJBadgeInfo *> *)infos
{
    if (0 == infos.count) return;
    
    for (RJBadgeInfo *info in infos) {
        [self unobserveWithInfo:info];
    }
}

#pragma mark - Setup Badge
- (void)setupRootBadge
{
    NSString     *badgeFile    = [NSString badgeJSONPath];
    NSDictionary *badgeFileDic = [NSDictionary dictionaryWithContentsOfFile:badgeFile];
    NSDictionary *badgeDic     = badgeFileDic ? : @{RJBadgeNameKey : @"root",
                                                    RJBadgePathKey : @"root",
                                                    RJBadgeCountKey: @(0),
                                                    RJBadgeShowKey : @(YES)};
    _root = [RJBadgeModel initWithDictionary:badgeDic];
    
    if (!badgeFileDic) [self saveBadgeInfo];
}

- (void)saveBadgeInfo {
    [[_root dictionaryFormat] writeToFile:[NSString badgeJSONPath]
                               atomically:YES];
}

#pragma mark - Set Badge
- (void)setBadgeForKeyPath:(NSString *)keyPath {
    [self setBadgeForKeyPath:keyPath count:0];
}

- (void)setBadgeForKeyPath:(NSString *)keyPath count:(NSUInteger)count
{
    if (!keyPath) return;
    
    NSArray *keyPathArray        = [keyPath componentsSeparatedByString:@"."];
    NSMutableArray *notifyBadges = [NSMutableArray array];

    pthread_mutex_lock(&_mutex);

    id<RJBadge> bParent = _root;
    
    for (NSString *name in keyPathArray) {
        if ([name isEqualToString:@"root"]) continue;
        id<RJBadge> objFind = nil;
        for (id<RJBadge> obj in bParent.children) {
            if ([obj.name isEqualToString:name]) {
                objFind = obj; break;
            }
        }
        NSString *namePath   = [NSString stringWithFormat:@".%@",name];
        NSString *subKeyPath = [bParent.keyPath stringByAppendingString:namePath];
        if (!objFind) {
            BOOL set = ([name isEqualToString:[keyPathArray lastObject]]);
            objFind  = [RJBadgeModel initWithDictionary:@{RJBadgeNameKey : name,
                                                          RJBadgePathKey : subKeyPath,
                                                          RJBadgeCountKey: @(0),
                                                          RJBadgeShowKey : @(set)}];
            objFind.parent   = bParent;
            [bParent addChild:objFind];
        }
        bParent              = objFind;
        if ([subKeyPath isEqualToString:keyPath]) {
            objFind.needShow = YES;
            objFind.count    = count;
        }
        [notifyBadges addObject:objFind];
    }
    [self saveBadgeInfo];
    
    pthread_mutex_unlock(&_mutex);
    
    [self statusChangeForBadges:[notifyBadges mutableCopy]];
}

#pragma mark - Clear Badge
- (void)clearBadgeForKeyPath:(NSString *)keyPath {
    [self clearBadgeForKeyPath:keyPath forced:NO];
}

- (void)clearBadgeForKeyPath:(NSString *)keyPath forced:(BOOL)forced
{
    if (!keyPath) return;
    
    NSArray *keyPathArray        = [keyPath componentsSeparatedByString:@"."];
    NSMutableArray *notifyBadges = [NSMutableArray array];

    pthread_mutex_lock(&_mutex);
    
    id<RJBadge> bParent   = _root;

    for (NSString *name in keyPathArray) {
        if ([name isEqualToString:@"root"]) continue;
        id<RJBadge> objFind = nil;
        for (id<RJBadge> obj in bParent.children) {
            if ([obj.name isEqualToString:name]) {
                objFind = obj; bParent = objFind;
                break;
            }
        }
        if (!objFind) {
            pthread_mutex_unlock(&_mutex);
            return;
        }
        if ([name isEqualToString:[keyPathArray lastObject]]) {
            objFind.needShow = NO;
            if ([objFind.children count] == 0 || forced) {
                if ([objFind.children count]  && forced) {
                    NSArray *bs = [objFind.allLinkChildren mutableCopy];
                    [notifyBadges addObjectsFromArray:bs];
                    [objFind clearAllChildren];
                }
                objFind.count = 0;
                [objFind removeFromParent];
            }
            [self saveBadgeInfo];
        }
        [notifyBadges addObject:objFind];
    }
    pthread_mutex_unlock(&_mutex);
    
    [self  statusChangeForBadges:[notifyBadges mutableCopy]];
}

#pragma mark - Status Change
- (void)statusChangeForBadges:(NSArray<id<RJBadge>> *)badges
{
    if (![badges count]) return;
    
    for (id<RJBadge> badge in badges) {
        NSString *path = badge.keyPath;
        
        if ([path isEqualToString:RJBadgeRootPath]) continue;
        
        pthread_mutex_lock(&_mutex);
        
        NSMutableSet *infos = [[_objectInfosMap objectForKey:path] copy];
        
        pthread_mutex_unlock(&_mutex);
        
        [infos enumerateObjectsUsingBlock:^(RJBadgeInfo *bInfo, BOOL * _Nonnull stop) {
            id<RJBadgeView> badgeView = bInfo.badgeView;
            if (badgeView && [badgeView conformsToProtocol:@protocol(RJBadgeView)]) {
                NSUInteger c = badge.count;
                dispatch_main_async_rjbk(^{
                    if (c > 0) {
                        [badgeView showBadgeWithValue:c];
                    } else if (badge.needShow) {
                        [badgeView showBadge];
                    } else {
                        [badgeView hideBadge];
                    }
                });
            }
            if (bInfo.block) {
                id observer = bInfo.controller.observer;
                bInfo.block(observer, @{ RJBadgePathKey :   badge.keyPath,
                                         RJBadgeShowKey : @(badge.needShow),
                                         RJBadgeCountKey: @(badge.count) });
            }
        }];
    }
}

#pragma mark - Refresh Badge
- (void)refreshBadgeWithInfos:(NSHashTable<RJBadgeInfo *> *)infos
{
    if (0 == infos.count) return;
    
    for (RJBadgeInfo *bInfo in infos) {
        id<RJBadge> badge         = [self badgeForKeyPath:bInfo.keyPath];
        id<RJBadgeView> badgeView = bInfo.badgeView;
        if (badgeView && [badgeView conformsToProtocol:@protocol(RJBadgeView)]) {
            NSUInteger c = badge.count;
            dispatch_main_async_rjbk(^{
                if (c > 0) {
                    [badgeView showBadgeWithValue:c];
                } else if (badge.needShow) {
                    [badgeView showBadge];
                } else {
                    [badgeView hideBadge];
                }
            });
        }
    }
}

#pragma mark - Badge Status
- (BOOL)statusForKeyPath:(NSString *)keyPath {
    return [[self badgeForKeyPath:keyPath] needShow];
}

- (NSUInteger)countForKeyPath:(NSString *)keyPath
{
    id<RJBadge> badge = [self badgeForKeyPath:keyPath];
    return badge ? badge.count : 0;
}

#pragma mark - Helper
- (id<RJBadge>)badgeForKeyPath:(NSString *)keyPath
{
    NSArray *kPaths   = [keyPath componentsSeparatedByString:@"."];
    id<RJBadge> badge = nil;
    
    pthread_mutex_lock(&_mutex);

    id<RJBadge> bParent = _root;

    for (NSString *name in kPaths) {
        if ([name isEqualToString:RJBadgeRootPath]) {
            continue;
        }
        id<RJBadge> objFind = nil;
        for (id<RJBadge> obj in bParent.children) {
            if ([obj.name isEqualToString:name]) {
                objFind = obj; bParent = objFind;
                break;
            }
        }
        
        if (!objFind) {
            pthread_mutex_unlock(&_mutex);
            return nil;
        }
        
        badge = objFind;
    }
    
    pthread_mutex_unlock(&_mutex);

    return badge;
}

@end

NS_ASSUME_NONNULL_END
