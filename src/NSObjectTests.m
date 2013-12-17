#import "FoundationTests.h"

@interface NSObject (NSCFType)
- (NSString *)_copyDescription;
- (CFTypeID)_cfTypeID;
@end

@interface NSObject (NSZombie)
- (void)__dealloc_zombie;
@end

@interface NSObject (__NSIsKinds)
- (BOOL)isNSValue__;
- (BOOL)isNSTimeZone__;
- (BOOL)isNSString__;
- (BOOL)isNSSet__;
- (BOOL)isNSOrderedSet__;
- (BOOL)isNSNumber__;
- (BOOL)isNSDictionary__;
- (BOOL)isNSDate__;
- (BOOL)isNSData__;
- (BOOL)isNSArray__;
@end

@interface NSObject (Internal)
+ (BOOL)implementsSelector:(SEL)selector;
- (BOOL)implementsSelector:(SEL)selector;
+ (BOOL)instancesImplementSelector:(SEL)selector;
@end

@interface NSObject (NSCoder)
- (BOOL)_allowsDirectEncoding;
@end

extern CFTypeID CFTypeGetTypeID();

/*
 - (id)replacementObjectForCoder:(NSCoder *)aCoder
 - (id)awakeAfterUsingCoder:(NSCoder *)aDecoder
 

*/

@testcase(NSObject)

- (BOOL)test_copyDescription
{
    NSObject *obj = [[NSObject alloc] init];
    NSString *desc = [obj _copyDescription];
    testassert(desc != NULL);
    testassert([desc retainCount] >= 1);
    [desc release];
    [obj release];
    return YES;
}

- (BOOL)test_cfGetTypeID
{
    NSObject *obj = [[NSObject alloc] init];
    CFTypeID expected = CFTypeGetTypeID();
    testassert([obj _cfTypeID] == expected);
    return YES;
}

- (BOOL)test__dealloc_zombie
{
    Class NSObjectClass = objc_getClass("NSObject");
    Method m = class_getInstanceMethod(NSObjectClass, @selector(__dealloc_zombie));
    testassert(m != NULL);
    return YES;
}

- (BOOL)testIsNSValue__
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj isNSValue__] == NO);
    return YES;
}

- (BOOL)testIsNSTimeZone__
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj isNSTimeZone__] == NO);
    return YES;
}

- (BOOL)testIsNSString__
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj isNSString__] == NO);
    return YES;
}

- (BOOL)testIsNSSet__
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj isNSSet__] == NO);
    return YES;
}

- (BOOL)testIsNSOrderedSet__
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj isNSOrderedSet__] == NO);
    return YES;
}

- (BOOL)testIsNSNumber__
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj isNSNumber__] == NO);
    return YES;
}

- (BOOL)testIsNSDictionary__
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj isNSDictionary__] == NO);
    return YES;
}

- (BOOL)testIsNSDate__
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj isNSDate__] == NO);
    return YES;
}

- (BOOL)testIsNSData__
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj isNSData__] == NO);
    return YES;
}

- (BOOL)testIsNSArray__
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj isNSArray__] == NO);
    return YES;
}

- (BOOL)testInstanceMethodSignatureForSelector
{
    NSMethodSignature *sig = [NSObject instanceMethodSignatureForSelector:@selector(init)];
    testassert(sig != NULL);
    return YES;
}

- (BOOL)testMethodSignatureForSelector1
{
    NSMethodSignature *sig = [NSObject methodSignatureForSelector:@selector(alloc)];
    testassert(sig != NULL);
    return YES;
}

- (BOOL)testMethodSignatureForSelector2
{
    NSObject *obj = [[NSObject alloc] init];
    NSMethodSignature *sig = [obj methodSignatureForSelector:@selector(init)];
    testassert(sig != NULL);
    [obj release];
    return YES;
}

- (BOOL)testDescription1
{
    NSString *str = [NSObject description];
    testassert([str isEqualToString:@"NSObject"]);
    return YES;
}

- (BOOL)testDescription2
{
    NSObject *obj = [[NSObject alloc] init];
    NSString *desc = [obj description];
    testassert(desc != NULL);
    NSString *expected = [NSString stringWithFormat:@"<%s: %p>", object_getClassName(obj), obj];
    testassert([desc isEqualToString:expected]);
    [obj release];
    return YES;
}

- (BOOL)testDescription3
{
    NSString *str = (NSString *)CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@"), self);
    testassert([[self description] isEqualToString:str]);
    [str release];
    return YES;
}

- (BOOL)testImplementsSelector1
{
    testassert([NSObject implementsSelector:@selector(alloc)]);
    return YES;
}

- (BOOL)testImplementsSelector2
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj implementsSelector:@selector(init)]);
    [obj release];
    return YES;
}

- (BOOL)testInstancesImplementSelector
{
    testassert([NSObject instancesImplementSelector:@selector(init)]);
    return YES;
}

- (BOOL)testVersion
{
    NSInteger ver = [NSObject version];
    testassert(ver == 0);
    [NSObject setVersion:ver + 1];
    testassert([NSObject version] == ver + 1);
    return YES;
}

- (BOOL)testInitWithCoder
{
    Class NSObjectClass = objc_getClass("NSObject");
    Method m = class_getInstanceMethod(NSObjectClass, @selector(initWithCoder:));
    testassert(m == NULL);
    return YES;
}

- (BOOL)test_allowsDirectEncoding
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj _allowsDirectEncoding] == NO);
    [obj release];
    return YES;
}

- (BOOL)testClassForCoder
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj classForCoder] == [NSObject class]);
    [obj release];
    return YES;
}

- (BOOL)testReplacementObjectForCoder
{
    NSObject *obj = [[NSObject alloc] init];
    id replacement = [obj replacementObjectForCoder:nil];
    testassert(obj == replacement);
    [obj release];
    return YES;
}

- (BOOL)testAwakeAfterUsingCoder
{
    NSObject *obj = [[NSObject alloc] init];
    id replacement = [obj awakeAfterUsingCoder:nil];
    testassert(obj == replacement);
    [obj release];
    return YES;
}

- (BOOL)testMissingForwarding
{
    BOOL raised = NO;
    @try {
        [self thisSelectorIsNotImplemented];
    } @catch(NSException *e) {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        raised = YES;
    }
    testassert(raised);
    return YES;
}

@end
