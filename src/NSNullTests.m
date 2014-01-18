//
//  NSNullTests.m
//  FoundationTests
//
//  Created by Philippe Hausler on 11/20/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSNull)

test(NullSingleton)
{
    testassert([NSNull null] == [NSNull null]);
    return YES;
}

test(CFNull)
{
    testassert([NSNull null] == (id)kCFNull);
    return YES;
}

test(CFNullClass)
{
    testassert([(id)kCFNull class] == [NSNull class]);
    return YES;
}

@end
