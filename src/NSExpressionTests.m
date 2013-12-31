//
//  NSExpressionTests.m
//  FoundationTests
//
//  Created by Philippe Hausler on 12/31/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@interface NSExpression (NSFunctionExpressionInternal)
- (SEL)selector;
- (NSArray *)arguments;
- (id)operand;
@end

@testcase(NSExpression)

- (BOOL)testKeyPathExpression1
{
    NSExpression *exp = [NSExpression expressionForKeyPath:@"foo"];
    testassert(exp != nil);
    testassert([exp selector] == @selector(valueForKey:));
    testassert([[exp operand] isKindOfClass:NSClassFromString(@"NSSelfExpression")]);
    return YES;
}

- (BOOL)testKeyPathExpression2
{
    NSExpression *exp = [NSExpression expressionForKeyPath:@"foo.bar"];
    testassert(exp != nil);
    testassert([exp selector] == @selector(valueForKeyPath:));
    testassert([[exp operand] isKindOfClass:NSClassFromString(@"NSSelfExpression")]);
    return YES;
}

@end
