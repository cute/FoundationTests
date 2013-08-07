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
    [obj release];
    return YES;
}

- (BOOL)testOneWay
{
    NSObject *obj = [[NSObject alloc] init];

    NSMethodSignature *methodSignature = [obj methodSignatureForSelector:@selector(release)];
    testassert([methodSignature isOneway] == YES);

    methodSignature = [obj methodSignatureForSelector:@selector(init)];
    testassert([methodSignature isOneway] == NO);
    [obj release];
    return YES;
}

- (BOOL)testMethodReturnLength
{
    NSObject *obj = [[NSObject alloc] init];
    NSMethodSignature *methodSignature = [obj methodSignatureForSelector:@selector(release)];
    testassert([methodSignature methodReturnLength] == 0);
    
    methodSignature = [obj methodSignatureForSelector:@selector(init)];
    testassert([methodSignature methodReturnLength] == sizeof(id));
    
    methodSignature = [obj methodSignatureForSelector:@selector(class)];
    testassert([methodSignature methodReturnLength] == sizeof(Class));
    
    methodSignature = [obj methodSignatureForSelector:@selector(methodForSelector:)];
    testassert([methodSignature methodReturnLength] == sizeof(IMP));
    
    methodSignature = [obj methodSignatureForSelector:@selector(conformsToProtocol:)];
    testassert([methodSignature methodReturnLength] == sizeof(BOOL));

    methodSignature = [obj methodSignatureForSelector:@selector(hash)];
    testassert([methodSignature methodReturnLength] == sizeof(NSUInteger));
    [obj release];
    
    NSNumber *num = [[NSNumber alloc] initWithFloat:3.141f];
    methodSignature = [num methodSignatureForSelector:@selector(floatValue)];
    testassert([methodSignature methodReturnLength] == sizeof(float));
    [num release];
    
    num = [[NSNumber alloc] initWithDouble:M_PI];
    methodSignature = [num methodSignatureForSelector:@selector(doubleValue)];
    testassert([methodSignature methodReturnLength] == sizeof(double));
    [num release];
    
    num = [[NSNumber alloc] initWithChar:'d'];
    methodSignature = [num methodSignatureForSelector:@selector(charValue)];
    testassert([methodSignature methodReturnLength] == sizeof(char));
    [num release];
    
    num = [[NSNumber alloc] initWithShort:22222];
    methodSignature = [num methodSignatureForSelector:@selector(shortValue)];
    testassert([methodSignature methodReturnLength] == sizeof(short));
    [num release];
    
    num = [[NSNumber alloc] initWithInt:22222];
    methodSignature = [num methodSignatureForSelector:@selector(intValue)];
    testassert([methodSignature methodReturnLength] == sizeof(int));
    [num release];
    
    num = [[NSNumber alloc] initWithInteger:22222];
    methodSignature = [num methodSignatureForSelector:@selector(integerValue)];
    testassert([methodSignature methodReturnLength] == sizeof(NSInteger));
    [num release];
    
    return YES;
}

@end
