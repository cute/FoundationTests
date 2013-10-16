#import "FoundationTests.h"
#import "WebServer.h"

@testcase(NSURLConnection)

- (BOOL)testSynchronous
{
    APPORTABLE_KNOWN_CRASHER();
    NSString *urlStr = [NSString stringWithFormat:@"http://%@/website.html", [WebServer.shared hostnameString]];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    
    NSData *otherData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"website" ofType:@"html"]];
    
    return [data isEqualToData:otherData];
}

@end
