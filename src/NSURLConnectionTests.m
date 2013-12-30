#import "FoundationTests.h"
#import "WebServer.h"
#import "ConnectionDelegate.h"

#define HOST @"http://apportableplayground.herokuapp.com"

@testcase(NSURLConnection)

- (BOOL)testSynchronous
{
    NSString *urlStr = [NSString stringWithFormat:@"http://%@/website.html", [WebServer.shared hostnameString]];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    
    NSData *otherData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"website" ofType:@"html"]];
    
    return [data isEqualToData:otherData];
}

- (BOOL)testGZip
{
    ConnectionDelegate *delegate = [[ConnectionDelegate alloc] init];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/gzipHeaderCompressed", HOST]];
    NSMutableURLRequest* request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    [connection start];
    while (dispatch_semaphore_wait(delegate.semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    dispatch_release(delegate.semaphore);
    testassert(delegate.error == nil);
    testassert(delegate.resultData.length > 0);
    return YES;
}

@end
