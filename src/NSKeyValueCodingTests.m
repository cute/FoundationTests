#import "FoundationTests.h"

#include <stdio.h>
#import <objc/runtime.h>

@testcase(NSKeyValueCoding)

// https://developer.apple.com/library/ios/documentation/cocoa/conceptual/KeyValueCoding/Articles/CollectionOperators.html

- (BOOL)testNSDictionary_valueForKeyPath
{
    BOOL exception = NO;
    // NOTE : this also tests encapsulated NSArray and NSSet
    
    NSMutableSet *subset = [[NSMutableSet alloc] initWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"42", @"42", nil];
    NSMutableArray *subarray = [[NSMutableArray alloc] initWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *loop = [[NSMutableDictionary alloc] initWithCapacity:2];
    NSMutableDictionary *subdict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", subarray, @"subarray", loop, @"loop", subset, @"subset", nil];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:subdict, @"subdict", nil];

    NSMutableArray *anArray = [[NSMutableArray alloc] initWithObjects:dict, nil];
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
    id anObj = [dict valueForKeyPath:nil];
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
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key ."]);
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
        testassert([[e reason] hasSuffix:@"this class does not implement the count operation."]);
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
        testassert([[e reason] hasSuffix:@"this class does not implement the count operation."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@anInvalidOperator.with.a.remainder.path"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"this class does not implement the anInvalidOperator operation."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@anInvalidOperator"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key anInvalidOperator."]);
    }
    testassert(exception);

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
            NSString *s = [NSString stringWithFormat:@"this class is not key value coding-compliant for the key %@.", op];
            testassert([[e reason] hasSuffix:s]);
        }
        testassert(exception);
        
        @try {
            exception = NO;
            anObj = [dict valueForKeyPath:[NSString stringWithFormat:@"subdict.@%@.intValue", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
            NSString *s = [NSString stringWithFormat:@"this class does not implement the %@ operation.", op];
            testassert([[e reason] hasSuffix:s]);
        }
        testassert(exception);

        @try {
            exception = NO;
            anObj = [dict valueForKeyPath:[NSString stringWithFormat:@"subdict.subarray.@%@.invalidKey", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
            testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key invalidKey."]);
        }
        testassert(exception);
        
        ++i;
    }

    // --------------------------------------------------
    // ALLOC another array for specific tests...
    
    NSMutableArray *anotherArray = [[NSMutableArray alloc] initWithCapacity:5];
    [anotherArray addObject:anArray];
    [anotherArray addObject:subarray];
    [anotherArray addObject:@[@"foo", @"bar"]];
    [anotherArray addObject:@[@"foo", @"bar"]];
    //[anotherArray addObject:anotherArray]; -- recursion will crash @{distinctU,u}nionOf{Objects,Arrays}
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
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key unionOfObjects."]);
    }
    testassert(exception);

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subset.@unionOfObjects.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"this class does not implement the unionOfObjects operation."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@distinctUnionOfObjects.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"this class does not implement the distinctUnionOfObjects operation."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@unionOfObjects.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"this class does not implement the unionOfObjects operation."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@distinctUnionOfObjects"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key distinctUnionOfObjects."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@unionOfObjects"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key unionOfObjects."]);
    }
    testassert(exception);
    
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
    NSMutableSet *anotherSet = [[NSMutableSet alloc] initWithCapacity:5];
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
        testassert([[e reason] hasSuffix:@"array argument is not an NSArray"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subarray.@unionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"array argument is not an NSArray"]);
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
        testassert([[e reason] hasSuffix:@"array argument is not an NSArray"]);
    }
    testassert(exception);

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subset.@unionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"this class does not implement the unionOfArrays operation."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@unionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"this class does not implement the unionOfArrays operation."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@distinctUnionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"this class does not implement the distinctUnionOfArrays operation."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@unionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key unionOfArrays."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@distinctUnionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key distinctUnionOfArrays."]);
    }
    testassert(exception);

    // --------------------------------------------------
    // @distinctUnionOfSets
    // NOTE : seems to only work on an NSSet of NSSets (returns NSSet) --OR-- NSArray of NSSets (returns NSArray)
    
    [anotherArray removeAllObjects];
    [anotherArray addObject:[NSSet setWithArray:anArray]];
    [anotherArray addObject:[NSSet setWithArray:subarray]];
    [anotherArray addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    [anotherArray addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    
    [anotherSet removeAllObjects];
    [anotherSet addObject:[NSSet setWithArray:anArray]];
    [anotherSet addObject:[NSSet setWithArray:subarray]];
    [anotherSet addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    [anotherSet addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    
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
        testassert([[e reason] hasSuffix:@"set argument is not an NSSet"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subarray.@distinctUnionOfSets.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"set argument is not an NSSet"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.@distinctUnionOfSets.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"this class does not implement the distinctUnionOfSets operation."]);
    }
    testassert(exception);

    // --------------------------------------------------
    
    [anotherSet release];
    [anotherArray release];

    [subset release];
    [subarray release];
    [loop release];
    [subdict release];
    [dict release];
    [anArray release];
    
    return YES;
}

- (BOOL)testNSArray_valueForKeyPath
{
    NSDictionary *subdict = [[NSDictionary alloc] initWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    
    NSMutableArray *anArray = [[NSMutableArray alloc] initWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];
    
    NSMutableArray *recursiveArray = [[NSMutableArray alloc] initWithCapacity:5];
    [recursiveArray addObject:recursiveArray];
    [recursiveArray addObject:@[@"foo", @"bar"]];
    [recursiveArray addObject:@[@"foo", @"bar"]];
    
    NSMutableArray *anotherArray = [[NSMutableArray alloc] initWithCapacity:5];
    
    //[anotherArray addObject:anotherArray]; -- recursion will crash @{distinctU,u}nionOf{Objects,Arrays}
    
    // Created collections should not be nil
    testassert(subdict != nil);
    testassert(anArray != nil);
    testassert(recursiveArray != nil);
    testassert(anotherArray != nil);
    
    BOOL exception = NO;
    id anObj;
    
    // --------------------------------------------------
    // random path tests
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:nil];
    }
    @catch (NSException *e) {
        NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key (null)."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"lastObject"];
    }
    @catch (NSException *e) {
        NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key lastObject."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@""];
    }
    @catch (NSException *e) {
        NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key ."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"."];
    }
    @catch (NSException *e) {
        NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key ."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@"];
    }
    @catch (NSException *e) {
        NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key ."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"1"];
    }
    @catch (NSException *e) {
        NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key 1."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@1"];
    }
    @catch (NSException *e) {
        NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key 1."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@@@@@@@"];
    }
    @catch (NSException *e) {
        NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key @@@@@@."]);
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
        NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key foo@count."]);
    }
    testassert(exception);
    
    // --------------------------------------------------
    // @max, @min, @avg, @sum
    
    //anObj = [recursiveArray valueForKeyPath:@"@max.count"]; -- stack overflow in iOS simulator
    //anObj = [recursiveArray valueForKeyPath:@"@min.count"]; -- ditto
    //anObj = [recursiveArray valueForKeyPath:@"@avg.count"]; -- ditto
    //anObj = [recursiveArray valueForKeyPath:@"@sum.count"]; -- ditto
    
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
        anObj = [anotherArray valueForKeyPath:[NSString stringWithFormat:@"@%@.count", op]];
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
                NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
                exception = YES;
                testassert([[e name] isEqualToString:@"NSDecimalNumberOverflowException"]);
                testassert([[e reason] hasSuffix:@"NSDecimalNumber overflow exception"]);
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
            NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
            NSString *str = [NSString stringWithFormat:@"this class is not key value coding-compliant for the key foo@%@.", op];
            testassert([[e reason] hasSuffix:str]);
        }
        testassert(exception);
        
        // throw exception for no suffix --
        @try {
            exception = NO;
            anObj = [anArray valueForKeyPath:[NSString stringWithFormat:@"@%@", op]];
        }
        @catch (NSException *e) {
            NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
            NSString *str = [NSString stringWithFormat:@"this class is not key value coding-compliant for the key %@.", op];
            testassert([[e reason] hasSuffix:str]);
        }
        testassert(exception);
        
        // throw exception for invalid suffix --
        @try {
            exception = NO;
            anObj = [anArray valueForKeyPath:[NSString stringWithFormat:@"@%@.foobar", op]];
        }
        @catch (NSException *e) {
            NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
            NSString *str = [NSString stringWithFormat:@"this class is not key value coding-compliant for the key foobar."];
            testassert([[e reason] hasSuffix:str]);
        }
        testassert(exception);
        
        ++i;
    }
    
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
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key unionOfObjects."]);
    }
    testassert(exception);
    
    // --------------------------------------------------
    // @unionOfArrays @distinctUnionOfArrays
    // NOTE : seems to only work on an NSSet of NSArrays (returns NSArray) --OR-- NSArray of NSArray (returns NSArray)
    
    //anObj = [recursiveArray valueForKeyPath:@"@unionOfArrays.description"]; -- stack overflow in iOS simulator
    
    [anotherArray addObject:[NSArray arrayWithObjects:@[@1, @2, @42], @[@1, @2, @42], @3.3, @[@1, @2, @3], nil]];
    [anotherArray addObject:[NSArray arrayWithObjects:@"hello", @"world", @"-23", nil]];
    
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
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key distinctUnionOfArrays."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anotherArray valueForKeyPath:@"@unionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key unionOfArrays."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@distinctUnionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"array argument is not an NSArray"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@unionOfArrays.description"];
    }
    @catch (NSException *e) {
        NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"array argument is not an NSArray"]);
    }
    testassert(exception);
    
    // --------------------------------------------------
    // @distinctUnionOfSets
    // NOTE : seems to only work on an NSSet of NSSets (returns NSSet) --OR-- NSArray of NSSets (returns NSArray)
    
    [anotherArray removeAllObjects];
    [anotherArray addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    [anotherArray addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    
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
        testassert([[e reason] hasSuffix:@"set argument is not an NSSet"]);
    }
    testassert(exception);
    
    // --------------------------------------------------
    
    [anotherArray release];
    [recursiveArray release];
    [subdict release];
    [anArray release];
    
    return YES;
}

- (BOOL)testNSSet_valueForKeyPath
{
    NSDictionary *subdict = [[NSDictionary alloc] initWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    
    NSSet *aSet = [[NSSet alloc] initWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];
    
    NSMutableSet *recursiveSet = [[NSMutableSet alloc] initWithCapacity:5];
    [recursiveSet addObject:@[@"foo", @"bar"]];
    [recursiveSet addObject:@[@"foo", @"bar"]];
    [recursiveSet addObject:recursiveSet];
    
    NSMutableSet *anotherSet = [[NSMutableSet alloc] initWithCapacity:5];
    
    // Created collections should not be nil
    testassert(subdict != nil);
    testassert(aSet != nil);
    testassert(recursiveSet != nil);
    testassert(anotherSet != nil);
    
    BOOL exception = NO;
    id anObj;
    
    // --------------------------------------------------
    // random path tests
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:nil];
    }
    @catch (NSException *e) {
        NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key (null)."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"lastObject"];
    }
    @catch (NSException *e) {
        NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key lastObject."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@""];
    }
    @catch (NSException *e) {
        NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key ."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"."];
    }
    @catch (NSException *e) {
        NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key ."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@"];
    }
    @catch (NSException *e) {
        NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key ."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"1"];
    }
    @catch (NSException *e) {
        NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key 1."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@1"];
    }
    @catch (NSException *e) {
        NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key 1."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@@@@@@@"];
    }
    @catch (NSException *e) {
        NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key @@@@@@."]);
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
        NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key foo@count."]);
    }
    testassert(exception);
    
    // --------------------------------------------------
    // @max, @min, @avg, @sum
    
    //anObj = [recursiveSet valueForKeyPath:@"@max.count"]; //-- stack overflow in iOS simulator
    //anObj = [recursiveSet valueForKeyPath:@"@min.count"]; //-- ditto
    //anObj = [recursiveSet valueForKeyPath:@"@avg.count"]; //-- ditto
    //anObj = [recursiveSet valueForKeyPath:@"@sum.count"]; //-- ditto
    
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
            @try {
                exception = NO;
                anObj = [aSet valueForKeyPath:[NSString stringWithFormat:@"@%@.description", op]];
            }
            @catch (NSException *e) {
                NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
                exception = YES;
                testassert([[e name] isEqualToString:@"NSDecimalNumberOverflowException"]);
                testassert([[e reason] hasSuffix:@"NSDecimalNumber overflow exception"]);
            }
            testassert(exception);
        }
        else
        {
            anObj = [aSet valueForKeyPath:[NSString stringWithFormat:@"@%@.description", op]];
            testassert(anObj != nil);
            testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
            testassert([[anObj description] isEqual:[[valResults objectAtIndex:j] description]]);
        }
        
        // throw exception with invalid prefix --
        @try {
            exception = NO;
            anObj = [aSet valueForKeyPath:[NSString stringWithFormat:@"foo@%@.description", op]];
        }
        @catch (NSException *e) {
            NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
            NSString *str = [NSString stringWithFormat:@"this class is not key value coding-compliant for the key foo@%@.", op];
            testassert([[e reason] hasSuffix:str]);
        }
        testassert(exception);
        
        // throw exception for no suffix --
        @try {
            exception = NO;
            anObj = [aSet valueForKeyPath:[NSString stringWithFormat:@"@%@", op]];
        }
        @catch (NSException *e) {
            NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
            NSString *str = [NSString stringWithFormat:@"this class is not key value coding-compliant for the key %@.", op];
            testassert([[e reason] hasSuffix:str]);
        }
        testassert(exception);
        
        // throw exception for invalid suffix --
        @try {
            exception = NO;
            anObj = [aSet valueForKeyPath:[NSString stringWithFormat:@"@%@.foobar", op]];
        }
        @catch (NSException *e) {
            NSLog(@"%@ - %@ - %@", [e name], [e reason], [e userInfo]);
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
            NSString *str = [NSString stringWithFormat:@"this class is not key value coding-compliant for the key foobar."];
            testassert([[e reason] hasSuffix:str]);
        }
        testassert(exception);
        
        ++i;
    }
    
    // --------------------------------------------------
    // @unionOfObjects @distinctUnionOfObjects
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@unionOfObjects.intValue"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"this class does not implement the unionOfObjects operation."]);
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
        testassert([[e reason] hasSuffix:@"object cannot be nil"]);
    }
    testassert(exception);
    
    // ---
    [anotherSet removeAllObjects];
    [anotherSet addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", [NSSet setWithObjects:@"subsetobj", @"subsetobj", [NSSet setWithObjects:@"subsubsetobj", nil], nil], nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    NSArray *subAry = [NSArray arrayWithObjects:@[ @"helloset", @"helloset" ], @"helloset", @"helloset", @"arrayobj", nil];
    [anotherSet addObject:subAry];
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
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key distinctUnionOfObjects."]);
    }
    testassert(exception);
    
    // --------------------------------------------------
    // @unionOfArrays @distinctUnionOfArrays
    // NOTE : seems to only work on an NSSet of NSArrays (returns NSArray) --OR-- NSArray of NSArray (returns NSArray)
    
    //anObj = [recursiveSet valueForKeyPath:@"@distinctUnionOfArrays.description"]; //-- stack overflow in iOS simulator
    
    @try {
        exception = NO;
        anObj = [anotherSet valueForKeyPath:@"@unionOfArrays.intValue"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"this class does not implement the unionOfArrays operation."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anotherSet valueForKeyPath:@"@unionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key unionOfArrays."]);
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
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key distinctUnionOfArrays."]);
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
        testassert([[e reason] hasSuffix:@"array argument is not an NSArray"]);
    }
    testassert(exception);
    [anotherSet removeObject:aNumber];

    // --------------------------------------------------
    // @distinctUnionOfSets
    // NOTE : seems to only work on an NSSet of NSSets (returns NSSet) --OR-- NSArray of NSSets (returns NSArray)
    
    [anotherSet removeObject:subAry];
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
        testassert([[e reason] hasSuffix:@"set argument is not an NSSet"]);
    }
    testassert(exception);
    
    // --------------------------------------------------
    
    [anotherSet release];
    [recursiveSet release];
    [subdict release];
    [aSet release];
    
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
