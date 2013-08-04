#import "FoundationTests.h"

#define ASCII_SAMPLE \
'T','h','i','s',' ','i','s',' ','a',' ', \
's','i','m','p','l','e',' ','A','S','C', \
'I','I',' ','s','t','r','i','n','g',' ', \
'r','a','n','g','i','n','g',' ','f','r', \
'o','m',' ','\1',' ','t','o',' ','\127','.'


// this is the worst possible case of string expansion 13 characters -> 23 bytes
static char *UTF8Sample = "مرحبا العالم"; // hello world
static NSString *UTF8SampleNSString = @"مرحبا العالم";
static NSUInteger UTF8SampleLen = 23;

// Sample strings are mutable to avoid warnings.
static char AsciiSample[] = {ASCII_SAMPLE, 0};
static const NSUInteger AsciiSampleLength = sizeof(AsciiSample) - 1;
static unichar AsciiSampleUnicode[] = {ASCII_SAMPLE};
static const NSUInteger AsciiSampleMaxUnicodeLength = 100;
static const NSUInteger AsciiSampleMaxUTF8Length = 150;

@testcase(NSString)

- (BOOL)testCreationWithNil
{
    void (^block)() = ^{
        [[NSString alloc] initWithString:nil];
    };

    // Creation with nil string is invalid
    BOOL raised = NO;

    @try {
        block();
    }
    @catch (NSException *e) {
        raised = [[e name] isEqualToString:NSInvalidArgumentException];
    }

    testassert(raised);

    return YES;
}

- (BOOL)testCreationWithAscii
{
    // Sample with ascii encoding must not throw
    [NSString stringWithCString:AsciiSample encoding:NSASCIIStringEncoding];

    return YES;
}

- (BOOL)testCreationWithUnicode
{
    // Sample with unicode must not throw
    [NSString stringWithCharacters:AsciiSampleUnicode length:AsciiSampleMaxUnicodeLength];

    return YES;
}

- (BOOL)testDepreciatedCStringCreation1
{
    // Creation with cstring of NULL and zero length must not throw
    [NSString stringWithCString:NULL length:0];

    return YES;
}

- (BOOL)testDepreciatedCStringCreation2
{
    // Creation with cstring of sample must not throw
    [NSString stringWithCString:AsciiSample length:AsciiSampleLength];

    return YES;
}

- (BOOL)testLengths
{
    // TODO

    return YES;
}

- (BOOL)testConstantStrings
{
    const char *s = [UTF8SampleNSString UTF8String];

    // Pointers should be re-used from constant strings
    testassert(strcmp(s, UTF8Sample) == 0);
    NSUInteger len = [UTF8SampleNSString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    testassert(len == UTF8SampleLen);
    for (NSUInteger i = 0; i < len; i++)
    {
        // Bytes at each index must be equal
        testassert(s[i] == UTF8Sample[i]);
    }

    return YES;
}

- (BOOL)runLossyEncodingTest:(NSStringEncoding)encoding
{
    NSString *baseString = @"🄰🄱🄲🄳🄴🄵🄶🄷🄸🄹🄺🄻🄼🄽🄾🄿🅀🅁🅂🅃🅄🅅🅆🅇🅈🅉";

    NSUInteger len = [baseString maximumLengthOfBytesUsingEncoding:encoding];
    char *buf = malloc(len);
    NSUInteger outLen = 0;

    BOOL res = [baseString getBytes:buf maxLength:len usedLength:&outLen encoding:encoding options:NSStringEncodingConversionAllowLossy range:NSMakeRange(0, [baseString length]) remainingRange:NULL];
    testassert(res);
    testassert(outLen > 0);

    NSString *encoded = [[NSString alloc] initWithBytesNoCopy:buf length:outLen encoding:encoding freeWhenDone:YES];
    testassert(encoded != nil);
    [encoded release];

    return YES;
}

- (BOOL)testLossyEncodingNSASCIIStringEncoding
{
    return [self runLossyEncodingTest:NSASCIIStringEncoding];
}

- (BOOL)testLossyEncodingNSNEXTSTEPStringEncoding
{
    return [self runLossyEncodingTest:NSNEXTSTEPStringEncoding];
}

- (BOOL)testLossyEncodingNSUTF8StringEncoding
{
    return [self runLossyEncodingTest:NSUTF8StringEncoding];
}

- (BOOL)testLossyEncodingNSISOLatin1StringEncoding
{
    return [self runLossyEncodingTest:NSISOLatin1StringEncoding];
}

- (BOOL)testLossyEncodingNSNonLossyASCIIStringEncoding
{
    return [self runLossyEncodingTest:NSNonLossyASCIIStringEncoding];
}

- (BOOL)testLossyEncodingNSUnicodeStringEncoding
{
    return [self runLossyEncodingTest:NSUnicodeStringEncoding];
}

- (BOOL)testLossyEncodingNSWindowsCP1252StringEncoding
{
    return [self runLossyEncodingTest:NSWindowsCP1252StringEncoding];
}

- (BOOL)testLossyEncodingNSMacOSRomanStringEncoding
{
    return [self runLossyEncodingTest:NSMacOSRomanStringEncoding];
}

- (BOOL)testLossyEncodingNSUTF16StringEncoding
{
    return [self runLossyEncodingTest:NSUTF16StringEncoding];
}

- (BOOL)testLossyEncodingNSUTF16BigEndianStringEncoding
{
    return [self runLossyEncodingTest:NSUTF16BigEndianStringEncoding];
}

- (BOOL)testLossyEncodingNSUTF16LittleEndianStringEncoding
{
    return [self runLossyEncodingTest:NSUTF16LittleEndianStringEncoding];
}

- (BOOL)testLossyEncodingNSUTF32BigEndianStringEncoding
{
    return [self runLossyEncodingTest:NSUTF32BigEndianStringEncoding];
}

- (BOOL)testLossyEncodingNSUTF32LittleEndianStringEncoding
{
    return [self runLossyEncodingTest:NSUTF32LittleEndianStringEncoding];
}

// these tests should be run when we have a icu database for the encodings
#if ICU_DATA

- (BOOL)testLossyEncodingNSJapaneseEUCStringEncoding
{
    return [self runLossyEncodingTest:NSJapaneseEUCStringEncoding];
}

- (BOOL)testLossyEncodingNSSymbolStringEncoding
{
    return [self runLossyEncodingTest:NSSymbolStringEncoding];
}

- (BOOL)testLossyEncodingNSShiftJISStringEncoding
{
    return [self runLossyEncodingTest:NSShiftJISStringEncoding];
}

- (BOOL)testLossyEncodingNSISOLatin2StringEncoding
{
    return [self runLossyEncodingTest:NSISOLatin2StringEncoding];
}

- (BOOL)testLossyEncodingNSWindowsCP1251StringEncoding
{
    return [self runLossyEncodingTest:NSWindowsCP1251StringEncoding];
}

- (BOOL)testLossyEncodingNSWindowsCP1253StringEncoding
{
    return [self runLossyEncodingTest:NSWindowsCP1253StringEncoding];
}

- (BOOL)testLossyEncodingNSWindowsCP1254StringEncoding
{
    return [self runLossyEncodingTest:NSWindowsCP1254StringEncoding];
}

- (BOOL)testLossyEncodingNSWindowsCP1250StringEncoding
{
    return [self runLossyEncodingTest:NSWindowsCP1250StringEncoding];
}

- (BOOL)testLossyEncodingNSISO2022JPStringEncoding
{
    return [self runLossyEncodingTest:NSISO2022JPStringEncoding];
}

#endif

@end

#warning TODO: String tests & cleanup

/*
{
    NSTEST_BEGIN

    NSTEST_EXCEPTION([[NSString alloc] initWithString:Nil],
                     NSInvalidArgumentException, YES,
                     "stringWithString:Nil");
    NSTEST_EXCEPTION([[NSString alloc] initWithString:Nil],
                     NSInvalidArgumentException, YES,
                     "initWithString:Nil");

    NSString* asciiSample =
    [[[NSString allocWithZone:(NSZone*)kCFAllocatorMalloc]
      initWithCString:AsciiSample]
     autorelease];
    TestAsciiString([NSString stringWithString:asciiSample],
                    "stringWithString (ascii)");
    TestAsciiString([[[NSString alloc] initWithString:asciiSample] autorelease],
                    "initWithString (ascii)");

    NSTEST_END
}

// Empty strings.
{
    NSTEST_BEGIN

    TestEmptyString(@"",
                    "@\"\"");

    TestEmptyString((NSString*)CFSTR(""),
                    "CFSTR(\"\")");

    TestEmptyString([NSString string],
                    "string");

    TestEmptyString([NSString stringWithCharacters:NULL length:0],
                    "stringWithCharacters:(NULL)");

    TestEmptyString([NSString stringWithCharacters:EmptyUnicodeSample length:0],
                    "stringWithCharacters:(empty)");

    NSTEST_EXCEPTION([NSString stringWithCString:NULL],
                     NSInvalidArgumentException, YES,
                     "stringWithCString:(NULL)");

    TestEmptyString([NSString stringWithCString:"" length:0],
                    "stringWithCString:(empty)");

    TestEmptyString([NSString stringWithCString:NULL length:0],
                    "stringWithCString:(NULL) length:0");

    TestEmptyString([[[NSString allocWithZone:(NSZone*)kCFAllocatorMalloc] init] autorelease],
                    "(non-standard zone) init");

    //TODO test NULLs and Nils in creation methods.

    NSTEST_END
}

// sort out
{
    NSTEST_BEGIN

    //TODO test all format methods
    TEST_ASSERT((
                 [[NSString stringWithFormat:@"%d %s %@", 1, "two", @"three"]
                  isEqualToString:[NSString stringWithString:@"1 two three"]]),
                "stringWithFormat");

    NSTEST_END
}

// Ascii strings.
{
    NSTEST_BEGIN

    TestAsciiString([NSString stringWithCString:AsciiSample],
                    "stringWithCString");

    TestAsciiString([NSString stringWithCharacters:AsciiSampleUnicode length:AsciiSampleLength],
                    "stringWithCharacters:(ascii)");

    TestAsciiString([NSString stringWithString:[NSString stringWithCString:AsciiSample]],
                    "stringWithString:(ascii)");

    NSTEST_END
}

// Unicode strings.
{
    NSTEST_BEGIN

    TestUnicodeString([NSString stringWithString:
                       [NSString stringWithCString:UnicodeSampleUTF8 encoding:NSUTF8StringEncoding]],
                      "stringWithString");

    TestUnicodeString([NSString stringWithCString:UnicodeSampleUTF8 encoding:NSUTF8StringEncoding],
                      "stringCString:(unicode) encoding:(UTF8)");

    TestUnicodeString([NSString stringWithCharacters:UnicodeSample length:UnicodeSampleLength],
                      "stringWithCharacters:(unicode)");

    NSTEST_END
}

// 	rangeOfString
{
    NSTEST_BEGIN

    NSRange range;


    range = [@"I'm gonna drink 'til I reboot!"
             rangeOfString:@" DRInK" options:NSCaseInsensitiveSearch];
    TEST_ASSERT(NSEqualRanges(range, NSMakeRange(9, 6)),
                "rangeOfString:opions:(case insensitive)");

    range = [@"I'm gonna drink 'til I reboot!"
             rangeOfString:@"unrelated" options:NSCaseInsensitiveSearch];
    TEST_ASSERT(NSEqualRanges(range, RangeNotFound),
                "rangeOfString:opions:(case insensitive)");

    NSTEST_END
}

// compare
{
    NSTEST_BEGIN

    TEST_ASSERT([@"test" compare:@"test"] == NSOrderedSame,
                "compare:(equal)");
    TEST_ASSERT([@"test" compare:@"unrelated"] != NSOrderedSame,
                "compare:(not equal)");
    TEST_ASSERT([@"test" compare:@"Test"] == NSOrderedDescending,
                "compare:(ascending)");
    TEST_ASSERT([@"TEst" compare:@"Test"] == NSOrderedAscending,
                "compare:(descending)");

    TEST_ASSERT([@"test" caseInsensitiveCompare:@"tEsT"] == NSOrderedSame,
                "compare:(case insensitive)");

    //TODO all other cases

    NSTEST_END
}

// getLineStart:end:contentsEnd:forRange
{
    NSTEST_BEGIN

    NSString* lines = @"one\rtwo\nthree\r\nfour";

    AssertGetLineStart("getLineStart:(beginning)",
                       lines, NSMakeRange(0, 0), 0, 4, 3);
    AssertGetLineStart("getLineStart:(middle)",
                       lines, NSMakeRange(5, 0), 4, 8, 7);
    AssertGetLineStart("getLineStart:(end)",
                       lines, NSMakeRange(16, 0), 15, 19, 19);

    AssertGetLineStart("getLineStart:(whole)",
                       lines, NSMakeRange(0, 19), 0, 19, 19);

    AssertGetLineStart("getLineStart:(overlapping)",
                       lines, NSMakeRange(6, 3), 4, 15, 13);

    AssertGetLineStart("getLineStart:(CR in CRLF)",
                       lines, NSMakeRange(13, 1), 8, 15, 13);
    AssertGetLineStart("getLineStart:(LF in CRLF)",
                       lines, NSMakeRange(14, 1), 8, 15, 13);

    NSUInteger start;
    NSUInteger lineEnd;
    NSUInteger contentsEnd;

    NSTEST_EXCEPTION(
                     [lines getLineStart:&start end:&lineEnd contentsEnd:&contentsEnd
                                forRange:NSMakeRange(0, [lines length] + 1)],
                     NSRangeException, YES,
                     "getLineStart:range:(invalid length)");
    NSTEST_EXCEPTION(
                     [lines getLineStart:&start end:&lineEnd contentsEnd:&contentsEnd
                                forRange:NSMakeRange([lines length] + 1, 0)],
                     NSRangeException, YES,
                     "getLineStart:range:(invalid location)");
    NSTEST_EXCEPTION(
                     [lines getLineStart:&start end:&lineEnd contentsEnd:&contentsEnd
                                forRange:NSMakeRange([lines length] * 2, [lines length] + 1)],
                     NSRangeException, YES,
                     "getLineStart:range:(invalid location & length)");
    NSTEST_EXCEPTION(
                     [lines getLineStart:&start end:&lineEnd contentsEnd:&contentsEnd
                                forRange:NSMakeRange(NSUIntegerMax / 2, 2)],
                     NSRangeException, YES,
                     "getLineStart:range:(positive overflow)");

#ifndef __APPLE__
    NSTEST_EXCEPTION(
                     [lines getLineStart:&start end:&lineEnd contentsEnd:&contentsEnd
                                forRange:NSMakeRange(NSUIntegerMax - 1, 2)],
                     NSRangeException, YES,
                     "getLineStart:range:(negative overflow)");
#endif

    NSTEST_END
}

// lowercaseString
{
    NSTEST_BEGIN

    TEST_ASSERT([[@"aBC" lowercaseString] isEqualToString:@"abc"],
                "lowercaseString");

    TEST_ASSERT([[@"abc" lowercaseString] isEqualToString:@"abc"],
                "lowercaseString (lowercased)");

    TEST_ASSERT([[@"" lowercaseString] isEqualToString:@""],
                "lowercaseString (empty)");

#ifndef __APPLE__
    TEST_ASSERT(![[@"abc" lowercaseString] isKindOfClass:[NSMutableString class]],
                "lowercaseString returns immutable string");
#endif

    NSTEST_END
}

// uppercaseString
{
    NSTEST_BEGIN

    TEST_ASSERT([[@"aBc" uppercaseString] isEqualToString:@"ABC"],
                "uppercaseString");

    TEST_ASSERT([[@"ABC" uppercaseString] isEqualToString:@"ABC"],
                "uppercaseString (uppercased)");

    TEST_ASSERT([[@"" uppercaseString] isEqualToString:@""],
                "uppercaseString (empty)");

#ifndef __APPLE__
    TEST_ASSERT(![[@"abc" uppercaseString] isKindOfClass:[NSMutableString class]],
                "uppercaseString returns immutable string");
#endif

    NSTEST_END
}

// capitalizeString
{
    NSTEST_BEGIN

    TEST_ASSERT([[@"tEst" capitalizedString] isEqualToString:@"Test"],
                "capitalizedString (one word)");

    TEST_ASSERT([[@"a" capitalizedString] isEqualToString:@"A"],
                "capitalizedString (one letter)");

    TEST_ASSERT([[@"one t\tthree\nf\rfive\r\ns\n" capitalizedString]
                 isEqualToString:@"One T\tThree\nF\rFive\r\nS\n"],
                "capitalizedString (sentense)");

    TEST_ASSERT([[@" one\n t\r\tthree\r\n\nf \rfive\t\r\ns\n " capitalizedString]
                 isEqualToString:@" One\n T\r\tThree\r\n\nF \rFive\t\r\nS\n "],
                "capitalizedString (sentense with double separators)");

    TEST_ASSERT([[@"Test" capitalizedString] isEqualToString:@"Test"],
                "capitalizedString (capitalized)");

#ifndef __APPLE__
    TEST_ASSERT(![[@"test" capitalizedString] isKindOfClass:[NSMutableString class]],
                "capitalizedString returns immutable string");
#endif

    NSTEST_END
}

// stringByAppendingFormat
{
    NSTEST_BEGIN

    TEST_ASSERT([[@"test" stringByAppendingFormat:@""] isEqualToString:@"test"],
                "stringByAppendingFormat (empty)");

    TEST_ASSERT(([[@"safe code: " stringByAppendingFormat:@"%s, %@, %1$s", "one", @"two"]
                  isEqualToString:@"safe code: one, two, one"]),
                "stringByAppendingFormat (format)");

    NSTEST_EXCEPTION([@"test" stringByAppendingFormat:Nil],
                     NSInvalidArgumentException, YES,
                     "stringByAppendingFormat (Nil)");

#ifndef __APPLE__
    TEST_ASSERT(![[@"test" stringByAppendingFormat:@""] isKindOfClass:[NSMutableString class]],
                "stringByAppendingFormat returns immutable string");
#endif

    NSTEST_END
}

// canBeConvertedToEncoding
{
    NSTEST_BEGIN

    TEST_ASSERT([@"test" canBeConvertedToEncoding:NSASCIIStringEncoding],
                "canBeConvertedToEncoding (ASCII)");
    TEST_ASSERT([@"test" canBeConvertedToEncoding:NSNEXTSTEPStringEncoding],
                "canBeConvertedToEncoding (NEXTSTEP)");

    TEST_ASSERT(![@"test" canBeConvertedToEncoding:-100],
                "canBeConvertedToEncoding (invalid)");

    unichar uchars[] = {
        'A', 'P', 'P', 'L', 'E',
        ' ',
        0xF8FF, // Apple logo
    };
    NSString* ustring = [NSString stringWithCharacters:uchars
                                                length:(sizeof(uchars) / sizeof(*uchars))];

    TEST_ASSERT(![ustring canBeConvertedToEncoding:NSASCIIStringEncoding],
                "canBeConvertedToEncoding (unicode -> ASCII)");
    TEST_ASSERT(![ustring canBeConvertedToEncoding:NSISOLatin1StringEncoding],
                "canBeConvertedToEncoding (unicode -> ISOLatin1)");
    TEST_ASSERT([ustring canBeConvertedToEncoding:NSMacOSRomanStringEncoding],
                "canBeConvertedToEncoding (unicode -> MacOSRoman)");
    TEST_ASSERT([ustring canBeConvertedToEncoding:NSUnicodeStringEncoding],
                "canBeConvertedToEncoding (unicode -> Unicode)");

    //TODO empty strings - should convert to any encoding

    NSTEST_END
}
*/
