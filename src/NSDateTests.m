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

- (BOOL)testReasonableDate
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

- (BOOL)testTimeIntervalSince1970
{
    NSDate *d1 = [NSDate dateWithTimeIntervalSince1970:12345678.0];
    
    NSTimeInterval timeInterval = [d1 timeIntervalSince1970];
    
    testassert(timeInterval == 12345678.0);
    
    return YES;
}

@end
