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

- (BOOL)testScannerWithStringDefaultConfiguration
{
    NSScanner* scanner = [NSScanner scannerWithString:@""];
    
    testassert(scanner.scanLocation == 0);
    testassert(scanner.caseSensitive == NO);
    testassert([scanner.charactersToBeSkipped isEqual:[NSCharacterSet whitespaceAndNewlineCharacterSet]]);
    testassert(scanner.charactersToBeSkipped == [NSCharacterSet whitespaceAndNewlineCharacterSet]);
    testassert(scanner.locale == nil);
    
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

- (BOOL)testScanCharactersFromSetEmtpy
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

- (BOOL)testScanCharactersFromSetSimple
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"ABBAXYZ"];
    
    NSString* result = nil;
    testassert([scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"ABC"] intoString:&result]);
    testassert([result isEqualToString:@"ABBA"]);
    
    [scanner release];
    
    return YES;
}

- (BOOL)testScanCharactersFromSetSkipping
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@" \n\tABC"];
    
    NSString* result = nil;
    testassert([scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"ABZ"] intoString:&result]);
    testassert([result isEqualToString:@"AB"]);
    
    [scanner release];
    
    return YES;
}

- (BOOL)testScanCharactersFromSetLocation
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"ABCXYZ"];
    scanner.scanLocation = 3;
    
    NSString* result = nil;
    testassert([scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"XYZ"] intoString:&result]);
    testassert([result isEqualToString:@"XYZ"]);
    
    [scanner release];
    
    return YES;
}

@end
