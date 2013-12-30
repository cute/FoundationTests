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
        _semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_resultData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _error = error;
    dispatch_semaphore_signal(_semaphore);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    dispatch_semaphore_signal(_semaphore);
}

@end
