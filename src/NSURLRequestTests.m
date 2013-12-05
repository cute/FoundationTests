#import "FoundationTests.h"

@interface NSURLRequest (internal)
+ (NSTimeInterval)defaultTimeoutInterval;
+ (void)setDefaultTimeoutInterval:(NSTimeInterval)ti;
@end

@testcase(NSURLRequest)

- (BOOL)testSingletonFactoryPattern
{
    testassert([NSURLRequest alloc] != [NSURLRequest alloc]);

    return YES;
}

- (BOOL)testDefaultTimeout
{
    testassert([NSURLRequest defaultTimeoutInterval] == 60.0);
    return YES;
}

- (BOOL)testSetDefaultTimeout
{
    NSTimeInterval ti = [NSURLRequest defaultTimeoutInterval];
    [NSURLRequest setDefaultTimeoutInterval:30.0];

    testassert([NSURLRequest defaultTimeoutInterval] == 30.0);

    [NSURLRequest setDefaultTimeoutInterval:ti]; // restore it for other tests

    return YES;
}


- (BOOL)testDefaultInit
{
    NSURLRequest *request = [[NSURLRequest alloc] init];

    testassert(request != nil);

    testassert([request URL] == nil);

    testassert([request cachePolicy] == NSURLRequestUseProtocolCachePolicy);

    testassert([request timeoutInterval] == 60.0);

    testassert([request mainDocumentURL] == nil);

    testassert([request networkServiceType] == NSURLNetworkServiceTypeDefault);

    testassert([request allowsCellularAccess] == YES);

    testassert([[request HTTPMethod] isEqualToString:@"GET"]);

    testassert([request allHTTPHeaderFields] == nil);

    testassert([request HTTPBody] == nil);

    testassert([request HTTPBodyStream] == nil);

    // radar://15366677
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_7_0
    testassert([request HTTPShouldHandleCookies] == YES);
#elif __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_6_1
    testassert([request HTTPShouldHandleCookies] == YES);
#endif

    testassert([request HTTPShouldUsePipelining] == NO);

    [request release];
    return YES;
}

- (BOOL)testURLConstruction
{
    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

    testassert([[request URL] isEqual:url]);
    testassert([request mainDocumentURL] == nil);

    [request release];

    return YES;
}

- (BOOL)testAdvancedConstruction
{
    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:42.5];

    testassert([request cachePolicy] == NSURLRequestReturnCacheDataElseLoad);

    testassert([request timeoutInterval] == 42.5);

    [request release];
    return YES;
}

- (BOOL)testDefaultMutableInit
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    testassert(request != nil);

    testassert([request URL] == nil);

    testassert([request cachePolicy] == NSURLRequestUseProtocolCachePolicy);

    testassert([request timeoutInterval] == 60.0);

    testassert([request mainDocumentURL] == nil);

    testassert([request networkServiceType] == NSURLNetworkServiceTypeDefault);

    testassert([request allowsCellularAccess] == YES);

    testassert([[request HTTPMethod] isEqualToString:@"GET"]);

    testassert([request allHTTPHeaderFields] == nil);

    testassert([request HTTPBody] == nil);

    testassert([request HTTPBodyStream] == nil);
    // radar://15366677
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_7_0
    testassert([request HTTPShouldHandleCookies] == YES);
#elif __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_6_1
    testassert([request HTTPShouldHandleCookies] == YES);
#endif

    testassert([request HTTPShouldUsePipelining] == NO);

    [request release];
    return YES;
}

- (BOOL)testMutableRequest
{
    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSString *shoes = @"Wearing";
    NSString *mayhem = @("ß!:\n\n\r;;\r\n\r\n\n\n\\\\ \\ '\"\\012345");

    [req setValue:shoes forHTTPHeaderField:@"Shoes"];
    [req setValue:mayhem forHTTPHeaderField:@"Mayhem"]; // This should fail to set
    [req setValue:@"ShoesValue" forHTTPHeaderField:shoes];
    [req setValue:@"MayhemValue" forHTTPHeaderField:mayhem]; // This should set successfully

    NSDictionary *dict =
    @{
        @"Shoes" : shoes,
        shoes: @"ShoesValue",
        mayhem: @"MayhemValue"
    };

    testassert([req.allHTTPHeaderFields isEqual:dict]);

    [req setHTTPMethod:shoes];
    testassert([req.HTTPMethod isEqual:shoes]);
    [req setHTTPMethod:mayhem];
    testassert([req.HTTPMethod isEqual:mayhem]);

    testassert([req.URL isEqual:url]);

    NSData *weirdData = [mayhem dataUsingEncoding:NSUTF8StringEncoding];

    req.HTTPBody = weirdData;

    testassert([req.HTTPBody isEqual:weirdData]);

    return YES;
}

- (BOOL)testAllHeaderFieldsIsCopied
{
    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSDictionary *dict = @{@"foo": @"bar"};
    [req setAllHTTPHeaderFields:dict];
    testassert(dict != [req allHTTPHeaderFields]);
    return YES;
}

- (BOOL)testAllHeaderFieldsIsCFDictionary
{
    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSDictionary *dict = @{@"foo": @"bar"};
    [req setAllHTTPHeaderFields:dict];
    testassert([[req allHTTPHeaderFields] isKindOfClass:[NSMutableDictionary class]]);
    BOOL thrown = NO;
    @try {
        [(NSMutableDictionary *)[req allHTTPHeaderFields] setObject:@"baz" forKey:@"foo"];
    } @catch(NSException *e) {
        thrown = YES;
        testassert([e.name isEqualToString:@"NSInternalInconsistencyException"]);
    }
    testassert(thrown);
    return YES;
}

@end
