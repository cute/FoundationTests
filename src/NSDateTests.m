//
//  NSDateTests.m
//  FoundationTests
//
//  Created by Paul Beusterien on 8/18/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

#include <stdio.h>
#import <objc/runtime.h>

@testcase(NSDate)

test(Allocate)
{
    NSDate *d1 = [NSDate alloc];
    NSDate *d2 = [NSDate alloc];
    
    testassert(d1 == d2);
    
    return YES;
}

test(ReasonableDate)
{
    NSDate *d1 = [NSDate date];
    
    NSTimeInterval t1 = [d1 timeIntervalSinceReferenceDate];
    NSTimeInterval t2 = CFAbsoluteTimeGetCurrent();
    NSTimeInterval t3 = CFDateGetAbsoluteTime((CFDateRef)(d1));
    
    NSDate *d2 = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:t1];
    
    testassert(t1 == t3);
    testassert(t2 >= t1 && (t1 + 1.0) > t2);
    testassert(t1 == CFDateGetAbsoluteTime((CFDateRef)(d2)));
    
    return YES;
}

test(TimeIntervalSince1970)
{
    NSDate *d1 = [NSDate dateWithTimeIntervalSince1970:12345678.0];
    
    NSTimeInterval timeInterval = [d1 timeIntervalSince1970];
    
    testassert(timeInterval == 12345678.0);
    
    return YES;
}

test(DistantFuture)
{
    NSTimeInterval t = 0;
    NSDate *date = [NSDate distantFuture];
    t = [date timeIntervalSinceReferenceDate];
    testassert(t == 63113904000);
    t = [date timeIntervalSince1970];
    testassert(t == 64092211200);
    return YES;
}

test(DistantPast)
{
    NSTimeInterval t = 0;
    NSDate *date = [NSDate distantPast];
    t = [date timeIntervalSinceReferenceDate];
    testassert(t == -63114076800);
    t = [date timeIntervalSince1970];
    testassert(t == -62135769600);
    return YES;
}

test(DescriptionWithLocale)
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:1389044286.5453091];
    testassert([[date description] isEqualToString:@"2014-01-06 21:38:06 +0000"]);
    return YES;
}

@end
