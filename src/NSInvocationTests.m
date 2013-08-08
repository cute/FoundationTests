#import "FoundationTests.h"

@testcase(NSInvocation)

- (BOOL)testIncorrectAllocInit
{
    NSInvocation *inv = [[NSInvocation alloc] init]; // should not throw
    
    testassert(inv == nil);
    return YES;
}

- (BOOL)testInvocationWithMethodSiganture
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    testassert(inv != nil);
    return YES;
}

- (BOOL)testSelectorUnset
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    SEL bad = [inv selector];
    testassert(bad == nil);
    return YES;
}

- (BOOL)testSelectorSet
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv setSelector:@selector(objectForKey:)];
    SEL good = [inv selector];
    testassert(good == @selector(objectForKey:));
    return YES;
}

- (BOOL)testTargetUnset
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    id target = [inv target];
    testassert(target == nil);
    return YES;
}

- (BOOL)testTargetSet
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv setTarget:dict];
    id target = [inv target];
    testassert(target == dict);
    return YES;
}

- (BOOL)testMethodSignature
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    NSMethodSignature *ms = [inv methodSignature];
    testassert(ms != nil);
    return YES;
}

- (BOOL)testArgumentsSetOutOfOrder
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    NSString *foo = [NSString stringWithUTF8String:"Foo"];
    [inv setArgument:&foo atIndex:2]; // odd that &@"Foo" doesn't work...
    id fooFrom;
    [inv getArgument:&fooFrom atIndex:2];
    testassert([fooFrom isEqual:foo]);
    
    return YES;
}

- (BOOL)testArgumentsRetainedUnretained
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    testassert([inv argumentsRetained] == NO);
    return YES;
}

- (BOOL)testArgumentsRetainedRetained
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv retainArguments];
    NSUInteger rc = [dict retainCount];
    testassert([inv argumentsRetained] == YES);
    [inv setTarget:dict];
    testassert(rc < [dict retainCount]);
    return YES;
}

- (BOOL)testGetReturnValueUninvoked
{
    return YES;
}

- (BOOL)testGetReturnValueInvoked
{
    return YES;
}

- (BOOL)testSetReturnValueUninvoked
{
    return YES;
}

- (BOOL)testSetReturnValueInvoked
{
    return YES;
}

- (BOOL)testReturnValueBufferTooSmall
{
    return YES;
}

- (BOOL)testReturnValueBufferTooLarge
{
    return YES;
}

- (BOOL)testSetArgumentAtIndex
{
    return YES;
}

- (BOOL)testSetArgumentAtIndexWithRetainedArguments
{
    return YES;
}

- (BOOL)testGetArgumentAtIndex
{
    return YES;
}

- (BOOL)testCharStarBehaviorWithRetainedArguments
{
    return YES;
}

- (BOOL)testInvoke
{
    return YES;
}

- (BOOL)testInvokeWithTarget
{
    return YES;
}
@end
