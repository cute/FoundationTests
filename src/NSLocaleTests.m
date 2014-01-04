//
//  NSLocaleTests.m
//  FoundationTests
//
//  Created by Paul Beusterien on 10/16/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSLocale)

- (BOOL)testAllocate
{
    NSLocale *l1 = [NSLocale alloc];
    NSLocale *l2 = [NSLocale alloc];
    
    testassert(l1 == l2);
    
    return YES;
}

- (BOOL)testPreferredLanguages
{
    NSArray *langs = [NSLocale preferredLanguages];
    testassert([langs count] >= 1);
    NSString *myLanguage = [langs objectAtIndex:0];
    testassert([myLanguage isEqualToString:@"en"]);  // Will fail on non English speaking devices
    return YES;
}

- (BOOL)testAutoupdatingCurrentLocale
{
    NSLocale *autoCurrentLocale = [NSLocale autoupdatingCurrentLocale];
    NSLocale *currentLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    testassert([autoCurrentLocale isKindOfClass:[NSLocale class]]);
    testassert([currentLocale isKindOfClass:[NSLocale class]]);
    testassert([[autoCurrentLocale localeIdentifier] isEqualToString:[currentLocale localeIdentifier]]);
    return YES;
}

@end
