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

- (BOOL)testDecimalNumber_notANumber
{
    NSDecimalNumber *aNaN = [NSDecimalNumber notANumber];
    testassert(isnan([aNaN doubleValue]) != 0);
    return YES;
}

- (BOOL)testDecimalNumber_notANumber2
{
    NSDecimalNumber *aNAN = [[NSDecimalNumber alloc] initWithDouble:NAN];
    NSDecimalNumber *notANumber = [NSDecimalNumber notANumber];
    
    testassert([aNAN isEqual:notANumber]);

    [aNAN release];
    return YES;
}

- (BOOL)testDecimalNumber_notANumber3a
{
    NSDecimalNumber *notANumber = [NSDecimalNumber notANumber];
    
    NSDecimal dcm = [notANumber decimalValue];
    testassert(dcm._exponent == 0);
    testassert(dcm._length == 0);
    testassert(dcm._isNegative == 1);
    testassert(dcm._isCompact == 0);
    testassert(dcm._reserved == 0);
    for (unsigned int i=0; i<NSDecimalMaxSize; i++)
    {
        testassert(dcm._mantissa[i] == 0);
    }
    
    return YES;
}

- (BOOL)testDecimalNumber_notANumber3b
{
    NSDecimalNumber *notANumber = [NSDecimalNumber notANumber];
    
    NSDecimal dcm = [notANumber decimalValue];
    testassert(dcm._exponent == 0);
    testassert(dcm._length == 0);
    testassert(dcm._isNegative == 1);
    testassert(dcm._isCompact == 0);
    testassert(dcm._reserved == 0);
    uint8_t *ptr = (uint8_t *)&dcm._mantissa;
    for (unsigned int i=0; i<NSDecimalMaxSize; i++)
    {
        testassert(ptr[i] == 0);
    }
    
    return YES;
}

- (BOOL)testDecimalNumber_notANumber4
{
    NSDecimal dcm = { 0 };
    dcm._isNegative = 1;
    
    NSDecimalNumber *constructedNaN = [[NSDecimalNumber alloc] initWithDecimal:dcm];
    testassert([[NSDecimalNumber notANumber] isEqual:constructedNaN]);
    [constructedNaN release];
    
    return YES;
}

- (BOOL)testDecimalNumber_constructedNaN
{
    NSDecimal dcm = { 0 };
    dcm._isNegative = 1;
    
    NSDecimalNumber *constructedNaN = [[NSDecimalNumber alloc] initWithDecimal:dcm];
    testassert(isnan([constructedNaN doubleValue]));
    [constructedNaN release];
    
    return YES;
}

- (BOOL)testDecimalNumber_notANumber_doubleBits
{
    double d = [[NSDecimalNumber notANumber] doubleValue];
    uint8_t *buf = (uint8_t *)&d;
    
    testassert(sizeof(double) == 8);
    
    testassert(buf[0] == 0x0);
    testassert(buf[1] == 0x0);
    testassert(buf[2] == 0x0);
    testassert(buf[3] == 0x0);
    testassert(buf[4] == 0x0);
    testassert(buf[5] == 0x0);
    testassert(buf[6] == 0xf8);
    testassert(buf[7] == 0x7f);
    
    return YES;
}

@end
