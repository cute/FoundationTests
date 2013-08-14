#include <stdio.h>

#include "utlist.h"

#import <objc/runtime.h>
#import "FoundationTests.h"

#ifndef DEBUG_LOG
#define DEBUG_LOG printf
#endif

static unsigned int total_success_count;
static unsigned int total_skip_count;
static unsigned int total_failure_count;

struct failure {
    const char *class;
    const char *sel;
    struct failure *next;
    struct failure *prev;
};

static void runTests(id tests)
{
    struct failure *failures = NULL;

    unsigned int count;
    Class c = [tests class];
    const char *class_name = class_getName(c);
    Method *methods = class_copyMethodList(c, &count);

    unsigned int success_count = 0;
    unsigned int skip_count = 0;
    unsigned int failure_count = 0;

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

        @try
        {
            success = (BOOL)imp(tests, sel);
        }
        @catch (id e)
        {
            DEBUG_LOG("%s: %s EXCEPTION THROWN\n", class_name, sel_name);
        }

        if (success)
        {
            success_count++;
            total_success_count++;
            DEBUG_LOG("%s: %s passed\n", class_name, sel_name);
        }
        else
        {
            failure_count++;
            total_failure_count++;

            struct failure *f = calloc(sizeof(*f), 1);
            f->class = class_name;
            f->sel = sel_name;
            DL_APPEND(failures, f);

            DEBUG_LOG("%s: %s FAILED\n", class_name, sel_name);
        }
    }

    DEBUG_LOG("%u successes\n", success_count);
    DEBUG_LOG("%u skipped\n", skip_count);
    DEBUG_LOG("%u failures\n\n", failure_count);

    struct failure *elt = NULL;
    struct failure *tmp = NULL;
    DL_FOREACH_SAFE(failures, elt, tmp)
    {
        DL_DELETE(failures, elt);
    }

    free(methods);
}

void runFoundationTests(void)
{
    TEST_CLASSES(@testrun)

    DEBUG_LOG("Foundation test totals\n");
    DEBUG_LOG("%u successes\n", total_success_count);
    DEBUG_LOG("%u skipped\n", total_skip_count);
    DEBUG_LOG("%u failures\n\n", total_failure_count);
}

static void test_failure(const char *file, int line)
{
    DEBUG_LOG("Test failure at %s:%d\n", file, line);
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
