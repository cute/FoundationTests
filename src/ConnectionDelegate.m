//
//  ConnectionDelegate.m
//  FoundationTests
//
//  Created by Sean on 12/30/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "ConnectionDelegate.h"


@implementation ConnectionDelegate

- (id)init
{
    self = [super init];
    if (self) {
        _resultData = [[NSMutableData alloc] init];
        _didRedirect = YES;
        _done = NO;
        _error = nil;
    }
    return self;
}

- (void)dealloc
{
    [_resultData release];
    [super dealloc];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (![[[connection originalRequest] URL] isEqual:[response URL]])
    {
        _didRedirect = YES;
    }
    [_resultData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_resultData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _error = [error copy];
    _done = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    _done = YES;
}

@end
