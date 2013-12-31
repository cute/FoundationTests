#import "FoundationTests.h"
#import "WebServer.h"
#import "ConnectionDelegate.h"

#define HOST @"http://apportableplayground.herokuapp.com"
#define TIMEOUT 5

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

- (BOOL)testGZip
{
    ConnectionDelegate *delegate = [[ConnectionDelegate alloc] init];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/gzipHeaderCompressed", HOST]];
    NSMutableURLRequest* request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    [connection start];
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:TIMEOUT];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
    } while (!delegate.done);

    NSData *expectedData = [@"Hello World" dataUsingEncoding:NSUTF8StringEncoding];
    testassert(delegate.done == YES);
    testassert(delegate.error == nil);
    testassert([delegate.resultData isEqualToData:expectedData]);
    return YES;
}

- (BOOL)testGZipDecodeFail
{
    ConnectionDelegate *delegate = [[ConnectionDelegate alloc] init];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/gzipHeaderUnCompressed", HOST]];
    NSMutableURLRequest* request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    [connection start];
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:TIMEOUT];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
    } while (!delegate.done);

    testassert(delegate.done == YES);
    testassert(delegate.error != nil);
    testassert(delegate.error.code == -1015);
    testassert(delegate.resultData.length == 0);
    return YES;
}

@end
