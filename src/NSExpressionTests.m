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

- (BOOL)testSimpleMath1
{
    NSExpression *expression = [NSExpression expressionWithFormat:@"1+1"];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(2)]);
    return YES;
}

- (BOOL)testNewLines
{
    NSExpression *expression = [NSExpression expressionWithFormat:@"1\n+1"];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(2)]);
    return YES;
}

- (BOOL)testTabs
{
    NSExpression *expression = [NSExpression expressionWithFormat:@"1\t+1"];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(2)]);
    return YES;
}

- (BOOL)testEscaped
{
    BOOL thrown = NO;
    @try {
        NSExpression *expression = [NSExpression expressionWithFormat:@"1\\n+1"];
        id value = [expression expressionValueWithObject:nil context:nil];
        testassert([value isEqual:@(2)]);
    } @catch (NSException *e) {
        thrown = YES;
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
    }
    return YES;
}

- (BOOL)testSimpleMath2
{
    NSExpression *expression = [NSExpression expressionWithFormat:@"0x4444+0x2222"];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(0x6666)]);
    return YES;
}

- (BOOL)testSimpleMathWithComments1
{
    BOOL thrown = NO;
    @try {
        NSExpression *expression = [NSExpression expressionWithFormat:@"1+1 /* testing a comment */"];
        id value = [expression expressionValueWithObject:nil context:nil];
        testassert([value isEqual:@(2)]);
    } @catch (NSException *e) {
        thrown = YES;
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
    }
    return YES;
}

- (BOOL)testSimpleMathWithComments2
{
    BOOL thrown = NO;
    @try {
        NSExpression *expression = [NSExpression expressionWithFormat:@"1+1 // testing a comment"];
        id value = [expression expressionValueWithObject:nil context:nil];
        testassert([value isEqual:@(2)]);
    } @catch (NSException *e) {
        thrown = YES;
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
    }
    return YES;
}

- (BOOL)testTrigraph
{
    BOOL thrown = NO;
    @try {
        NSExpression *expression = [NSExpression expressionWithFormat:@"1//+1"];
        id value = [expression expressionValueWithObject:nil context:nil];
        testassert([value isEqual:@(2)]);
    } @catch (NSException *e) {
        thrown = YES;
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
    }
    return YES;
}

- (BOOL)testStatistics1
{
    NSArray *numbers = @[@1, @2, @3];
    NSExpression *expression = [NSExpression expressionForFunction:@"sum:" arguments:@[[NSExpression expressionForConstantValue:numbers]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(1 + 2 + 3)]);
    return YES;
}

- (BOOL)testStatistics2
{
    NSArray *numbers = @[@1, @2, @3];
    NSExpression *expression = [NSExpression expressionForFunction:@"count:" arguments:@[[NSExpression expressionForConstantValue:numbers]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(3)]);
    return YES;
}

- (BOOL)testStatistics3
{
    NSArray *numbers = @[@1, @2, @3];
    NSExpression *expression = [NSExpression expressionForFunction:@"average:" arguments:@[[NSExpression expressionForConstantValue:numbers]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@((double)(1 + 2 + 3) / (double)3)]);
    return YES;
}

- (BOOL)testStatistics4
{
    NSArray *numbers = @[@1, @2, @3];
    NSExpression *expression = [NSExpression expressionForFunction:@"min:" arguments:@[[NSExpression expressionForConstantValue:numbers]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(1)]);
    return YES;
}

- (BOOL)testStatistics5
{
    NSArray *numbers = @[@1, @2, @3];
    NSExpression *expression = [NSExpression expressionForFunction:@"max:" arguments:@[[NSExpression expressionForConstantValue:numbers]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(3)]);
    return YES;
}

- (BOOL)testStatistics6
{
    NSArray *numbers = @[@1, @2, @3];
    NSExpression *expression = [NSExpression expressionForFunction:@"median:" arguments:@[[NSExpression expressionForConstantValue:numbers]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(2)]);
    return YES;
}

- (BOOL)testStatistics7
{
    NSArray *numbers = @[@1, @2, @3, @3];
    NSExpression *expression = [NSExpression expressionForFunction:@"mode:" arguments:@[[NSExpression expressionForConstantValue:numbers]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@[@(3)]]);
    return YES;
}

- (BOOL)testAdvancedArithmetics1
{
    NSExpression *expression = [NSExpression expressionForFunction:@"sqrt:" arguments:@[[NSExpression expressionForConstantValue:@9]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(3)]);
    return YES;
}

- (BOOL)testAdvancedArithmetics2
{
    NSExpression *expression = [NSExpression expressionForFunction:@"log:" arguments:@[[NSExpression expressionForConstantValue:@9]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(log10(9))]);
    return YES;
}

- (BOOL)testAdvancedArithmetics3
{
    NSExpression *expression = [NSExpression expressionForFunction:@"ln:" arguments:@[[NSExpression expressionForConstantValue:@9]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(log(9))]);
    return YES;
}

@end
