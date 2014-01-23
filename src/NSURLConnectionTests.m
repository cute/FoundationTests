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

test(SSL3TLS1)
{
    NSString *urlStr = [NSString stringWithFormat:@"https://www.google.com"];
    
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

test(SimplePost)
{
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/simplePost", HOST]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:10.0];
    [theRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest setHTTPMethod:@"POST"];
    NSError *err = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&err];
    testassert(data.length > 0);
    testassert(response != nil);
    testassert(err == nil);
    testassert([[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease] isEqualToString:@"Hello World"]);
    return YES;
}

test(PostWithBodyFromData)
{
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/postWithFormBody", HOST]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:10.0];
    [theRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest setHTTPMethod:@"POST"];
    const char *body = "uuid=BFFC8B8B-C0B9-4C87-8AC3-E1B53469B642&happendtime=1390104433&modtime=1390104433&rectime=1390104433&myrefercode=BJZZZv&refereecode=3333";
    [theRequest setHTTPBody:[NSData dataWithBytes:body length:strlen(body)]];
    NSError *err = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&err];
    testassert(data.length > 0);
    testassert(response != nil);
    testassert(err == nil);
    testassert([[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease] isEqualToString:@"{\"uuid\":\"BFFC8B8B-C0B9-4C87-8AC3-E1B53469B642\",\"happendtime\":\"1390104433\",\"modtime\":\"1390104433\",\"rectime\":\"1390104433\",\"myrefercode\":\"BJZZZv\",\"refereecode\":\"3333\"}"]);
    return YES;
}

@end
