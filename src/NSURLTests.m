#import "FoundationTests.h"

@testcase(NSURL)

- (BOOL)testStandardizedURL
{
    NSURL *url = [[NSURL alloc] initWithString:@"base://foo/bar/../bar/./././/baz"];
    [url standardizedURL];

    return YES;
}

- (BOOL)testURLdescription
{
    NSURL *url = [[NSURL alloc] initWithString:@"basestring" relativeToURL:[NSURL URLWithString:@"relative://url"]];
    NSString *expected = @"basestring -- relative://url";
    [[url description] isEqualToString:expected];

    return YES;
}

@end
