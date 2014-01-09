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
    ConnectionDelegate *delegate = [[[ConnectionDelegate alloc] init] autorelease];
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

- (BOOL)testHamletRaw
{
    ConnectionDelegate *delegate = [[[ConnectionDelegate alloc] init] autorelease];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/hamletInTheRaw", HOST]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    [connection start];
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:TIMEOUT];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
    } while (!delegate.done);
    
    testassert(delegate.done == YES);
    testassert(delegate.error == nil);
    
    NSString *hamlet = [[[NSString alloc] initWithData:[delegate resultData] encoding:NSUTF8StringEncoding] autorelease];
    
    testassert([hamlet length] == 193080);
    NSString *thouArtSlain = [hamlet substringWithRange:NSMakeRange(188534, 14)];
    
    testassert([thouArtSlain isEqualToString:@"thou art slain"]);
    return YES;
}

- (BOOL)testHamletRawWithDelay
{
    ConnectionDelegate *delegate = [[[ConnectionDelegate alloc] init] autorelease];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/hamletInTheRawWithKeepAliveAndDelay", HOST]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    [connection start];
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:TIMEOUT];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
    } while (!delegate.done);
    
    testassert(delegate.done == YES);
    testassert(delegate.error == nil);
    
    NSString *hamlet = [[[NSString alloc] initWithData:[delegate resultData] encoding:NSUTF8StringEncoding] autorelease];
    
    testassert([hamlet length] == 193080);
    NSString *thouArtSlain = [hamlet substringWithRange:NSMakeRange(188534, 14)];
    
    testassert([thouArtSlain isEqualToString:@"thou art slain"]);
    return YES;
}

- (BOOL)testHamletGzipped
{
    ConnectionDelegate *delegate = [[[ConnectionDelegate alloc] init] autorelease];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/gzipHeaderCompressedHamlet", HOST]];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    [connection start];
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:TIMEOUT];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
    } while (!delegate.done);
    
    testassert(delegate.done == YES);
    testassert(delegate.error == nil);
    
    NSString *hamlet = [[[NSString alloc] initWithData:[delegate resultData] encoding:NSUTF8StringEncoding] autorelease];
    
    testassert([hamlet length] == 193080);
    NSString *thouArtSlain = [hamlet substringWithRange:NSMakeRange(188534, 14)];
    
    testassert([thouArtSlain isEqualToString:@"thou art slain"]);
    return YES;
}

- (BOOL)testHamletGzipped2
{
    ConnectionDelegate *delegate = [[[ConnectionDelegate alloc] init] autorelease];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/gzipHeaderCompressedHamletWithKeepAliveAndDelay", HOST]];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    [connection start];
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:TIMEOUT];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
    } while (!delegate.done);
    
    testassert(delegate.done == YES);
    testassert(delegate.error == nil);
    
    NSString *hamlet = [[[NSString alloc] initWithData:[delegate resultData] encoding:NSUTF8StringEncoding] autorelease];
    
    testassert([hamlet length] == 193080);
    NSString *thouArtSlain = [hamlet substringWithRange:NSMakeRange(188534, 14)];
    
    testassert([thouArtSlain isEqualToString:@"thou art slain"]);
    return YES;
}

- (BOOL)testGZipDecodeFail
{
    ConnectionDelegate *delegate = [[[ConnectionDelegate alloc] init] autorelease];
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
