//
//  NSCalendarTests.m
//  FoundationTests
//
//  Created by Paul Beusterien on 10/24/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSCalendar)

- (BOOL)testAllocate
{
    NSCalendar *c1 = [NSCalendar alloc];
    NSCalendar *c2 = [NSCalendar alloc];
    
    testassert(c1 == c2);
    
    return YES;
}

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
    NSTimeInterval t = 409957455.721963; // 2013-12-28 21:04:15 +0000
    NSDate *ref = [NSDate dateWithTimeIntervalSinceReferenceDate:t];
    NSTimeInterval interval;
    BOOL result = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay startDate:&date interval:&interval forDate:ref];
    testassert(result == YES);
    return YES;
}

- (BOOL)testComponentsFromDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSTimeInterval t = 409957455.721963; // 2013-12-28 21:04:15 +0000
    NSDate *ref = [NSDate dateWithTimeIntervalSinceReferenceDate:t];
    NSDateComponents *comps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:ref];
    testassert(comps != nil);
    testassert([comps year] == 2013);
    testassert([comps month] == 12);
    testassert([comps day] == 28);
    [calendar release];
    return YES;
}

- (BOOL)testBlankDateComponents
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    testassert([comps era] == INT_MAX);
    testassert([comps year] == INT_MAX);
    testassert([comps month] == INT_MAX);
    testassert([comps day] == INT_MAX);
    testassert([comps hour] == INT_MAX);
    testassert([comps minute] == INT_MAX);
    testassert([comps second] == INT_MAX);
    testassert([comps week] == INT_MAX);
    testassert([comps weekday] == INT_MAX);
    testassert([comps weekdayOrdinal] == INT_MAX);
    testassert([comps quarter] == INT_MAX);
    testassert([comps weekOfMonth] == INT_MAX);
    testassert([comps weekOfYear] == INT_MAX);
    testassert([comps yearForWeekOfYear] == INT_MAX);
    testassert([comps calendar] == nil);
    testassert([comps timeZone] == nil);
    return YES;
}

- (BOOL)testEra
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger flags = NSCalendarUnitEra;
    NSTimeInterval t = 409957455.721963; // 2013-12-28 21:04:15 +0000
    NSDate *ref = [NSDate dateWithTimeIntervalSinceReferenceDate:t];
    NSDateComponents *comps = [calendar components:flags fromDate:ref];
    testassert([comps era] == 1);
    [calendar release];
    return YES;
}

- (BOOL)testYear
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger flags = NSCalendarUnitYear;
    NSTimeInterval t = 409957455.721963; // 2013-12-28 21:04:15 +0000
    NSDate *ref = [NSDate dateWithTimeIntervalSinceReferenceDate:t];
    NSDateComponents *comps = [calendar components:flags fromDate:ref];
    testassert([comps year] == 2013);
    [calendar release];
    return YES;
}

- (BOOL)testMonth
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger flags = NSCalendarUnitMonth;
    NSTimeInterval t = 409957455.721963; // 2013-12-28 21:04:15 +0000
    NSDate *ref = [NSDate dateWithTimeIntervalSinceReferenceDate:t];
    NSDateComponents *comps = [calendar components:flags fromDate:ref];
    testassert([comps month] == 12);
    [calendar release];
    return YES;
}

- (BOOL)testDay
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger flags = NSCalendarUnitDay;
    NSTimeInterval t = 409957455.721963; // 2013-12-28 21:04:15 +0000
    NSDate *ref = [NSDate dateWithTimeIntervalSinceReferenceDate:t];
    NSDateComponents *comps = [calendar components:flags fromDate:ref];
    testassert([comps day] == 28);
    [calendar release];
    return YES;
}

- (BOOL)testHour
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger flags = NSCalendarUnitHour;
    NSTimeInterval t = 409957455.721963; // 2013-12-28 21:04:15 +0000
    NSDate *ref = [NSDate dateWithTimeIntervalSinceReferenceDate:t];
    NSDateComponents *comps = [calendar components:flags fromDate:ref];
    testassert([comps hour] == 13);
    [calendar release];
    return YES;
}

- (BOOL)testMinute
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger flags = NSCalendarUnitMinute;
    NSTimeInterval t = 409957455.721963; // 2013-12-28 21:04:15 +0000
    NSDate *ref = [NSDate dateWithTimeIntervalSinceReferenceDate:t];
    NSDateComponents *comps = [calendar components:flags fromDate:ref];
    testassert([comps minute] == 4);
    [calendar release];
    return YES;
}

- (BOOL)testSecond
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger flags = NSCalendarUnitSecond;
    NSTimeInterval t = 409957455.721963; // 2013-12-28 21:04:15 +0000
    NSDate *ref = [NSDate dateWithTimeIntervalSinceReferenceDate:t];
    NSDateComponents *comps = [calendar components:flags fromDate:ref];
    testassert([comps second] == 15);
    [calendar release];
    return YES;
}

- (BOOL)testWeekday
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger flags = NSCalendarUnitWeekday;
    NSTimeInterval t = 409957455.721963; // 2013-12-28 21:04:15 +0000
    NSDate *ref = [NSDate dateWithTimeIntervalSinceReferenceDate:t];
    NSDateComponents *comps = [calendar components:flags fromDate:ref];
    testassert([comps weekday] == 7);
    [calendar release];
    return YES;
}

- (BOOL)testWeekdayOrdinal
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger flags = NSCalendarUnitWeekdayOrdinal;
    NSTimeInterval t = 409957455.721963; // 2013-12-28 21:04:15 +0000
    NSDate *ref = [NSDate dateWithTimeIntervalSinceReferenceDate:t];
    NSDateComponents *comps = [calendar components:flags fromDate:ref];
    testassert([comps weekdayOrdinal] == 4);
    [calendar release];
    return YES;
}

- (BOOL)testQuarter
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger flags = NSCalendarUnitQuarter;
    NSTimeInterval t = 409957455.721963; // 2013-12-28 21:04:15 +0000
    NSDate *ref = [NSDate dateWithTimeIntervalSinceReferenceDate:t];
    NSDateComponents *comps = [calendar components:flags fromDate:ref];
    testassert([comps quarter] == 0);
    [calendar release];
    return YES;
}

- (BOOL)testWeekOfMonth
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger flags = NSCalendarUnitWeekOfMonth;
    NSTimeInterval t = 409957455.721963; // 2013-12-28 21:04:15 +0000
    NSDate *ref = [NSDate dateWithTimeIntervalSinceReferenceDate:t];
    NSDateComponents *comps = [calendar components:flags fromDate:ref];
    testassert([comps weekOfMonth] == 4);
    [calendar release];
    return YES;
}

- (BOOL)testWeekOfYear
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger flags = NSCalendarUnitWeekOfYear;
    NSTimeInterval t = 409957455.721963; // 2013-12-28 21:04:15 +0000
    NSDate *ref = [NSDate dateWithTimeIntervalSinceReferenceDate:t];
    NSDateComponents *comps = [calendar components:flags fromDate:ref];
    testassert([comps weekOfYear] == 52);
    [calendar release];
    return YES;
}

- (BOOL)testYearForWeekOfYear
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger flags = NSCalendarUnitYearForWeekOfYear;
    NSTimeInterval t = 409957455.721963; // 2013-12-28 21:04:15 +0000
    NSDate *ref = [NSDate dateWithTimeIntervalSinceReferenceDate:t];
    NSDateComponents *comps = [calendar components:flags fromDate:ref];
    testassert([comps yearForWeekOfYear] == 2013);
    [calendar release];
    return YES;
}

- (BOOL)testFullComponents
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSTimeInterval t = 409957455.721963; // 2013-12-28 21:04:15 +0000
    NSDate *ref = [NSDate dateWithTimeIntervalSinceReferenceDate:t];
    NSUInteger flags = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal | NSCalendarUnitQuarter | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitYearForWeekOfYear | NSCalendarUnitCalendar | NSCalendarUnitTimeZone;
    NSDateComponents *comps = [calendar components:flags fromDate:ref];
    testassert(comps != nil);
    testassert([comps era] == 1);
    testassert([comps year] == 2013);
    testassert([comps month] == 12);
    testassert([comps day] == 28);
    testassert([comps hour] == 13);
    testassert([comps minute] == 4);
    testassert([comps second] == 15);
    // huh? this value makes no sense!
    // this deserves more research to determine if it is
    // testassert([comps week] == 2147483647);
    testassert([comps weekday] == 7);
    testassert([comps weekdayOrdinal] == 4);
    testassert([comps quarter] == 0);
    testassert([comps weekOfMonth] == 4);
    testassert([comps weekOfYear] == 52);
    testassert([comps yearForWeekOfYear] == 2013);
    [calendar release];
    return YES;
}

@end
