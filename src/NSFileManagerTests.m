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

test(FileSystemAttributes)
{
    NSError *error = nil;
    NSFileManager* manager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *attributes = [manager attributesOfFileSystemForPath:paths[0] error:&error];
    testassert(attributes != nil);
    testassert(error == nil);
    
    NSString* fileSystemAttributes[] = {
        NSFileSystemSize,
        NSFileSystemFreeSize,
        NSFileSystemNodes,
        NSFileSystemFreeNodes
    };
    const int num = sizeof(fileSystemAttributes) / sizeof(fileSystemAttributes[0]);
    
    for (int i=0; i<num; ++i)
    {
        NSNumber *number = [attributes objectForKey:fileSystemAttributes[i]];
        testassert([number unsignedLongLongValue] > 0);
    }
    
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

test(DirectoryEnumeratorAtNilURL)
{
    void (^block)() = ^{
        [[NSFileManager defaultManager] enumeratorAtURL:nil includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:nil];
    };
    
    // Enumerator with nil URL is invalid
    BOOL raised = NO;
    
    @try {
        block();
    }
    @catch (NSException *e) {
        raised = [[e name] isEqualToString:NSInvalidArgumentException];
    }
    
    testassert(raised);
    return YES;
}

test(DirectoryEnumeratorAtURL1)
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

test(DirectoryEnumeratorAtURL2)
{

    
    union ive_seen_it_all {
        int i;
        struct {
            BOOL saw0:1;
            BOOL saw1:1;
            BOOL saw2:1;
            BOOL saw3:1;
            BOOL saw4:1;
            BOOL saw5:1;
            BOOL saw6:1;
            BOOL saw7:1;
            BOOL saw8:1;
            BOOL saw9:1;
            BOOL saw10:1;
            BOOL saw11:1;
            BOOL saw12:1;
            BOOL saw13:1;
            BOOL saw14:1;
            BOOL saw15:1;
            BOOL saw16:1;
            BOOL saw17:1;
            BOOL saw18:1;
            BOOL saw19:1;
            BOOL saw20:1;
            BOOL saw21:1;
            BOOL saw22:1;
            BOOL saw23:1;
            BOOL saw24:1;
            BOOL saw25:1;
            BOOL saw26:1;
            BOOL saw27:1;
            BOOL saw28:1;
        };
    };
    
    // Tests ordering of items returned by enumerator
    
    union ive_seen_it_all seenitall = { 0 };
    NSURL *url = [[NSBundle mainBundle] bundleURL];
    NSDirectoryEnumerator* dirEnum = [[NSFileManager defaultManager] enumeratorAtURL:url includingPropertiesForKeys:nil options:0 errorHandler:nil ];
    
    int i = 0;
    for (; YES; i++)
    {
        static int previousLine = 0;
        NSURL *nextURL = [dirEnum nextObject];
        if (nextURL == nil) {
            break;
        }
        
        testassert([[NSFileManager defaultManager] fileExistsAtPath:[nextURL path]]);
        
        // We keep track of line numbers to ensure that we find resources in the correct order
        if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"asset"]]) {
            seenitall.saw0 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"bundle"]]) {
            seenitall.saw1 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0-0" withExtension:@"bundle" subdirectory:@"0.bundle"]]) {
            seenitall.saw2 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0-0-0" withExtension:@"bundle" subdirectory:@"0.bundle/0-0.bundle"]]) {
            seenitall.saw3 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0-0-0" withExtension:@"asset" subdirectory:@"0.bundle/0-0.bundle/0-0-0.bundle"]]) {
            seenitall.saw4 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0-0" withExtension:@"asset" subdirectory:@"0.bundle/0-0.bundle"]]) {
            seenitall.saw5 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"asset" subdirectory:@"0.bundle"]]) {
            seenitall.saw6 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"ATestPlist" withExtension:@"plist"]]) {
            seenitall.saw7 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"bigfile" withExtension:@"txt"]]) {
            seenitall.saw8 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"data" withExtension:@"json"]]) {
            seenitall.saw9 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"Default-568h@2x" withExtension:@"png"]]) {
            seenitall.saw10 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"Default" withExtension:@"png"]]) {
            seenitall.saw11 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"Default@2x" withExtension:@"png"]]) {
            seenitall.saw12 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"en" withExtension:@"lproj"]]) {
            seenitall.saw13 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"InfoPlist" withExtension:@"strings" subdirectory:@"en.lproj"]]) {
            seenitall.saw14 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"folderref0" withExtension:nil]]) {
            seenitall.saw15 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"asset" subdirectory:@"folderref0"]]) {
            seenitall.saw16 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"folderref0-0" withExtension:nil subdirectory:@"folderref0"]]) {
            seenitall.saw17 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"asset" subdirectory:@"folderref0/folderref0-0"]]) {
            seenitall.saw18 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"bundle" subdirectory:@"folderref0/folderref0-0"]]) {
            seenitall.saw19 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"asset" subdirectory:@"folderref0/folderref0-0/0.bundle"]]) {
            seenitall.saw20 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }

        // Isn't implemented on platform, so it will appear as NO
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"FoundationTests" withExtension:nil]]) {
            seenitall.saw21 = NO;//YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"Info" withExtension:@"plist"]]) {
            seenitall.saw22 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"Localizable" withExtension:@"strings"]]) {
            seenitall.saw23 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        // Isn't implemented on platform, so it will appear as NO
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"PkgInfo" withExtension:nil]]) {
            seenitall.saw24 = NO;// YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"SpecialCharactersJSONTest" withExtension:@"json"]]) {
            seenitall.saw25 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"stringData" withExtension:@"bin"]]) {
            seenitall.saw26 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"utf8" withExtension:@"txt"]]) {
            seenitall.saw27 = YES & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
    }
    
    // Remove this test when the above items are implemented
    testassert(seenitall.i == 249561087);
    
    // Enable the below test when above items are implemented
    //    testassert(seenitall.i == 536870911);
    
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

test(CopyItemAtPath)
{
    NSString *documentDir =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSError *error = nil;
    NSFileManager* manager = [NSFileManager defaultManager];
    NSString *src = [documentDir stringByAppendingPathComponent:@"copyItemAtPath.txt"];
    NSString *dst = [documentDir stringByAppendingPathComponent:@"copyItemAtPath copy.txt"];
    
    [manager removeItemAtPath:src error:nil];
    [manager removeItemAtPath:dst error:nil];
    
    testassert([manager createFileAtPath:src contents:nil attributes:nil]);
    testassert([manager copyItemAtPath:src toPath:dst error:&error]);
    testassert(error == nil);
    
    testassert([manager fileExistsAtPath:src isDirectory:NULL]);
    testassert([manager fileExistsAtPath:dst isDirectory:NULL]);
    
    return YES;
}

test(MoveItemAtPath)
{
    NSString *documentDir =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSError *error = nil;
    NSFileManager* manager = [NSFileManager defaultManager];
    NSString *src = [documentDir stringByAppendingPathComponent:@"moveItemAtPath.txt"];
    NSString *dst = [documentDir stringByAppendingPathComponent:@"moveItemAtPath move.txt"];
    
    [manager removeItemAtPath:src error:nil];
    [manager removeItemAtPath:dst error:nil];
    
    testassert([manager createFileAtPath:src contents:nil attributes:nil]);
    testassert([manager moveItemAtPath:src toPath:dst error:&error]);
    testassert(error == nil);
    
    testassert(![manager fileExistsAtPath:src isDirectory:NULL]);
    testassert([manager fileExistsAtPath:dst isDirectory:NULL]);
    
    return YES;
}

test(RemoveItemAtPath)
{
    NSString *documentDir =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSError *error = nil;
    NSFileManager* manager = [NSFileManager defaultManager];
    NSString *path = [documentDir stringByAppendingPathComponent:@"removeItemAtPath.txt"];
    
    [manager removeItemAtPath:path error:nil];
    
    testassert([manager createFileAtPath:path contents:nil attributes:nil]);
    testassert([manager removeItemAtPath:path error:&error]);
    testassert(error == nil);
    
    testassert(![manager fileExistsAtPath:path isDirectory:NULL]);
    
    return YES;
}

test(CopyItemAtURL)
{
    NSString *documentDir =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSError *error = nil;
    NSFileManager* manager = [NSFileManager defaultManager];
    NSURL *src = [NSURL fileURLWithPath:[documentDir stringByAppendingPathComponent:@"copyItemAtURL.txt"]];
    NSURL *dst = [NSURL fileURLWithPath:[documentDir stringByAppendingPathComponent:@"copyItemAtURL copy.txt"]];
    
    [manager removeItemAtPath:src.path error:nil];
    [manager removeItemAtPath:dst.path error:nil];
    
    testassert([manager createFileAtPath:src.path contents:nil attributes:nil]);
    testassert([manager copyItemAtURL:src toURL:dst error:&error]);
    testassert(error == nil);
    
    testassert([manager fileExistsAtPath:src.path isDirectory:NULL]);
    testassert([manager fileExistsAtPath:dst.path isDirectory:NULL]);
    
    return YES;
}

test(MoveItemAtURL)
{
    NSString *documentDir =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSError *error = nil;
    NSFileManager* manager = [NSFileManager defaultManager];
    NSURL *src = [NSURL fileURLWithPath:[documentDir stringByAppendingPathComponent:@"moveItemAtURL.txt"]];
    NSURL *dst = [NSURL fileURLWithPath:[documentDir stringByAppendingPathComponent:@"moveItemAtURL copy.txt"]];
    
    [manager removeItemAtPath:src.path error:nil];
    [manager removeItemAtPath:dst.path error:nil];
    
    testassert([manager createFileAtPath:src.path contents:nil attributes:nil]);
    testassert([manager moveItemAtURL:src toURL:dst error:&error]);
    testassert(error == nil);
    
    testassert(![manager fileExistsAtPath:src.path isDirectory:NULL]);
    testassert([manager fileExistsAtPath:dst.path isDirectory:NULL]);
    
    return YES;
}

test(RemoveItemAtURL)
{
    NSString *documentDir =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSError *error = nil;
    NSFileManager* manager = [NSFileManager defaultManager];
    NSURL *url = [NSURL fileURLWithPath:[documentDir stringByAppendingPathComponent:@"removeItemAtURL.txt"]];
    
    [manager removeItemAtPath:url.path error:nil];
    
    testassert([manager createFileAtPath:url.path contents:nil attributes:nil]);
    testassert([manager removeItemAtURL:url error:&error]);
    testassert(error == nil);
    
    testassert(![manager fileExistsAtPath:url.path isDirectory:NULL]);
    
    return YES;
}

@end
