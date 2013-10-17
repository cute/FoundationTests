//
//  NSTimeZoneTests.m
//  FoundationTests
//
//  Created by Paul Beusterien on 10/16/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSTimeZone)

// Change this if device has another default
#define MY_TIMEZONE @"America/Los_Angeles"

- (BOOL)testCFTimeZoneCopySystem
{
    NSTimeZone *d = (NSTimeZone *)CFTimeZoneCopySystem();
    NSString *name = [d name];
    testassert([name length] > 0);
    testassert([name isEqualToString:MY_TIMEZONE]);
    return YES;
}

- (BOOL)testCFTimeZoneGetName
{
    CFTimeZoneRef tz = CFTimeZoneCopySystem();
    CFStringRef n = CFTimeZoneGetName(tz);
    testassert([(NSString *)n isEqualToString:MY_TIMEZONE]);
    return YES;
}

- (BOOL)testCFTimeZoneCopyDefault
{
    NSTimeZone *d = (NSTimeZone *)CFTimeZoneCopyDefault();
    NSString *name = [d name];
    testassert([name length] > 0);
    testassert([name isEqualToString:MY_TIMEZONE]);
    return YES;
}

- (BOOL)testCFTimeZoneCreateWithName
{
    NSTimeZone *d = (NSTimeZone *)CFTimeZoneCreateWithName(NULL, CFSTR("Europe/Monaco"), false);
    NSString *name = [d name];
    testassert([name length] > 0);
    testassert([name isEqualToString:@"Europe/Monaco"]);
    return YES;
}


- (BOOL)testCFTimeZoneSetDefault
{
    CFTimeZoneRef cftz = CFTimeZoneCreateWithName(NULL, CFSTR("Europe/Monaco"), false);
    CFTimeZoneSetDefault(cftz);
    
    NSTimeZone *d = (NSTimeZone *)CFTimeZoneCopyDefault();
    testassert([[d name] isEqualToString:@"Europe/Monaco"]);
    
    d = (NSTimeZone *)CFTimeZoneCopySystem();
    testassert([[d name] isEqualToString:MY_TIMEZONE]);
    
    CFTimeZoneSetDefault(CFTimeZoneCopySystem());
    
    d = (NSTimeZone *)CFTimeZoneCopyDefault();
    testassert([[d name] isEqualToString:MY_TIMEZONE]);
    return YES;
}

- (BOOL)testDefaultTimeZone
{
    NSTimeZone *d = [NSTimeZone defaultTimeZone];
    const char *cName = object_getClassName(d);
    testassert(strcmp(cName, "__NSTimeZone") == 0);
    return YES;
}

- (BOOL)testDefaultTimeZoneName
{
    NSTimeZone *d = [NSTimeZone defaultTimeZone];
    NSString *name = [d name];
    testassert([name length] > 0);
    testassert([name isEqualToString:MY_TIMEZONE]);
    return YES;
}

- (BOOL)testLocalTimeZoneName
{
    NSTimeZone *d = [NSTimeZone localTimeZone];
    NSString *name = [d name];
    testassert([name length] > 0);
    testassert([name isEqualToString:MY_TIMEZONE]);
    return YES;
}


@end
