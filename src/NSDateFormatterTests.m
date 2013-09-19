//
//  NSDateFormatterTests.m
//  FoundationTests
//
//  Created by Paul Beusterien on 9/11/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSDateFormatter)

- (BOOL)testNSDateFormatterShortStyle
{
    NSDate *today = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateStyle:NSDateFormatterShortStyle];
    NSString *dateString = [dateFormat stringFromDate:today];  // 9/11/13
    testassert([dateString length] >= 6 && [dateString length] <=8);
    return YES;
}


- (BOOL)testNSDateFormatterLongerStyle
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy hh:mma"];
    NSString *dateString = [dateFormat stringFromDate:today];   // 09/11/2013 03:02PM
    testassert([dateString length] == strlen("09/11/2013 03:02PM"));
    [dateFormat release];
    return YES;
}

- (BOOL)testNSDateFormatterLongerStyle2
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEEE MMMM d, YYYY"];
    NSString *dateString = [dateFormat stringFromDate:today];  // Wednesday September 11, 2013
    testassert([dateString characterAtIndex:([dateString length] - 4)] == '2'); // this test will fail in the year 3000
    [dateFormat release];
    return YES;
}

- (BOOL)testNSDateFormatterTime
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"h:mm a, zzz"];
    NSString *dateString = [dateFormat stringFromDate:today]; // 3:11 PM, PDT
    testassert([dateString characterAtIndex:([dateString length] - 4)] == ' ');
    [dateFormat release];
    return YES;
}

- (BOOL)testNSDateFormatterConvert
{
    NSString *dateStr = @"20130912";
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSDate *date = [dateFormat dateFromString:dateStr];
    
    [dateFormat setDateFormat:@"EEEE MMMM d, YYYY"];
    dateStr = [dateFormat stringFromDate:date];
    [dateFormat release];
    testassert([dateStr isEqualToString:@"Thursday September 12, 2013"]);
    return YES;
}


@end
