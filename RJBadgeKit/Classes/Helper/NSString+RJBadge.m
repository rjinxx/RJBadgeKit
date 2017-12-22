//
//  NSString+RJBadge.m
//  RJBadgeKit
//
//  Created by Ryan Jin on 06/08/2017.
//
//

#import "NSString+RJBadge.h"

@implementation NSString (RJBadge)

#pragma mark - public
+ (NSString *)badgeFilePath
{
    NSString *mpath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support"];
    NSString *bpath = [mpath stringByAppendingPathComponent:@"RJBadge"];
    
    NSURL *url   = [NSURL fileURLWithPath:bpath];
    [self addSkipBackupAttributeToItemAtURL:url];
    
    return bpath;
}

+ (NSString *)badgeJSONPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath         = [self badgeFilePath];
    
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createDirectoryAtPath:filePath
               withIntermediateDirectories:YES
                                attributes:nil error:nil];
    }
    return [filePath stringByAppendingPathComponent:@"badge.json"];
}

#pragma mark - private method
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]) {
        NSError *error = nil;
        BOOL success   = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                        forKey:NSURLIsExcludedFromBackupKey
                                         error:&error];
        if (!success) {
            NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent],
                                                        error);
        }
        return success;
    }
    return NO;
}

@end
