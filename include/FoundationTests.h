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

#if !defined(__APPLE__)
#define KNOWN_CRASHER() DEBUG_LOG("SKIPPING KNOWN CRASHING TEST!"); testassert(0)
#else
#define KNOWN_CRASHER()
#endif

void runFoundationTests(void);

#define TEST_CLASSES(action) \
action(CFRunLoop) \
action(NSArray) \
action(NSBlock) \
action(NSBundle) \
action(NSByteCountFormatter) \
action(NSCountedSet) \
action(NSDictionary) \
action(NSException) \
action(NSInvocation) \
action(NSLock) \
action(NSMethodSignature) \
action(NSNumber) \
action(NSObjCRuntime) \
action(NSScanner) \
action(NSScannerSubclass) \
action(NSSortDescriptor) \
action(NSString) \
action(NSPathUtilities) \
action(NSThread) \
action(NSURL) \
action(NSUserDefaults) \

TEST_CLASSES(@testdecl)
