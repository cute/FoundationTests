#import "FoundationTests.h"
#import "WebServer.h"
#import "ConnectionDelegate.h"

#define HOST @"http://apportableplayground.herokuapp.com"
#define TIMEOUT 5

@testcase(NSURLConnection)

test(Synchronous)
{
    NSString *urlStr = [NSString stringWithFormat:@"http://www.apportable.com"];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    
    testassert([data length] > 0);
    return YES;
}

test(SynchronousHTTPS)
{
    NSString *urlStr = [NSString stringWithFormat:@"https://apportableplayground.herokuapp.com/hamletInTheRaw"];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    NSString *hamlet = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    testassert([hamlet length] == 193080);
    testassert([hamlet hash] == 2475820992u);
    NSString *thouArtSlain = [hamlet substringWithRange:NSMakeRange(188534, 14)];
    
    testassert([thouArtSlain isEqualToString:@"thou art slain"]);
    return YES;
}

test(GZip)
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

/* This test is a bit abusive and takes some time so it should stay commented out unless you want to test is outright
test(LargeNumberofRequestsInSuccession)
{

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://apportableplayground.herokuapp.com/hamletInTheRaw"]];

    for(int i = 0; i < 1030; i++)
    {
        @autoreleasepool {
            ConnectionDelegate *delegate = [[[ConnectionDelegate alloc] init] autorelease];
            NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:5];
            NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
            [connection start];
            do {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
            } while (!delegate.done);
        }
    }
    return YES;
}*/

test(HamletRaw)
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
    testassert([hamlet hash] == 2475820992u);
    NSString *thouArtSlain = [hamlet substringWithRange:NSMakeRange(188534, 14)];
    
    testassert([thouArtSlain isEqualToString:@"thou art slain"]);
    return YES;
}

test(HamletRawWithDelay)
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
    testassert([hamlet hash] == 2475820992u);
    NSString *thouArtSlain = [hamlet substringWithRange:NSMakeRange(188534, 14)];
    
    testassert([thouArtSlain isEqualToString:@"thou art slain"]);
    return YES;
}

test(HamletGzipped)
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
    testassert([hamlet hash] == 2475820992u);
    NSString *thouArtSlain = [hamlet substringWithRange:NSMakeRange(188534, 14)];
    
    testassert([thouArtSlain isEqualToString:@"thou art slain"]);
    return YES;
}

test(HamletGzipped2)
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
    testassert([hamlet hash] == 2475820992u);
    NSString *thouArtSlain = [hamlet substringWithRange:NSMakeRange(188534, 14)];
    
    testassert([thouArtSlain isEqualToString:@"thou art slain"]);
    return YES;
}

test(GZipDecodeFail)
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
