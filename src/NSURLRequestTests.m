#import "FoundationTests.h"

@testcase(NSURLRequest)

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

@end
