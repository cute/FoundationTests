//
//  NSPredicateTests.m
//  FoundationTests
//
//  Created by Philippe Hausler on 1/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSPredicateTests)

- (BOOL)testBlockPredicateEvaluation
{
    __block BOOL blockExecuted = NO;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"foo", @"bar", nil];
    Class cls = [dict class];
    NSPredicate *blockPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        testassert(bindings == dict);
        testassert([bindings class] == cls);
        [(NSMutableDictionary *)bindings setObject:@"test" forKey:@"test"];
        blockExecuted = YES;
        return YES;
    }];
    testassert(blockPredicate != nil);
    
    BOOL evaluated = [blockPredicate evaluateWithObject:@"foo" substitutionVariables:dict];
    testassert(evaluated);
    testassert(blockExecuted);
    testassert([dict count] == 2);
    return YES;
}

@end
