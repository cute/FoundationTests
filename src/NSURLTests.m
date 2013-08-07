#import "FoundationTests.h"

@testcase(NSURL)

- (BOOL)testStandardizedURL
{
    NSURL *url = [[NSURL alloc] initWithString:@"base://foo/bar/../bar/./././/baz"];
    testassert([[[url standardizedURL] absoluteString] isEqualToString:@"base://foo/bar//baz"]);

    [url release];
    
    return YES;
}

- (BOOL)testURLdescription
{
    NSURL *url = [[NSURL alloc] initWithString:@"basestring" relativeToURL:[NSURL URLWithString:@"relative://url"]];
    NSString *expected = @"basestring -- relative://url";
    testassert([[url description] isEqualToString:expected]);
    [url release];

    return YES;
}

@end
