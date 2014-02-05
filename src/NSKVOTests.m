#import "FoundationTests.h"
#import <objc/runtime.h>

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

@interface DependentObservable : Observable
{
    float _aFloat;
}
@property float aFloat;
@end

@implementation DependentObservable
+ (NSSet *)keyPathsForValuesAffectingAFloat
{
    return [NSSet setWithObject:@"anInt"];
}
@end

@interface NestedObservable : Observable
@property (nonatomic, strong) NestedObservable *nested;
@end
@implementation NestedObservable
@end

@interface NameClass : NSObject
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@end

@implementation NameClass
@end

@interface NestedDependentObservable : Observable
@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, strong) NameClass *nameObject;
@end

@implementation NestedDependentObservable
+ (NSSet *)keyPathsForValuesAffectingFullName
{
    return [NSSet setWithObjects:@"nameObject.firstName", @"nameObject.lastName", nil];
}
@end

// -----------------------------

@interface ObjectWithInternalObserver : NSObject
@end

@implementation ObjectWithInternalObserver {
    NSObject *_internal;
}

- (id)init
{
    self = [super init];
    if (self) {
        _internal = [[NSObject alloc] init];
        [self addObserver:_internal
               forKeyPath:@"fooKeyPath"
                  options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew)
                  context:NULL];
        [self addObserver:_internal
               forKeyPath:@"barKeyPath"
                  options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew)
                  context:NULL];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:_internal forKeyPath:@"barKeyPath"];
    [self removeObserver:_internal forKeyPath:@"fooKeyPath"];
    [_internal release];
    _internal = nil;
    [super dealloc];
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

test(BasicNotifyingInstanceCharacteristics)
{
    @autoreleasepool
    {
        Observable *observable = [Observable observable];
        Observer *observer = [Observer observer];
        Class originalObservableClass = object_getClass(observable);
        IMP originalClassIMP = class_getMethodImplementation(originalObservableClass, @selector(class));
        IMP originalDeallocIMP = class_getMethodImplementation(originalObservableClass, @selector(dealloc));
        IMP original_isKVOAIMP = class_getMethodImplementation(originalObservableClass, @selector(_isKVOA)); // this should be NULL.
        IMP originalSetterIMP = class_getMethodImplementation(originalObservableClass, @selector(setAnInt:));
        id originalObservationInfo = [observable observationInfo];
        [observable addObserver:observer forKeyPath:@"anInt" options:0 context:NULL];
        id notifyingObservationInfo = [observable observationInfo];
        Class notifyingObservableClass = object_getClass(observable);
        IMP notifyingClassIMP = class_getMethodImplementation(notifyingObservableClass, @selector(class));
        IMP notifyingDeallocIMP = class_getMethodImplementation(notifyingObservableClass, @selector(dealloc));
        IMP notifying_isKVOAIMP = class_getMethodImplementation(notifyingObservableClass, @selector(_isKVOA));
        IMP notifyingSetterIMP = class_getMethodImplementation(notifyingObservableClass, @selector(setAnInt:));
        testassert([observable class] == [Observable class]);
        testassert(object_getClass(observable) == NSClassFromString(@"NSKVONotifying_Observable"));
        testassert([observable class] != object_getClass(observable));
        testassert(originalObservableClass != notifyingObservableClass);
        testassert(originalClassIMP != notifyingClassIMP);
        testassert(originalDeallocIMP != notifyingDeallocIMP);
        testassert(original_isKVOAIMP != notifying_isKVOAIMP);
        testassert(originalSetterIMP != notifyingSetterIMP);
        testassert(originalObservationInfo != notifyingObservationInfo);
        [observable removeObserver:observer forKeyPath:@"anInt"];
        id postRemoveObservationInfo = [observable observationInfo];
        testassert(originalObservableClass == object_getClass(observable));
        testassert(postRemoveObservationInfo == originalObservationInfo);
        return YES;
    }
}

test(ZeroObservances)
{
    OBSERVER_PROLOGUE(Observable, @"anInt", 0, NULL);

    testassert([observer observationCountForKeyPath:keyPath] == 0);

    OBSERVER_EPILOGUE();
}

test(SingleObservance)
{
    OBSERVER_PROLOGUE(Observable, @"anInt", 0, NULL);

    [observable setAnInt:42];

    testassert([observer observationCountForKeyPath:keyPath] == 1);

    OBSERVER_EPILOGUE();
}

test(ManyObservances)
{
    static const NSUInteger iterations = 10;

    OBSERVER_PROLOGUE(Observable, @"anInt", 0, NULL);

    for (NSUInteger i = 0; i < iterations; i++)
    {
        [observable setAnInt:i];
    }

    testassert([observer observationCountForKeyPath:keyPath] == iterations);

    OBSERVER_EPILOGUE();
}

test(PriorObservance)
{
    OBSERVER_PROLOGUE(Observable, @"anInt", NSKeyValueObservingOptionPrior, NULL);

    [observable setAnInt:42];

    testassert([observer priorObservationMadeForKeyPath:keyPath]);

    OBSERVER_EPILOGUE();
}

test(ZeroObservancesWithBadObservable)
{
    OBSERVER_PROLOGUE(BadObservable, @"anInt", 0, NULL);

    testassert([observer observationCountForKeyPath:keyPath] == 0);

    OBSERVER_EPILOGUE();
}

test(SingleObservanceWithBadObservable)
{
    OBSERVER_PROLOGUE(BadObservable, @"anInt", 0, NULL);

    [observable setAnInt:42];

    testassert([observer observationCountForKeyPath:keyPath] == 1);

    OBSERVER_EPILOGUE();
}

test(ManyObservancesWithBadObservable)
{
    static const NSUInteger iterations = 10;

    OBSERVER_PROLOGUE(BadObservable, @"anInt", 0, NULL);

    for (NSUInteger i = 0; i < iterations; i++)
    {
        [observable setAnInt:i];
    }

    testassert([observer observationCountForKeyPath:keyPath] == iterations);

    OBSERVER_EPILOGUE();
}

test(PriorObservanceWithBadObservable)
{
    OBSERVER_PROLOGUE(BadObservable, @"anInt", NSKeyValueObservingOptionPrior, NULL);

    [observable setAnInt:42];

    testassert([observer priorObservationMadeForKeyPath:keyPath]);

    OBSERVER_EPILOGUE();
}


test(DependantKeyChange)
{
    @autoreleasepool
    {
        DependentObservable *observable = [DependentObservable observable];
        Observer *observer = [Observer observer];
        [observable addObserver:observer forKeyPath:@"aFloat" options:0 context:NULL];
        [observable setAnInt:5];
        [observable removeObserver:observer forKeyPath:@"aFloat"];
        testassert([observer observationCountForKeyPath:@"aFloat"] == 1);
        return YES;
    }
}
test(DependantKeyIndependentChange)
{
    @autoreleasepool
    {
        DependentObservable *observable = [DependentObservable observable];
        Observer *observer = [Observer observer];
        [observable addObserver:observer forKeyPath:@"aFloat" options:0 context:NULL];
        [observable setAFloat:5.0f];
        [observable removeObserver:observer forKeyPath:@"aFloat"];
        testassert([observer observationCountForKeyPath:@"aFloat"] == 1);
        return YES;
    }
}
test(NestedDependantKeyChange)
{
    @autoreleasepool
    {
        NestedDependentObservable *observable = [NestedDependentObservable observable];
        Observer *observer = [Observer observer];
        observable.nameObject = [NameClass new];
        [observable addObserver:observer forKeyPath:@"fullName" options:0 context:NULL];
        [observable.nameObject setFirstName:@"Bob"];
        [observable removeObserver:observer forKeyPath:@"fullName"];
        testassert([observer observationCountForKeyPath:@"fullName"] == 1);
        return YES;
    }
}
test(NestedDependantKeyUnnestedChange)
{
    @autoreleasepool
    {
        NestedDependentObservable *observable = [NestedDependentObservable observable];
        Observer *observer = [Observer observer];
        observable.nameObject = [NameClass new];
        [observable addObserver:observer forKeyPath:@"fullName" options:0 context:NULL];
        observable.nameObject = [NameClass new];
        [observable removeObserver:observer forKeyPath:@"fullName"];
        testassert([observer observationCountForKeyPath:@"fullName"] == 1);
        return YES;
    }
}


test(NestedObservableLeaf)
{
    @autoreleasepool
    {
        NestedObservable *topLevelObservable = [NestedObservable observable];
        NestedObservable *leafObservable = [NestedObservable observable];
        topLevelObservable.nested = leafObservable;
        Observer *observer = [Observer observer];
        [topLevelObservable addObserver:observer forKeyPath:@"nested.anInt" options:0 context:NULL];
        [leafObservable setAnInt:5];
        [topLevelObservable removeObserver:observer forKeyPath:@"nested.anInt"];
        testassert([observer observationCountForKeyPath:@"nested.anInt"] == 1);
        return YES;
    }
}

test(NestedObservableBranch)
{
    @autoreleasepool
    {
        NestedObservable *topLevelObservable = [NestedObservable observable];
        NestedObservable *leafObservable = [NestedObservable observable];
        leafObservable.anInt = 5;
        Observer *observer = [Observer observer];
        [topLevelObservable addObserver:observer forKeyPath:@"nested.anInt" options:0 context:NULL];
        [topLevelObservable setNested:leafObservable];
        [topLevelObservable removeObserver:observer forKeyPath:@"nested.anInt"];
        testassert([observer observationCountForKeyPath:@"nested.anInt"] == 1);
        return YES;
    }
}

// "Bad" Tests. These tests tests things you shouldn't do with KVO that existing implementations
// let you do anyway. It would not more accurate to call these tests of unspecified behavior
// rather than undocumented, although they are generally not documented either. These tests have
// the potential to break the global data structures used by KVO; as such they are at the bottom
// of the test suite, and should remain there, to avoid fouling other tests. Tests which are found
// to break these data structures should be removed. As some of them are relatively common
// programming errors, however, they should be supported where possible, at least to the extent
// that exists in KVO implementations already.

test(MidCycleUnregister)
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
test(MidCycleRegister)
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
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        [badObservable removeObserver:observer2 forKeyPath:@"anInt"];
        testassert([observer observationCountForKeyPath:@"anInt"] == 1); //TODO: is this a bug in iOS?
        testassert([observer2 observationCountForKeyPath:@"anInt"] == 0);
        return YES;
    }
}
test(MidCycleRegisterSame)
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
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        testassert([observer observationCountForKeyPath:@"anInt"] == 1); //TODO: is this a bug in iOS?
        return YES;
    }
}

test(MidCyclePartialUnregister)
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
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        testassert([observer observationCountForKeyPath:@"anInt"] == 2); //This seems wrong.
        return YES;
    }
}

test(MidCycleReregister)
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
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        testassert([observer observationCountForKeyPath:@"anInt"] == 1); // really?
        return YES;
    }
}

test(MidCycleReregisterWithContext)
{
    @autoreleasepool
    {
        ReallyBadObservable *badObservable = [ReallyBadObservable observable];
        Observer *observer = [Observer observer];
        [badObservable addObserver:observer forKeyPath:@"anInt" options:0 context:NULL];
        [badObservable willChangeValueForKey:@"anInt"];
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        [badObservable setAnInt:50];
        [badObservable addObserver:observer forKeyPath:@"anInt" options:0 context:badObservable];
        [badObservable didChangeValueForKey:@"anInt"];
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        testassert([observer observationCountForKeyPath:@"anInt"] == 0);
        return YES;
    }
}

#undef OBSERVER_PROLOGUE
#undef OBSERVER_EPILOGUE

@end
