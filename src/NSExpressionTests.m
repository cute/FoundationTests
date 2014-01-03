//
//  NSExpressionTests.m
//  FoundationTests
//
//  Created by Philippe Hausler on 12/31/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"
#import <CoreLocation/CoreLocation.h>

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
    testassert(thrown);
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
    testassert(thrown);
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
    testassert(thrown);
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
    testassert(thrown);
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

- (BOOL)testStatistics8
{
    NSArray *numbers = @[@1, @2, @3];
    double avg = (1.0 + 2.0 + 3.0) / 3.0;
    double stddev = sqrt(((1 - avg) * (1 - avg) + (2 - avg) * (2 - avg) + (3 - avg) * (3 - avg)) / 3.0);
    NSExpression *expression = [NSExpression expressionForFunction:@"stddev:" arguments:@[[NSExpression expressionForConstantValue:numbers]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(stddev)]);
    return YES;
}

- (BOOL)testBounding1
{
    NSExpression *expression = [NSExpression expressionForFunction:@"ceiling:" arguments:@[[NSExpression expressionForConstantValue:@3.3]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(4)]);
    return YES;
}

- (BOOL)testBounding2
{
    NSExpression *expression = [NSExpression expressionForFunction:@"trunc:" arguments:@[[NSExpression expressionForConstantValue:@3.3]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(3)]);
    return YES;
}

- (BOOL)testBasicArithmetics1
{
    NSExpression *expression = [NSExpression expressionForFunction:@"add:to:" arguments:@[[NSExpression expressionForConstantValue:@1], [NSExpression expressionForConstantValue:@1]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(1 + 1)]);
    return YES;
}

- (BOOL)testBasicArithmetics2
{
    NSExpression *expression = [NSExpression expressionForFunction:@"from:subtract:" arguments:@[[NSExpression expressionForConstantValue:@3], [NSExpression expressionForConstantValue:@1]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(3 - 1)]);
    return YES;
}

- (BOOL)testBasicArithmetics3
{
    NSExpression *expression = [NSExpression expressionForFunction:@"multiply:by:" arguments:@[[NSExpression expressionForConstantValue:@2], [NSExpression expressionForConstantValue:@6]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(2 * 6)]);
    return YES;
}

- (BOOL)testBasicArithmetics4
{
    NSExpression *expression = [NSExpression expressionForFunction:@"divide:by:" arguments:@[[NSExpression expressionForConstantValue:@8], [NSExpression expressionForConstantValue:@2]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(8 / 2)]);
    return YES;
}

- (BOOL)testBasicArithmetics5
{
    NSExpression *expression = [NSExpression expressionForFunction:@"modulus:by:" arguments:@[[NSExpression expressionForConstantValue:@7], [NSExpression expressionForConstantValue:@2]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(7 % 2)]);
    return YES;
}

- (BOOL)testBasicArithmetics6
{
    NSExpression *expression = [NSExpression expressionForFunction:@"abs:" arguments:@[[NSExpression expressionForConstantValue:@(-7)]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(abs(-7))]);
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

- (BOOL)testAdvancedArithmetics4
{
    NSExpression *expression = [NSExpression expressionForFunction:@"floor:" arguments:@[[NSExpression expressionForConstantValue:@3.3]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(3)]);
    return YES;
}

- (BOOL)testAdvancedArithmetics5
{
    NSExpression *expression = [NSExpression expressionForFunction:@"raise:toPower:" arguments:@[[NSExpression expressionForConstantValue:@4], [NSExpression expressionForConstantValue:@3]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(pow(4, 3))]);
    return YES;
}

- (BOOL)testAdvancedArithmetics6
{
    NSExpression *expression = [NSExpression expressionForFunction:@"exp:" arguments:@[[NSExpression expressionForConstantValue:@4]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(exp(4))]);
    return YES;
}

- (BOOL)testDate
{
    NSExpression *expression = [NSExpression expressionForFunction:@"now" arguments:@[]];
    NSDate *now = [NSDate date];
    usleep(100);
    NSDate *then = [expression expressionValueWithObject:nil context:nil];
    usleep(100);
    NSDate *later = [NSDate date];
    testassert([then isKindOfClass:[NSDate class]]);
    testassert([now compare:then] == NSOrderedAscending);
    testassert([then compare:later] == NSOrderedAscending);
    return YES;
    
}

- (BOOL)testRandom
{
    NSExpression *expression = [NSExpression expressionForFunction:@"random" arguments:@[]];
    [expression expressionValueWithObject:nil context:nil]; // lolz sploitz
    srandom(6);
    expression = [NSExpression expressionForFunction:@"random" arguments:@[]];
    NSNumber *n = [expression expressionValueWithObject:nil context:nil];
    testassert([n isEqual:@(0.135438768658787)]);
    return YES;
}

- (BOOL)testRandomn
{
    NSExpression *expression = [NSExpression expressionForFunction:@"randomn:" arguments:@[[NSExpression expressionForConstantValue:@200]]];
    [expression expressionValueWithObject:nil context:nil]; // same exploit as random
    srandom(99885);
    expression = [NSExpression expressionForFunction:@"randomn:" arguments:@[[NSExpression expressionForConstantValue:@200]]];
    NSNumber *n = [expression expressionValueWithObject:nil context:nil];
    testassert([n isEqual:@(15)]);
    return YES;
}


- (BOOL)testRandom2
{
    BOOL thrown = NO;
    @try {
        [NSExpression expressionForFunction:@"random:" arguments:@[[NSExpression expressionForConstantValue:@9]]];
    } @catch (NSException *e) {
        thrown = YES;
        testassert([[e name] isEqualToString:NSInternalInconsistencyException]);
    }
    testassert(thrown);
    return YES;
}

- (BOOL)testBitwiseArithmetics1
{
    NSExpression *expression = [NSExpression expressionForFunction:@"bitwiseAnd:with:" arguments:@[[NSExpression expressionForConstantValue:@4], [NSExpression expressionForConstantValue:@12]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(4 & 12)]);
    return YES;
}

- (BOOL)testBitwiseArithmetics2
{
    NSExpression *expression = [NSExpression expressionForFunction:@"bitwiseOr:with:" arguments:@[[NSExpression expressionForConstantValue:@4], [NSExpression expressionForConstantValue:@3]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(4 | 3)]);
    return YES;
}

- (BOOL)testBitwiseArithmetics3
{
    NSExpression *expression = [NSExpression expressionForFunction:@"bitwiseXor:with:" arguments:@[[NSExpression expressionForConstantValue:@4], [NSExpression expressionForConstantValue:@3]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(4 ^ 3)]);
    return YES;
}

- (BOOL)testBitwiseArithmetics4
{
    NSExpression *expression = [NSExpression expressionForFunction:@"leftshift:by:" arguments:@[[NSExpression expressionForConstantValue:@2], [NSExpression expressionForConstantValue:@3]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(2 << 3)]);
    return YES;
}

- (BOOL)testBitwiseArithmetics5
{
    NSExpression *expression = [NSExpression expressionForFunction:@"rightshift:by:" arguments:@[[NSExpression expressionForConstantValue:@4096], [NSExpression expressionForConstantValue:@1]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(4096 >> 1)]);
    return YES;
}

- (BOOL)testBitwiseArithmetics6
{
    NSExpression *expression = [NSExpression expressionForFunction:@"onesComplement:" arguments:@[[NSExpression expressionForConstantValue:@8]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(~8)]);
    return YES;
}

- (BOOL)testStrings1
{
    NSExpression *expression = [NSExpression expressionForFunction:@"lowercase:" arguments:@[[NSExpression expressionForConstantValue:@"FOO"]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@"foo"]);
    return YES;
}

- (BOOL)testStrings2
{
    NSExpression *expression = [NSExpression expressionForFunction:@"uppercase:" arguments:@[[NSExpression expressionForConstantValue:@"foo"]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@"FOO"]);
    return YES;
}

- (BOOL)testStrings3
{
    NSExpression *expression = [NSExpression expressionForFunction:@"_convertStringToNumber:" arguments:@[[NSExpression expressionForConstantValue:@"112233"]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@112233]);
    return YES;
}

- (BOOL)testDistance
{
    CLLocation *l1 = [[CLLocation alloc] initWithLatitude:5.5 longitude:3.3];
    CLLocation *l2 = [[CLLocation alloc] initWithLatitude:7.7 longitude:2.2];
    NSExpression *expression = [NSExpression expressionForFunction:@"distanceToLocation:fromLocation:" arguments:@[[NSExpression expressionForConstantValue:l1], [NSExpression expressionForConstantValue:l2]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    double distance = [l1 distanceFromLocation:l2];
    testassert([value isEqual:@(distance)]);
    return YES;
}

- (BOOL)testContainerIndex
{
    NSDictionary *container = @{@"foo": @"bar", @"baz" : @"Foo"};
    NSExpression *expression = [NSExpression expressionForFunction:@"objectFrom:withIndex:" arguments:@[[NSExpression expressionForConstantValue:container], [NSExpression expressionForSymbolicString:@"SIZE"]]];
    id value = [expression expressionValueWithObject:nil context:nil];
    testassert([value isEqual:@(2)]);
    return YES;
}

@end
