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

- (BOOL) testMutableDataWithLength
{
    NSMutableData *data = [NSMutableData dataWithLength:7];
    testassert([data length] == 7);
    [data release];
    return YES;
}

- (BOOL) testMutableDataWithData
{
    NSData *data = [NSData dataWithBytes:"abc" length:3];
    NSMutableData *data2 = [NSMutableData dataWithData:data];
    testassert([data2 length] == 3);
    [data release];
    [data2 release];
    return YES;
}

- (BOOL) testMutableDataWithDataMutable
{
    NSMutableData *data = [NSMutableData dataWithLength:7];
    NSMutableData *data2 = [NSMutableData dataWithData:data];
    testassert([data2 length] == 7);
    [data release];
    [data2 release];
    return YES;
}
@end
