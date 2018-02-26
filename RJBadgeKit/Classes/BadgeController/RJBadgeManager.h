//
//  RJBadgeManager.h
//  RJBadgeKit
//
//  Created by Ryan Jin on 06/12/2017.
//

#import <Foundation/Foundation.h>
#import "RJBadgeInfo.h"
#import "RJBadgeModel.h"

/** BADGE TREE            PATH
    -root               : root
        -first          : root.first
             -firstA    : root.first.firstA
             -firstB    : root.first.firstB
        -sencond        : root.second
               -secondA : root.second.secondA
        -third          : root.third
 */

NS_ASSUME_NONNULL_BEGIN

extern NSString * const RJBadgeRootPath;
extern NSString * const RJBadgeNameKey;

@interface RJBadgeManager : NSObject

#pragma mark - Initialize

+ (RJBadgeManager *)sharedManager;

#pragma mark - Observe

- (void)observeWithInfo:(nullable RJBadgeInfo *)info;

#pragma mark - Unobserve

- (void)unobserveWithInfo:(nullable RJBadgeInfo *)info;

- (void)unobserveWithInfos:(nullable NSHashTable<RJBadgeInfo *> *)infos;

#pragma mark - Operation

- (void)refreshBadgeWithInfos:(NSHashTable<RJBadgeInfo *> *)infos;

- (void)setBadgeForKeyPath:(NSString *)keyPath;
- (void)setBadgeForKeyPath:(NSString *)keyPath count:(NSUInteger)count;

- (void)clearBadgeForKeyPath:(NSString *)keyPath;
- (void)clearBadgeForKeyPath:(NSString *)keyPath forced:(BOOL)forced;

- (BOOL)statusForKeyPath:(NSString *)keyPath;

- (NSUInteger)countForKeyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
