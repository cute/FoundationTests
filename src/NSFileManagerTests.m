//
//  NSFileManagerTests.m
//  FoundationTests
//
//  Created by Paul Beusterien on 8/19/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

#include <stdio.h>
#import <objc/runtime.h>

@testcase(NSFileManager)


- (BOOL)testURLsForDirectory
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    testassert([directories count] > 0);
    
    return YES;
}

- (BOOL)testFileDoesNotExist
{
    NSFileManager* manager = [NSFileManager defaultManager];
    
    testassert([manager fileExistsAtPath:@"IDontExist"] == NO);
    return YES;
}

static NSString *makePath(NSFileManager *manager, NSString *name)
{
    NSError *error;
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES );
    NSString* dir = [paths objectAtIndex:0];
    NSString *path = [dir stringByAppendingPathComponent:name];
    [manager removeItemAtPath:path error:&error];
    return path;
}

- (BOOL)testCreateFile
{
    NSFileManager* manager = [NSFileManager defaultManager];
    testassert([manager createFileAtPath:makePath(manager, @"createTest") contents:nil attributes:nil] == YES);
    return YES;
}

- (BOOL)testFileSize
{
    NSError* error;
    NSFileManager* manager = [NSFileManager defaultManager];
    NSString *path = makePath(manager, @"fileSizeTest");
    testassert([manager createFileAtPath:path contents:nil attributes:nil]);
    NSDictionary* attrs = [manager attributesOfItemAtPath:path error:&error];
    NSNumber* size = [attrs objectForKey:NSFileSize];
    testassert(size.longValue == 0);
    return YES;
}

- (BOOL)testContentsOfDirectoryAtPath
{
    NSError *error = nil;
    NSArray *bundleContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] bundlePath] error:&error];
    testassert([bundleContents count] >= 8);   /* more items are likely to be added over time */
    testassert([bundleContents containsObject:@"Info.plist"]);
    testassert(error == nil);
    return YES;
}

/* Android and iOS main bundle matches except for FoundationTests and PkgInfo */

- (BOOL)testMainBundleContentsTODO
{
    NSError *error = nil;
    NSArray *bundleContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] bundlePath] error:&error];
    testassert([bundleContents containsObject:@"FoundationTests"]);
    testassert([bundleContents containsObject:@"PkgInfo"]);
    return YES;
}

- (BOOL)testContentsOfDirectoryAtPathWithExtension
{
    NSError *error = nil;
    NSArray *bundleContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] bundlePath] error:&error];
    testassert([bundleContents count] >= 8);   /* more items are likely to be added over time */
    testassert([bundleContents containsObject:@"Info.plist"]);
    testassert(error == nil);
    return YES;
}

@end
