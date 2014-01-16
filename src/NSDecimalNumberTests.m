//
//  NSDecimalNumberTests.m
//  FoundationTests
//
//  Created by Paul Beusterien on 10/28/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSDecimalNumber)
#if 0

- (BOOL)testInitWithDecimal1
{
    NSDecimal decimal;
    decimal._mantissa[0] = 65535;
    decimal._mantissa[1] = 65535;
    decimal._mantissa[2] = 65535;
    decimal._mantissa[3] = 65535;
    decimal._mantissa[4] = 65535;
    decimal._mantissa[5] = 65535;
    decimal._mantissa[6] = 65535;
    decimal._mantissa[7] = 65535;
    decimal._exponent = 0;
    decimal._length = NSDecimalMaxSize;
    
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDecimal:decimal];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 8);
    testassert(decimal._isNegative == 1);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    for (int i = 0; i < NSDecimalMaxSize; i++) {
        testassert(decimal._mantissa[i] == 65535);
    }
    
    return YES;
}

- (BOOL)testInitWithMantissa1
{
    NSNumber *number = [[NSDecimalNumber alloc] initWithMantissa:0ULL exponent:0 isNegative:NO];
    NSDecimal decimal = [number decimalValue];
    
    testassert([number isEqual:[NSDecimalNumber zero]]);
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 0);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 0);
    testassert(decimal._reserved == 0);
    for (int i = 0; i < NSDecimalMaxSize; i++) {
        testassert(decimal._mantissa[i] == 0);
    }
    
    return YES;
}

- (BOOL)testInitWithMantissa2
{
    NSNumber *number = [[NSDecimalNumber alloc] initWithMantissa:0ULL exponent:0 isNegative:YES];
    NSDecimal decimal = [number decimalValue];
    
    testassert([number isEqual:[NSDecimalNumber notANumber]]);
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 0);
    testassert(decimal._isNegative == 1);
    testassert(decimal._isCompact == 0);
    testassert(decimal._reserved == 0);
    for (int i = 0; i < NSDecimalMaxSize; i++) {
        testassert(decimal._mantissa[i] == 0);
    }
    
    return YES;
}

- (BOOL)testInitWithMantissa3
{
    NSNumber *number = [[NSDecimalNumber alloc] initWithMantissa:1ULL exponent:0 isNegative:NO];
    NSDecimal decimal = [number decimalValue];
    
    testassert([number isEqual:[NSDecimalNumber one]]);
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 1);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 1);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

- (BOOL)testInitWithMantissa4
{
    NSNumber *number = [[NSDecimalNumber alloc] initWithMantissa:0xffffffff exponent:0x7f isNegative:NO];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 127);
    testassert(decimal._length == 2);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 65535);
    testassert(decimal._mantissa[1] == 65535);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

- (BOOL)testInitWithMantissa5
{
    NSNumber *number = [[NSDecimalNumber alloc] initWithMantissa:0xffffffff exponent:0x7f isNegative:YES];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 127);
    testassert(decimal._length == 2);
    testassert(decimal._isNegative == 1);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 65535);
    testassert(decimal._mantissa[1] == 65535);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

- (BOOL)testInitWithMantissa6
{
    NSNumber *number = [[NSDecimalNumber alloc] initWithMantissa:0x43f0000000000000ULL exponent:0 isNegative:NO];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 17392);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

- (BOOL)testInitWithMantissa7
{
    NSNumber *number = [[NSDecimalNumber alloc] initWithMantissa:0x43f0000000000000ULL exponent:0 isNegative:NO];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 17392);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

- (BOOL)testInitWithMantissa8
{
    NSNumber *number = [[NSDecimalNumber alloc] initWithMantissa:1.8e+146 exponent:0 isNegative:NO];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 65535);
    testassert(decimal._mantissa[1] == 65535);
    testassert(decimal._mantissa[2] == 65535);
    testassert(decimal._mantissa[3] == 65535);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

- (BOOL)testInitWithMantissa9
{
    NSNumber *number = [[NSDecimalNumber alloc] initWithMantissa:1.8e+146 + 1 exponent:0 isNegative:NO];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 65535);
    testassert(decimal._mantissa[1] == 65535);
    testassert(decimal._mantissa[2] == 65535);
    testassert(decimal._mantissa[3] == 65535);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

- (BOOL)testInitWithMantissa10
{
    NSNumber *number = [[NSDecimalNumber alloc] initWithMantissa:0x43e0000000000000 exponent:0 isNegative:NO];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 17392);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

- (BOOL)testNSDecimalNumberRepresentation1
{
    NSDecimal decimal = [[NSDecimalNumber numberWithInt:1] decimalValue];
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 1);
    testassert(decimal._isNegative == NO);
    testassert(decimal._isCompact == YES);
    testassert(decimal._mantissa[0] == 1);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

- (BOOL)testNSDecimalNumberRepresentation2
{
    NSDecimal decimal = [[NSDecimalNumber numberWithInt:(unsigned short)-1] decimalValue];
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 1);
    testassert(decimal._isNegative == NO);
    testassert(decimal._isCompact == YES);
    testassert(decimal._mantissa[0] == 65535);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

- (BOOL)testNSDecimalNumberRepresentation3
{
    NSDecimal decimal = [[NSDecimalNumber numberWithInt:65536] decimalValue];
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 2);
    testassert(decimal._isNegative == NO);
    testassert(decimal._isCompact == YES);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 1);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

- (BOOL)testNSDecimalNumberRepresentation4
{
    NSDecimal decimal = [[NSDecimalNumber numberWithDouble:65536.65535] decimalValue];
    testassert(decimal._exponent == -14);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == NO);
    testassert(decimal._isCompact == YES);
    testassert(decimal._mantissa[0] == 14336);
    testassert(decimal._mantissa[1] == 52837);
    testassert(decimal._mantissa[2] == 19476);
    testassert(decimal._mantissa[3] == 23283);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

- (BOOL)testNSDecimalNumberRepresentation5
{
    unsigned long long max = (unsigned long long)-1;

    NSDecimal decimal = [[NSDecimalNumber numberWithDouble:65536.65536] decimalValue];
    testassert(decimal._exponent == -5);
    testassert(decimal._length == 3);
    testassert(decimal._isNegative == NO);
    testassert(decimal._isCompact == YES);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 34465);
    testassert(decimal._mantissa[2] == 1);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

- (BOOL)testNSDecimalNumberRepresentation6
{
    NSDecimal decimal = [[NSDecimalNumber numberWithDouble:-65536.65536] decimalValue];
    testassert(decimal._exponent == -5);
    testassert(decimal._length == 3);
    testassert(decimal._isNegative == YES);
    testassert(decimal._isCompact == YES);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 34465);
    testassert(decimal._mantissa[2] == 1);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

- (BOOL)testNSDecimalNumberRepresentation7
{
    NSDecimal decimal = [[NSDecimalNumber numberWithDouble:1345.231534661346] decimalValue];
    testassert(decimal._exponent == -16);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == NO);
    testassert(decimal._isCompact == YES);
    testassert(decimal._mantissa[0] == 20480);
    testassert(decimal._mantissa[1] == 51566);
    testassert(decimal._mantissa[2] == 14728);
    testassert(decimal._mantissa[3] == 47792);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);

    return YES;
}

- (BOOL)testNSDecimalNumberRepresentation8
{
    NSDecimal decimal = [[[NSDecimalNumber alloc] initWithMantissa:18446744073709551615ULL exponent:0 isNegative:NO] decimalValue];
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == NO);
    testassert(decimal._isCompact == YES);
    testassert(decimal._mantissa[0] == 65535);
    testassert(decimal._mantissa[1] == 65535);
    testassert(decimal._mantissa[2] == 65535);
    testassert(decimal._mantissa[3] == 65535);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

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

- (BOOL)testDoubleValue1
{
    NSDecimalNumber *n = nil;
    n = [NSDecimalNumber decimalNumberWithString:@"0"];
    testassert([n doubleValue] == 0.0);
    
    return YES;
}

- (BOOL)testDoubleValue2
{
    NSDecimalNumber *n = nil;
    n = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    testassert([n doubleValue] == 0.0);
    
    return YES;
}

- (BOOL)testDoubleValue3
{
    NSDecimalNumber *n = nil;
    n = [NSDecimalNumber decimalNumberWithString:@"-0"];
    testassert([n doubleValue] == +0.0);
    testassert([n doubleValue] == -0.0);
    
    return YES;
}

- (BOOL)testDoubleValue4
{
    NSDecimalNumber *n = nil;
    n = [NSDecimalNumber decimalNumberWithString:@"-0.0"];
    testassert([n doubleValue] == +0.0);
    testassert([n doubleValue] == -0.0);
    
    return YES;
}

- (BOOL)testDoubleValue5
{
    NSDecimalNumber *n = nil;
    n = [NSDecimalNumber decimalNumberWithString:@"0.33"];
    testassert([n doubleValue] != 0.33);
    testassert([n doubleValue] - 0.33 < DBL_MIN);
    
    return YES;
}

- (BOOL)testDoubleValue6
{
    NSDecimalNumber *n = nil;
    n = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%d", USHRT_MAX]];
    testassert([n doubleValue] == (double)USHRT_MAX);
    
    return YES;
}

- (BOOL)testDoubleValue7
{
    NSDecimalNumber *n = nil;
    n = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",(double)USHRT_MAX + 1.0]];
    testassert([n doubleValue] == 1.0 + (double)USHRT_MAX);
    
    return YES;
}

- (BOOL)testDoubleValue8
{
    NSDecimalNumber *n = nil;
    n = [NSDecimalNumber decimalNumberWithString:@"65536"];
    testassert([n doubleValue] == 65536.0);
    
    return YES;
}

- (BOOL)testDoubleValue9
{
    NSDecimalNumber *n = nil;
    n = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%llu", ULLONG_MAX]];
    testassert([n doubleValue] == (double)ULLONG_MAX);
    
    return YES;
}

- (BOOL)testDoubleValue10
{
    NSDecimalNumber *n = nil;
    n = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", 1 + (double)ULLONG_MAX]];
    testassert([n doubleValue] == (double)ULLONG_MAX);
    
    return YES;
}

- (BOOL)testDoubleValue11
{
    NSDecimalNumber *n = nil;
    n = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", 2.0 * (double)ULLONG_MAX]];
    testassert([n doubleValue] == 2.0 * (double)ULLONG_MAX);
    
    return YES;
}

- (BOOL)testDoubleValue12
{
    NSDecimalNumber *n = nil;
    n = [NSDecimalNumber decimalNumberWithString:@"123234623564.12351251345134"];
    testassert([n doubleValue] != 123234623564.1235);
    testassert([n doubleValue] - 123234623564.1235 == 0.000030517578125);
    
    return YES;
}

- (BOOL)testDoubleValue13
{
    NSDecimalNumber *n = nil;
    n = [NSDecimalNumber decimalNumberWithString:@"12345678901234567890123456789012345678"];
    testassert([n doubleValue] == 12345678901234567890123456789012345678.0);
    
    return YES;
}

- (BOOL)testNanEquality
{
    NSDecimal nanDec = [[NSDecimalNumber notANumber] decimalValue];
    NSComparisonResult result = NSDecimalCompare(&nanDec, &nanDec);
    testassert(result == NSOrderedSame);
    return YES;
}

- (BOOL)testNanEquality2
{
    NSDecimal nanDec = [[NSDecimalNumber notANumber] decimalValue];
    NSDecimal nanDec2 = [[NSDecimalNumber notANumber] decimalValue];
    NSComparisonResult result = NSDecimalCompare(&nanDec, &nanDec2);
    testassert(result == NSOrderedSame);
    return YES;
}


- (BOOL)testNanEquality3
{
    NSDecimal nanDec = [[NSDecimalNumber notANumber] decimalValue];
    NSDecimal zeroDec = [[NSDecimalNumber zero] decimalValue];
    NSComparisonResult result = NSDecimalCompare(&nanDec, &zeroDec);
    testassert(result == NSOrderedAscending);
    return YES;
}

- (BOOL)testNanEquality4
{
    NSDecimal nanDec = [[NSDecimalNumber notANumber] decimalValue];
    NSDecimal zeroDec = [[NSDecimalNumber zero] decimalValue];
    NSComparisonResult result = NSDecimalCompare(&zeroDec, &nanDec);
    testassert(result == NSOrderedDescending);
    return YES;
}

- (BOOL)testNanEquality5
{
    NSDecimal nanDec = [[NSDecimalNumber notANumber] decimalValue];
    NSDecimal oneDec = [[NSDecimalNumber one] decimalValue];
    NSComparisonResult result = NSDecimalCompare(&nanDec, &oneDec);
    testassert(result == NSOrderedAscending);
    return YES;
}

- (BOOL)testDecimalNumberDoubleValue
{
    double zero = [[NSDecimalNumber zero] doubleValue];
    testassert(zero == 0.0);
    
    double one = [[NSDecimalNumber one] doubleValue];
    testassert(one == 1.0);
    
    double ten = [[NSDecimalNumber numberWithInt:10] doubleValue];
    testassert(ten == 10.0);
    
    double leet = [[NSDecimalNumber numberWithInt:1337] doubleValue];
    testassert(leet == 1337.0);
    
    double ushortMax = [[NSDecimalNumber numberWithInt:(unsigned short)-1] doubleValue];
    testassert(ushortMax == 65535.0);
    
    double uShortMaxPlusOne = [[NSDecimalNumber numberWithInt:((unsigned short)-1) + 1] doubleValue];
    testassert(uShortMaxPlusOne == 65536.0);
    
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

- (BOOL)testDecimalNumberInitWithCoder
{    
    NSDecimalNumber *number1 = [NSDecimalNumber decimalNumberWithString:@"123"];
    NSData *archive = [NSKeyedArchiver archivedDataWithRootObject:number1];
    NSDecimalNumber *number2 = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
    
    unsigned char expectedArchiveBytes[] = {
        0x62, 0x70, 0x6c, 0x69, 0x73, 0x74, 0x30, 0x30, 0xd4, 0x01, 0x02, 0x03, 0x04, 0x05, 0x08, 0x22, 0x23, 0x54, 0x24, 0x74, 0x6f, 0x70, 0x58, 0x24,
        0x6f, 0x62, 0x6a, 0x65, 0x63, 0x74, 0x73, 0x58, 0x24, 0x76, 0x65, 0x72, 0x73, 0x69, 0x6f, 0x6e, 0x59, 0x24, 0x61, 0x72, 0x63, 0x68, 0x69, 0x76,
        0x65, 0x72, 0xd1, 0x06, 0x07, 0x54, 0x72, 0x6f, 0x6f, 0x74, 0x80, 0x01, 0xa3, 0x09, 0x0a, 0x18, 0x55, 0x24, 0x6e, 0x75, 0x6c, 0x6c, 0xd7, 0x0b,
        0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x14, 0x5b, 0x4e, 0x53, 0x2e, 0x6e, 0x65, 0x67, 0x61, 0x74, 0x69, 0x76,
        0x65, 0x56, 0x24, 0x63, 0x6c, 0x61, 0x73, 0x73, 0x5e, 0x4e, 0x53, 0x2e, 0x6d, 0x61, 0x6e, 0x74, 0x69, 0x73, 0x73, 0x61, 0x2e, 0x62, 0x6f, 0x5a,
        0x4e, 0x53, 0x2e, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0x5b, 0x4e, 0x53, 0x2e, 0x65, 0x78, 0x70, 0x6f, 0x6e, 0x65, 0x6e, 0x74, 0x5b, 0x4e,
        0x53, 0x2e, 0x6d, 0x61, 0x6e, 0x74, 0x69, 0x73, 0x73, 0x61, 0x59, 0x4e, 0x53, 0x2e, 0x6c, 0x65, 0x6e, 0x67, 0x74, 0x68, 0x08, 0x80, 0x02, 0x10,
        0x01, 0x09, 0x10, 0x00, 0x4f, 0x10, 0x10, 0x7b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xd2,
        0x19, 0x1a, 0x1b, 0x21, 0x58, 0x24, 0x63, 0x6c, 0x61, 0x73, 0x73, 0x65, 0x73, 0x5a, 0x24, 0x63, 0x6c, 0x61, 0x73, 0x73, 0x6e, 0x61, 0x6d, 0x65,
        0xa5, 0x1c, 0x1d, 0x1e, 0x1f, 0x20, 0x5f, 0x10, 0x1a, 0x4e, 0x53, 0x44, 0x65, 0x63, 0x69, 0x6d, 0x61, 0x6c, 0x4e, 0x75, 0x6d, 0x62, 0x65, 0x72,
        0x50, 0x6c, 0x61, 0x63, 0x65, 0x68, 0x6f, 0x6c, 0x64, 0x65, 0x72, 0x5f, 0x10, 0x0f, 0x4e, 0x53, 0x44, 0x65, 0x63, 0x69, 0x6d, 0x61, 0x6c, 0x4e,
        0x75, 0x6d, 0x62, 0x65, 0x72, 0x58, 0x4e, 0x53, 0x4e, 0x75, 0x6d, 0x62, 0x65, 0x72, 0x57, 0x4e, 0x53, 0x56, 0x61, 0x6c, 0x75, 0x65, 0x58, 0x4e,
        0x53, 0x4f, 0x62, 0x6a, 0x65, 0x63, 0x74, 0x5f, 0x10, 0x1a, 0x4e, 0x53, 0x44, 0x65, 0x63, 0x69, 0x6d, 0x61, 0x6c, 0x4e, 0x75, 0x6d, 0x62, 0x65,
        0x72, 0x50, 0x6c, 0x61, 0x63, 0x65, 0x68, 0x6f, 0x6c, 0x64, 0x65, 0x72, 0x12, 0x00, 0x01, 0x86, 0xa0, 0x5f, 0x10, 0x0f, 0x4e, 0x53, 0x4b, 0x65,
        0x79, 0x65, 0x64, 0x41, 0x72, 0x63, 0x68, 0x69, 0x76, 0x65, 0x72, 0x00, 0x08, 0x00, 0x11, 0x00, 0x16, 0x00, 0x1f, 0x00, 0x28, 0x00, 0x32, 0x00,
        0x35, 0x00, 0x3a, 0x00, 0x3c, 0x00, 0x40, 0x00, 0x46, 0x00, 0x55, 0x00, 0x61, 0x00, 0x68, 0x00, 0x77, 0x00, 0x82, 0x00, 0x8e, 0x00, 0x9a, 0x00,
        0xa4, 0x00, 0xa5, 0x00, 0xa7, 0x00, 0xa9, 0x00, 0xaa, 0x00, 0xac, 0x00, 0xbf, 0x00, 0xc4, 0x00, 0xcd, 0x00, 0xd8, 0x00, 0xde, 0x00, 0xfb, 0x01,
        0x0d, 0x01, 0x16, 0x01, 0x1e, 0x01, 0x27, 0x01, 0x44, 0x01, 0x49, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x5b
    };
    
    NSData *bytesToCompare = [NSData dataWithBytes:expectedArchiveBytes length:sizeof(expectedArchiveBytes)];
    
    testassert([archive isEqualToData:bytesToCompare]);
    testassert([number1 isEqual:number2]);
    
    return YES;
}

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

- (BOOL)testDecimalNumberCopy
{
    NSDecimal decimalSource = [[NSDecimalNumber numberWithInt:1337] decimalValue];
    NSDecimal decimalDestination;
    NSDecimalCopy(&decimalDestination, &decimalSource);
        
    testassert(decimalDestination._exponent == decimalSource._exponent);
    testassert(decimalDestination._isCompact == decimalSource._isCompact);
    testassert(decimalDestination._isNegative == decimalSource._isNegative);
    testassert(decimalDestination._length == decimalSource._length);

    // _reserved is not copied
    for (int i = 0; i < decimalSource._length; i++) {
        testassert(decimalDestination._mantissa[i] == decimalSource._mantissa[i]);
    }
    
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
#endif
@end
