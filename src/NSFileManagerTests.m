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

@interface NSFileManager (Internal)
- (BOOL)getFileSystemRepresentation:(char *)buffer maxLength:(NSUInteger)maxLength withPath:(NSString *)path;
@end

@testcase(NSFileManager)


test(URLsForDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    testassert([directories count] > 0);
    return YES;
}

test(FileDoesNotExist)
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

test(CreateFile)
{
    NSFileManager* manager = [NSFileManager defaultManager];
    testassert([manager createFileAtPath:makePath(manager, @"createTest") contents:nil attributes:nil] == YES);
    return YES;
}

test(FileSize)
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

test(ContentsOfDirectoryAtPath)
{
    NSError *error = nil;
    NSArray *bundleContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] bundlePath] error:&error];
    testassert([bundleContents count] >= 8);   /* more items are likely to be added over time */
    testassert([bundleContents containsObject:@"Info.plist"]);
    testassert(error == nil);
    return YES;
}

/* Android and iOS main bundle matches except for FoundationTests and PkgInfo */

test(MainBundleContentsTODO)
{
    NSError *error = nil;
    NSArray *bundleContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] bundlePath] error:&error];
    testassert([bundleContents containsObject:@"FoundationTests"]);
    testassert([bundleContents containsObject:@"PkgInfo"]);
    return YES;
}

test(ContentsOfDirectoryAtPathWithExtension)
{
    NSError *error = nil;
    NSArray *bundleContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] bundlePath] error:&error];
    testassert([bundleContents count] >= 8);   /* more items are likely to be added over time */
    testassert([bundleContents containsObject:@"Info.plist"]);
    testassert(error == nil);
    return YES;
}

test(DirectoryEnumeratorAtPath)
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    testassert(enumerator != nil);
    NSString *item = nil;
    NSUInteger count = 0;
    BOOL asset0Found = NO;
    BOOL bundle0Found = NO;
    BOOL bundle0ContentsFound = NO;
    BOOL enLprojInfoPlistStringsFound = NO;
    while (item = [enumerator nextObject])
    {
        if ([item isEqualToString:@"0.asset"])
        {
            asset0Found = YES;
        }
        else if ([item isEqualToString:@"0.bundle"])
        {
            bundle0Found = YES;
        }
        else if ([item isEqualToString:@"0.bundle/0-0.bundle"])
        {
            bundle0ContentsFound = YES;
        }
        else if ([item isEqualToString:@"en.lproj/InfoPlist.strings"])
        {
            enLprojInfoPlistStringsFound = YES;
        }
        count++;
    }
    testassert(count > 1);
    testassert(asset0Found);
    testassert(bundle0Found);
    testassert(bundle0ContentsFound);
    testassert(enLprojInfoPlistStringsFound);
    return YES;
}

test(DirectoryEnumeratorAtURL)
{
    __block BOOL errorOccurred = NO;
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:path] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
        errorOccurred = YES;
        return YES;
    }];
    testassert(enumerator != nil);
    NSURL *item = nil;
    NSUInteger count = 0;
    BOOL asset0Found = NO;
    BOOL bundle0Found = NO;
    BOOL bundle0ContentsFound = NO;
    BOOL enLprojInfoPlistStringsFound = NO;
    while (item = [enumerator nextObject])
    {
        item = [item URLByStandardizingPath];
        if ([item isEqual:[NSURL fileURLWithPath:[path stringByAppendingPathComponent:@"0.asset"]]])
        {
            asset0Found = YES;
        }
        else if ([item isEqual:[NSURL fileURLWithPath:[path stringByAppendingPathComponent:@"0.bundle"]]])
        {
            bundle0Found = YES;
        }
        else if ([item isEqual:[NSURL fileURLWithPath:[path stringByAppendingPathComponent:@"0.bundle/0-0.bundle"]]])
        {
            bundle0ContentsFound = YES;
        }
        else if ([item isEqual:[NSURL fileURLWithPath:[path stringByAppendingPathComponent:@"en.lproj/InfoPlist.strings"]]])
        {
            enLprojInfoPlistStringsFound = YES;
        }
        count++;
    }
    testassert(count > 1);
    testassert(asset0Found);
    testassert(bundle0Found);
    testassert(!bundle0ContentsFound);
    testassert(!enLprojInfoPlistStringsFound);
    testassert(!errorOccurred);
    return YES;
}

test(GetFileSystemRepresentationBlank)
{
    NSUInteger sz = PATH_MAX;
    char buffer[sz];
    buffer[0] = -1;
    BOOL success = [[NSFileManager defaultManager] getFileSystemRepresentation:buffer maxLength:sz withPath:@""];
    testassert(!success);
    testassert(buffer[0] == -1);
    return YES;
}

test(GetFileSystemRepresentation)
{
    NSUInteger sz = PATH_MAX;
    char buffer[sz];
    buffer[0] = -1;
    BOOL success = [[NSFileManager defaultManager] getFileSystemRepresentation:buffer maxLength:sz withPath:@"/System"];
    testassert(success);
    testassert(buffer[0] != -1);
    testassert(strcmp(buffer, "/System") == 0);
    return YES;
}

test(CurrentDirectoryIsFSRoot)
{
    testassert([[[NSFileManager defaultManager] currentDirectoryPath] isEqualToString:@"/"]);
    
    NSUInteger sz = PATH_MAX;
    char buffer[sz];
    getcwd(buffer, sz);
    testassert([[[NSFileManager defaultManager] currentDirectoryPath] isEqualToString:[NSString stringWithCString:buffer encoding:NSUTF8StringEncoding]]);
    
    return YES;
}

test(RelativePathWithBundleCWD)
{
    NSString* oldCWD = [[NSFileManager defaultManager] currentDirectoryPath];
    
    FILE* fd = NULL;
    
    @try
    {
        [[NSFileManager defaultManager] changeCurrentDirectoryPath:[[NSBundle mainBundle] bundlePath]];
        testassert([[[NSFileManager defaultManager] currentDirectoryPath] isEqualToString:[[NSBundle mainBundle] bundlePath]]);
        
        NSString* realPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        testassert(realPath != nil);
        
        // These should resolve to a file inside the bundle
        NSUInteger sz = PATH_MAX;
        char buffer[sz];
        
        fd = fopen("./Info.plist", "r");
        testassert(fd != NULL);
        fclose(fd);
        
        realpath("./Info.plist", buffer);
        testassert([realPath isEqualToString:[NSString stringWithCString:buffer encoding:NSUTF8StringEncoding]]);
        
        fd = fopen("Info.plist", "r");
        testassert(fd != NULL);
        fclose(fd);
        
        realpath("Info.plist", buffer);
        testassert([realPath isEqualToString:[NSString stringWithCString:buffer encoding:NSUTF8StringEncoding]]);
        
        fd = NULL;
    }
    @finally
    {
        if (fd != NULL)
        {
            fclose(fd);
        }
        testassert([[NSFileManager defaultManager] changeCurrentDirectoryPath:oldCWD]);
    }
    
    return YES;
}

@end
