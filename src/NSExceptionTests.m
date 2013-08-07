#import "FoundationTests.h"

@testcase(NSException)

- (BOOL)testInitWithNameReasonUserInfo
{
    NSException *e = [[NSException alloc] initWithName:nil reason:nil userInfo:nil];

    testassert(e != nil);

    [e release];

    return YES;
}

- (BOOL)testExceptionWithNameReasonUserInfo
{
    NSException *e = [NSException exceptionWithName:nil reason:nil userInfo:nil];

    testassert(e != nil);

    return YES;
}

- (BOOL)testCopy
{
    NSException *e1 = [NSException exceptionWithName:nil reason:nil userInfo:nil];
    NSException *e2 = [e1 copy];

    // Exceptions are immutable and copies should be the same pointer.
    testassert(e1 == e2);

    [e2 release];

    return YES;
}

- (BOOL)testRaise
{
    NSException *e = [NSException exceptionWithName:nil reason:nil userInfo:nil];
    BOOL raised = NO;

    @try {
        [e raise];
    }
    @catch (NSException *caught) {
        raised = YES;
    }

    testassert(raised);

    return YES;
}

- (BOOL)testCatch
{
    NSException *e = [NSException exceptionWithName:nil reason:nil userInfo:nil];

    @try {
        [e raise];
    }
    @catch (NSException *caught) {
        testassert(caught == e);
    }

    return YES;
}

@end
