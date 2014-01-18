//
//  NSRegularExpressionTests.m
//  FoundationTests
//
//  Created by Paul Beusterien on 12/9/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSRegularExpression)

test(RegularEnumerateSimple)
{
    NSError *error = NULL;
    __block BOOL enteredBlock = NO;
    __block BOOL flagsCheck = NO;
    __block BOOL rangeCheck = NO;
    __block NSInteger rangeCount = -1;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"ac"
                                                                           options:0
                                                                             error:&error];
    [regex enumerateMatchesInString:@"ac" options:0 range:NSMakeRange(0,2) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        enteredBlock = YES;
        flagsCheck = flags == 0;
        rangeCount = [result numberOfRanges];
        rangeCheck = [result range].location == 0 && [result range].length == 2;
    }];
    testassert(enteredBlock);
    testassert(flagsCheck);
    testassert(rangeCount == 1);
    testassert(rangeCheck);
    return YES;
}

test(RegularEnumerateMultiple)
{
    NSError *error = NULL;
    __block BOOL enteredBlock = NO;
    __block BOOL flagsCheck = NO;
    __block BOOL rangeCheck = NO;
    __block NSInteger rangeCount = -1;
    __block int count = 0;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"ac"
                                                                           options:0
                                                                             error:&error];
    [regex enumerateMatchesInString:@"acacxyzacac" options:0 range:NSMakeRange(0,11) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        enteredBlock = YES;
        flagsCheck = flags == 0;
        rangeCount = [result numberOfRanges];
        rangeCheck = [result range].location == 9 && [result range].length == 2;
        count ++;
    }];
    testassert(count == 4);
    testassert(enteredBlock);
    testassert(flagsCheck);
    testassert(rangeCount == 1);
    testassert(rangeCheck);
    return YES;
}

test(RegularEnumerateSimpleNotFound)
{
    NSError *error = NULL;
    __block BOOL enteredBlock = NO;
    __block int count = 0;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"xyz"
                                                                           options:0
                                                                             error:&error];
    [regex enumerateMatchesInString:@"ac" options:0 range:NSMakeRange(0,2) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        enteredBlock = YES;
        count++;
    }];
    testassert(count == 0);
    testassert(enteredBlock == NO);
    return YES;
}

test(RegularEnumerate)
{
    NSError *error = NULL;
    __block BOOL enteredBlock = NO;
    __block BOOL flagsCheck = NO;
    __block BOOL rangeCheck = NO;
    __block NSInteger rangeCount = -1;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\b(a|b)(c|d)\\b"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    [regex enumerateMatchesInString:@"ac" options:0 range:NSMakeRange(0,2) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        enteredBlock = YES;
        flagsCheck = flags == NSMatchingHitEnd;
        rangeCount = [result numberOfRanges];
        rangeCheck = [result range].location == 0 && [result range].length == 2;
    }];
    testassert(enteredBlock);
    testassert(flagsCheck);
    testassert(rangeCount == 3);
    testassert(rangeCheck);
    return YES;
}

test(RegularExpressionNumberOfMatches)
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\b(a|b)(c|d)\\b"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    testassert([regex numberOfMatchesInString:@"ac" options:0 range:NSMakeRange(0, 2)]);
    testassert([regex numberOfMatchesInString:@"Ac" options:0 range:NSMakeRange(0, 2)]);
    testassert(![regex numberOfMatchesInString:@"AZ" options:0 range:NSMakeRange(0, 2)]);
    return YES;
}

test(RegularExpressionNumberOfMatches2)
{
    NSString *in = @"^[0-9a-zA-Z_]+[0-9a-zA-Z _-]*$";
    
    NSError *regexError;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:in
                                                                    options:0
                                                                      error:&regexError];

    testassert([regex numberOfMatchesInString:@"3_method" options:0 range:NSMakeRange(0, 8)]);
    testassert([regex numberOfMatchesInString:@"abcdefghijklmnopqrstuvwzyz" options:0 range:NSMakeRange(0, 26)]);
    testassert(![regex numberOfMatchesInString:@"asdflkj$sadlfj" options:0 range:NSMakeRange(0, 11)]);
    return YES;
}


test(RegularEnumerateSimpleReportCompletion)
{
    NSError *error = NULL;
    __block BOOL enteredBlock = NO;
    __block BOOL flagsCheck = NO;
    __block BOOL rangeCheck = NO;
    __block NSInteger rangeCount = -1;
    __block BOOL foundNilResult = NO;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"ac"
                                                                           options:0
                                                                             error:&error];
    [regex enumerateMatchesInString:@"ac" options:NSMatchingReportCompletion range:NSMakeRange(0,2) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (!enteredBlock)  // will enter twice
        {
            enteredBlock = YES;
            rangeCount = [result numberOfRanges];
            rangeCheck = [result range].location == 0 && [result range].length == 2;
        }
        else
        {
            flagsCheck = flags == (NSMatchingCompleted | NSMatchingHitEnd);
            foundNilResult = result == nil;
        }
    }];
    testassert(enteredBlock);
    testassert(flagsCheck);
    testassert(rangeCount == 1);
    testassert(rangeCheck);
    testassert(foundNilResult);
    return YES;
}

test(RegularEnumerateSimpleReportProgress)
{
    NSError *error = NULL;
    __block BOOL enteredBlock = NO;
    __block BOOL flagsCheck = NO;
    __block BOOL rangeCheck = NO;
    __block NSInteger rangeCount = -1;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"ac"
                                                                           options:0
                                                                             error:&error];
    [regex enumerateMatchesInString:@"ac" options:NSMatchingReportProgress range:NSMakeRange(0,2) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        enteredBlock = YES;
        flagsCheck = flags == 0;
        rangeCount = [result numberOfRanges];
        rangeCheck = [result range].location == 0 && [result range].length == 2;
    }];
    testassert(enteredBlock);
    testassert(flagsCheck);
    testassert(rangeCount == 1);
    testassert(rangeCheck);
    return YES;
}



test(RegularExpressionNilString)
{
    
    NSString *in = @"^[0-9a-zA-Z_]+[0-9a-zA-Z _-]*$";
    
    NSError *regexError;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:in
                                                                           options:0
                                                                             error:&regexError];
    
    BOOL foundException = NO;
    @try
    {
        testassert([regex numberOfMatchesInString:nil options:0 range:NSMakeRange(0, 8)]);
    }
    @catch(NSException *e)
    {
        foundException = YES;
    }
    testassert(foundException);
    return YES;
}


test(StringByReplacingMatchesInString) // issue 571
{
    NSError *error = nil;
    NSString* testStr = @"aaa<bbb>ccc";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<bbb>" options:NSRegularExpressionCaseInsensitive error:&error];
    
    testStr = [regex stringByReplacingMatchesInString:testStr options:0 range:NSMakeRange(0, [testStr length]) withTemplate:@""];
    testassert([testStr isEqualToString:@"aaaccc"]);
    return YES;
}

@end
