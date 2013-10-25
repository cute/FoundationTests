#import <Foundation/Foundation.h>

#if defined(APPLE_FOUNDATION_TEST)
#define FoundationTest(c) c##Apple
#else
#define FoundationTest(c) c##Apportable
#endif

#define testdecl(name) interface FoundationTest(name##Tests) : NSObject @end

#define testcase(name) implementation FoundationTest(name##Tests) : NSObject

#define testrun(name) try { \
    id suite = [[FoundationTest(name##Tests) alloc] init]; \
    runTests(suite); \
    [suite release]; \
} @catch(...) { \
}

#define testassert(b) do { if (!_testassert(b, __FILE__, __LINE__)) return NO; } while (NO)
BOOL _testassert(BOOL b, const char *file, int line) __attribute__((analyzer_noreturn));

#ifdef __Foundation_h_GNUSTEP_BASE_INCLUDE
#define GNUSTEP_KNOWN_CRASHER() DEBUG_LOG("SKIPPING KNOWN CRASHING TEST!"); testassert(0)
#else
#define GNUSTEP_KNOWN_CRASHER()
#endif

#if defined(APPORTABLE) && !defined(__Foundation_h_GNUSTEP_BASE_INCLUDE)
#define APPORTABLE_KNOWN_CRASHER() DEBUG_LOG("SKIPPING KNOWN CRASHING TEST!"); testassert(0)
#else
#define APPORTABLE_KNOWN_CRASHER()
#endif

#if TARGET_IPHONE_SIMULATOR
#define IOS_SIMULATOR_BUG_FAILURE() NSLog(@"SKIPPING FAILURE DUE TO SIMULATOR BUG!"); return YES
#else
#define IOS_SIMULATOR_BUG_FAILURE()
#endif

void runFoundationTests(void);

#define TEST_CLASSES(action) \
action(CFRunLoop) \
action(CFGetTypeID) \
action(NSAttributedString) \
action(NSArray) \
action(NSBlock) \
action(NSBundle) \
action(NSByteCountFormatter) \
action(NSCalendar) \
action(NSCountedSet) \
action(NSData) \
action(NSDate) \
action(NSDateFormatter) \
action(NSDictionary) \
action(NSException) \
action(NSFileHandle) \
action(NSFileManager) \
action(NSIndexSet) \
action(NSInvocation) \
action(NSKVO) \
action(NSLocale) \
action(NSLock) \
action(NSMethodSignature) \
action(NSNumber) \
action(NSNumberFormatter) \
action(NSObjCRuntime) \
action(NSScanner) \
action(NSScannerSubclass) \
action(NSSet) \
action(NSSortDescriptor) \
action(NSString) \
action(NSPathUtilities) \
action(NSThread) \
action(NSTimeZone) \
action(NSURL) \
action(NSUserDefaults) \
action(NSValue) \
action(NSKeyValueCoding) \
action(NSPort) \
action(NSURLConnection) \
action(NSURLRequest) \
action(NSHTTPCookieStorage) \
action(NSCachedURLResponse) \
action(NSURLCache) \
action(NSURLAuthenticationChallenge) \
action(SecItem) \
action(SecureTransport) \

TEST_CLASSES(@testdecl)
