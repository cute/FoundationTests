#import "FoundationTests.h"

#include <stdio.h>
#import <objc/runtime.h>

@interface ArrayCodingMutationTest : NSObject
@end

@implementation ArrayCodingMutationTest
{
    // Not naming instance variable _foo to ensure accessors used.
    NSMutableArray *_boo;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _boo = [[NSMutableArray alloc] initWithObjects:@(42), nil];
    }
    return self;
}

- (void)dealloc
{
    [_boo release];
    [super dealloc];
}

- (NSMutableArray*)foo
{
    return _boo;
}

- (void)insertObject:(id)object inFooAtIndex:(NSUInteger)index
{
    [_boo insertObject:object atIndex:index];
}

- (void)removeObjectFromFooAtIndex:(NSUInteger)index
{
    [_boo removeObjectAtIndex:index];
}

@end

@interface ArrayCodingAccessorTest : NSObject
{
    NSMutableArray *_boo;
}
@end

@implementation ArrayCodingAccessorTest

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _boo = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_boo release];
    [super dealloc];
}

- (NSMutableArray*)foo
{
    return _boo;
}

- (void)setFoo:(NSMutableArray*)array
{
    array = [array retain];
    [_boo release];
    _boo = array;
}

@end

@interface ArrayCodingInstanceVariableTest : NSObject
{
@public
    NSMutableArray *_foo;
}
@end

@implementation ArrayCodingInstanceVariableTest

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _foo = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_foo release];
    [super dealloc];
}

@end

@interface ArrayCodingUndefinedKeyTest : NSObject
{
@public
    NSMutableArray *_boo;
}
@end

@implementation ArrayCodingUndefinedKeyTest

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _boo = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_boo release];
    [super dealloc];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"foo"]) {
        return _boo;
    }
    else {
        return [super valueForUndefinedKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"foo"]) {
        value = [value retain];
        [_boo release];
        _boo = value;
    }
    else {
        [super setValue:value forUndefinedKey:key];
    }
}

@end

@interface OrderedSetCodingTest : NSObject
@end

@implementation OrderedSetCodingTest
{
    NSMutableOrderedSet *_boo;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _boo = [[NSMutableOrderedSet alloc] initWithObjects:@(42), nil];
    }
    return self;
}

- (void)dealloc
{
    [_boo release];
    [super dealloc];
}

- (void)insertObject:(id)object inFooAtIndex:(NSUInteger)index
{
    [_boo insertObject:object atIndex:index];
}

- (void)removeObjectFromFooAtIndex:(NSUInteger)index
{
    [_boo removeObjectAtIndex:index];
}

@end

@interface SetCodingTest : NSObject
@end

@implementation SetCodingTest
{
    NSMutableSet *_foo;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _foo = [[NSMutableSet alloc] initWithObjects:@(42), nil];
    }
    return self;
}

- (void)dealloc
{
    [_foo release];
    [super dealloc];
}

- (void)addFooObject:(id)object
{
    [_foo addObject:object];
}

- (void)removeFooObject:(id)object
{
    [_foo removeObject:object];
}

@end


@testcase(NSKeyValueCodingContainer)

test(mutableArrayValueForKey_basicMutationMethodAccess)
{
    ArrayCodingMutationTest *arrayCoding = [[[ArrayCodingMutationTest alloc] init] autorelease];
    
    NSMutableArray *mutableArrayValues = [arrayCoding mutableArrayValueForKey:@"foo"];
    testassert([mutableArrayValues isEqualToArray:@[@(42)]]);

    [mutableArrayValues insertObject:@(23) atIndex:1];
    testassert([arrayCoding.foo isEqualToArray:@[@(42), @(23)]]);

    [mutableArrayValues insertObject:@(23) atIndex:2];
    testassert([mutableArrayValues isEqualToArray:@[@(42), @(23), @(23)]]);

    [mutableArrayValues removeObjectAtIndex:0];
    testassert([arrayCoding.foo isEqualToArray:@[@(23), @(23)]]);

    [mutableArrayValues removeObjectAtIndex:0];
    testassert([mutableArrayValues isEqualToArray:@[@(23)]]);

    [mutableArrayValues removeObjectAtIndex:0];
    testassert([arrayCoding.foo isEqualToArray:@[]]);

    return YES;
}

test(mutableArrayValueForKey_basicAccessorMethodAccess)
{
    ArrayCodingAccessorTest *arrayCoding = [[[ArrayCodingAccessorTest alloc] init] autorelease];
    
    NSMutableArray* foo = [arrayCoding mutableArrayValueForKey:@"foo"];
    testassert(foo != arrayCoding.foo);
    
    [foo addObject:@"bar"];
    testassert([foo isEqualToArray:@[@"bar"]]);
    
    [foo insertObject:@"baz" atIndex:0];
    testassert([foo isEqualToArray:arrayCoding.foo]);
    
    [foo removeLastObject];
    testassert([arrayCoding.foo isEqualToArray:@[@"baz"]]);
    
    [foo replaceObjectAtIndex:0 withObject:@"qux"];
    testassert([foo isEqualToArray:arrayCoding.foo]);
    
    [foo removeObjectAtIndex:0];
    testassert([foo isEqualToArray:@[]]);
    
    [foo insertObjects:@[@(1), @(2), @(3)] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
    testassert([foo isEqualToArray:@[@(1), @(2), @(3)]]);
    
    [foo removeAllObjects];
    testassert([foo isEqualToArray:@[]]);
    
    return YES;
}

test(mutableArrayValueForKey_modifyUnderlyingContainer)
{
    ArrayCodingAccessorTest *arrayCoding = [[[ArrayCodingAccessorTest alloc] init] autorelease];
    
    NSMutableArray* foo = [arrayCoding mutableArrayValueForKey:@"foo"];
    testassert([foo isEqualToArray:@[]]);
    
    [arrayCoding setFoo:[NSMutableArray arrayWithObject:@(42)]];
    testassert([foo isEqualToArray:arrayCoding.foo]);
    
    NSMutableArray* observedFoo = arrayCoding.foo;
    [observedFoo addObject:@(32)];
    testassert([foo isEqualToArray:observedFoo]);
    
    [observedFoo sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int val1 = [obj1 integerValue];
        int val2 = [obj2 integerValue];
        if (val1 < val2)
            return NSOrderedAscending;
        else if (val2 < val1)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
    testassert([foo isEqualToArray:@[@(32), @(42)]]);
    
    return YES;
}

test(mutableArrayValueForKey_basicInstanceVariableAccess)
{
    ArrayCodingInstanceVariableTest *arrayCoding = [[[ArrayCodingInstanceVariableTest alloc] init] autorelease];
    
    NSMutableArray* foo = [arrayCoding mutableArrayValueForKey:@"foo"];
    testassert(foo != arrayCoding->_foo);
    
    [foo addObject:@"One"];
    testassert([arrayCoding->_foo isEqualToArray:@[@"One"]]);
    
    [arrayCoding->_foo addObject:@"Two"];
    testassert([foo isEqualToArray:@[@"One", @"Two"]]);
    
    [foo addObject:@"Three"];
    testassert([foo isEqualToArray:arrayCoding->_foo]);
    
    return YES;
}

test(mutableArrayValueForKey_basicUndefinedKeyAccess)
{
    ArrayCodingUndefinedKeyTest *arrayCoding = [[[ArrayCodingUndefinedKeyTest alloc] init] autorelease];
    
    NSMutableArray* foo = [arrayCoding mutableArrayValueForKey:@"foo"];
    [foo addObjectsFromArray:@[@"A", @"B", @"C"]];
    [arrayCoding->_boo isEqualToArray:@[@"A", @"B", @"C"]];
    
    NSMutableArray* bar = [arrayCoding mutableArrayValueForKey:@"bar"];
    BOOL thrown = NO;
    @try {
        [bar addObject:@"Oops"];
    } @catch(NSException *e) {
        thrown = [[e name] isEqualToString:NSUndefinedKeyException];
    }
    testassert(thrown);
    
    return YES;
}

test(mutableOrderedSetValueForKey_basicMethodAccess)
{
    OrderedSetCodingTest *orderedSetCoding = [[[OrderedSetCodingTest alloc] init] autorelease];

    [orderedSetCoding insertObject:@(23) inFooAtIndex:1];
    NSMutableOrderedSet *mutableOrderedSetValues = [orderedSetCoding mutableOrderedSetValueForKey:@"foo"];
    testassert([mutableOrderedSetValues isEqualToOrderedSet:[NSOrderedSet orderedSetWithArray:@[@(42), @(23)]]]);

    [orderedSetCoding insertObject:@(23) inFooAtIndex:2];
    mutableOrderedSetValues = [orderedSetCoding mutableOrderedSetValueForKey:@"foo"];
    testassert([mutableOrderedSetValues isEqualToOrderedSet:[NSOrderedSet orderedSetWithArray:@[@(42), @(23)]]]);

    [orderedSetCoding removeObjectFromFooAtIndex:0];
    mutableOrderedSetValues = [orderedSetCoding mutableOrderedSetValueForKey:@"foo"];
    testassert([mutableOrderedSetValues isEqualToOrderedSet:[NSOrderedSet orderedSetWithArray:@[@(23)]]]);

    [orderedSetCoding removeObjectFromFooAtIndex:0];
    mutableOrderedSetValues = [orderedSetCoding mutableOrderedSetValueForKey:@"foo"];
    testassert([mutableOrderedSetValues isEqualToOrderedSet:[NSOrderedSet orderedSetWithArray:@[]]]);

    return YES;
}

test(mutableSetValueForKey_basicMethodAccess)
{
    SetCodingTest *setCoding = [[[SetCodingTest alloc] init] autorelease];

    [setCoding addFooObject:@(23)];
    NSMutableSet *mutableSetValues = [setCoding mutableSetValueForKey:@"foo"];
    testassert([mutableSetValues isEqualToSet:[NSSet setWithArray:@[@(42), @(23)]]]);

    [setCoding addFooObject:@(23)];
    mutableSetValues = [setCoding mutableSetValueForKey:@"foo"];
    testassert([mutableSetValues isEqualToSet:[NSSet setWithArray:@[@(42), @(23)]]]);

    [setCoding removeFooObject:@(42)];
    mutableSetValues = [setCoding mutableSetValueForKey:@"foo"];
    testassert([mutableSetValues isEqualToSet:[NSSet setWithArray:@[@(23)]]]);

    [setCoding removeFooObject:@(23)];
    mutableSetValues = [setCoding mutableSetValueForKey:@"foo"];
    testassert([mutableSetValues isEqualToSet:[NSSet setWithArray:@[]]]);

    return YES;
}

@end
