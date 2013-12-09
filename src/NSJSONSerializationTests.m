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

- (BOOL)testSuccessAtCreatingASimpleJSONObject
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *someData = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:someData options:0 error:nil];
    testassert(json != nil);
    NSArray *keys = [json allKeys];
    testassert([keys containsObject:@"decimals"]);
    testassert([keys containsObject:@"number"]);
    testassert([keys containsObject:@"hello"]);
    testassert([keys containsObject:@"dictionary"]);
    testassert([keys containsObject:@"key"]);
    
    return YES;
}

- (BOOL)testSuccessAtCreatingJSONWithCrazyCharacters
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"SpecialCharactersJSONTest" ofType:@"json"];
    NSData *someData = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:someData options:0 error:nil];
    testassert(json != nil);
    NSArray *keys = [json allKeys];
    testassert([keys containsObject:@"crazyCharacters"]);
    NSString *theString = [json objectForKey:@"crazyCharacters"];
    testassert([theString isEqualToString:@"Hello,\n“foo bar.”\n"]);
    
    return YES;
}

@end
