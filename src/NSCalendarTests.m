//
//  NSCalendarTests.m
//  FoundationTests
//
//  Created by Paul Beusterien on 10/24/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSCalendar)

static NSDate *makeNSDate(int year, int month, int day, int hour, int minute)
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:day];
    [comps setMonth:month];
    [comps setYear:year];
    [comps setHour:hour];
    [comps setMinute:minute];
    //    [comps setSecond:0];    // Unitialized should be treated as zero
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [cal dateFromComponents:comps];
    [comps release];
    [cal release];
    return date;
}

- (BOOL) testNSCalendarDateByAddingComponents1Minute
{
    NSDate *date = makeNSDate(2013, 10, 19, 4, 45);
    testassert([date timeIntervalSinceReferenceDate] == 403875900);  // nothing else will work if this fails
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    [comps setMinute:1];
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date2 = [cal dateByAddingComponents:comps toDate:date options:0];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy hh:mm:ssa"];
    
    NSString *s = [dateFormat stringFromDate:date2];
    testassert([s isEqualToString:@"10/19/2013 04:46:00AM"]);
    
    return YES;
}

- (BOOL) testNSCalendarDateByAddingComponents1Second
{
    NSDate *date = makeNSDate(2013, 10, 19, 4, 45);
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    [comps setSecond:1];
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date2 = [cal dateByAddingComponents:comps toDate:date options:0];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy hh:mm:ssa"];
    
    NSString *s = [dateFormat stringFromDate:date2];
    testassert([s isEqualToString:@"10/19/2013 04:45:01AM"]);
    
    return YES;
}

- (BOOL) testNSCalendarDateByAddingComponents99Seconds
{
    NSDate *date = makeNSDate(2013, 10, 19, 4, 45);
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];

    [comps setSecond:99];
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date2 = [cal dateByAddingComponents:comps toDate:date options:0];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy hh:mm:ssa"];
    
    NSString *s = [dateFormat stringFromDate:date2];
    testassert([s isEqualToString:@"10/19/2013 04:46:39AM"]);
    
    return YES;
}

- (BOOL) testNSCalendarDateByAddingComponents
{
    NSDate *date = makeNSDate(2013, 10, 19, 4, 45);
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:4];
    [comps setMonth:7];
    [comps setYear:7];
    [comps setHour:9];
    [comps setMinute:11];
    [comps setSecond:99];
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date2 = [cal dateByAddingComponents:comps toDate:date options:0];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy hh:mm:ssa"];
    
    NSString *s = [dateFormat stringFromDate:date2];
    testassert([s isEqualToString:@"05/23/2021 01:57:39PM"]);
    
    return YES;
}

- (BOOL)testRangeOfUnitStartDateIntervalForDate
{
    NSDate *date = nil;
    NSTimeInterval interval;
    BOOL result = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay startDate:&date interval:&interval forDate:[NSDate date]];
    testassert(result == NO);
    return YES;
}

@end
