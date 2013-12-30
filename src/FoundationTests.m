#include <stdio.h>

#import <objc/runtime.h>
#import <signal.h>
#import <setjmp.h>

#import "FoundationTests.h"

#ifndef DEBUG_LOG
#define DEBUG_LOG printf
#endif


@implementation SubclassTracker {
    CFMutableArrayRef calls;
    Class class;
}

static CFStringRef sel_copyDescription(const void *value)
{
    if (value == NULL)
    {
        return CFSTR("<NULL>");
    }
    return CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("@selector(%s)"), sel_getName((SEL)value));
}

- (id)initWithClass:(Class)cls
{
    self = [super init];
    if (self)
    {
        class = cls;
        CFArrayCallBacks callbacks = {
            .version = 0,
            .copyDescription = &sel_copyDescription
        };
        calls = CFArrayCreateMutable(kCFAllocatorDefault, 0, &callbacks);
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)track:(SEL)cmd
{
    CFArrayAppendValue(calls, cmd);
}

- (CFArrayRef)calls
{
    return calls;
}

+ (BOOL)verify:(id)target commands:(SEL)cmd, ...
{
    SubclassTracker *tracker = objc_getAssociatedObject(target, [target class]);
    if (tracker == nil)
    {
        return NO;
    }
    CFArrayCallBacks callbacks = {
        .version = 0,
        .copyDescription = &sel_copyDescription
    };
    CFMutableArrayRef expected = CFArrayCreateMutable(kCFAllocatorDefault, 0, &callbacks);
    CFArrayRef calls = [tracker calls];
    va_list args;
    va_start(args, cmd);
    SEL command = cmd;
    do {
        CFArrayAppendValue(expected, command);
        command = va_arg(args, SEL);
    } while (command != NULL);
    if (CFEqual(calls, expected))
    {
        return YES;
    }
    else
    {
        
        DEBUG_LOG("Expected call pattern: %s", [(NSString *)CFCopyDescription(expected) UTF8String]);
        DEBUG_LOG("Recieved call pattern: %s", [(NSString *)CFCopyDescription(calls) UTF8String]);
        return NO;
    }
}

+ (BOOL)dumpVerification:(id)target
{
    SubclassTracker *tracker = objc_getAssociatedObject(target, [target class]);
    if (tracker == nil)
    {
        return NO;
    }
    CFArrayRef calls = [tracker calls];
    CFIndex count = CFArrayGetCount(calls);
    NSMutableString *verification = [NSMutableString stringWithFormat:@"BOOL verified = [%s verify:target commands:", object_getClassName(self)];
    for (CFIndex index = 0; index < count; index++)
    {
        SEL command = (SEL)CFArrayGetValueAtIndex(calls, index);
        [verification appendFormat:@"@selector(%s), ", sel_getName(command)];
    }
    [verification appendString:@"nil];\n testassert(verified);\n"];
    printf("%s", [verification UTF8String]);
    return YES;
}

@end


static void failure_log(const char *error)
{
    DEBUG_LOG("%s", error);
}

static unsigned int total_success_count = 0;
static unsigned int total_assertion_count = 0;
static unsigned int total_skip_count = 0;
static unsigned int total_uncaught_exception_count = 0;
static unsigned int total_failure_count = 0;
static unsigned int total_signal_count = 0;
static unsigned int total_test_count = 0;

static sigjmp_buf jbuf;
static int signal_hit = 0;

static void test_signal(int sig)
{
    signal_hit = sig;
    siglongjmp(jbuf, 1);
}

static void runTests(id tests)
{
    unsigned int count;
    Class c = [tests class];
    const char *class_name = class_getName(c);
    Method *methods = class_copyMethodList(c, &count);

    unsigned int success_count = 0;
    unsigned int assertion_count = 0;
    unsigned int skip_count = 0;
    unsigned int uncaught_exception_count = 0;
    unsigned int failure_count = 0;
    unsigned int signal_count = 0;
    unsigned int test_count = 0;
    
    DEBUG_LOG("Running tests for %.*s:\n", (int)strlen(class_name) - (int)strlen("TestsApportable"), class_name);
    for (unsigned int i = 0; i < count; i++)
    {
        SEL sel = method_getName(methods[i]);
        const char *sel_name = sel_getName(sel);
        IMP imp = method_getImplementation(methods[i]);

        if (strncmp(sel_name, "test", 4) != 0)
        {
            continue;
        }

        char returnType[256];
        method_getReturnType(methods[i], returnType, sizeof(returnType));

        if (strncmp(returnType, @encode(BOOL), sizeof(returnType)))
        {
            skip_count++;
            total_skip_count++;
            DEBUG_LOG("%s: %s SKIPPED (return type %s should be BOOL)\n", class_name, sel_name, returnType);
            continue;
        }

        BOOL success = NO;
        BOOL exception = NO;

        void (*sigsegv_handler)(int) = signal(SIGSEGV, &test_signal);
        void (*sigbus_handler)(int) = signal(SIGBUS, &test_signal);
        signal_hit = 0;
        if (sigsetjmp(jbuf, 1) == 0) {
            @try
            {
                @autoreleasepool {
                    total_test_count++;
                    test_count++;
                    success = (BOOL)imp(tests, sel);
                    if (!success)
                    {
                        assertion_count++;
                        total_assertion_count++;
                    }
                }
            }
            @catch (NSException *e)
            {
                exception = YES;
                char error[4096] = {0};
                snprintf(error, 4096, "%s: %s UNCAUGHT EXCEPTION\n%s\n", class_name, sel_name, [[e reason] UTF8String]);
                failure_log(error);
            }
        }

        signal(SIGBUS, sigbus_handler);
        signal(SIGSEGV, sigsegv_handler);

        success = success && !signal_hit;

        if (success)
        {
            success_count++;
            total_success_count++;
        }
        else
        {
            if (exception)
            {
                uncaught_exception_count++;
                total_uncaught_exception_count++;
            }
            
            if (signal_hit)
            {
                signal_count++;
                DEBUG_LOG("Got signal %s\n", strsignal(signal_hit));
                total_signal_count++;
            }
            
            DEBUG_LOG("%s: %s FAILED\n", class_name, sel_name);
            failure_count++;
            total_failure_count++;
        }
    }

    DEBUG_LOG("%u/%u successes\n", success_count, test_count);
    DEBUG_LOG("%u assertions\n", assertion_count);
    DEBUG_LOG("%u skipped\n", skip_count);
    DEBUG_LOG("%u uncaught exceptions\n", uncaught_exception_count);
    DEBUG_LOG("%u signals raised\n", signal_count);
    DEBUG_LOG("%u failures (assertions, signals, and uncaught exceptions)\n\n", failure_count);

    free(methods);
}

void runFoundationTests(void)
{
    TEST_CLASSES(@testrun)

    DEBUG_LOG("Foundation test totals %.02f%%\n", 100.0 * ((double)total_success_count / (double)total_test_count));
    DEBUG_LOG("%u/%u successes\n", total_success_count, total_test_count);
    DEBUG_LOG("%u assertions\n", total_assertion_count);
    DEBUG_LOG("%u skipped\n", total_skip_count);
    DEBUG_LOG("%u uncaught exceptions\n", total_uncaught_exception_count);
    DEBUG_LOG("%u signals raised\n", total_signal_count);
    DEBUG_LOG("%u failures (assertions, signals, and uncaught exceptions)\n\n", total_failure_count);
}

static void test_failure(const char *file, int line)
{
    char msg[4096] = {0};
    snprintf(msg, 4096, "Test failure at %s:%d\n", file, line);
    failure_log(msg);
}

BOOL _testassert(BOOL b, const char *file, int line)
{
    if (!(b))
    {
        test_failure(file, line);
        return NO;
    }

    return YES;
}
