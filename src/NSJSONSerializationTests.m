//
//  NSJSONSerializationTests.m
//  FoundationTests
//
//  Created by Glenna Buford on 11/18/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSJSONSerialization)

- (BOOL)testCreatingDataFromJSONObject1
{
    NSData *someData = [NSJSONSerialization dataWithJSONObject:@{@"someKey": @"someValue"} options:0 error:nil];
    testassert(someData != nil);
    return YES;
}

- (BOOL)testFailingAtCreatingAJSONObjectAndPassingANilError1
{
    NSData *someData = [@"data" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *json = [NSJSONSerialization JSONObjectWithData:someData options:0 error:nil];
    testassert(json == nil);
    return YES;
}

@end
