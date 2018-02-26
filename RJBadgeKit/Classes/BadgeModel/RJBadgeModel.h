//
//  RJBadgeModel.h
//  RJBadgeKit
//
//  Created by Ryan Jin on 04/08/2017.
//
//

#import <Foundation/Foundation.h>
#import "RJBadge.h"

@interface RJBadgeModel : NSObject <RJBadge>

@property (strong, nonatomic, readonly) NSString *name;    // e.g. 'badge'
@property (strong, nonatomic, readonly) NSString *keyPath; // e.g. 'root.RJ.badge'
/**
 1. non-leaf node, sum of children
 2. terminal node: return  'count'
 3. setter valid for terminal node
 */
@property (assign, nonatomic) NSUInteger count; // badge value
/**
 1. non-leaf node: has any children?
 2. terminal node: return 'needShow'
 */
@property (assign, nonatomic) BOOL needShow; // red dot

// immediate children of current badge
@property (strong, nonatomic, readonly) NSMutableArray<id<RJBadge>> *children;
// all linked children, including children's children
@property (strong, nonatomic, readonly) NSMutableArray<id<RJBadge>> *allLinkChildren;

@property (weak, nonatomic) id<RJBadge> parent;

// regist nodes in terms of key path
+ (id<RJBadge>)initWithDictionary:(NSDictionary *)dic;

/**
 convert id <RJBadge> object to dictionary,
 useful for, e.g. Data Persistence / Archive
 */
- (NSDictionary *)dictionaryFormat;

- (void)addChild:(id<RJBadge>)child;     // add leaf
- (void)removeChild:(id<RJBadge>)child;  // cut leaf
- (void)clearAllChildren;                // clearAll

- (void)removeFromParent; // [parent removeChild:self]

@end

