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

- (BOOL)testPathExtension_forNSPathStore2_1
{
    NSString *path = @"abc";
    
    NSString *subpath = [path stringByDeletingPathExtension];
    testassert([subpath class] == objc_getClass("NSPathStore2"));
    testassert([subpath isEqualToString:@"abc"]);
    
    testassert([[subpath pathExtension] isEqualToString:@""]);
    
    return YES;
}

- (BOOL)testPathExtension_forNSPathStore2_1b
{
    NSString *path = @"a/bc";
    
    NSString *subpath = [path stringByDeletingPathExtension];
    testassert([subpath class] == objc_getClass("NSPathStore2"));
    testassert([subpath isEqualToString:@"a/bc"]);
    
    testassert([[subpath pathExtension] isEqualToString:@""]);
    
    return YES;
}

- (BOOL)testPathExtension_forNSPathStore2_1c
{
    NSString *path = @".abc.xyz";
    
    NSString *subpath = [path stringByDeletingPathExtension];
    testassert([subpath class] == objc_getClass("NSPathStore2"));
    testassert([subpath isEqualToString:@".abc"]);
    
    testassert([[subpath pathExtension] isEqualToString:@""]);
    
    return YES;
}

- (BOOL)testPathExtension_forNSPathStore2_1d
{
    NSString *path = @"1.abc.xyz";
    
    NSString *subpath = [path stringByDeletingPathExtension];
    testassert([subpath class] == objc_getClass("NSPathStore2"));
    testassert([subpath isEqualToString:@"1.abc"]);
    
    testassert([[subpath pathExtension] isEqualToString:@"abc"]);
    
    return YES;
}

- (BOOL)testPathExtension_forNSPathStore2_2
{
    NSString *path = @"abc.xyz.";
    
    NSString *subpath = [path stringByDeletingPathExtension];
    testassert([subpath class] == objc_getClass("NSPathStore2"));
    testassert([subpath isEqualToString:@"abc.xyz"]);
    
    testassert([[subpath stringByDeletingPathExtension] isEqualToString:@"abc"]);
    
    return YES;
}

- (BOOL)testPathExtension_forNSPathStore2_2b
{
    NSString *path = @".abc.xyz";
    
    NSString *subpath = [path stringByDeletingPathExtension];
    testassert([subpath class] == objc_getClass("NSPathStore2"));
    testassert([subpath isEqualToString:@".abc"]);
    
    testassert([[subpath stringByDeletingPathExtension] isEqualToString:@".abc"]);
    
    return YES;
}

- (BOOL)testPathExtension_forNSPathStore2_2c
{
    NSString *path = @"abc.xyz.uvw";
    
    NSString *subpath = [path stringByDeletingPathExtension];
    testassert([subpath class] == objc_getClass("NSPathStore2"));
    testassert([subpath isEqualToString:@"abc.xyz"]);
    
    testassert([[subpath stringByDeletingPathExtension] isEqualToString:@"abc"]);
    
    return YES;
}

- (BOOL)testPathExtension_forNSPathStore2_3
{
    NSString *path = @"abc.xyz.uvw";
    
    NSString *subpath = [path stringByDeletingPathExtension];
    testassert([subpath class] == objc_getClass("NSPathStore2"));
    testassert([subpath isEqualToString:@"abc.xyz"]);
    
    testassert([[subpath pathExtension] isEqualToString:@"xyz"]);
    
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


- (BOOL)testURLFromPathStore
{
    NSString *str = [NSString pathWithComponents:@[@"/", @"foo", @"bar", @"baz"]];
    testassert([str class] == NSClassFromString(@"NSPathStore2"));
    testassert([str isEqualToString:@"/foo/bar/baz"]);
    NSURL *url = [NSURL fileURLWithPath:str];
    testassert(url != nil);
    testassert([url isEqual:[NSURL URLWithString:@"file:///foo/bar/baz"]]);
    return YES;
}

- (BOOL)testStringByDeletingPathExtension1
{
    NSString *str = [@"foo/bar/baz.bar" stringByDeletingPathExtension];
    testassert([str isEqualToString:@"foo/bar/baz"]);
    testassert([str class] == NSClassFromString(@"NSPathStore2"));
    return YES;
}

- (BOOL)testStringByDeletingPathExtension2
{
    NSString *str = [@"foo/bar/baz" stringByDeletingPathExtension];
    testassert([str isEqualToString:@"foo/bar/baz"]);
    return YES;
}

- (BOOL)testStringByDeletingPathExtension3
{
    NSString *str = [@"foo/bar/.baz" stringByDeletingPathExtension];
    testassert([str isEqualToString:@"foo/bar/.baz"]);
    return YES;
}

- (BOOL)testStringByDeletingPathExtension4
{
    NSString *str = [@"foo/bar/." stringByDeletingPathExtension];
    testassert([str isEqualToString:@"foo/bar/."]);
    return YES;
}

- (BOOL)testSubstringWithRange
{
    NSString *str = [[NSString pathWithComponents:@[@"foo", @"bar", @"baz"]] substringWithRange:NSMakeRange(4, 3)];
    testassert([str isEqualToString:@"bar"]);
    return YES;
}

- (BOOL)testNSPathStore2Hash
{
    NSString *path = [NSString pathWithComponents:@[@"/", @"foo", @"bar", @"baz"]];
    testassert([path class] == NSClassFromString(@"NSPathStore2"));
    testassert([path isEqualToString:@"/foo/bar/baz"]);
    
    testassert([path hash] == 2138626127);
    
    return YES;
}

- (BOOL)testNSPathStore2HashComparison
{
    NSString *path = [NSString pathWithComponents:@[@"/", @"foo", @"bar", @"baz"]];
    testassert([path class] == NSClassFromString(@"NSPathStore2"));
    testassert([path isEqualToString:@"/foo/bar/baz"]);
    
    NSString *str = @"/foo/bar/baz";
    
    testassert([path hash] == [str hash]);
    
    return YES;
}

- (BOOL)testNSPathStore2InDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *path = [NSString pathWithComponents:@[@"/", @"foo", @"bar", @"baz"]];
    testassert([path class] == NSClassFromString(@"NSPathStore2"));
    testassert([path isEqualToString:@"/foo/bar/baz"]);
    
    [dict setObject:@"foo" forKey:path];
    
    NSString *str = @"/foo/bar/baz";
    
    testassert([str isEqualToString:path]);
    
    [dict setObject:@"foo" forKey:str];

    testassert([dict count] == 1);
    
    return YES;
}

@end
