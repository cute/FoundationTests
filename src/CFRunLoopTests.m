#import "FoundationTests.h"

#import <CoreFoundation/CFRunLoop.h>


@testcase(CFRunLoop)

- (BOOL)testGetCurrent
{
    CFRunLoopRef rl = CFRunLoopGetCurrent();

    // Get current must return the current thread's runloop
    testassert(rl != NULL);

    return YES;
}

- (BOOL)testGetMain
{
    CFRunLoopRef rl = CFRunLoopGetMain();

    // Get main must return the main thread's runloop
    testassert(rl != NULL);

    return YES;
}

@end
