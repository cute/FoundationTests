#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define FoundationTest(c) c##TestsApportable

#define testdecl(name) interface FoundationTest(name) : NSObject @end

#define testcase(name) implementation FoundationTest(name) : NSObject

#define testrun(name) try { \
    id suite = [[FoundationTest(name) alloc] init]; \
    runTests(suite); \
    [suite release]; \
} @catch(...) { \
}

#define testassert(b) do { if (!_testassert(b, __FILE__, __LINE__)) return NO; } while (NO)
BOOL _testassert(BOOL b, const char *file, int line) __attribute__((analyzer_noreturn));

#define track(sup) ({ \
    Class __cls = [self class]; \
    SubclassTracker *__tracker = (SubclassTracker *)objc_getAssociatedObject(self, __cls); \
    if (__tracker == nil) { \
        __tracker = [[SubclassTracker alloc] initWithClass:__cls]; \
        objc_setAssociatedObject(self, __cls, __tracker, OBJC_ASSOCIATION_RETAIN); \
        [__tracker release]; \
    } \
    [__tracker track:_cmd]; \
    YES; \
}) ? sup : sup

#if defined(APPORTABLE) && !defined(__Foundation_h_GNUSTEP_BASE_INCLUDE)
#define APPORTABLE_KNOWN_CRASHER() DEBUG_LOG("SKIPPING KNOWN CRASHING TEST!"); testassert(0)
#else
#define APPORTABLE_KNOWN_CRASHER()
#endif

#if TARGET_IPHONE_SIMULATOR
#define IOS_SIMULATOR_BUG_FAILURE() NSLog(@"SKIPPING FAILURE DUE TO SIMULATOR BUG!"); testassert(0)
#else
#define IOS_SIMULATOR_BUG_FAILURE()
#endif

void runFoundationTests(void);

@interface InequalObject : NSObject
@end

@interface SubclassTracker : NSObject

- (id)initWithClass:(Class)cls;
- (void)track:(SEL)cmd;
+ (BOOL)verify:(id)target commands:(SEL)cmd, ... NS_REQUIRES_NIL_TERMINATION;
+ (BOOL)dumpVerification:(id)target; // used to build testasserts

@end


#define TEST_CLASSES(action) \
action(CFGetTypeID) \
action(CFRunLoop) \
action(Concurrency) \
action(Forwarding) \
action(NSArray) \
action(NSAttributedString) \
action(NSBlock) \
action(NSBundle) \
action(NSByteCountFormatter) \
action(NSCachedURLResponse) \
action(NSCalendar) \
action(NSCoder) \
action(NSCountedSet) \
action(NSData) \
action(NSDate) \
action(NSDateFormatter) \
action(NSDecimalNumber) \
action(NSDictionary) \
action(NSException) \
action(NSFileHandle) \
action(NSFileManager) \
action(NSHTTPCookieStorage) \
action(NSIndexSet) \
action(NSInvocation) \
action(NSJSONSerialization) \
action(NSKVO) \
action(NSKeyValueCoding) \
action(NSLocale) \
action(NSLock) \
action(NSMethodSignature) \
action(NSNull) \
action(NSNumber) \
action(NSNumberFormatter) \
action(NSObjCRuntime) \
action(NSObject) \
action(NSOrderedSet) \
action(NSPathUtilities) \
action(NSPointerFunctions) \
action(NSPort) \
action(NSProxy) \
action(NSRegularExpression) \
action(NSScanner) \
action(NSScannerSubclass) \
action(NSSet) \
action(NSSortDescriptor) \
action(NSString) \
action(NSStringSubclass) \
action(NSThread) \
action(NSTimeZone) \
action(NSURL) \
action(NSURLAuthenticationChallenge) \
action(NSURLCache) \
action(NSURLConnection) \
action(NSURLRequest) \
action(NSUserDefaults) \
action(NSValue) \
action(SecItem) \
action(SecureTransport) \

TEST_CLASSES(@testdecl)
