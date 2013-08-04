#import "FoundationTests.h"

@testcase(NSBlock)

- (BOOL)testGlobalBlock
{
    NSString *desc = [^{

    } description];
    testassert(desc != nil);

    return YES;
}

- (BOOL)testBlockCopy
{
    id block = [^{

    } copy];
    testassert(block != nil);

    return YES;
}

- (BOOL)testBlockRelease
{
    void (^block)() = Block_copy(^{

    });
    [block release];

    return YES;
}

- (BOOL)testBlockInvoke
{
    __block BOOL invoked = NO;
    [^{
        invoked = YES;
    } invoke];
    testassert(invoked);

    return YES;
}

@end
