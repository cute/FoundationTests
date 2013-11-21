//
//  NSNullTests.m
//  FoundationTests
//
//  Created by Philippe Hausler on 11/20/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSNull)

- (BOOL)testNullSingleton
{
    testassert([NSNull null] == [NSNull null]);
    return YES;
}

- (BOOL)testCFNull
{
    testassert([NSNull null] == (id)kCFNull);
    return YES;
}

- (BOOL)testCFNullClass
{
    testassert([(id)kCFNull class] == [NSNull class]);
    return YES;
}

@end
