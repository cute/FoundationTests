#import "FoundationTests.h"

#include <stdio.h>
#import <objc/runtime.h>

@testcase(NSKeyValueCoding)

// https://developer.apple.com/library/ios/documentation/cocoa/conceptual/KeyValueCoding/Articles/CollectionOperators.html

- (BOOL)test_NSDictionary_valueForKeyPath_Basics
{
    BOOL exception = NO;
    id anObj;
    NSMutableSet *subset = [NSMutableSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"42", @"42", nil];
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *loop = [NSMutableDictionary dictionary];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", subarray, @"subarray", loop, @"loop", subset, @"subset", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:dict, nil];
    [dict setObject:anArray forKey:@"anArray"];
    
    // inf loop ...
    [loop setObject:dict forKey:@"dict"];
    [loop setObject:loop forKey:@"loop"];

    // Created collections should not be nil
    testassert(subset != nil);
    testassert(loop != nil);
    testassert(subarray != nil);
    testassert(subdict != nil);
    testassert(dict != nil);
    testassert(anArray != nil);
    
    // --------------------------------------------------
    // test getting objects with various keyPaths
    anObj = [dict valueForKeyPath:nil];
    testassert(anObj == nil);

    anObj = [dict valueForKeyPath:@"subdict.subarray"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSMutableArray class]]);
    testassert([anObj isEqual:subarray]);
    
    anObj = [dict valueForKeyPath:@".subdict.subarray"];
    testassert(anObj == nil);
    
    anObj = [dict valueForKeyPath:@"subdict."];
    testassert(anObj == nil);
    
    [subdict setObject:@"foo" forKey:@""];
    anObj = [dict valueForKeyPath:@"subdict."];
    testassert([anObj isKindOfClass:[NSString class]]);
    testassert([anObj isEqualToString:@"foo"]);
    [subdict removeObjectForKey:@""];
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subarray."];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    anObj = [dict valueForKeyPath:@"subdict.loop"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSMutableDictionary class]]);
    testassert([anObj isEqual:loop]);
    
    anObj = [dict valueForKeyPath:@"subdict.loop.loop"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSMutableDictionary class]]);
    testassert([anObj isEqual:loop]);

    anObj = [dict valueForKeyPath:@"subdict.loop.dict"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSMutableDictionary class]]);
    testassert([anObj isEqual:dict]);
    
    anObj = [dict valueForKeyPath:@"subdict.loop.loop.loop.dict.subdict.loop.dict.subdict.subarray"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSMutableArray class]]);
    testassert([anObj isEqual:subarray]);

    anObj = [dict valueForKeyPath:@"a.completely.wrong.path.that.is.syntactically.correct"];
    testassert(anObj == nil);
    
    anObj = [dict valueForKeyPath:@"#!/bin/sh -c 'echo hello.world'"];
    testassert(anObj == nil);

    // --------------------------------------------------
    // @count tests
    anObj = [dict valueForKeyPath:@"@count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 2);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@count.subdict"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    anObj = [dict valueForKeyPath:@"subdict.@count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 6);
    
    anObj = [dict valueForKeyPath:@"subdict.loop.@count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 2);
    
    anObj = [dict valueForKeyPath:@"subdict.subarray.@count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 6);
    
    anObj = [dict valueForKeyPath:@"subdict.subarray.@count.right.hand.path.here.should.be.ignored"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 6);
    
    anObj = [dict valueForKeyPath:@"subdict.subset.@count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 5);

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.@count.subarray"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@anInvalidOperator.with.a.remainder.path"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@anInvalidOperator"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    return YES;
}

- (BOOL)test_NSDictionary_valueForKeyPath_AvgMaxMinSum
{
    BOOL exception = NO;
    id anObj;
    NSMutableSet *subset = [NSMutableSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"42", @"42", nil];
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *loop = [NSMutableDictionary dictionary];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", subarray, @"subarray", loop, @"loop", subset, @"subset", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:dict, nil];
    [dict setObject:anArray forKey:@"anArray"];

    // --------------------------------------------------
    // @avg, @max, @min, @sum
    
    NSArray *operators = @[@"avg", @"max", @"min", @"sum"];
    NSArray *results = @[
                         @{@"valResults": @[@17, @33, @0, @0],
                           @"valClasses": @[[NSDecimalNumber class], [NSDecimalNumber class], [NSDecimalNumber class], [NSDecimalNumber class]]
                           },
                         @{@"valResults": @[@101, @127, @0, @0],
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSNull class], [NSNull class]]
                           },
                         @{@"valResults": @[@-2, @-6, @0, @0],
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSNull class], [NSNull class]]
                           },
                         @{@"valResults": @[@103, @166, @0, @0],
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSDecimalNumber class], [NSDecimalNumber class]]
                           },
                         ];
    unsigned int i=0;
    for (NSString *op in operators)
    {
        NSLog(@"testing for operator : %@", op);
        unsigned int j=0;
        NSDictionary *cribSheet = [results objectAtIndex:i];
        NSArray *valClasses = [cribSheet objectForKey:@"valClasses"];
        NSArray *valResults = [cribSheet objectForKey:@"valResults"];
        
        anObj = [dict valueForKeyPath:[NSString stringWithFormat:@"subdict.subarray.@%@.intValue", op]];
        testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
        testassert([anObj intValue] == [[valResults objectAtIndex:j] intValue]);
        ++j;

        anObj = [dict valueForKeyPath:[NSString stringWithFormat:@"subdict.subset.@%@.floatValue", op]];
        testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
        testassert([anObj intValue] == [[valResults objectAtIndex:j] intValue]);
        ++j;

        anObj = [dict valueForKeyPath:[NSString stringWithFormat:@"anArray.@%@.dict.subdict.subset.floatValue", op]];
        testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
        testassert([anObj intValue] == [[valResults objectAtIndex:j] intValue]);
        ++j;

        anObj = [dict valueForKeyPath:[NSString stringWithFormat:@"anArray.@%@.dict.subdict.subset", op]];
        testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
        testassert([anObj intValue] == [[valResults objectAtIndex:j] intValue]);
        ++j;
        
        @try {
            exception = NO;
            anObj = [dict valueForKeyPath:[NSString stringWithFormat:@"subdict.@%@", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        }
        testassert(exception);
        
        @try {
            exception = NO;
            anObj = [dict valueForKeyPath:[NSString stringWithFormat:@"subdict.@%@.intValue", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        }
        testassert(exception);

        @try {
            exception = NO;
            anObj = [dict valueForKeyPath:[NSString stringWithFormat:@"subdict.subarray.@%@.invalidKey", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        }
        testassert(exception);
        
        ++i;
    }
    
    return YES;
}

- (BOOL)test_NSDictionary_valueForKeyPath_unionOfObjects_distinctUnionOfObjects
{
    BOOL exception = NO;
    id anObj;
    NSMutableSet *subset = [NSMutableSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"42", @"42", nil];
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *loop = [NSMutableDictionary dictionary];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", subarray, @"subarray", loop, @"loop", subset, @"subset", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:dict, nil];
    [dict setObject:anArray forKey:@"anArray"];
    
    NSMutableArray *anotherArray = [NSMutableArray array];
    [anotherArray addObject:anArray];
    [anotherArray addObject:subarray];
    [anotherArray addObject:@[@"foo", @"bar"]];
    [anotherArray addObject:@[@"foo", @"bar"]];
    [subdict setObject:anotherArray forKey:@"anotherArray"];

    // --------------------------------------------------
    // @unionOfObjects @distinctUnionOfObjects

    anObj = [dict valueForKeyPath:@"subdict.subarray.@unionOfObjects.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 6);
    
    anObj = [dict valueForKeyPath:@"subdict.subarray.@distinctUnionOfObjects.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 4);
    
    anObj = [dict valueForKeyPath:@"subdict.subset.@distinctUnionOfObjects.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 5);
    
    anObj = [dict valueForKeyPath:@"subdict.anotherArray.@distinctUnionOfObjects.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 3);
    
    anObj = [dict valueForKeyPath:@"subdict.anotherArray.@unionOfObjects.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 4);

    // @operator as last element in path ...
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subarray.@unionOfObjects"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subset.@unionOfObjects.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@distinctUnionOfObjects.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@unionOfObjects.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@distinctUnionOfObjects"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@unionOfObjects"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    return YES;
}

- (BOOL)test_NSDictionary_valueForKeyPath_unionOfArrays_distinctUnionOfArrays
{
    BOOL exception = NO;
    id anObj;
    NSMutableSet *subset = [NSMutableSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"42", @"42", nil];
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *loop = [NSMutableDictionary dictionary];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", subarray, @"subarray", loop, @"loop", subset, @"subset", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:dict, nil];
    [dict setObject:anArray forKey:@"anArray"];
    
    NSMutableArray *anotherArray = [NSMutableArray array];
    [anotherArray addObject:anArray];
    [anotherArray addObject:subarray];
    [anotherArray addObject:@[@"foo", @"bar"]];
    [anotherArray addObject:@[@"foo", @"bar"]];
    [subdict setObject:anotherArray forKey:@"anotherArray"];
    
    // --------------------------------------------------
    // @unionOfArrays @distinctUnionOfArrays
    // NOTE : seems to only work on an NSArray of NSArrays (returns NSArray) --OR-- NSSet of NSArrays (returns NSSet)

    anObj = [dict valueForKeyPath:@"subdict.anotherArray.@unionOfArrays.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 11);
    
    anObj = [dict valueForKeyPath:@"subdict.anotherArray.@distinctUnionOfArrays.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 7);
    
    // NSSet positive test
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:anArray];
    [anotherSet addObject:subarray];
    [anotherSet addObject:@[@"foo", @"bar"]];
    [anotherSet addObject:@[@"foo", @"bar"]];
    [subdict setObject:anotherSet forKey:@"anotherSet"];
    
    anObj = [dict valueForKeyPath:@"subdict.anotherSet.@distinctUnionOfArrays.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 7);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subarray.@distinctUnionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subarray.@unionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    // Also verify exception occurs on NSSet
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subset.@distinctUnionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subset.@unionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@unionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@distinctUnionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@unionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@distinctUnionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
}

- (BOOL)test_NSDictionary_valueForKeyPath_distinctUnionOfSets
{
    BOOL exception = NO;
    id anObj;
    NSMutableSet *subset = [NSMutableSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"42", @"42", nil];
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *loop = [NSMutableDictionary dictionary];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", subarray, @"subarray", loop, @"loop", subset, @"subset", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:dict, nil];
    [dict setObject:anArray forKey:@"anArray"];
    
    NSMutableArray *anotherArray = [NSMutableArray array];
    [anotherArray addObject:[NSSet setWithArray:anArray]];
    [anotherArray addObject:[NSSet setWithArray:subarray]];
    [anotherArray addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    [anotherArray addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    [subdict setObject:anotherArray forKey:@"anotherArray"];
    
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:[NSSet setWithArray:anArray]];
    [anotherSet addObject:[NSSet setWithArray:subarray]];
    [anotherSet addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    [anotherSet addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    [subdict setObject:anotherSet forKey:@"anotherSet"];

    // --------------------------------------------------
    // @distinctUnionOfSets
    // NOTE : seems to only work on an NSSet of NSSets (returns NSSet) --OR-- NSArray of NSSets (returns NSArray)
    
    anObj = [dict valueForKeyPath:@"subdict.anotherSet.@distinctUnionOfSets.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 6);
    
    anObj = [dict valueForKeyPath:@"subdict.anotherArray.@distinctUnionOfSets.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 6);

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subset.@distinctUnionOfSets.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subarray.@distinctUnionOfSets.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.@distinctUnionOfSets.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    // --------------------------------------------------
    
    return YES;
}

- (BOOL)test_NSArray_valueForKeyPath_Basics
{
    BOOL exception = NO;
    id anObj;
    NSDictionary *subdict = [NSDictionary dictionaryWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];
    
    // --------------------------------------------------
    // random path tests
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:nil];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"lastObject"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@""];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"."];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"1"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@1"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@@@@@@@"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    // --------------------------------------------------
    // @count tests
    anObj = [anArray valueForKeyPath:@"@count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 11);
    
    anObj = [anArray valueForKeyPath:@"@count.should.ignore.right.hand.path"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 11);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"foo@count"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    return YES;
}

- (BOOL)test_NSArray_valueForKeyPath_Recursion
{
    NSMutableArray *recursiveArray = [NSMutableArray array];
    [recursiveArray addObject:recursiveArray];
    [recursiveArray addObject:@[@"foo", @"bar"]];
    [recursiveArray addObject:@[@"foo", @"bar"]];
    
    //anObj = [recursiveArray valueForKeyPath:@"@max.count"]; -- stack overflow in iOS simulator
    //anObj = [recursiveArray valueForKeyPath:@"@min.count"]; -- ditto
    //anObj = [recursiveArray valueForKeyPath:@"@avg.count"]; -- ditto
    //anObj = [recursiveArray valueForKeyPath:@"@sum.count"]; -- ditto
    
    return YES;
}

- (BOOL)test_NSArray_valueForKeyPath_MaxMinAvgSum
{
    BOOL exception = NO;
    id anObj;
    NSDictionary *subdict = [NSDictionary dictionaryWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];
    NSMutableArray *anotherArray = [NSMutableArray array];
    
    // --------------------------------------------------
    // @max, @min, @avg, @sum
    
    NSArray *operators = @[@"max", @"min", @"avg", @"sum"];
    NSArray *results = @[
                         @{@"valResults": @[@127, @127, [NSNull null], @"another constant NSString with a long description"],
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSNumber class], [NSString class]]
                           },
                         @{@"valResults": @[@-127, @-127, [NSNull null], @""],
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSNumber class], [NSString class]]
                           },
                         @{@"valResults": @[@7, @7],
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSNumber class], [NSNull class]]
                           },
                         @{@"valResults": @[@82, @81, @0, @"NaN"],
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSNumber class], [NSDecimalNumber class]]
                           },
                         ];
    unsigned int i=0;
    for (NSString *op in operators)
    {
        NSLog(@"testing for operator : %@", op);
        
        unsigned int j=0;
        NSDictionary *cribSheet = [results objectAtIndex:i];
        NSArray *valClasses = [cribSheet objectForKey:@"valClasses"];
        NSArray *valResults = [cribSheet objectForKey:@"valResults"];
        
        anObj = [anArray valueForKeyPath:[NSString stringWithFormat:@"@%@.intValue", op]];
        testassert(anObj != nil);
        testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
        testassert([anObj intValue] == [[valResults objectAtIndex:j] intValue]);
        ++j;
        
        anObj = [anArray valueForKeyPath:[NSString stringWithFormat:@"@%@.floatValue", op]];
        testassert(anObj != nil);
        testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
        testassert([anObj intValue] == [[valResults objectAtIndex:j] intValue]);
        ++j;
        
        // array of arrays
        anObj = [anotherArray valueForKeyPath:[NSString stringWithFormat:@"@%@.count", op]]; // HACK use anArray instead?
        if ([op isEqualToString:@"sum"])
        {
            testassert(anObj != nil);
            testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
            testassert([anObj intValue] == [[valResults objectAtIndex:j] intValue]);
        }
        else
        {
            testassert(anObj == nil);
        }
        ++j;
        
        if ([op isEqualToString:@"avg"])
        {
            // cannot call @avg.description && @sum.description
            @try {
                exception = NO;
                anObj = [anArray valueForKeyPath:[NSString stringWithFormat:@"@%@.description", op]];
            }
            @catch (NSException *e) {
                exception = YES;
                testassert([[e name] isEqualToString:@"NSDecimalNumberOverflowException"]);
            }
            testassert(exception);
        }
        else
        {
            anObj = [anArray valueForKeyPath:[NSString stringWithFormat:@"@%@.description", op]];
            testassert(anObj != nil);
            testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
            testassert([[anObj description] isEqual:[[valResults objectAtIndex:j] description]]);
        }
        
        // throw exception with invalid prefix --
        @try {
            exception = NO;
            anObj = [anArray valueForKeyPath:[NSString stringWithFormat:@"foo@%@.description", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        }
        testassert(exception);
        
        // throw exception for no suffix --
        @try {
            exception = NO;
            anObj = [anArray valueForKeyPath:[NSString stringWithFormat:@"@%@", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        }
        testassert(exception);
        
        // throw exception for invalid suffix --
        @try {
            exception = NO;
            anObj = [anArray valueForKeyPath:[NSString stringWithFormat:@"@%@.foobar", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        }
        testassert(exception);
        
        ++i;
    }
    
    return YES;
}

- (BOOL)test_NSArray_valueForKeyPath_unionOfObjects_distinctUnionOfObjects
{
    BOOL exception = NO;
    id anObj;
    NSDictionary *subdict = [NSDictionary dictionaryWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];
    NSMutableArray *anotherArray = [NSMutableArray array];
    
    // --------------------------------------------------
    // @unionOfObjects @distinctUnionOfObjects
    
    anObj = [anArray valueForKeyPath:@"@unionOfObjects.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 10);
    
    anObj = [anArray valueForKeyPath:@"@distinctUnionOfObjects.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 9);
    
    anObj = [anotherArray valueForKeyPath:@"@unionOfObjects.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 0);

    // @operator as last element in path ...
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@unionOfObjects"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    return YES;
}

- (BOOL)test_NSArray_valueForKeyPath_unionOfArrays_distinctUnionOfArrays
{
    BOOL exception = NO;
    id anObj;
    NSDictionary *subdict = [NSDictionary dictionaryWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];
    NSMutableArray *anotherArray = [NSMutableArray array];
    [anotherArray addObject:[NSArray arrayWithObjects:@[@1, @2, @42], @[@1, @2, @42], @3.3, @[@1, @2, @3], nil]];
    [anotherArray addObject:[NSArray arrayWithObjects:@"hello", @"world", @"-23", nil]];
    
    // --------------------------------------------------
    // @unionOfArrays @distinctUnionOfArrays
    // NOTE : seems to only work on an NSSet of NSArrays (returns NSArray) --OR-- NSArray of NSArray (returns NSArray)
    
    //anObj = [recursiveArray valueForKeyPath:@"@unionOfArrays.description"]; -- stack overflow in iOS simulator
    
    anObj = [anotherArray valueForKeyPath:@"@unionOfArrays.doubleValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 7);
    id subObj = [anObj objectAtIndex:0];
    testassert([subObj isKindOfClass:[NSArray class]]);
    testassert([subObj count] == 3);
    
    anObj = [anotherArray valueForKeyPath:@"@distinctUnionOfArrays.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 6);
    subObj = [anObj objectAtIndex:0];
    testassert([subObj isKindOfClass:[NSArray class]]);
    testassert([subObj count] == 3);
    
    @try {
        exception = NO;
        anObj = [anotherArray valueForKeyPath:@"@distinctUnionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anotherArray valueForKeyPath:@"@unionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@distinctUnionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@unionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    return YES;
}

- (BOOL)test_NSArray_valueForKeyPath_distinctUnionOfSets
{
    BOOL exception = NO;
    id anObj;
    NSDictionary *subdict = [NSDictionary dictionaryWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];
    NSMutableArray *anotherArray = [NSMutableArray array];
    [anotherArray addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    [anotherArray addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    
    // --------------------------------------------------
    // @distinctUnionOfSets
    // NOTE : seems to only work on an NSSet of NSSets (returns NSSet) --OR-- NSArray of NSSets (returns NSArray)
    
    
    anObj = [anotherArray valueForKeyPath:@"@distinctUnionOfSets.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 2);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@distinctUnionOfSets.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    // --------------------------------------------------
    
    return YES;
}

- (BOOL)test_NSSet_valueForKeyPath_Basics
{
    BOOL exception = NO;
    id anObj;
    NSDictionary *subdict = [NSDictionary dictionaryWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    NSSet *aSet = [NSSet setWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];
    
    // Created collections should not be nil
    testassert(subdict != nil);
    testassert(aSet != nil);
    
    // --------------------------------------------------
    // random path tests
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:nil];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"lastObject"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@""];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"."];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"1"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@1"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@@@@@@@"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    // --------------------------------------------------
    // @count tests
    anObj = [aSet valueForKeyPath:@"@count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 10);
    
    anObj = [aSet valueForKeyPath:@"@count.should.ignore.right.hand.path"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 10);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"foo@count"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    return YES;
}

- (BOOL)test_NSSet_valueForKeyPath_recursion
{
    NSMutableSet *recursiveSet = [NSMutableSet set];
    [recursiveSet addObject:@[@"foo", @"bar"]];
    [recursiveSet addObject:@[@"foo", @"bar"]];
    [recursiveSet addObject:recursiveSet];
    //anObj = [recursiveSet valueForKeyPath:@"@max.count"]; //-- stack overflow in iOS simulator
    //anObj = [recursiveSet valueForKeyPath:@"@min.count"]; //-- ditto
    //anObj = [recursiveSet valueForKeyPath:@"@avg.count"]; //-- ditto
    //anObj = [recursiveSet valueForKeyPath:@"@sum.count"]; //-- ditto
    
    return YES;
}

- (BOOL)test_NSSet_valueForKeyPathMaxMinAvgSumOperators
{
    BOOL exception = NO;
    id anObj;
    NSDictionary *subdict = [NSDictionary dictionaryWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    NSSet *aSet = [NSSet setWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];
    NSMutableSet *anotherSet = [NSMutableSet set];
    
    // --------------------------------------------------
    // @max, @min, @avg, @sum
    
    NSArray *operators = @[@"max", @"min", @"avg", @"sum"];
    NSArray *results = @[
                         @{@"valResults": @[@127, @127, [NSNull null], @"another constant NSString with a long description"],
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSNumber class], [NSString class]]
                           },
                         @{@"valResults": @[@-127, @-127, [NSNull null], @""],
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSNumber class], [NSString class]]
                           },
                         @{@"valResults": @[@4, @3],
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSNumber class], [NSNull class]]
                           },
                         @{@"valResults": @[@40, @39, @0, @"NaN"],
                           //@"valClasses": @[[NSNumber class], [NSNumber class], [NSNumber class], [NSDecimalNumber class]]
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSNumber class], [NSNumber class]]
                           },
                         ];
    unsigned int i=0;
    for (NSString *op in operators)
    {
        NSLog(@"testing for operator : %@", op);
        
        unsigned int j=0;
        NSDictionary *cribSheet = [results objectAtIndex:i];
        NSArray *valClasses = [cribSheet objectForKey:@"valClasses"];
        NSArray *valResults = [cribSheet objectForKey:@"valResults"];
        
        anObj = [aSet valueForKeyPath:[NSString stringWithFormat:@"@%@.intValue", op]];
        testassert(anObj != nil);
        testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
        testassert([anObj intValue] == [[valResults objectAtIndex:j] intValue]);
        ++j;
        
        anObj = [aSet valueForKeyPath:[NSString stringWithFormat:@"@%@.floatValue", op]];
        testassert(anObj != nil);
        testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
        testassert([anObj intValue] == [[valResults objectAtIndex:j] intValue]);
        ++j;
        
        // array of arrays
        anObj = [anotherSet valueForKeyPath:[NSString stringWithFormat:@"@%@.count", op]];//FIXME... aSet?
        if ([op isEqualToString:@"sum"])
        {
            testassert(anObj != nil);
            testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
            testassert([anObj intValue] == [[valResults objectAtIndex:j] intValue]);
        }
        else
        {
            testassert(anObj == nil);
        }
        ++j;
        
        if ([op isEqualToString:@"avg"])
        {
            // cannot call @avg.description && @sum.description
/* HACK !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            @try {
                exception = NO;
                anObj = [aSet valueForKeyPath:[NSString stringWithFormat:@"@%@.description", op]];
            }
            @catch (NSException *e) {
                exception = YES;
                testassert([[e name] isEqualToString:@"NSDecimalNumberOverflowException"]);
            }
            testassert(exception);
 */
        }
        else
        {
            anObj = [aSet valueForKeyPath:[NSString stringWithFormat:@"@%@.description", op]];
            testassert(anObj != nil);
            testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
            // HACK !!!!!!!!!!!!!!!!
            if (![op isEqualToString:@"sum"])
            {
                testassert([[anObj description] isEqual:[[valResults objectAtIndex:j] description]]);
            }
        }
        
        // throw exception with invalid prefix --
        @try {
            exception = NO;
            anObj = [aSet valueForKeyPath:[NSString stringWithFormat:@"foo@%@.description", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        }
        testassert(exception);
        
        // throw exception for no suffix --
        @try {
            exception = NO;
            anObj = [aSet valueForKeyPath:[NSString stringWithFormat:@"@%@", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        }
        testassert(exception);
        
        // throw exception for invalid suffix --
        @try {
            exception = NO;
            anObj = [aSet valueForKeyPath:[NSString stringWithFormat:@"@%@.foobar", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        }
        testassert(exception);
        
        ++i;
    }
    
    return YES;
}

- (BOOL)test_NSSet_valueForKeyPath_extraMinMaxAvgSum
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"fooVal", @"fooKey", @"barVal", @"barKey", @101, @"101Key", nil];
    NSMutableSet *set = [NSMutableSet setWithObject:dict];
    
    id aValue = [set valueForKeyPath:@"@max.intValue"];
    testassert(aValue == nil);
    
    aValue = [set valueForKeyPath:@"@min.intValue"];
    testassert(aValue == nil);
    
    aValue = [set valueForKeyPath:@"@avg.intValue"];
    testassert([aValue intValue] == 0);
    
    aValue = [set valueForKeyPath:@"@sum.intValue"];
    testassert([aValue intValue] == 0);
    
    [set addObject:[NSNumber numberWithInt:42]];
    
    aValue = [set valueForKeyPath:@"@max.intValue"];
    testassert([aValue intValue] == 42);
    
    aValue = [set valueForKeyPath:@"@min.intValue"];
    testassert([aValue intValue] == 42);
    
    aValue = [set valueForKeyPath:@"@sum.intValue"];
    testassert([aValue intValue] == 42);
    
    aValue = [set valueForKeyPath:@"@avg.intValue"];
    testassert([aValue intValue] == 21);
    
    [set addObject:[NSNumber numberWithInt:-10]];
    
    aValue = [set valueForKeyPath:@"@avg.intValue"];
    testassert([aValue intValue] == 10);
    
    return YES;
}

- (BOOL)test_NSSet_valueForKeyPath_unionOfObjects_distinctUnionOfObjects
{
    BOOL exception = NO;
    id anObj;
    NSDictionary *subdict = [NSDictionary dictionaryWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    NSSet *aSet = [NSSet setWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", [NSSet setWithObjects:@"subsetobj", @"subsetobj", [NSSet setWithObjects:@"subsubsetobj", nil], nil], nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    NSArray *subAry = [NSArray arrayWithObjects:@[ @"helloset", @"helloset" ], @"helloset", @"helloset", @"arrayobj", nil];
    [anotherSet addObject:subAry];

    // --------------------------------------------------
    // @unionOfObjects @distinctUnionOfObjects
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@unionOfObjects.intValue"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    // ---
    testassert([anotherSet count] == 3);

    anObj = [anotherSet valueForKeyPath:@"@distinctUnionOfObjects.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 3);
    testassert([anObj isEqual:anotherSet]);
    
    anObj = [anotherSet valueForKeyPath:@"@distinctUnionOfObjects.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 3);
    
    // @operator as last element in path ...
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@distinctUnionOfObjects"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@distinctUnionOfObjects.intValue"];
    }
    @catch (NSException *e) {
        // why exactly is this happening?  can't seem to make it happen with NSArray...
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    return YES;
}

- (BOOL)test_NSSet_valueForKeyPath_unionOfArrays_distinctUnionOfArrays
{
    BOOL exception = NO;
    id anObj;
    NSDictionary *subdict = [NSDictionary dictionaryWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    NSSet *aSet = [NSSet setWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", [NSSet setWithObjects:@"subsetobj", @"subsetobj", [NSSet setWithObjects:@"subsubsetobj", nil], nil], nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    NSArray *subAry = [NSArray arrayWithObjects:@[ @"helloset", @"helloset" ], @"helloset", @"helloset", @"arrayobj", nil];
    [anotherSet addObject:subAry];
    
    // --------------------------------------------------
    // @unionOfArrays @distinctUnionOfArrays
    // NOTE : seems to only work on an NSSet of NSArray/NSSet (returns NSArray/NSSet) --OR-- NSArray of NSArray/NSSet (returns NSArray/NSSet)
    
    @try {
        exception = NO;
        anObj = [anotherSet valueForKeyPath:@"@unionOfArrays.intValue"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anotherSet valueForKeyPath:@"@unionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    anObj = [anotherSet valueForKeyPath:@"@distinctUnionOfArrays.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 9);
#warning TODO: iterate/verify subobjects

    anObj = [anotherSet valueForKeyPath:@"@distinctUnionOfArrays.doubleValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 5);
#warning TODO: iterate/verify subobjects

    @try {
        exception = NO;
        anObj = [anotherSet valueForKeyPath:@"@distinctUnionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    NSNumber *aNumber = [NSNumber numberWithInt:1001];
    [anotherSet addObject:aNumber];
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@distinctUnionOfArrays.intValue"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    [anotherSet removeObject:aNumber];
    
    return YES;
}

- (BOOL)test_NSSet_valueForKeyPath_distinctUnionOfSets
{
    BOOL exception = NO;
    id anObj;
    NSDictionary *subdict = [NSDictionary dictionaryWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    NSSet *aSet = [NSSet setWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", [NSSet setWithObjects:@"subsetobj", @"subsetobj", [NSSet setWithObjects:@"subsubsetobj", nil], nil], nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    // --------------------------------------------------
    // @distinctUnionOfSets
    // NOTE : seems to only work on an NSSet of NSSets (returns NSSet) --OR-- NSArray of NSSets (returns NSArray)
    
    anObj = [anotherSet valueForKeyPath:@"@distinctUnionOfSets.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 7);    
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@distinctUnionOfSets.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    // --------------------------------------------------
    
    return YES;
}

- (BOOL)test_valueForKeyPath_strangeExceptions
{
    NSSet *aSet = [NSSet setWithObjects:[NSMutableString stringWithString:@"an NSMutableString"], nil];
    NSArray *anArray = [NSArray arrayWithObjects:[NSMutableString stringWithString:@"an NSMutableString"], nil];
    BOOL exception = NO;
    id aValue;

    @try {
        exception = NO;
        aValue = [anArray valueForKeyPath:@"@avg.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSDecimalNumberOverflowException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        aValue = [aSet valueForKeyPath:@"@avg.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSDecimalNumberOverflowException"]);
    }
    testassert(exception);

    return YES;
}

- (BOOL)test_valueForKeyPath_onEmptySet
{
    NSMutableSet *set = [NSMutableSet set];
    
    id aValue = [set valueForKeyPath:@"max.intValue"];
    testassert([aValue isKindOfClass:[NSSet class]]);
    testassert([aValue isEqual:set]);
    testassert([aValue count] == 0);
    
    aValue = [set valueForKeyPath:@"min.intValue"];
    testassert([aValue isKindOfClass:[NSSet class]]);
    testassert([aValue isEqual:set]);
    testassert([aValue count] == 0);
    
    aValue = [set valueForKeyPath:@"avg.intValue"];
    testassert([aValue isKindOfClass:[NSSet class]]);
    testassert([aValue isEqual:set]);
    testassert([aValue count] == 0);
    
    aValue = [set valueForKeyPath:@"sum.intValue"];
    testassert([aValue isKindOfClass:[NSSet class]]);
    testassert([aValue isEqual:set]);
    testassert([aValue count] == 0);
    return YES;
}

- (BOOL) _assertClass:(Class)clazz forObject:(NSObject*)anObj
{
    if ([clazz isEqual:[NSNull class]])
    {
        testassert((anObj == nil) || [anObj isKindOfClass:[NSNull class]]);
    }
    else
    {
        testassert([anObj isKindOfClass:clazz]);
    }
    
    return YES;
}

@end
