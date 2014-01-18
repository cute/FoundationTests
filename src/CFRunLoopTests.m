#import "FoundationTests.h"

#import <CoreFoundation/CFRunLoop.h>
#import <pthread.h>
#import <libkern/OSAtomic.h>

@testcase(CFRunLoop)

test(GetCurrent)
{
    CFRunLoopRef rl = CFRunLoopGetCurrent();

    // Get current must return the current thread's runloop
    testassert(rl != NULL);

    return YES;
}

test(GetMain)
{
    CFRunLoopRef rl = CFRunLoopGetMain();

    // Get main must return the main thread's runloop
    testassert(rl != NULL);

    return YES;
}


/* These tests are a bit abusive and take some time so they should stay commented out unless you are running them specifically
static int runloopDeallocEvents = 0;

static void *runLoopStart(void *ctx)
{
    DeallocWatcher *watcher = [[DeallocWatcher alloc] initWithBlock:^{
        OSAtomicIncrement32(&runloopDeallocEvents);
    }];
    objc_setAssociatedObject((id)CFRunLoopGetCurrent(), &runloopDeallocEvents, watcher, OBJC_ASSOCIATION_RETAIN);
    [watcher release];
    return NULL;
}

test(CFTLSReleaseCycles)
{
    runloopDeallocEvents = 0;
    for (int i = 0; i < 1025; i++)
    {
        pthread_t t;
        pthread_create(&t, NULL, &runLoopStart, NULL);
        usleep(300);
    }
    sleep(5);
    testassert(runloopDeallocEvents == 1025);
    return YES;
}

static void *runLoopStart2(void *ctx)
{
    [NSRunLoop currentRunLoop];
    return NULL;
}

test(NSTLSReleaseCycles)
{
    for (int i = 0; i < 1025; i++)
    {
        pthread_t t;
        pthread_create(&t, NULL, &runLoopStart2, NULL);
        usleep(100);
    }
    return YES;
}*/

@end
