#import "FoundationTests.h"

@testcase(NSException)

typedef void (^dummyBlock)(void);

static int func(NSException *e)
{
    [e raise];
    return 99;
}

- (BOOL)testRaiseWithCall
{
    NSException *e = [NSException exceptionWithName:nil reason:nil userInfo:nil];
    BOOL raised = NO;
    
    @try {
        func(e);
    }
    @catch (NSException *caught) {
        raised = YES;
    }
    
    testassert(raised);
    return YES;
}

static int funcWithBlock(NSException *e)
{
    __block int x = 0;
    
    dummyBlock myBlock = ^(void) {
        x = 9;
    };
    
    [e raise];
    myBlock();
    return x;
}

- (BOOL)testRaiseWithBlockVariablesCall
{
    NSException *e = [NSException exceptionWithName:nil reason:nil userInfo:nil];
    BOOL raised = NO;
    
    @try {
        funcWithBlock(e);
    }
    @catch (NSException *caught) {
        raised = YES;
    }
    
    testassert(raised);
    
    return YES;
}

- (BOOL)testRaiseWithBlockVariables
{
    NSException *e = [NSException exceptionWithName:nil reason:nil userInfo:nil];
    BOOL raised = NO;
    __block int x = 0;
    
    dummyBlock myBlock = ^(void) {
        x = 9;
    };
    
    myBlock();
    
    @try {
        [e raise];
    }
    @catch (NSException *caught) {
        raised = YES;
        testassert(x == 9);
    }
    
    testassert(raised);
    
    return YES;
}

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
