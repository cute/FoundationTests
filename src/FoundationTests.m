#include <stdio.h>

#import <objc/runtime.h>
#import <signal.h>
#import <setjmp.h>

#import "FoundationTests.h"

#ifndef DEBUG_LOG
#define DEBUG_LOG printf
#endif

static void failure_log(const char *error)
{
    DEBUG_LOG("%s", error);
}

static unsigned int total_success_count;
static unsigned int total_skip_count;
static unsigned int total_uncaught_exception_count;
static unsigned int total_failure_count;

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
    unsigned int skip_count = 0;
    unsigned int uncaught_exception_count = 0;
    unsigned int failure_count = 0;
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
                    success = (BOOL)imp(tests, sel);
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
            else
            {
                failure_count++;
                total_failure_count++;
            }
            DEBUG_LOG("%s: %s FAILED\n", class_name, sel_name);
            if (signal_hit)
            {
                DEBUG_LOG("Got signal %s\n", strsignal(signal_hit));
            }

        }
    }

    DEBUG_LOG("%u successes\n", success_count);
    DEBUG_LOG("%u skipped\n", skip_count);
    DEBUG_LOG("%u uncaught exceptions\n", uncaught_exception_count);
    DEBUG_LOG("%u failures\n\n", failure_count);

    free(methods);
}

void runFoundationTests(void)
{
    TEST_CLASSES(@testrun)

    DEBUG_LOG("Foundation test totals\n");
    DEBUG_LOG("%u successes\n", total_success_count);
    DEBUG_LOG("%u skipped\n", total_skip_count);
    DEBUG_LOG("%u uncaught exceptions\n", total_uncaught_exception_count);
    DEBUG_LOG("%u failures\n\n", total_failure_count);
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
