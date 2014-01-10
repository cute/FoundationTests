//
//  NSDataTests.m
//  FoundationTests
//
//  Created by Philippe Hausler on 9/2/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSData)

- (BOOL)testAllocate
{
    NSData *d1 = [NSData alloc];
    NSData *d2 = [NSData alloc];
    
    testassert(d1 == d2);
    
    return YES;
}

- (BOOL)testInitWithContentsOfFileNil
{
    NSData *data = [[NSData alloc] initWithContentsOfFile:nil];
    testassert(data == nil);
    return YES;
}

- (BOOL)testDataWithContentsOfFileNil
{
    NSData *data = [NSData dataWithContentsOfFile:nil];
    testassert(data == nil);
    return YES;
}

- (BOOL)testDataWithContentsOfMappedFileNil
{
    NSData *data = [NSData dataWithContentsOfMappedFile:nil];
    testassert(data == nil);
    return YES;
}

- (BOOL)testInitWithContentsOfURLNil
{
    NSData *data = [[NSData alloc] initWithContentsOfURL:nil];
    testassert(data == nil);
    return YES;
}

- (BOOL)testDataWithContentsOfURLNil
{
    NSData *data = [NSData dataWithContentsOfURL:nil];
    testassert(data == nil);
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

- (BOOL)testInitWithContentsOfURLGood
{
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.apportable.com/about"]];
    testassert(data != nil);
    [data release];
    return YES;
}

- (BOOL)testInitWithContentsOfURLBad
{
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.apportablexxxx.com/about"]];
    testassert(data == nil);
    [data release];
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
    
    range = [data rangeOfData:searchData3 options:0 range:NSMakeRange(1, 2)];
    testassert(range.location == NSNotFound);
    testassert(range.length == 0);

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

- (BOOL)testNSData_writeToFileAtomicallyYes
{
    const char bytes[] = {"foo"};
    NSData *data = [NSData dataWithBytes:bytes length:4];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"NSDataOutput0"];
    
    BOOL result = [data writeToFile:filePath atomically:YES];
    testassert(result);

    NSData *data2 = [NSData dataWithContentsOfFile:filePath];
    testassert([data2 isEqualToData:data]);
    
    return YES;
}

- (BOOL)testNSData_writeToFileAtomically_withNilValue
{
    const char bytes[] = {"foo"};
    NSData *data = [NSData dataWithBytes:bytes length:4];
    BOOL result = [data writeToFile:nil atomically:YES];
    testassert(!result);
    return YES;
}

- (BOOL)testNSData_writeToFileAtomically_withEmptyValue
{
    NSData *data = [NSData data];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"DictionaryTest1"];
    
    BOOL result = [data writeToFile:filePath atomically:YES];
    testassert(result);

    NSData *data2 = [NSData dataWithContentsOfFile:filePath];
    testassert([data2 isEqualToData:data]);
    
    return YES;
}

- (BOOL)testNSData_writeToURLAtomicallyYes
{
    const char bytes[] = {"foo"};
    NSData *data = [NSData dataWithBytes:bytes length:4];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"NSDataOutput0"];
    
    BOOL result = [data writeToURL:[NSURL fileURLWithPath:filePath] atomically:YES];
    testassert(result);

    NSData *data2 = [NSData dataWithContentsOfFile:filePath];
    testassert([data2 isEqualToData:data]);
    
    return YES;
}

- (BOOL)testNSData_writeToURLAtomically_withNilValue
{
    const char bytes[] = {"foo"};
    NSData *data = [NSData dataWithBytes:bytes length:4];
    BOOL result = [data writeToURL:nil atomically:YES];
    testassert(!result);
    return YES;
}

- (BOOL)testNSData_writeToURLAtomically_withEmptyValue
{
    NSData *data = [NSData data];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"DictionaryTest1"];
    
    BOOL result = [data writeToURL:[NSURL fileURLWithPath:filePath] atomically:YES];
    testassert(result);

    NSData *data2 = [NSData dataWithContentsOfFile:filePath];
    testassert([data2 isEqualToData:data]);

    return YES;
}

- (BOOL)testNSData_writeToFile_options_error
{
    const char bytes[] = {"foo"};
    NSData *data = [NSData dataWithBytes:bytes length:4];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"NSDataOutput100"];
    
    NSError *error = nil;
    BOOL result = [data writeToFile:filePath options:0 error:&error];
    testassert(result);

    NSData *data2 = [NSData dataWithContentsOfFile:filePath];
    testassert([data2 isEqualToData:data]);
    
    return YES;
}

- (BOOL)testNSData_writeToNilFile_options_error
{
    const char bytes[] = {"foo"};
    NSData *data = [NSData dataWithBytes:bytes length:4];
    
    NSError *error = nil;
    
    BOOL exception = NO;
    @try {
        [data writeToFile:nil options:0 error:&error];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
    }
    
    testassert(exception);
    testassert(error == nil);

    return YES;
}

- (BOOL)testNSData_writeToURL_options_error
{
    const char bytes[] = {"foo"};
    NSData *data = [NSData dataWithBytes:bytes length:4];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"NSDataOutput100"];
    
    NSError *error = nil;
    BOOL result = [data writeToURL:[NSURL fileURLWithPath:filePath] options:0 error:&error];
    testassert(result);

    NSData *data2 = [NSData dataWithContentsOfFile:filePath];
    testassert([data2 isEqualToData:data]);
    
    return YES;
}

- (BOOL)testNSData_writeToNilURL_options_error
{
    const char bytes[] = {"foo"};
    NSData *data = [NSData dataWithBytes:bytes length:4];
    
    NSError *error = nil;
    
    BOOL exception = NO;
    @try {
        [data writeToURL:nil options:0 error:&error];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
    }
    
    testassert(exception);
    testassert(error == nil);
    
    return YES;
}

- (BOOL)testNoCopySmallAllocation
{
    char *buffer = malloc(10);
    NSData *data = [NSData dataWithBytesNoCopy:buffer length:10 freeWhenDone:YES];
    testassert([data bytes] == buffer);
    return YES;
}

@end
