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

@end

@testcase(NSStringSubclass)

- (BOOL)testRangeOfStringCallPattern
{
    NSStringSubclass *subclass = [[NSStringSubclass alloc] init];
    testassert(subclass != nil);
    [subclass rangeOfString:@"fasd"];
    BOOL verified = [SubclassTracker verify:subclass commands:@selector(init), @selector(rangeOfString:), @selector(length), @selector(rangeOfString:options:range:locale:), @selector(length), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), nil];
    testassert(verified);
    [subclass release];
    return YES;
}

@end
