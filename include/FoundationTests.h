#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define FoundationTest(c) c##TestsApportable

#define testcase(name) interface FoundationTest(name) : NSObject @end \
static void name##Register() __attribute((constructor)); \
static void name##Register() { registerTestClass([FoundationTest(name) class]); } \
@implementation FoundationTest(name)

#define testrun(name) try { \
    id suite = [[FoundationTest(name) alloc] init]; \
    runTests(suite); \
    [suite release]; \
} @catch(...) { \
}

#define testassert(b, ...) do { if (!_testassert(b , ##__VA_ARGS__, __FILE__, __LINE__)) return NO; } while (NO)
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

extern void registerTestClass(Class cls);
