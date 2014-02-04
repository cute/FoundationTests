#import "FoundationTests.h"

@interface KVCNSMutableArray : NSMutableArray
{
@public
    NSMutableArray *_backing;
}
@end

@implementation KVCNSMutableArray

-(id)init
{
    self = [super init];
    if (self)
    {
        _backing = [NSMutableArray new];
    }
    return self;
}

-(void)dealloc
{
    [_backing release];
    [super dealloc];
}

- (NSUInteger)count
{
    return track([_backing count]);
}

- (id)objectAtIndex:(NSUInteger)index
{
    return track([_backing objectAtIndex:index]);
}

- (void)addObject:(id)anObject
{
    track([_backing addObject:anObject]);
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    track([_backing insertObject:anObject atIndex:index]);
}

- (void)removeLastObject
{
    track([_backing removeLastObject]);
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    track([_backing removeObjectAtIndex:index]);
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    track([_backing replaceObjectAtIndex:index withObject:anObject]);
}

@end

@interface ArrayCodingMutationSubclassTest : KVCNSMutableArray
@end

@implementation ArrayCodingMutationSubclassTest

- (NSMutableArray*)foo
{
    // Use this object as both as the KVC target and the array which is proxied.
    // This allows us to track both calls to the target's accessors and the calls
    // to the proxied array, and see how they're interleaved.
    return track(self);
}

- (void)insertObject:(id)object inFooAtIndex:(NSUInteger)index
{
    track([self insertObject:object atIndex:index]);
}

- (void)removeObjectFromFooAtIndex:(NSUInteger)index
{
    track([self removeObjectAtIndex:index]);
}

@end

@interface ArrayCodingMutationIndexesSubclassTest : ArrayCodingMutationSubclassTest
@end

@implementation ArrayCodingMutationIndexesSubclassTest

- (void)insertFoo:(NSArray *)objects atIndexes:(NSIndexSet *)indexes
{
    track([self insertObjects:objects atIndexes:indexes]);
}

- (void)removeFooAtIndexes:(NSIndexSet *)indexes
{
    track([self removeObjectsAtIndexes:indexes]);
}

@end

@interface ArrayCodingMutationReplaceSubclassTest : ArrayCodingMutationSubclassTest
@end

@implementation ArrayCodingMutationReplaceSubclassTest

-(void)replaceObjectInFooAtIndex:(NSUInteger)index withObject:(id)anObject
{
    track([self replaceObjectAtIndex:index withObject:anObject]);
}

-(void)replaceFooAtIndexes:(NSIndexSet *)indexes withFoo:(NSArray *)objects
{
    track([self replaceObjectsAtIndexes:indexes withObjects:objects]);
}

@end

@interface ArrayCodingAccessorSubclassTest : KVCNSMutableArray
@end

@implementation ArrayCodingAccessorSubclassTest

- (NSMutableArray*)foo
{
    return track(self);
}

- (void)setFoo:(NSMutableArray*)array
{
    track(array);
    if (array != self) {
        array = [array retain];
        [_backing release];
        _backing = array;
    }
}

@end

@testcase(NSKeyValueCodingMutableContainerSubclass)

test(ArrayMutation_insertObject_atIndex_CallPattern)
{
    ArrayCodingMutationSubclassTest *target = [[[ArrayCodingMutationSubclassTest alloc] init] autorelease];
    
    NSMutableArray* foo = [target mutableArrayValueForKey:@"foo"];
    [foo addObject:@"Zero"];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(foo), @selector(count), @selector(insertObject:inFooAtIndex:), @selector(insertObject:atIndex:), nil];
    testassert(verified);
    
    return YES;
}

test(ArrayMutation_removeObjectAtIndex_CallPattern)
{
    ArrayCodingMutationSubclassTest *target = [[[ArrayCodingMutationSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@"Remove"];
    
    NSMutableArray* foo = [target mutableArrayValueForKey:@"foo"];
    [foo removeLastObject];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(foo), @selector(count), @selector(removeObjectFromFooAtIndex:), @selector(removeObjectAtIndex:), nil];
    testassert(verified);
    
    return YES;
}

test(ArrayMutation_insertObjects_atIndexes_CallPattern)
{
    ArrayCodingMutationIndexesSubclassTest *target = [[[ArrayCodingMutationIndexesSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@"One"];
    
    NSMutableArray* foo = [target mutableArrayValueForKey:@"foo"];
    NSArray *objects = @[@"Zero", @"Two"];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndex:0];
    [indexes addIndex:2];
    [foo insertObjects:objects atIndexes:indexes];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(insertFoo:atIndexes:), @selector(count), @selector(count), @selector(insertObject:atIndex:), @selector(count), @selector(insertObject:atIndex:), nil];
    testassert(verified);
    
    return YES;
}

test(ArrayMutation_removeObjectsAtIndexes_CallPattern)
{
    ArrayCodingMutationIndexesSubclassTest *target = [[[ArrayCodingMutationIndexesSubclassTest alloc] init] autorelease];
    [target->_backing addObjectsFromArray:@[@(0), @(1), @(2)]];
    
    NSMutableArray* foo = [target mutableArrayValueForKey:@"foo"];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndex:0];
    [indexes addIndex:2];
    [foo removeObjectsAtIndexes:indexes];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(removeFooAtIndexes:), @selector(count), @selector(count), @selector(removeObjectAtIndex:), @selector(count), @selector(removeObjectAtIndex:), nil];
    testassert(verified);
    
    return YES;
}

test(ArrayMutation_replaceObjectAtIndex_withObject_CallPattern)
{
    ArrayCodingMutationReplaceSubclassTest *target = [[[ArrayCodingMutationReplaceSubclassTest alloc] init] autorelease];
    [target->_backing addObjectsFromArray:@[@"Zero", @"Three", @"Two"]];
    
    NSMutableArray* foo = [target mutableArrayValueForKey:@"foo"];
    [foo replaceObjectAtIndex:1 withObject:@"One"];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(replaceObjectInFooAtIndex:withObject:), @selector(replaceObjectAtIndex:withObject:), nil];
    testassert(verified);
    
    return YES;
}

test(ArrayMutation_replaceObjectsAtIndexes_withObjects_CallPattern)
{
    ArrayCodingMutationReplaceSubclassTest *target = [[[ArrayCodingMutationReplaceSubclassTest alloc] init] autorelease];
    [target->_backing addObjectsFromArray:@[@(0), @"One", @(2), @"Three"]];
    
    NSMutableArray* foo = [target mutableArrayValueForKey:@"foo"];
    NSArray *objects = @[@(1), @(3)];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndex:1];
    [indexes addIndex:3];
    [foo replaceObjectsAtIndexes:indexes withObjects:objects];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(replaceFooAtIndexes:withFoo:), @selector(count), @selector(count), @selector(replaceObjectAtIndex:withObject:), @selector(count), @selector(replaceObjectAtIndex:withObject:), nil];
    testassert(verified);
    
    return YES;
}

test(ArrayAccessor_isEqualToArray_CallPattern)
{
    ArrayCodingAccessorSubclassTest *target = [[[ArrayCodingAccessorSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@(42)];
    
    NSMutableArray* foo = [target mutableArrayValueForKey:@"foo"];
    [foo isEqualToArray:@[@(42)]];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(foo), @selector(count), @selector(foo), @selector(count), @selector(objectAtIndex:), nil];
    testassert(verified);
    
    return YES;
}

test(ArrayAccessor_addObject_CallPattern)
{
    ArrayCodingAccessorSubclassTest *target = [[[ArrayCodingAccessorSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@"Hello"];
    
    NSMutableArray* foo = [target mutableArrayValueForKey:@"foo"];
    [foo addObject:@" and "];
    [foo addObject:@"welcome!"];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(foo), @selector(count), @selector(count), @selector(count), @selector(objectAtIndex:), @selector(setFoo:), @selector(foo), @selector(count), @selector(count), @selector(count), @selector(objectAtIndex:), @selector(objectAtIndex:), @selector(setFoo:), nil];
    testassert(verified);

    return YES;
}

test(ArrayAccessor_removeObjectAtIndex_CallPattern)
{
    ArrayCodingAccessorSubclassTest *target = [[[ArrayCodingAccessorSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@"Hello, world!"];
    
    NSMutableArray* foo = [target mutableArrayValueForKey:@"foo"];
    [foo removeObjectAtIndex:0];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(foo), @selector(count), @selector(count), @selector(count), @selector(objectAtIndex:), @selector(setFoo:), nil];
    testassert(verified);
    
    return YES;
}

@end
