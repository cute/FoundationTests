#import "FoundationTests.h"

@interface Observer : NSObject
@end

@implementation Observer
{
    NSMutableDictionary *_observationCounts;
    NSMutableSet *_priorNotificationValues;
}

+ (instancetype)observer
{
    return [[[self alloc] init] autorelease];
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _observationCounts = [NSMutableDictionary dictionary];
        _priorNotificationValues = [NSMutableSet set];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSNumber *count = [_observationCounts objectForKey:keyPath];
    if (count == nil)
    {
        count = @(0);
    }
    [_observationCounts setObject:@([count integerValue] + 1) forKey:keyPath];

    if ([change objectForKey:NSKeyValueChangeNotificationIsPriorKey] != nil)
    {
        [_priorNotificationValues addObject:keyPath];
    }
}

- (NSUInteger)observationCountForKeyPath:(NSString *)keyPath
{
    NSNumber *count = [_observationCounts objectForKey:keyPath];
    if (count == nil)
    {
        count = @(0);
    }

    return [count unsignedIntegerValue];
}

- (BOOL)priorObservationMadeForKeyPath:(NSString *)keyPath
{
    return [_priorNotificationValues containsObject:keyPath];
}

@end

@interface Observable : NSObject {
    int _anInt;
}
@property int anInt;
@end

@implementation Observable
@synthesize anInt=_anInt;
+ (instancetype)observable
{
    return [[[self alloc] init] autorelease];
}
@end
@interface ReallyBadObservable : Observable
@end

@implementation ReallyBadObservable
- (void)setAnInt:(int)anInt
{
    _anInt = anInt;
}
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}
@end
@interface BadObservable : Observable
@end

@implementation BadObservable
- (void)setAnInt:(int)anInt
{
    _anInt = anInt;
    [self didChangeValueForKey:@"anInt"];
}
@end

@testcase(NSKVO)

#define OBSERVER_PROLOGUE(_Observable, _keyPath, _options, _context) \
    @autoreleasepool { \
        NSString *keyPath = (_keyPath); \
        Observer *observer = [Observer observer]; \
        _Observable *observable = [_Observable observable];               \
        [observable addObserver:observer forKeyPath:keyPath options:(_options) context:(_context)]; \
        BOOL result = YES;

#define OBSERVER_EPILOGUE() \
        [observable removeObserver:observer forKeyPath:keyPath]; \
        return result; \
    }

- (BOOL)testZeroObservances
{
    OBSERVER_PROLOGUE(Observable, @"anInt", 0, NULL);

    testassert([observer observationCountForKeyPath:keyPath] == 0);

    OBSERVER_EPILOGUE();
}

- (BOOL)testSingleObservance
{
    OBSERVER_PROLOGUE(Observable, @"anInt", 0, NULL);

    [observable setAnInt:42];

    testassert([observer observationCountForKeyPath:keyPath] == 1);

    OBSERVER_EPILOGUE();
}

- (BOOL)testManyObservances
{
    static const NSUInteger iterations = 100000;

    OBSERVER_PROLOGUE(Observable, @"anInt", 0, NULL);

    for (NSUInteger i = 0; i < iterations; i++)
    {
        [observable setAnInt:i];
    }

    testassert([observer observationCountForKeyPath:keyPath] == iterations);

    OBSERVER_EPILOGUE();
}

- (BOOL)testPriorObservance
{
    OBSERVER_PROLOGUE(Observable, @"anInt", NSKeyValueObservingOptionPrior, NULL);

    [observable setAnInt:42];

    testassert([observer priorObservationMadeForKeyPath:keyPath]);

    OBSERVER_EPILOGUE();
}

- (BOOL)testZeroObservancesWithBadObservable
{
    OBSERVER_PROLOGUE(BadObservable, @"anInt", 0, NULL);

    testassert([observer observationCountForKeyPath:keyPath] == 0);

    OBSERVER_EPILOGUE();
}

- (BOOL)testSingleObservanceWithBadObservable
{
    OBSERVER_PROLOGUE(BadObservable, @"anInt", 0, NULL);

    [observable setAnInt:42];

    testassert([observer observationCountForKeyPath:keyPath] == 1);

    OBSERVER_EPILOGUE();
}

- (BOOL)testManyObservancesWithBadObservable
{
    static const NSUInteger iterations = 100000;

    OBSERVER_PROLOGUE(BadObservable, @"anInt", 0, NULL);

    for (NSUInteger i = 0; i < iterations; i++)
    {
        [observable setAnInt:i];
    }

    testassert([observer observationCountForKeyPath:keyPath] == iterations);

    OBSERVER_EPILOGUE();
}

- (BOOL)testPriorObservanceWithBadObservable
{
    OBSERVER_PROLOGUE(BadObservable, @"anInt", NSKeyValueObservingOptionPrior, NULL);

    [observable setAnInt:42];

    testassert([observer priorObservationMadeForKeyPath:keyPath]);

    OBSERVER_EPILOGUE();
}

-(BOOL)testMidCycleUnregister
{
    @autoreleasepool
    {
        ReallyBadObservable *badObservable = [ReallyBadObservable observable];
        Observer *observer = [Observer observer];
        [badObservable addObserver:observer forKeyPath:@"anInt" options:0 context:NULL];
        [badObservable willChangeValueForKey:@"anInt"];
        [badObservable setAnInt:50];
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        [badObservable didChangeValueForKey:@"anInt"];
        testassert([observer observationCountForKeyPath:@"anInt"] == 0);
        return YES;
    }
}
-(BOOL)testMidCycleRegister
{
    @autoreleasepool
    {
        ReallyBadObservable *badObservable = [ReallyBadObservable observable];
        Observer *observer = [Observer observer];
        Observer *observer2 = [Observer observer];
        [badObservable addObserver:observer forKeyPath:@"anInt" options:0 context:NULL];
        [badObservable willChangeValueForKey:@"anInt"];
        [badObservable addObserver:observer2 forKeyPath:@"anInt" options:0 context:NULL];
        [badObservable setAnInt:50];
        [badObservable didChangeValueForKey:@"anInt"];
        testassert([observer observationCountForKeyPath:@"anInt"] == 1); //TODO: is this a bug in iOS?
        testassert([observer2 observationCountForKeyPath:@"anInt"] == 0);
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        [badObservable removeObserver:observer2 forKeyPath:@"anInt"];
        return YES;
    }
}
-(BOOL)testMidCycleRegisterSame
{
    @autoreleasepool
    {
        ReallyBadObservable *badObservable = [ReallyBadObservable observable];
        Observer *observer = [Observer observer];
        [badObservable addObserver:observer forKeyPath:@"anInt" options:0 context:NULL];
        [badObservable willChangeValueForKey:@"anInt"];
        [badObservable addObserver:observer forKeyPath:@"anInt" options:0 context:NULL];
        [badObservable setAnInt:50];
        [badObservable didChangeValueForKey:@"anInt"];
        testassert([observer observationCountForKeyPath:@"anInt"] == 1); //TODO: is this a bug in iOS?
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        return YES;
    }
}

-(BOOL)testMidCyclePartialUnregister
{
    @autoreleasepool
    {
        ReallyBadObservable *badObservable = [ReallyBadObservable observable];
        Observer *observer = [Observer observer];
        [badObservable addObserver:observer forKeyPath:@"anInt" options:0 context:NULL];
        [badObservable addObserver:observer forKeyPath:@"anInt" options:0 context:NULL];
        [badObservable willChangeValueForKey:@"anInt"];
        [badObservable setAnInt:50];
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        [badObservable didChangeValueForKey:@"anInt"];
        testassert([observer observationCountForKeyPath:@"anInt"] == 2); //This seems wrong. 
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        return YES;
    }
}

-(BOOL)testMidCycleReregister
{
    @autoreleasepool
    {
        ReallyBadObservable *badObservable = [ReallyBadObservable observable];
        Observer *observer = [Observer observer];
        [badObservable addObserver:observer forKeyPath:@"anInt" options:0 context:NULL];
        [badObservable willChangeValueForKey:@"anInt"];
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        [badObservable setAnInt:50];
        [badObservable addObserver:observer forKeyPath:@"anInt" options:0 context:NULL];
        [badObservable didChangeValueForKey:@"anInt"];
        testassert([observer observationCountForKeyPath:@"anInt"] == 1); // really?
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        return YES;
    }
}


#undef OBSERVER_PROLOGUE
#undef OBSERVER_EPILOGUE

@end
