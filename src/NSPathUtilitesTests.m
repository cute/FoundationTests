#import "FoundationTests.h"

#include "objc/runtime.h"

@testcase(NSPathUtilities)

- (BOOL)testPathExtension
{
    NSString *s = @"abc.xyz";
    testassert([[s pathExtension] isEqualToString:@"xyz"]);
    return YES;
}

- (BOOL)testPathExtensionEmpty
{
    NSString *s = @"abc";
    testassert([[s pathExtension] isEqualToString:@""]);
    return YES;
}


- (BOOL)testPathExtensionEmptyStart
{
    NSString *s = @"";
    testassert([[s pathExtension] isEqualToString:@""]);
    return YES;
}


- (BOOL)testPathExtensionDot
{
    NSString *s = @".";
    testassert([[s pathExtension] isEqualToString:@""]);
    return YES;
}

- (BOOL)testPathExtensionDotEnd
{
    NSString *s = @"abc.";
    testassert([[s pathExtension] isEqualToString:@""]);
    return YES;
}

- (BOOL)testPathExtensionLeadingDot
{
    NSString *s = @".xyz";
    testassert([[s pathExtension] isEqualToString:@""]);
    return YES;
}

- (BOOL)testPathExtensionDouble
{
    NSString *s = @"abc.xyz.uvw";
    testassert([[s pathExtension] isEqualToString:@"uvw"]);
    return YES;
}

- (BOOL)testPathWithComponentsNil
{
    BOOL raised = NO;

    @try {
        [NSString pathWithComponents:nil];
    }
    @catch (NSException *e) {
        raised = [[e name] isEqualToString:NSInvalidArgumentException];
    }

    testassert(raised);

    return YES;
}

- (BOOL)testPathWithComponentsClass
{
    NSString* path = [NSString pathWithComponents:@[@"foo"]];

    testassert([path class] == objc_getClass("NSPathStore2"));

    return YES;
}

- (BOOL)testStringByDeletingLastPathComponentReturnValueType
{
    id path = [@"/foo/bar/baz" stringByDeletingLastPathComponent];
    testassert([path class] == objc_getClass("NSPathStore2"));
    return YES;
}


- (BOOL)testPathWithComponentsEmpty
{
    NSString* path = [NSString pathWithComponents:@[@""]];

    testassert([path isEqualToString:@""]);

    return YES;
}

- (BOOL)testPathWithComponentsSimple
{
    NSString* path = [NSString pathWithComponents:@[@"foo"]];

    testassert([path isEqualToString:@"foo"]);

    return YES;
}

- (BOOL)testPathWithComponentsPair
{
    NSString* path = [NSString pathWithComponents:@[@"foo", @"bar"]];

    testassert([path isEqualToString:@"foo/bar"]);

    return YES;
}

- (BOOL)testPathWithComponentsWacky
{
    NSString* path = [NSString pathWithComponents:@[@"~`!@#%^&*()-_{}[];:\",.<>?/\\|"]];

    testassert([path isEqualToString:@"~`!@#%^&*()-_{}[];:\",.<>?/\\|"]);

    return YES;
}

- (BOOL)testPathWithComponentsSingleSlash
{
    NSString* path = [NSString pathWithComponents:@[@"/"]];

    testassert([path isEqualToString:@"/"]);

    return YES;
}

- (BOOL)testPathWithComponentsDoubleSlash
{
    NSString* path = [NSString pathWithComponents:@[@"/", @"/"]];

    testassert([path isEqualToString:@"/"]);

    return YES;
}

-(BOOL)testPathWithComponetnsTrailingEmpty
{
    NSString* path = [NSString pathWithComponents:@[@"foo", @""]];

    // Apple docs say:
    // "To include a trailing path divider, use an empty string as the last component."
    // they lied.
    testassert([path isEqualToString:@"foo"]);

    return YES;
}

- (BOOL)testPathWithComponentsTrailingSlash
{
    NSString* path = [NSString pathWithComponents:@[@"foo", @"/"]];

    testassert([path isEqualToString:@"foo"]);

    return YES;
}

- (BOOL)testPathWithComponentsSlashComponent
{
    NSString* path = [NSString pathWithComponents:@[@"foo", @"/", @"bar"]];

    testassert([path isEqualToString:@"foo/bar"]);

    return YES;
}

- (BOOL)testPathWithComponentsContainedSeparator
{
    NSString* path = [NSString pathWithComponents:@[@"foo/bar"]];

    testassert([path isEqualToString:@"foo/bar"]);

    return YES;
}

- (BOOL)testPathWithComponentsContainedDoubleSeparator
{
    NSString* path = [NSString pathWithComponents:@[@"foo//bar"]];

    testassert([path isEqualToString:@"foo/bar"]);

    return YES;
}

- (BOOL)testPathWithComponentsContainedTripleSeparator
{
    NSString* path = [NSString pathWithComponents:@[@"foo///bar"]];

    testassert([path isEqualToString:@"foo/bar"]);

    return YES;
}

- (BOOL)testPathWithComponentsContainedLeadingSlash
{
    NSString* path = [NSString pathWithComponents:@[@"/foo"]];

    testassert([path isEqualToString:@"/foo"]);

    return YES;
}

- (BOOL)testPathWithComponentsContainedTerminator
{
    NSString* path = [NSString pathWithComponents:@[@"foo\0bar"]];

    testassert([path isEqualToString:@"foo\0bar"]);

    return YES;
}

- (BOOL)testPathWithComponentsContainedTailingSlash
{
    NSString* path = [NSString pathWithComponents:@[@"foo/"]];

    testassert([path isEqualToString:@"foo"]);

    return YES;
}

- (BOOL)testPathWithComponentsParentDirectory
{
    NSString* path = [NSString pathWithComponents:@[@"/", @"foo", @"..", @"bar"]];

    testassert([path isEqualToString:@"/foo/../bar"]);

    return YES;
}

- (BOOL)testPathWithComponentsCurrentDirectory
{
    NSString* path = [NSString pathWithComponents:@[@"/", @"foo", @".", @"bar"]];

    testassert([path isEqualToString:@"/foo/./bar"]);

    return YES;
}

- (BOOL)testPathWithComponentsParentDirectoryContained
{
    NSString* path = [NSString pathWithComponents:@[@"foo/../bar"]];

    testassert([path isEqualToString:@"foo/../bar"]);

    return YES;
}

- (BOOL)testPathWithComponentsCurrentDirectoryContained
{
    NSString* path = [NSString pathWithComponents:@[@"foo/./bar"]];

    testassert([path isEqualToString:@"foo/./bar"]);

    return YES;
}

- (BOOL)testPathWithComponentsComponentsSplit
{
    NSString* path = [NSString pathWithComponents:@[@"/foo"]];

    BOOL match = [[path pathComponents] isEqualToArray:@[@"/", @"foo"]];

    testassert(match);

    return YES;
}

- (BOOL)testPathWithComponentsComponentsTwin
{
    NSString* path = [NSString pathWithComponents:@[@"foo/bar"]];

    BOOL match = [[path pathComponents] isEqualToArray:@[@"foo", @"bar"]];

    testassert(match);

    return YES;
}

- (BOOL)testStringByAppendingPathExtension1
{
    NSString *str = [@"foo" stringByAppendingPathExtension:@"bar"];
    testassert([str isEqualToString:@"foo.bar"]);
    return YES;
}

- (BOOL)testStringByAppendingPathExtension2
{
    NSString *str = [@"foo." stringByAppendingPathExtension:@"bar"];
    testassert([str isEqualToString:@"foo..bar"]);
    return YES;
}

- (BOOL)testStringByAppendingPathExtension3
{
    NSString *str = [@"foo" stringByAppendingPathExtension:@".bar"];
    testassert([str isEqualToString:@"foo..bar"]);
    return YES;
}

- (BOOL)testStringByAppendingPathExtension4
{
    NSString *str = [@"foo.bar" stringByAppendingPathExtension:@"baz"];
    testassert([str isEqualToString:@"foo.bar.baz"]);
    return YES;
}

- (BOOL)testStringByAppendingPathExtension5
{
    NSString *str = [@"foo.bar" stringByAppendingPathExtension:@"bar"];
    testassert([str isEqualToString:@"foo.bar.bar"]);
    return YES;
}

- (BOOL)testStringByAppendingPathExtensionNil
{
    BOOL thrown = NO;
    @try {
        NSString *str = [@"foo" stringByAppendingPathExtension:nil];
    } @catch (NSException *e) {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        thrown = YES;
    }
    testassert(thrown);
    return YES;
}

- (BOOL)testStringByExpandingTildeInPath1
{
    NSString *str = [@"~/test" stringByExpandingTildeInPath];
    testassert([str isEqualToString:[NSHomeDirectory() stringByAppendingPathComponent:@"test"]]);
    return YES;
}

- (BOOL)testStringByExpandingTildeInPath2
{
    NSString *str = [@"/foo/../~/test" stringByExpandingTildeInPath];
    testassert([str isEqualToString:@"/foo/../~/test"]);
    return YES;
}

@end
