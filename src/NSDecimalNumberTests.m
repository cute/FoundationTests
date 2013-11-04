//
//  NSDecimalNumberTests.m
//  FoundationTests
//
//  Created by Paul Beusterien on 10/28/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSDecimalNumber)

- (BOOL)testObjCType
{
    NSDecimalNumber *n = [NSDecimalNumber decimalNumberWithString:@"1.99"];
    testassert(strcmp([n objCType], "d") == 0);
    return YES;
}

- (BOOL)test_cfNumberType
{
    NSDecimalNumber *n = [NSDecimalNumber decimalNumberWithString:@"1.99"];
    testassert([n _cfNumberType] == kCFNumberDoubleType);
    return YES;
}

- (BOOL)testDecimalNumberDoubleValue
{
    NSDecimalNumber *dn = [NSDecimalNumber decimalNumberWithString:@"1.99"];
    double d = [dn doubleValue];
    testassert(d >= 1.98999 && d <= 1.990001);
    return YES;
}
//
//- (BOOL)testDecimalNumberGetValueForType
//{
//    NSDecimalNumber *dn = [NSDecimalNumber decimalNumberWithString:@"1.99"];
//    double d;
//    [dn _getValue:&d forType:@encode(double)];
//    testassert(d >= 1.98999 && d <= 1.990001);
//    return YES;
//}

- (BOOL)testDecimalNumberInitWithDecimal
{
    NSDecimalNumber *dn = [NSDecimalNumber decimalNumberWithString:@"1.99"];
    NSDecimal dv = [dn decimalValue];
    NSDecimalNumber *dn2 = [[NSDecimalNumber alloc] initWithDecimal:dv];
    double d = [dn2 doubleValue];
    [dn2 release];
    testassert(d >= 1.98999 && d <= 1.990001);
    return YES;
}

- (BOOL)testDecimalNumberGetValueForDecimal
{
    NSDecimalNumber *dn = [NSDecimalNumber decimalNumberWithString:@"1.99"];
    NSDecimal decimal = [dn decimalValue];
    decimal._mantissa[0] = 33;
    decimal._isNegative = YES;
    NSDecimalNumber *dn2 = [NSDecimalNumber decimalNumberWithDecimal:decimal];
    double d = [dn2 doubleValue];
    testassert(d >= -0.330001 && d <= -0.32999);
    return YES;
}

- (BOOL)testDecimalNumberZeroOne
{
    NSDecimalNumber *one = [NSDecimalNumber one];
    NSDecimalNumber *zero = [NSDecimalNumber zero];
    NSDecimal decimal1 = [one decimalValue];
    NSDecimal decimal0 = [zero decimalValue];
    testassert(decimal1._mantissa[0] == 1);
    testassert(decimal0._mantissa[0] == 0);
    return YES;
}

@end
