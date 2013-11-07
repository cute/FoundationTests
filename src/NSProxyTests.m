#import "FoundationTests.h"

#ifdef APPORTABLE
#warning "TODO: Apportable's new Foundation doesn't have NSProxy yet, so use this work-around to keep the tests linking."
#define NSProxy NSObject
#endif

@interface NSProxyTestHelper : NSProxy
@end

@implementation NSProxyTestHelper
- (id)method
{
    return @42;
}

- (id)method:(id)value
{
    return value;
}

- (id)concatStrings:(id)x and:(id)y
{
    return [(NSString*)x stringByAppendingString:(NSString*)y];
}
@end

@testcase(NSProxy)

#define ASSERT_NOT_IMPLEMENTED(callexpr) \
    do { \
        @try { \
            callexpr; \
            NSLog(@"error: expected %s to not be implemented", #callexpr); \
            testassert(NO); \
        } \
        @catch (NSException *e) { \
            testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]); \
        } \
    } while(0)

- (BOOL)testMethodExistence
{
    Class NSProxyTestHelperClass = [NSProxyTestHelper class];
    testassert([NSProxyTestHelperClass respondsToSelector:@selector(alloc)]);

    NSProxy *proxy = [NSProxyTestHelper alloc];
    [proxy retain];
    [proxy release];
    [proxy autorelease];
    [proxy hash];
    [proxy isEqual:proxy];
    testassert([proxy class] == NSProxyTestHelperClass);
    testassert([[proxy debugDescription] hasPrefix:@"<NSProxyTestHelper:"]);
    testassert([[proxy description] hasPrefix:@"<NSProxyTestHelper:"]);
    testassert([proxy forwardingTargetForSelector:@selector(method)] == nil);
    testassert([proxy isProxy]);
    testassert([[proxy performSelector:@selector(method)] isEqual:@42]);
    testassert([[proxy performSelector:@selector(method:) withObject:@17] isEqual:@17]);
    testassert([[proxy performSelector:@selector(concatStrings:and:) withObject:@"42" withObject:@"17"] isEqual:@"4217"]);
    testassert([proxy retainCount] == 1);
    ASSERT_NOT_IMPLEMENTED([proxy className]);
    ASSERT_NOT_IMPLEMENTED([proxy conformsToProtocol:@protocol(NSObject)]);
    ASSERT_NOT_IMPLEMENTED([proxy copy]);
    ASSERT_NOT_IMPLEMENTED([proxy init]);
    ASSERT_NOT_IMPLEMENTED([proxy isKindOfClass:NSProxyTestHelperClass]);
    ASSERT_NOT_IMPLEMENTED([proxy isMemberOfClass:NSProxyTestHelperClass]);
    ASSERT_NOT_IMPLEMENTED([proxy methodSignatureForSelector:@selector(method)]);
    ASSERT_NOT_IMPLEMENTED([proxy methodForSelector:@selector(method)]);
    ASSERT_NOT_IMPLEMENTED([proxy mutableCopy]);
    ASSERT_NOT_IMPLEMENTED([proxy respondsToSelector:@selector(method)]);

    return YES;
}

@end
