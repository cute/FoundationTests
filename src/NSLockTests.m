#import "FoundationTests.h"
#import <pthread.h>

@testcase(NSLock)

- (BOOL)testCreation
{
    NSLock *lock = [[NSLock alloc] init];
    testassert(lock != nil);
    [lock release];

    return YES;
}

- (BOOL)testBasicLock
{
    NSLock* lock = [[NSLock alloc] init];
    for (int i = 0;  i < 100; i++)
    {
        [lock lock];
        [lock unlock];
    }
    [lock release];
    return YES;
}

- (BOOL)testNoninitedBehavior
{
    NSLock* lock = [NSLock alloc];
    // should warn
    [lock unlock];
    [lock unlock];

    // should warn but not deadlock
    [lock lock];
    [lock lock];

    BOOL tryLockVal = [lock tryLock];
    testassert(!tryLockVal);

    // apple's lockAtDate is YES for non init
    BOOL lockDateVal = [lock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:1.]];
    testassert(lockDateVal);

    return YES;
}

typedef struct {
    int *count;
    int  workerID;
    NSLock *lock;
    int startValue;
    int endValue;
} WorkerStruct;


#define kWorkAmountPerThread (10000)
static void *workerThread(void *data)
{
    WorkerStruct* workOrder = (WorkerStruct*)data;
    // lock for the entire work
    [workOrder->lock lock];

    workOrder->startValue = (*(workOrder->count));
    for (int i = 0; i < kWorkAmountPerThread; i++)
    {
        (*(workOrder->count))++;
    }
    workOrder->endValue = (*(workOrder->count));

    [workOrder->lock unlock];

    return NULL;
}

#define kNumTestThreads (2)
- (BOOL)testTwoThreadsLock
{
    NSLock *lock = [[NSLock alloc] init];
    int workInt;
    WorkerStruct workOrder[kNumTestThreads];
    pthread_t threads[kNumTestThreads];
    for (int i = 0; i < kNumTestThreads; i++)
    {
        workOrder[i].count = &workInt;
        workOrder[i].workerID = i;
        workOrder[i].lock = lock;
        pthread_create(&threads[i], NULL, &workerThread, &workOrder[i]);
    }

    for (int i = 0; i < kNumTestThreads; i++)
    {
        pthread_join(threads[i], NULL);
        testassert(workOrder[i].startValue + kWorkAmountPerThread == workOrder[i].endValue);
    }
    [lock release];

    return YES;
}

- (BOOL)testRecusiveLock
{
    NSRecursiveLock *rLock = [[NSRecursiveLock alloc] init];

    [self recursiveLockHelper:100 lock:rLock];
    [rLock release];
    return YES;
}

- (void)recursiveLockHelper:(int)depth lock:(NSRecursiveLock *)rLock
{
    if (depth <= 0)
    {
        return;
    }

    [rLock lock];
    [self recursiveLockHelper:depth -1 lock:rLock];
    [rLock unlock];
}


#define kNumSignals (10000)
typedef struct {
    NSCondition *cond;
    int val;
} SignalData;

static void *signalingThread(void *ctx)
{
    SignalData* signalData = (SignalData*) ctx;
    for (int i = 0; i < kNumSignals; i++) {
        [signalData->cond lock];

        usleep(10);
        signalData->val++;
        [signalData->cond signal];
        [signalData->cond unlock];
    }
    return NULL;
}

static SignalData data;
- (BOOL)testCondition
{
    NSCondition *cond = [[NSCondition alloc] init];

    data.val = 0;
    data.cond = cond;

    pthread_t thread;
    // this thread steps  nd waits for the signaling thread to do some long thing and signal
    int ourSignalCount = 0;

    pthread_create(&thread, NULL, &signalingThread, &data);
    sleep(1);
    while (data.val < kNumSignals)
    {
        [data.cond lock];
        int val = data.val;
        while (val == data.val)
        {
            [data.cond wait];
        }
        ourSignalCount++;
        testassert(data.val == ourSignalCount);
        [data.cond unlock];
    }
    [cond release];

    return YES;
}

- (BOOL)testConditionNonInited
{
    NSCondition* cond = [NSCondition alloc];
    [cond lock];
    [cond lock];

    [cond wait];
    [cond wait];
    return YES;
}

@end
