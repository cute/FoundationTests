//
//  NSStringSubclassTests.m
//  FoundationTests
//
//  Created by Philippe Hausler on 12/29/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@interface NSStringSubclass : NSString

@end

@implementation NSStringSubclass {
    NSString *backing;
}

- (id)init
{
    self = track([super init]);
    if (self)
    {
        backing = @"asdfasdfasdf";
    }
    return self;
}

- (NSUInteger)length
{
    return track([backing length]);
}

- (unichar)characterAtIndex:(NSUInteger)index
{
    return track([backing characterAtIndex:index]);
}

- (NSRange)rangeOfString:(NSString *)aString
{
    return track([super rangeOfString:aString]);
}

- (NSRange)rangeOfString:(NSString *)str options:(NSStringCompareOptions)mask
{
    return track([super rangeOfString:str options:mask]);
}

- (NSRange)rangeOfString:(NSString *)str options:(NSStringCompareOptions)mask range:(NSRange)searchRange
{
    return track([super rangeOfString:str options:mask range:searchRange]);
}

- (NSRange)rangeOfString:(NSString *)str options:(NSStringCompareOptions)mask range:(NSRange)searchRange locale:(NSLocale *)locale
{
    return track([super rangeOfString:str options:mask range:searchRange locale:locale]);
}

- (id)copy
{
    return track([super copy]);
}

- (id)copyWithZone:(NSZone *)zone
{
    return track([super copyWithZone:zone]);
}

@end

@testcase(NSStringSubclass)

test(RangeOfStringCallPattern)
{
    NSStringSubclass *target = [[NSStringSubclass alloc] init];
    testassert(target != nil);
    [target rangeOfString:@"fasd"];
//    [SubclassTracker dumpVerification:target]
    BOOL verified = [SubclassTracker verify:target commands:@selector(init), @selector(rangeOfString:), @selector(length), @selector(rangeOfString:options:range:locale:), @selector(length), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), nil];
    testassert(verified);
    [target release];
    return YES;
}

test(Copy)
{
    NSStringSubclass *target = [[NSStringSubclass alloc] init];
    testassert(target != nil);
    NSString *str = [target copy];
    testassert(str != nil);
    testassert(target != str);
//    [SubclassTracker dumpVerification:target]
    BOOL verified = [SubclassTracker verify:target commands:@selector(init), @selector(copy), @selector(copyWithZone:), @selector(length), @selector(length), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), nil];
    testassert(verified);
    [str release];
    [target release];
    return YES;
}

test(CFStringCopy)
{
    NSStringSubclass *target = [[NSStringSubclass alloc] init];
    testassert(target != nil);
    NSString *str = (NSString *)CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)target);
    testassert(str != nil);
    testassert(target != str);
//    [SubclassTracker dumpVerification:target]
    BOOL verified = [SubclassTracker verify:target commands:@selector(init), @selector(copy), @selector(copyWithZone:), @selector(length), @selector(length), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), nil];
    testassert(verified);
    [str release];
    [target release];
    return YES;
}

@end
