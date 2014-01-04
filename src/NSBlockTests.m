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

- (BOOL)testBlockNSInvocation
{
    __block BOOL invoked = NO;
    void (^block)(char ch) = ^(char c){
        invoked = c == 'B';
    };
    char t = 'B';
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[(id)block methodSignatureForSelector:@selector(invoke)]];
    [inv setTarget:block];
    [inv setSelector:@selector(invoke)];
    [inv setArgument:&t atIndex:1];
    [inv invoke];
    testassert(invoked);
    return YES;
}

@end
