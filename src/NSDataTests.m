//
//  NSDataTests.m
//  FoundationTests
//
//  Created by Philippe Hausler on 9/2/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSData)

- (BOOL)testInitWithContentsOfFileNil
{
    NSData *data = [[NSData alloc] initWithContentsOfFile:nil];
    testassert(data == nil);
    [data release];
    return YES;
}

- (BOOL)testInitWithContentsOfURLNil
{
    NSData *data = [[NSData alloc] initWithContentsOfURL:nil];
    testassert(data == nil);
    [data release];
    return YES;
}

- (BOOL)testInitWithContentsOfURLNilOptionsError
{
    void (^block)() = ^{
        [[NSData alloc] initWithContentsOfURL:nil options:0 error:NULL];
    };

    // initWithContentsOfURL:options:error: should throw NSInvalidArgumentException
    BOOL raised = NO;

    @try {
        block();
    }
    @catch (NSException *e) {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        raised = YES;
    }

    testassert(raised);

    return YES;
}

- (BOOL)testInitWithContentsOfFileNilOptionsError
{
    void (^block)() = ^{
        [[NSData alloc] initWithContentsOfFile:nil options:0 error:NULL];
    };

    // initWithContentsOfFile:options:error: should throw NSInvalidArgumentException
    BOOL raised = NO;

    @try {
        block();
    }
    @catch (NSException *e) {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        raised = YES;
    }

    testassert(raised);

    return YES;
}

- (BOOL)testMutableDataWithLength
{
    NSMutableData *data = [NSMutableData dataWithLength:7];
    testassert([data length] == 7);
    return YES;
}

- (BOOL)testMutableDataWithData
{
    NSData *data = [NSData dataWithBytes:"abc" length:3];
    NSMutableData *data2 = [NSMutableData dataWithData:data];
    testassert([data2 length] == 3);
    return YES;
}

- (BOOL)testMutableDataWithDataMutable
{
    NSMutableData *data = [NSMutableData dataWithLength:7];
    NSMutableData *data2 = [NSMutableData dataWithData:data];
    testassert([data2 length] == 7);
    return YES;
}

- (BOOL)testMutableDataAppendBytes
{
    NSMutableData *data = [NSMutableData dataWithLength:7];
    [data appendBytes:"abc" length:3];
    [data appendBytes:"def" length:3];

    testassert([data length] == 13);

    const char *bytes = [data bytes];

    for (int i = 0; i < 7; i++)
    {
        testassert(bytes[i] == 0);
    }
    testassert(!strncmp("abcdef", bytes + 7, 6));

    return YES;
}

- (BOOL)testMutableDataReplaceBytes
{
    NSMutableData *data = [NSMutableData dataWithLength:16];
    testassert([data length] == 16);

    [data replaceBytesInRange:NSMakeRange(0, 4) withBytes:"wxyz"];
    testassert([data length] == 16);

    const char *bytes = [data bytes];
    testassert(!strncmp(bytes, "wxyz", 4));

    for (int i = 4; i < 16; i++)
    {
        testassert(bytes[i] == 0);
    }

    return YES;
}

- (BOOL)testMutableDataResetBytes
{
    NSMutableData *data = [NSMutableData dataWithLength:16];
    testassert([data length] == 16);
    
    [data replaceBytesInRange:NSMakeRange(0, 6) withBytes:"wxyzab"];
    [data resetBytesInRange:NSMakeRange(4, 16)];
    testassert([data length] == 20);
    
    const char *bytes = [data bytes];
    testassert(!strncmp(bytes, "wxyz", 4));
    
    for (int i = 4; i < 20; i++)
    {
        testassert(bytes[i] == 0);
    }
    
    return YES;
}

- (BOOL)testRangeOfData
{
    const char *bytes = "abcdabcdbcd";
    NSData *data = [NSData dataWithBytes:bytes length:strlen(bytes)];
    NSData *searchData4 = [NSData dataWithBytes:"abcd" length:4];
    NSData *searchData3 = [NSData dataWithBytes:"bcd" length:3];
    NSData *searchData0 = [NSData data];
    NSRange range;

    range = [data rangeOfData:searchData0 options:0 range:NSMakeRange(0, [data length])];
    testassert(range.location == NSNotFound);
    testassert(range.length == 0);

    range = [data rangeOfData:searchData4 options:0 range:NSMakeRange(0, [data length])];
    testassert(range.location == 0);
    testassert(range.length == 4);

    range = [data rangeOfData:searchData4 options:0 range:NSMakeRange(1, [data length] - 1)];
    testassert(range.location == 4);
    testassert(range.length == 4);

    range = [data rangeOfData:searchData4 options:NSDataSearchAnchored range:NSMakeRange(1, [data length] - 1)];
    testassert(range.location == NSNotFound);
    testassert(range.length == 0);

    range = [data rangeOfData:searchData4 options:NSDataSearchBackwards range:NSMakeRange(0, [data length])];
    testassert(range.location == 4);
    testassert(range.length == 4);

    range = [data rangeOfData:searchData4 options:NSDataSearchAnchored|NSDataSearchBackwards range:NSMakeRange(1, [data length] - 1)];
    testassert(range.location == NSNotFound);
    testassert(range.length == 0);

    range = [data rangeOfData:searchData3 options:0 range:NSMakeRange(0, [data length])];
    testassert(range.location == 1);
    testassert(range.length == 3);

    range = [data rangeOfData:searchData3 options:0 range:NSMakeRange(1, [data length] - 1)];
    testassert(range.location == 1);
    testassert(range.length == 3);

    range = [data rangeOfData:searchData3 options:NSDataSearchAnchored range:NSMakeRange(1, [data length] - 1)];
    testassert(range.location == 1);
    testassert(range.length == 3);

    range = [data rangeOfData:searchData3 options:NSDataSearchBackwards range:NSMakeRange(0, [data length])];
    testassert(range.location == 8);
    testassert(range.length == 3);

    range = [data rangeOfData:searchData3 options:NSDataSearchAnchored|NSDataSearchBackwards range:NSMakeRange(1, [data length] - 1)];
    testassert(range.location == 8);
    testassert(range.length == 3);

    return YES;
}

@end
