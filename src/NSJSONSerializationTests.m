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

- (BOOL)testCreatingDataFromJSONObject2
{
    NSDictionary* msg = @{
                          @"type" : @"STATEBROADCAST",
                          @"currentState" : @"LoadingJson",
                          @"context" : [NSNull null],
                          @"fullURI" : @"stack://LoadingJson",
                          @"source"  : @"pushState",
                          };
    NSError *error = nil;
    NSData* data = [NSJSONSerialization dataWithJSONObject:msg options:0 error:&error];
    testassert(error == nil);
    testassert(data != nil);
    
    return YES;
}

- (BOOL)testEscapedCharacters
{
    NSString *str = @"{\"jsonData\": \"{\\\"stuff\\\": [{\\\"id\\\": 1234}],}\"}";
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    testassert(json != nil);
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

- (BOOL)testGeneralDataSeralization
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSDictionary *dict2 = @{@"obj1" : @"value1", @"obj2" : @"value2"};
    NSArray *arr1 = @[@"obj1value1", @"obj2value2", @"obj3value3"];
    BOOL boolYes = YES;
    int16_t int16 = 12345;
    int32_t int32 = 2134567890;
    uint32_t uint32 = 3124141341;
    unsigned long long ull = 312414134131241413ull;
    float fl = 3124134134678.13;
    double dl = 13421331.72348729 * 1000000000000000000000000000000000000000000000000000.0;
    long long negLong = -632414314135135234;
    
    dict[@"dict"] = dict2;
    dict[@"arr"] = arr1;
    dict[@"bool"] = @(boolYes);
    dict[@"int16"] = @(int16);
    dict[@"int32"] = @(int32);
    dict[@"fl"] = @(fl);
    dict[@"dl"] = @(dl);
    dict[@"uint32"] = @(uint32);
    dict[@"ull"] = @(ull);
    dict[@"negLong"] = @(negLong);
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    testassert(data != nil);
    
    NSDictionary *dict_back = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data
                                                                              options:NSJSONReadingMutableContainers
                                                                                error:nil];
    
    testassert(dict_back != nil);
    testassert(![dict_back isEqualToDictionary:dict]);
    testassert(([(NSNumber *)dict_back[@"bool"] boolValue] == boolYes));
    testassert(([[(NSNumber *)dict_back[@"bool"] stringValue] isEqualToString:@"1"]));
    testassert(([(NSNumber *)dict_back[@"int16"] intValue] == int16));
    testassert(([(NSNumber *)dict_back[@"int32"] intValue] == int32));
    testassert(([(NSNumber *)dict_back[@"uint32"] intValue] == uint32));
    testassert(([(NSNumber *)dict_back[@"ull"] unsignedLongLongValue] == ull));
    testassert(abs([(NSNumber *)dict_back[@"fl"] floatValue] - fl) < (fl/100000.0));
    testassert(abs([(NSNumber *)dict_back[@"dl"] doubleValue] - dl) < (dl/1000000000.0));
    testassert(([(NSNumber *)dict_back[@"negLong"] longLongValue] == negLong));
    return YES;
}

- (BOOL)testEmptyArray
{
    NSString *str = @"{\"test\":[]}";
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
    testassert([dict objectForKey:@"test"] != nil);
    testassert([[dict objectForKey:@"test"] count] == 0);
    return YES;
}

- (BOOL)testEmptyDict
{
    NSString *str = @"{\"test\":{}}";
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
    testassert([dict objectForKey:@"test"] != nil);
    testassert([[dict objectForKey:@"test"] count] == 0);
    return YES;
}

@end
