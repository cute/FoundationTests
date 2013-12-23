#import "FoundationTests.h"
#import "WebServer.h"

@testcase(NSURLConnection)

- (BOOL)testSynchronous
{
    NSString *urlStr = [NSString stringWithFormat:@"http://www.apportable.com"];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    
    testassert([data length] > 0);
    return YES;
}

@end
