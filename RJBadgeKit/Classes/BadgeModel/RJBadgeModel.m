//
//  RJBadgeModel.m
//  RJBadgeKit
//
//  Created by Ryan Jin on 04/08/2017.
//
//

#import "RJBadgeModel.h"

NSString * const RJBadgeRootPath    = @"root";

NSString * const RJBadgeNameKey     = @"RJBadgeNameKey";
NSString * const RJBadgePathKey     = @"RJBadgePathKey";
NSString * const RJBadgeChildrenKey = @"RJBadgeChildrenKey";
NSString * const RJBadgeShowKey     = @"RJBadgeShowKey";
NSString * const RJBadgeCountKey    = @"RJBadgeCountKey";

@interface RJBadgeModel ()

@property (strong, nonatomic, readwrite) NSString *name;
@property (strong, nonatomic, readwrite) NSString *keyPath;

@property (strong, nonatomic, readwrite) NSMutableArray<id<RJBadge>> *children;

@end

@implementation RJBadgeModel

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        self.name     = dic[RJBadgeNameKey];
        self.keyPath  = dic[RJBadgePathKey];
        
        self.needShow = [dic[RJBadgeShowKey] boolValue];
        self.count    = [dic[RJBadgeCountKey] unsignedIntegerValue];
        self.children = [[NSMutableArray alloc] init];
        
        NSArray *children = dic[RJBadgeChildrenKey];
        if (children) {
            [children enumerateObjectsUsingBlock:^(NSDictionary *child,
                                                   NSUInteger   idx,
                                                   BOOL         *stop) {
                RJBadgeModel *obj  = [RJBadgeModel initWithDictionary:child];
                if (obj) {obj.parent = self; [self.children addObject:obj];}
            }];
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    RJBadgeModel *model = [[[self class] alloc] init];
    
    model.name            = self.name;
    model.keyPath         = self.keyPath;
    model.count           = self.count;
    model.needShow        = self.needShow;
    model.parent          = self.parent;
    model.children        = self.children;

    return model;
}

#pragma mark - RJBadge
+ (id<RJBadge>)initWithDictionary:(NSDictionary *)dic
{
    if (![dic count]) return nil;
    
    return [[RJBadgeModel alloc] initWithDictionary:dic];
}

- (void)addChild:(id<RJBadge>)child
{
    @synchronized (self) {
        if (child) [self.children addObject:child];
    }
}

- (void)removeChild:(id<RJBadge>)child
{
    @synchronized (self) {
        if ([self.children containsObject:child]) {
            [self.children removeObject:child];
            if (![self.children count]) {
                self.needShow = 0;
                self.count    = 0;
            }
        }
    }
}

- (void)removeFromParent
{
    if (self.parent) {
        [self.parent removeChild:self];
        self.parent              = nil;
    }
}

- (NSDictionary *)dictionaryFormat
{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    if (self.name)     dic[RJBadgeNameKey]  = self.name;
    if (self.keyPath)  dic[RJBadgePathKey]  = self.keyPath;
    if (self.count)    dic[RJBadgeCountKey] = @(self.count);
    if (self.needShow) dic[RJBadgeShowKey]  = @(self.needShow);
    
    if ([self.children count]) {
        NSMutableArray *children  = [NSMutableArray new];
        dic[RJBadgeChildrenKey] = children;
        [self.children enumerateObjectsUsingBlock:^(id<RJBadge> obj,
                                                    NSUInteger  idx,
                                                    BOOL       *stop) {
            [children addObject:[obj dictionaryFormat]];
        }];
    }
    return dic;
}

#pragma mark - setter/getter
- (BOOL)needShow
{
    if ([self.children count]) {
        for (id<RJBadge> badge in self.children) {
            if (badge.needShow) return YES;
        }
        return NO;
    }
    return _needShow;
}

- (NSUInteger)count
{
    if ([self.children count]) {
        __block NSUInteger subCount = 0;
        [self.children enumerateObjectsUsingBlock:^(id<RJBadge> obj,
                                                    NSUInteger  idx,
                                                    BOOL       *stop) {
            subCount += obj.count;
        }];
        _count = subCount;
    }
    return _count;
}

@end
