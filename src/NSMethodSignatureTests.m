#import "FoundationTests.h"

#import <objc/message.h>
#import <objc/runtime.h>

@testcase(NSMethodSignature)

- (BOOL)testFrameLength
{
    NSString *obj = [[NSString alloc] init];

    NSMethodSignature *methodSignature = [obj methodSignatureForSelector:@selector(initWithBytesNoCopy:length:encoding:freeWhenDone:)];
    // This would be 24 on iOS, but we need a 64-bit runtime on Mac.
#ifdef __LP64__
    testassert([methodSignature frameLength] == 44);
#else
    testassert([methodSignature frameLength] == 24);
#endif

    methodSignature = [obj methodSignatureForSelector:@selector(init)];
#ifdef __LP64__
    testassert([methodSignature frameLength] == 16);
#else
    testassert([methodSignature frameLength] == 8);
#endif
    return YES;
}

- (BOOL)testOneWay
{
    NSObject *obj = [[NSObject alloc] init];

    NSMethodSignature *methodSignature = [obj methodSignatureForSelector:@selector(release)];
    testassert([methodSignature isOneway] == YES);

    methodSignature = [obj methodSignatureForSelector:@selector(init)];
    testassert([methodSignature isOneway] == NO);

    return YES;
}

@end
