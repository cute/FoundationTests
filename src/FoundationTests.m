#include <stdio.h>

#import <objc/runtime.h>
#import <signal.h>
#import <setjmp.h>
#import <sys/stat.h>

#import "FoundationTests.h"
#import "uthash.h"

typedef struct {
    char test[256];
    char status;
    UT_hash_handle hh;
} TestResults;

TestResults *oldResults = NULL;
TestResults *newResults = NULL;

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

static void runTests(id tests, FILE *f)
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
        TestResults *entry = malloc(sizeof(TestResults));
        snprintf(entry->test, 256, "%s_%s", class_name, sel_name);
        if (success)
        {
            entry->status = 'P';
            success_count++;
            total_success_count++;
        }
        else
        {
            if (exception)
            {
                entry->status = 'X';
                uncaught_exception_count++;
                total_uncaught_exception_count++;
            }
            else
            {
                entry->status = 'F';
                failure_count++;
                total_failure_count++;
            }
            DEBUG_LOG("%s: %s FAILED\n", class_name, sel_name);
            if (signal_hit)
            {
                entry->status = 'S';
                DEBUG_LOG("Got signal %s\n", strsignal(signal_hit));
            }
        }
        fprintf(f, "%c %s\n", entry->status, entry->test);
        HASH_ADD_STR(newResults, test, entry);
    }

    DEBUG_LOG("%u successes\n", success_count);
    DEBUG_LOG("%u skipped\n", skip_count);
    DEBUG_LOG("%u uncaught exceptions\n", uncaught_exception_count);
    DEBUG_LOG("%u failures\n\n", failure_count);
    free(methods);
}

void runFoundationTests(void)
{
    char *env_home = getenv("HOME");
    char *lib = "/Documents";
    char *testdoc = "/tests";
    char *home = malloc(strlen(env_home) + strlen(lib) + strlen(testdoc) + 1);
    strcpy(home, env_home);
    char *documents = strcat(home, lib);
    struct stat info;
    if (stat(documents, &info) != 0) {
        mkdir(documents, 777);
    }
    char *path = strcat(documents, testdoc);
    FILE *f = fopen(path, "r");
    if (f != NULL)
    {
        while (!feof(f))
        {
            TestResults *entry = malloc(sizeof(TestResults));
            fscanf(f, "%c %256s\n", &entry->status, entry->test);
            HASH_ADD_STR(oldResults, test, entry);
        }
        fclose(f);
    }
    f = fopen(path, "w+");
    free(path);
    
    TEST_CLASSES(@testrun)

    TestResults *element = NULL;
    TestResults *tmp = NULL;
    int delta = 0;
    HASH_ITER(hh, newResults, element, tmp)
    {
        TestResults *found = NULL;
        HASH_FIND_STR(oldResults, element->test, found);
        if (found != NULL)
        {
            if (found->status == 'P' && found->status != element->status)
            {
                switch (element->status)
                {
                    case 'S':
                        DEBUG_LOG("Test for %s previously passed but now is throwing a signal\n", element->test);
                    case 'X':
                        DEBUG_LOG("Test for %s previously passed but now is raising an exception\n", element->test);
                    case 'F':
                        DEBUG_LOG("Test for %s previously passed but now is failing\n", element->test);
                        break;
                }
                delta++;
            }
        }
    }
    fclose(f);
    
    DEBUG_LOG("Foundation test totals\n");
    DEBUG_LOG("%u successes\n", total_success_count);
    DEBUG_LOG("%u skipped\n", total_skip_count);
    DEBUG_LOG("%u uncaught exceptions\n", total_uncaught_exception_count);
    DEBUG_LOG("%u failures\n\n", total_failure_count);
    if (delta == 0)
    {
        DEBUG_LOG("Test status unchanged from last run");
    }
    else
    {
        DEBUG_LOG("%d tests changed from last run", delta);
    }
    
    element = NULL;
    tmp = NULL;
    HASH_ITER(hh, oldResults, element, tmp)
    {
        HASH_DEL(oldResults, element);
        free(element);
    }
    
    element = NULL;
    tmp = NULL;
    HASH_ITER(hh, newResults, element, tmp)
    {
        HASH_DEL(newResults, element);
        free(element);
    }
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
