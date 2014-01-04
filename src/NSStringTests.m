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

@interface NSString (TestInternal)
- (BOOL)_getCString:(char *)buffer maxLength:(NSUInteger)maxBufferCount encoding:(CFStringEncoding)encoding;
@end

@testcase(NSString)

- (BOOL)testAllocate
{
    NSString *s1 = [NSString alloc];
    NSString *s2 = [NSString alloc];
    
    testassert(s1 == s2);
    
    return YES;
}

- (BOOL)teststringByReplacingOccurrencesOfString
{
    NSString *s = @"abcdefghij+1234+567";
    NSString *s2 = [s stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    testassert([s2 isEqualToString:@"abcdefghij 1234 567"]);
    return YES;
}

- (BOOL)teststringByReplacingPercentEscapesUsingEncoding
{
    NSString *s = @"abcd7";
    NSString *s2 = [s stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    testassert([s2 isEqualToString:s]);
    return YES;
}

- (BOOL)teststringByReplacingPercentEscapesUsingEncodingNil
{
    NSString *s = @"abcdefg%hij+1234+56%7";
    NSString *s2 = [s stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    testassert(s2 == nil);
    return YES;
}

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

- (BOOL)testMutableCreationWithUnicode
{
    // Sample with unicode must not throw
    [NSMutableString stringWithCharacters:AsciiSampleUnicode length:AsciiSampleMaxUnicodeLength];

    return YES;
}

- (BOOL)testMutableCreationWithUnicodeSuccess
{
    // Sample with unicode must not throw
    NSMutableString *aString = [NSMutableString stringWithCharacters:AsciiSampleUnicode length:50];
    testassert(aString != nil);
    testassert([aString isEqualToString:@"This is a simple ASCII string ranging from  to W."]);
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

- (BOOL)testcStringUsingEncoding
{
    NSString *s = @"abcd";
    NSString *s2 = [s substringToIndex:3];
    const char *cString = [s2 cStringUsingEncoding:NSASCIIStringEncoding];
    testassert(cString != NULL);
    testassert(strcmp(cString, "abc") == 0);
    testassert(strlen(cString) == 3);
    return YES;
}


- (BOOL)testcStringUsingEncoding2
{
    NSString *s = @"¡™£¢∞§¶";
    const char *cString = [s cStringUsingEncoding:NSASCIIStringEncoding];
    testassert(cString == NULL);
    return YES;
}


- (BOOL)testcStringUsingEncoding3
{
    NSString *s = @"¡™£¢∞§¶";
    const char *cString = [s cStringUsingEncoding:NSUnicodeStringEncoding];
    testassert(cString != NULL);
    testassert(strlen(cString) == 1);
    return YES;
}


// Fails with XCode 4
- (BOOL)testCFStringGetCStringPtr
{
    NSString *s = @"abcd";
    NSString *s2 = [s substringToIndex:3];
    const char *cString = CFStringGetCStringPtr((CFStringRef)s2, kCFStringEncodingASCII);
    testassert(cString != NULL);
    testassert(strcmp(cString, "abc") == 0);
    return YES;
}

- (BOOL)testCFStringGetCStringPtr2
{
    NSString *s = @"abcd";
    NSString *s2 = [s substringToIndex:3];
    const char *cString = CFStringGetCStringPtr((CFStringRef)s2, kCFStringEncodingInvalidId);
    testassert(cString == NULL);
    return YES;
}

// Fails with XCode 4
- (BOOL)testCFStringGetCStringPtr3
{
    NSString *s = @"abcd";
    NSString *s2 = [s substringToIndex:3];
    const char *cString = CFStringGetCStringPtr((CFStringRef)s2, kCFStringEncodingDOSRussian);
    testassert(cString != NULL);
    testassert(strcmp(cString, "abc") == 0);
    return YES;
}

- (BOOL)testCFStringGetCStringPtr4
{
    NSString *s = @"abcd";
    NSString *s2 = [s substringToIndex:3];
    const char *cString = CFStringGetCStringPtr((CFStringRef)s2, kCFStringEncodingUnicode);
    testassert(cString == NULL);
    return YES;
}

- (BOOL)testCFStringGetCStringPtr5
{
    NSString *s = @"abcd";
    NSString *s2 = [s substringToIndex:3];
    const char *cString = CFStringGetCStringPtr((CFStringRef)s2, kCFStringEncodingUTF32);
    testassert(cString == NULL);
    return YES;
}

// Fails with XCode 4
- (BOOL)testCFStringGetCStringPtr6
{
    CFStringRef s = CFSTR("abc");
    const char *cString = CFStringGetCStringPtr(s, kCFStringEncodingASCII);
    testassert(cString != NULL);
    testassert(strcmp(cString, "abc") == 0);
    return YES;
}

// Fails with XCode 4
- (BOOL)testCFStringGetCStringPtr7
{
    CFStringRef s = CFSTR("a/bc");
    const char *cString = CFStringGetCStringPtr(s, kCFStringEncodingASCII);
    testassert(cString != NULL);
    testassert(strcmp(cString, "a/bc") == 0);
    return YES;
}

- (BOOL)testCFStringGetCString
{
    CFStringRef s = CFSTR("abc");
    char cString[4];
    CFStringGetCString(s, cString, 4, kCFStringEncodingASCII);
    testassert(strcmp(cString, "abc") == 0);
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

- (BOOL)testConstantEquality
{
    testassert(@"foo" != @"bar");
    testassert(@"foo" == @"foo");
    return YES;
}

- (BOOL)testConstantEqualityFromExternal
{
    extern NSString *const externalFoo;
    testassert(externalFoo == @"foo");
    return YES;
}

- (BOOL)testInitAndLength
{
    NSString *s1 = @"abc";
    NSString *s2 = [NSString stringWithUTF8String:"abc"];
    NSString *s3 = [NSString stringWithFormat:@"%c%s", 'a', "bc"];

    testassert([s1 isEqualToString:s2]);
    testassert([s2 isEqualToString:s3]);
    testassert([s1 length] == 3);
    testassert([s2 length] == 3);
    testassert([s3 length] == 3);

    return YES;
}


- (BOOL)testStringWithFormat
{
    NSString *str = @"/abc";
    char *str2 = "~/Documents";
    NSString *out = [NSString stringWithFormat:@"%@%s", str, &str2[1]];
    testassert([out isEqualToString:@"/abc/Documents"]);

    return YES;
}

- (BOOL)testNullCharacters
{
    testassert(([[NSString stringWithFormat:@"%c", '\0'] length] == 0));

    unichar zero = 0;
    NSString *weirdStr = [NSString stringWithCharacters:&zero length:1];

    testassert(weirdStr.length == 1);

    weirdStr = [weirdStr stringByAppendingString:@"123"];

    testassert(weirdStr.length == 4);

    weirdStr = [NSString stringWithFormat:@"%@", weirdStr];

    testassert(weirdStr.length == 4);

    weirdStr = [NSString stringWithFormat:@"%c%@", '\0', weirdStr];

    testassert(weirdStr.length == 4);

    weirdStr = [weirdStr stringByAppendingString:[NSString stringWithCharacters:&zero length:1]];

    testassert(weirdStr.length == 5);

    testassert([weirdStr characterAtIndex:0] == 0);
    testassert([weirdStr characterAtIndex:1] == '1');
    testassert([weirdStr characterAtIndex:2] == '2');
    testassert([weirdStr characterAtIndex:3] == '3');
    testassert([weirdStr characterAtIndex:4] == 0);

    testassert([@"foo\0bar" length] == 7);
    testassert([@"\0foobar" length] == 7);
    testassert([@"foobar\0" length] == 7);

    return YES;
}

- (BOOL)testStringByDeletingLastPathComponent
{
    testassert([[@"" stringByDeletingLastPathComponent] isEqualToString:@""]);
    testassert([[@"/" stringByDeletingLastPathComponent] isEqualToString:@"/"]);
    testassert([[@"a" stringByDeletingLastPathComponent] isEqualToString:@""]);
    testassert([[@"a/" stringByDeletingLastPathComponent] isEqualToString:@""]);
    testassert([[@"b/asdf" stringByDeletingLastPathComponent] isEqualToString:@"b"]);
    testassert([[@"a/b/c" stringByDeletingLastPathComponent] isEqualToString:@"a/b"]);
    testassert([[@"a/b/asldfkjalskjdfasfdasfdlkasdfjasldkjfasdlkjf" stringByDeletingLastPathComponent] isEqualToString:@"a/b"]);
    testassert([[@"a//////b" stringByDeletingLastPathComponent] isEqualToString:@"a"]);
    testassert([[@"a////" stringByDeletingLastPathComponent] isEqualToString:@""]);
    testassert([[@"/a" stringByDeletingLastPathComponent] isEqualToString:@"/"]);
    testassert([[@"/b/c" stringByDeletingLastPathComponent] isEqualToString:@"/b"]);
    return YES;
}


/* stringByDeletingLastPathComponent should get rid of earlier duplicate slashes */

- (BOOL)testStringByDeletingLastPathComponentTODO
{
    testassert([[@"a//b/////c///" stringByDeletingLastPathComponent] isEqualToString:@"a/b"]);
    return YES;
}

- (BOOL)testStringByAppendingPathComponent
{
    testassert([[@"" stringByAppendingPathComponent:@""] isEqualToString:@""]);
    testassert([[@"a" stringByAppendingPathComponent:@""] isEqualToString:@"a"]);
    testassert([[@"a/" stringByAppendingPathComponent:@""] isEqualToString:@"a"]);
    testassert([[@"" stringByAppendingPathComponent:@"b"] isEqualToString:@"b"]);
    testassert([[@"a" stringByAppendingPathComponent:@"b"] isEqualToString:@"a/b"]);
    testassert([[@"a/" stringByAppendingPathComponent:@"b"] isEqualToString:@"a/b"]);
    testassert([[@"a" stringByAppendingPathComponent:@"/b"] isEqualToString:@"a/b"]);
    testassert([[@"a//////" stringByAppendingPathComponent:@"b"] isEqualToString:@"a/b"]);
    testassert([[@"a////" stringByAppendingPathComponent:@"///b"] isEqualToString:@"a/b"]);
    testassert([[@"a" stringByAppendingPathComponent:@"b/"] isEqualToString:@"a/b"]);
    testassert([[@"/" stringByAppendingPathComponent:@""] isEqualToString:@"/"]);
    testassert([[@"/" stringByAppendingPathComponent:@"b"] isEqualToString:@"/b"]);
    testassert([[@"/" stringByAppendingPathComponent:@"/b"] isEqualToString:@"/b"]);
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


- (BOOL) testStringWithString
{
    NSString *s = @"I'm constant";
    NSString *s2 = [NSString stringWithString:s];
    testassert([s isEqualToString:s2]);
    return YES;
}

- (BOOL) testStringWithNullUTF8String
{
    void (^block)() = ^{
        [NSString stringWithUTF8String:NULL];
    };
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

- (BOOL) testStringWithNullUTF8String2
{
    void (^block)() = ^{
        [[NSString alloc] initWithUTF8String:NULL];
    };
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

- (BOOL) testGetCharacters
{
    NSString *s = @"I'm constant";
    NSUInteger length = [s length];
    unichar buffer[length];
    [s getCharacters:buffer];
    testassert(buffer[0] == 'I' && buffer[length - 1] == 't');

    return YES;
}

- (BOOL) testGetCharacters_isNotNilTerminated
{
    NSString *s = @"föo";
    NSUInteger length = [s length];
    testassert(length == 3);
    NSRange range = NSMakeRange(0, length);

    struct {
        unichar buffer[4];
        uint32_t cap;
    } a_struct;

    memset(a_struct.buffer, 0xff, sizeof(a_struct.buffer));
    a_struct.cap = 0x0;

    testassert(sizeof(a_struct.buffer) > length*sizeof(unichar));
    [s getCharacters:a_struct.buffer range:range];
    testassert(a_struct.buffer[3] == 0xffff);

    // test bufover...
    unichar *ptr = a_struct.buffer;
    unsigned int i=0;
    for (; *ptr != '\0'; ptr++, i++)
    {
        // ...
    }

    testassert(i == sizeof(a_struct.buffer)/sizeof(unichar));

    return YES;
}

- (BOOL) testStringByTrimmingCharactersInSet
{
    NSString *abc = [@"##A#BCD#D##" stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    testassert([abc isEqualToString:@"A#BCD#D"]);

    return YES;
}

- (BOOL) testStringByTrimmingCharactersInSet2
{
    NSString *abc = [@"##A#BCD#D@@" stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#@"]];
    testassert([abc isEqualToString:@"A#BCD#D"]);

    return YES;
}

- (BOOL) testStringByTrimmingCharactersInSet3
{
    NSString *abc = [@"@@" stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#@"]];
    testassert([abc isEqualToString:@""]);

    return YES;
}

- (BOOL) testStringByTrimmingCharactersInSet4
{
    NSString *abc = [@"@123" stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#@"]];
    testassert([abc isEqualToString:@"123"]);

    return YES;
}

- (BOOL) testStringByTrimmingCharactersInSet5
{
    NSString *abc = [@"123#" stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#@"]];
    testassert([abc isEqualToString:@"123"]);

    return YES;
}

- (BOOL) testStringByTrimmingCharactersInSet6
{
    NSString *abc = [@"" stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#@"]];
    testassert([abc isEqualToString:@""]);

    return YES;
}

- (BOOL) testStringByDeletingPathExtension
{
    NSString *abc = [@"abc.xyz" stringByDeletingPathExtension];
    testassert([abc isEqualToString:@"abc"]);
    return YES;
}

- (BOOL) testStringByDeletingPathExtension2
{
    NSString *abc = [@".xyz" stringByDeletingPathExtension];
    testassert([abc isEqualToString:@".xyz"]);
    return YES;
}

- (BOOL) testStringByDeletingPathExtension3
{
    NSString *abc = [@"xyz" stringByDeletingPathExtension];
    testassert([abc isEqualToString:@"xyz"]);
    return YES;
}

- (BOOL) testStringByDeletingPathExtension4
{
    NSString *abc = [@"" stringByDeletingPathExtension];
    testassert([abc isEqualToString:@""]);
    return YES;
}

- (BOOL) testStringByDeletingPathExtension5
{
    NSString *abc = [@"abc..xyz" stringByDeletingPathExtension];
    testassert([abc isEqualToString:@"abc."]);
    return YES;
}

- (BOOL) testStringByStandardizingPath1
{
    NSString *abc = [@"/abc/" stringByStandardizingPath];
    testassert([abc isEqualToString:@"/abc"]);
    return YES;
}

- (BOOL)testStringByStandardizingPath2
{
    NSString *baz = [@"/abc/../bar/../baz" stringByStandardizingPath];
    testassert([baz isEqualToString:@"/baz"]);
    return YES;
}

- (BOOL)testStringByStandardizingPath3
{
    NSString *abc = [@"~/abc/" stringByStandardizingPath];
    testassert([abc isEqualToString:[NSHomeDirectory() stringByAppendingPathComponent:@"abc"]]);
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

- (BOOL)testStringComparisons
{
    NSComparisonResult result = [[NSString stringWithString:@"foo"] compare:nil];
    testassert(result == NSOrderedDescending);

    result = [@"foo" compare:nil];
    testassert(result == NSOrderedDescending);

#warning TODO : this is incomplete ...
    return YES;
}

- (BOOL)testExtraEncodings
{
    NSString *string = @"√∫˜µƒ©˙∆˚¬®†¥¨ˆøπ";
    const char *cstring = [string cStringUsingEncoding:NSASCIIStringEncoding];
    testassert(cstring == NULL);
    
    const char *cstringutf8 = [string cStringUsingEncoding:NSUTF8StringEncoding];
    testassert(cstringutf8 != NULL);
    
    NSString *base64 = @"validbase64=";
    const char *cbase64 = [base64 cStringUsingEncoding:NSASCIIStringEncoding];
    testassert(cbase64 != NULL);
    
    return YES;
}

- (BOOL)testFloatFormat1
{
    NSString *string = [NSString stringWithFormat:@"%g", 2.9f];
    testassert([string isEqualToString:@"2.9"]);
    return YES;
}

- (BOOL)testFloatFormat2
{
    NSString *string = [NSString stringWithFormat:@"%f", 2.9f];
    testassert([string isEqualToString:@"2.900000"]);
    return YES;
}

- (BOOL)testFloatFormat3
{
    CGSize sz = CGSizeMake(1.1f, 2.9f);
    NSString *string = [NSString stringWithFormat:@"%.*g", 8, sz.height];
    testassert([string isEqualToString:@"2.9000001"]);
    return YES;
}

- (BOOL)testFloatFormat4
{
    NSString *string = [NSString stringWithFormat:@"%.*g", 8, 2.9f];
    testassert([string isEqualToString:@"2.9000001"]);
    return YES;
}

- (BOOL)testFloatFormat5
{
    NSString *string = [NSString stringWithFormat:@"%.8g", 2.9f];
    testassert([string isEqualToString:@"2.9000001"]);
    return YES;
}

- (BOOL)testBoolValue
{
    testassert([@"1" boolValue] == YES);
    testassert([@"-1" boolValue] == YES);
    testassert([@"1000000" boolValue] == YES);
    testassert([@"10000000000" boolValue] == YES); // long overflow

    testassert([@"0" boolValue] == NO);
    testassert([@"0000000000000" boolValue] == NO);

    testassert([@"YES" boolValue] == YES);
    testassert([@"YEs" boolValue] == YES);
    testassert([@"true" boolValue] == YES);
    testassert([@"True" boolValue] == YES);

    testassert([@"NO" boolValue] == NO);
    testassert([@"no" boolValue] == NO);
    testassert([@"FALSE" boolValue] == NO);
    testassert([@"faLse" boolValue] == NO);

    testassert([@"" boolValue] == NO);
    testassert([@"apple" boolValue] == NO);

    return YES;
}

- (BOOL)testSimpleConstruction
{
    NSSimpleCString *str = [[NSSimpleCString alloc] initWithCStringNoCopy:strdup("foo") length:3];
    testassert(str != nil);
    testassert([str length] == 3);
    [str release];
    return YES;
}

- (BOOL)testGetCStringMaxBufferCount
{
   NSString *string = @"this is a string with 35 characters";

   char buffer[36];
   testassert([string getCString:buffer maxLength:36 encoding:NSUTF8StringEncoding]);
   testassert(!strcmp(buffer, "this is a string with 35 characters"));

   testassert(![string getCString:buffer maxLength:35 encoding:NSUTF8StringEncoding]);

   // What happens when the initial buffer has more?
   char longer_buff[46];
   strcpy(longer_buff, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
   testassert([string getCString:longer_buff maxLength:36 encoding:NSUTF8StringEncoding]);
   testassert(!strcmp(longer_buff, "this is a string with 35 characters"));

   return YES;
}

- (BOOL)testInternalGetCStringMaxBufferCount
{
    NSString *string = @"this is a string with 35 characters";
    
    char buffer[36];
    testassert([string _getCString:buffer maxLength:35 encoding:kCFStringEncodingUTF8]);
    testassert(!strcmp(buffer, "this is a string with 35 characters"));
    
    testassert(![string _getCString:buffer maxLength:34 encoding:kCFStringEncodingUTF8]);
    
    // What happens when the initial buffer has more?
    char longer_buff[46];
    strcpy(longer_buff, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    testassert([string _getCString:longer_buff maxLength:35 encoding:kCFStringEncodingUTF8]);
    testassert(!strcmp(longer_buff, "this is a string with 35 characters"));

    return YES;
}

- (BOOL)testHasPrefix
{
    NSString *str1 = @"the quick brown fox jumped over the lazy dog";
    NSString *str2 = @"the quick";
    NSString *str3 = @"the dead";
    
    testassert([str1 hasPrefix:str2]);
    testassert(![str1 hasPrefix:str3]);
    testassert(![str2 hasPrefix:str1]);
    testassert(![str3 hasPrefix:str1]);
    
    return YES;
}

#pragma mark -
#pragma mark test [NSString initWithFormat:arguments:]

+ (NSString *)aStringWithFormat:(NSString *)fmt andParameters:(va_list)ap
{
    NSString *str=[[NSString alloc] initWithFormat:fmt arguments:ap];
    return [str autorelease];
}

+ (NSString *)aStringWithFormat:(NSString *)fmt, ...
{
    va_list ap;
    va_start(ap, fmt);
    NSString *str = [[NSString alloc] initWithFormat:fmt arguments:ap];
    va_end(ap);
    return [str autorelease];
}

+ (NSString *)aStringWithFormat2:(NSString *)fmt, ...
{
    va_list ap;
    va_start(ap, fmt);
    NSString *str = [[self class] aStringWithFormat:fmt andParameters:ap];
    va_end(ap);
    return str;
}

- (BOOL)testInitWithFormat1
{
    NSString *str = [[self class] aStringWithFormat:@"a string '%@' and another string '%@'", @"foo", @"bar"];
    testassert([str isEqualToString:@"a string 'foo' and another string 'bar'"]);
    return YES;
}

- (BOOL)testInitWithFormat2
{
    NSString *str = [[self class] aStringWithFormat2:@"a string '%@' and another string '%@'", @"foo", @"bar"];
    testassert([str isEqualToString:@"a string 'foo' and another string 'bar'"]);
    return YES;
}

- (BOOL)testInitWithFormat_fromNSPathStore2
{
    NSString *defaultPngPath = [[NSBundle mainBundle] pathForResource:@"ATestPlist" ofType:@"plist"];
    testassert([defaultPngPath isKindOfClass:NSClassFromString(@"__NSCFString")]);
    defaultPngPath = [defaultPngPath stringByDeletingPathExtension];
    testassert([defaultPngPath isKindOfClass:NSClassFromString(@"NSPathStore2")]);
    
    NSString *str = [[self class] aStringWithFormat2:@"Path file : %@", defaultPngPath];
    
    testassert([[str substringToIndex:12] isEqualToString:@"Path file : "]);
    
    return YES;
}

- (BOOL)testSubstringWithRange
{
    NSString *str = [@"foo-bar-baz" substringWithRange:NSMakeRange(4, 3)];
    testassert([str isEqualToString:@"bar"]);
    return YES;
}

- (BOOL)testIsEqualToStringWithNSPathStore2
{
    NSString *str1 = @"name";
    NSString *str2 = @"name.ttf";
    NSString *str3 = [str2 stringByDeletingPathExtension];
    testassert([str1 isEqualToString:str3]);
    return YES;
}

#pragma mark -

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
