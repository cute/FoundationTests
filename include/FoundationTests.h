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

#define testassert(b) { if (!(b)) { test_failure(__FILE__, __LINE__); return NO; } }

#if !defined(__APPLE__)
#define KNOWN_CRASHER() DEBUG_LOG("SKIPPING KNOWN CRASHING TEST!"); testassert(0)
#else
#define KNOWN_CRASHER()
#endif

void test_failure(const char *file, int line);
void runFoundationTests(void);

#define TEST_CLASSES(action) \
action(CFRunLoop) \
action(NSBlock) \
action(NSByteCountFormatter) \
action(NSCountedSet) \
action(NSDictionary) \
action(NSException) \
action(NSLock) \
action(NSMethodSignature) \
action(NSNumber) \
action(NSObjCRuntime) \
action(NSSortDescriptor) \
action(NSString) \
action(NSPathUtilities) \
action(NSThread) \
action(NSURL) \

TEST_CLASSES(@testdecl)
