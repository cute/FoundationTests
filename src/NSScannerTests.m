#import "FoundationTests.h"

#include "objc/runtime.h"

@testcase(NSScanner)

- (BOOL)testScannerWithStringNil
{
    NSScanner* scanner = [NSScanner scannerWithString:nil];
    
    testassert([scanner.string isEqualToString:@""]);
    
    testassert(scanner.isAtEnd);
    
    return YES;
}

- (BOOL)testScannerWithStringEmpty
{
    NSScanner* scanner = [NSScanner scannerWithString:@""];
    
    testassert([scanner.string isEqualToString:@""]);
    
    int value = -1;
    testassert(![scanner scanInt:&value]);
    testassert(value == -1);
    
    return YES;
}

- (BOOL)testScannerWithStringSpaces
{
    NSScanner* scanner = [NSScanner scannerWithString:@"    "];
    
    int value = -1;
    testassert(![scanner scanInt:&value]);
    testassert(value == -1);
    testassert([scanner scanLocation] == 0);
    
    return YES;
}

- (BOOL)testScannerIsAtEnd
{
    NSScanner* scanner = [NSScanner scannerWithString:@"ABC"];
    testassert(![scanner isAtEnd]);
    scanner.scanLocation = 3;
    testassert([scanner isAtEnd]);
    
    scanner = [NSScanner scannerWithString:@"ABC  \n\t"];
    scanner.scanLocation = 3;
    testassert(scanner.isAtEnd);
    testassert(scanner.scanLocation == 3);
    
    return YES;
}

- (BOOL)testScannerWithStringNotEmpty
{
    NSScanner* scanner = [NSScanner scannerWithString:@"123"];
    
    testassert([scanner.string isEqualToString:@"123"]);
    
    int value = -1;
    testassert([scanner scanInt:&value]);
    testassert(value == 123);
    testassert([scanner scanLocation] == 3);
    return YES;
}

- (BOOL)testScannerWithStringLeadingSpaces
{
    NSScanner* scanner = [NSScanner scannerWithString:@"  123"];
    
    testassert([scanner.string isEqualToString:@"  123"]);
    
    int value = -1;
    testassert([scanner scanInt:&value]);
    testassert(value == 123);
    testassert([scanner scanLocation] == 5);
    return YES;
}

- (BOOL)testScannerWithStringNegative
{
    NSScanner* scanner = [NSScanner scannerWithString:@"   -123 14"];
    
    testassert([scanner.string isEqualToString:@"   -123 14"]);
    
    int value = -1;
    testassert([scanner scanInt:&value]);
    testassert(value == -123);
    testassert([scanner scanLocation] == 7);
    return YES;
}

- (BOOL)testScannerWithStringOverflow
{
    NSScanner* scanner = [NSScanner scannerWithString:@"12345678901"];
    
    int value = -1;
    testassert([scanner scanInt:&value]);
    testassert(value == INT_MAX);
    testassert([scanner scanLocation] == 11);
    return YES;
}

- (BOOL)testScanInteger
{
    NSScanner* scanner = [NSScanner scannerWithString:@"123"];
    NSInteger value = -1;
    testassert([scanner scanInteger:&value]);
    testassert(value == 123);
    testassert([scanner scanLocation] == 3);
    return YES;
}

- (BOOL)testScannerWithLongLong
{
    NSScanner* scanner = [NSScanner scannerWithString:@"12345678901"];
    
    long long value = -1;
    testassert([scanner scanLongLong:&value]);
    testassert(value == 12345678901);
    testassert([scanner scanLocation] == 11);
    return YES;
}


- (BOOL)testScannerWithNegativeLongLong
{
    NSScanner* scanner = [NSScanner scannerWithString:@"-98712345678901"];
    
    long long value = -1;
    testassert([scanner scanLongLong:&value]);
    testassert(value == -98712345678901);
    testassert([scanner scanLocation] == 15);
    return YES;
}


- (BOOL)testScannerWithSLongLongOverflow
{
    NSScanner* scanner = [NSScanner scannerWithString:@"  -9223372036854775809 "];
    
    long long value = -1;
    testassert([scanner scanLongLong:&value]);
    testassert(value == LONG_LONG_MIN);
    testassert([scanner scanLocation] == 22);
    return YES;
}

- (BOOL)testScanFloat
{
    NSScanner* scanner = [NSScanner scannerWithString:@"123"];
    float value = -1.f;
    testassert([scanner scanFloat:&value]);
    testassert(value == 123.f);
    testassert([scanner scanLocation] == 3);
    return YES;
}

- (BOOL)testScanFloat2
{
    NSScanner* scanner = [NSScanner scannerWithString:@" 123.5000 "];  // terminating binary for equality test
    float value = -1.f;
    testassert([scanner scanFloat:&value]);
    testassert(value == 123.5f);
    testassert([scanner scanLocation] == 9);
    return YES;
}

- (BOOL)testScanDouble
{
    NSScanner* scanner = [NSScanner scannerWithString:@"123"];
    double value = -1.0;
    testassert([scanner scanDouble:&value]);
    testassert(value == 123.0);
    testassert([scanner scanLocation] == 3);
    return YES;
}

- (BOOL)testScanDouble2
{
    NSScanner* scanner = [NSScanner scannerWithString:@" 123.5000 "]; // terminating binary for equality test
    double value = -1.0;
    testassert([scanner scanDouble:&value]);
    testassert(value == 123.5);
    testassert([scanner scanLocation] == 9);
    return YES;
}

- (BOOL)testScannerWithStringDefaultConfiguration
{
    NSScanner* scanner = [NSScanner scannerWithString:@""];
    
    testassert(scanner.scanLocation == 0);
    testassert(scanner.caseSensitive == NO);
    testassert([scanner.charactersToBeSkipped isEqual:[NSCharacterSet whitespaceAndNewlineCharacterSet]]);
    testassert(scanner.charactersToBeSkipped == [NSCharacterSet whitespaceAndNewlineCharacterSet]);
    testassert(scanner.locale == nil);
    testassert([scanner scanLocation] == 0);
    return YES;
}

- (BOOL)testLocalizedScannerWithStringConfiguration
{
    NSScanner* scanner = [NSScanner localizedScannerWithString:@""];
    
    testassert([scanner.locale isEqual:[NSLocale currentLocale]]);
    
    return YES;
}

- (BOOL)testAllocClass
{
    NSScanner* scanner = [NSScanner alloc];
    
    testassert(scanner.class == objc_getClass("NSConcreteScanner"));
    
    [[scanner init] release];
    
    return YES;
}

- (BOOL)testInitWithStringClass
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@""];

    testassert(scanner.class == objc_getClass("NSConcreteScanner"));

    [scanner release];

    return YES;
}

- (BOOL)testScanCharactersFromSetEmpty
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@""];
    
    NSString* result = nil;
    testassert(![scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@""] intoString:&result]);
    testassert(result == nil);
    
    [scanner release];
    
    return YES;
}

- (BOOL)testScanCharactersFromSetNone
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"ABC"];
    
    NSString* result = nil;
    testassert(![scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"XYZ"] intoString:&result]);
    testassert(result == nil);
    
    [scanner release];
    
    return YES;
}

- (BOOL)testCFStringFindCharacterFromSet
{
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"ABC"];
    NSString *s = @"ABBAXYZA";
    CFRange found;
    testassert(CFStringFindCharacterFromSet((CFStringRef)s, (CFCharacterSetRef)charSet, CFRangeMake(0,8 ), 1, &found));
    testassert(found.location == 0 && found.length == 1);
    return YES;
}

- (BOOL)testNSStringRangeOfCharacterFromSet
{
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"ABC"];
    NSString *s = @"ABBAXYZA";
    NSRange found = [s rangeOfCharacterFromSet:[charSet invertedSet] options:1 range:NSMakeRange(0, 8)];
    testassert(found.location == 4 && found.length == 1);
    return YES;
}

- (BOOL)testScanCharactersFromSetSimple
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"ABBABXYZA"];
    
    NSString* result = nil;
    testassert([scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"ABC"] intoString:&result]);
    testassert([result isEqualToString:@"ABBAB"]);
    testassert([scanner scanLocation] == 5);
    
    [scanner release];
    
    return YES;
}

- (BOOL)testScanCharactersFromSetSkipping
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@" \n\tABC"];
    
    NSString* result = nil;
    testassert([scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"ABZ"] intoString:&result]);
    testassert([result isEqualToString:@"AB"]);
    testassert([scanner scanLocation] == 5);
    [scanner release];
    
    return YES;
}

- (BOOL)testNSStringRangeOfCharacterFromSet2
{
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"XYZ"];
    NSString *s = @"ABCXYZ";
    NSRange found = [s rangeOfCharacterFromSet:[charSet invertedSet] options:1 range:NSMakeRange(3, 3)];
    testassert(found.location == NSNotFound && found.length == 0);
    return YES;
}

- (BOOL)testScanCharactersFromSetLocation
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"ABCXYZ"];
    scanner.scanLocation = 3;
    
    NSString* result = nil;
    testassert([scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"XYZ"] intoString:&result]);
    testassert([result isEqualToString:@"XYZ"]);
    testassert([scanner scanLocation] == 6);
    
    [scanner release];
    
    return YES;
}

- (BOOL)testSetScanLocationOverflow
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"ABCXYZ"];
    scanner.scanLocation = 6;
    
    BOOL sawException = NO;
    @try
    {
        scanner.scanLocation = 10;
    }
    @catch(NSException *e)
    {
        sawException = YES;
        testassert([[e name] isEqualToString:@"NSRangeException"]);
    }
    testassert(sawException);
    testassert([scanner scanLocation] == 6);
    [scanner release];
    
    return YES;
}

- (BOOL)testScanCharactersScanUpToCharacters
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"ABCXYZ"];
   
    testassert([scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"CX"] intoString:nil]);
    testassert([scanner scanLocation] == 2);

    testassert(![scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"X"] intoString:nil]);
    testassert([scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"C"] intoString:nil]);
    testassert([scanner scanLocation] == 3);
    
    NSString *newString;
    testassert([scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"Z"] intoString:&newString]);
    testassert([scanner scanLocation] == 5);
    testassert([newString isEqualToString:@"XY"]);
    testassert(![scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"Z"] intoString:&newString]);
    testassert(![scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"ABC"] intoString:&newString]);
    [scanner release];
    
    return YES;
}

- (BOOL)testScanCharactersScanUpToString
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"ABCXYZ"];
    
    testassert([scanner scanUpToString:@"CX" intoString:nil]);
    testassert([scanner scanLocation] == 2);
    
    testassert(![scanner scanString:@"X" intoString:nil]);
    testassert([scanner scanString:@"C" intoString:nil]);
    testassert([scanner scanLocation] == 3);
    
    NSString *newString;
    testassert([scanner scanUpToString:@"Z" intoString:&newString]);
    testassert([scanner scanLocation] == 5);
    testassert([newString isEqualToString:@"XY"]);
    testassert(![scanner scanUpToString:@"Z" intoString:&newString]);
    testassert(![scanner scanString:@"ABC" intoString:&newString]);
    [scanner release];
    
    return YES;
}

- (BOOL)testScanCharactersToBeSkipped
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"AAAABCXYZ"];
    testassert(![scanner scanString:@"BCX" intoString:nil]);
    testassert([scanner scanLocation] == 0);
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"A"]];
    testassert([scanner scanString:@"BCX" intoString:nil]);
    testassert([scanner scanLocation] == 7);
    return YES;
}

- (BOOL)testScanDecimal
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@" 5.67   0 -0 -12 .981"];
    NSDecimal decimal;
    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 567);
    testassert(decimal._exponent == -2);
    testassert([scanner scanLocation] == 5);
    
    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._exponent == 0);
    testassert(decimal._isNegative == 0);
    testassert([scanner scanLocation] == 9);
    
    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._exponent == 0);
    testassert(decimal._isNegative == 0);
    testassert([scanner scanLocation] == 12);
    
    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 12);
    testassert(decimal._exponent == 0);
    testassert(decimal._isNegative == 1);
    testassert([scanner scanLocation] == 16);

    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 981);
    testassert(decimal._exponent == -3);
    testassert(decimal._isNegative == 0);
    testassert([scanner scanLocation] == 21);
    
    return YES;
}



@end
