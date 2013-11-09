#import "FoundationTests.h"
#import <objc/runtime.h>

@testcase(NSProxy)

- (BOOL)testAlloc
{
    testassert([NSProxy alloc] != nil);
    return YES;
}

- (BOOL)testRetainReleaseAutorelease
{
    NSProxy *p = [NSProxy alloc];
    [p retain];
    [p release];
    [p autorelease];
    return YES;
}

- (BOOL)testBaseMethods
{
    NSProxy *p = [NSProxy alloc];
    [p hash];
    [p isEqual:p];
    [p release];
    return YES;
}

- (BOOL)testClass
{
    NSProxy *p = [NSProxy alloc];
    testassert([p class] == objc_getClass("NSProxy"));
    [p release];
    return YES;
}

- (BOOL)testForwardingTarget
{
    NSProxy *p = [NSProxy alloc];
    testassert([p forwardingTargetForSelector:@selector(test)] == nil);
    [p release];
    return YES;
}

- (BOOL)testImplementsConformsToProtocol
{
    Class cls = objc_getClass("NSProxy");
    testassert(class_getInstanceMethod(cls, @selector(conformsToProtocol:)) != NULL);
    return YES;
}

- (BOOL)testImplementsMethodSignatureForSelector
{
    Class cls = objc_getClass("NSProxy");
    testassert(class_getInstanceMethod(cls, @selector(methodSignatureForSelector:)) != NULL);
    return YES;
}

- (BOOL)testMethodSignatureForSelector
{
    NSProxy *p = [NSProxy alloc];
    BOOL exceptionCaught = NO;
    @try {
        [p methodSignatureForSelector:@selector(init)];
    } @catch(NSException *e) {
        if ([[e name] isEqualToString:NSInvalidArgumentException])
        {
            exceptionCaught = YES;
        }
    }
    testassert(exceptionCaught == YES);
    [p release];
    return YES;
}

- (BOOL)testImplementsIsKindOfClass
{
    Class cls = objc_getClass("NSProxy");
    testassert(class_getInstanceMethod(cls, @selector(isKindOfClass:)) != NULL);
    return YES;
}

- (BOOL)testIsKindOfClass
{
    NSProxy *p = [NSProxy alloc];
    BOOL exceptionCaught = NO;
    @try {
        [p isKindOfClass:[NSProxy class]];
    } @catch(NSException *e) {
        if ([[e name] isEqualToString:NSInvalidArgumentException])
        {
            exceptionCaught = YES;
        }
    }
    testassert(exceptionCaught == YES);
    [p release];
    return YES;
}

- (BOOL)testImplementsIsMemberOfClass
{
    Class cls = objc_getClass("NSProxy");
    testassert(class_getInstanceMethod(cls, @selector(isMemberOfClass:)) != NULL);
    return YES;
}

- (BOOL)testIsMemberOfClass
{
    NSProxy *p = [NSProxy alloc];
    BOOL exceptionCaught = NO;
    @try {
        [p isMemberOfClass:[NSProxy class]];
    } @catch(NSException *e) {
        if ([[e name] isEqualToString:NSInvalidArgumentException])
        {
            exceptionCaught = YES;
        }
    }
    testassert(exceptionCaught == YES);
    [p release];
    return YES;
}

@end
