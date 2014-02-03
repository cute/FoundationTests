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

@testcase(NSKeyValueCodingSubclass)

test(Mutation_insertObject_atIndex_CallPattern)
{
    ArrayCodingMutationSubclassTest *target = [[[ArrayCodingMutationSubclassTest alloc] init] autorelease];
    
    NSMutableArray* foo = [target mutableArrayValueForKey:@"foo"];
    [foo addObject:@"Zero"];
    
//    [SubclassTracker dumpVerification:target]
    BOOL verified = [SubclassTracker verify:target commands:@selector(foo), @selector(count), @selector(insertObject:inFooAtIndex:), @selector(insertObject:atIndex:), nil];
    testassert(verified);
    
    return YES;
}

test(Mutation_removeObjectAtIndex_CallPattern)
{
    ArrayCodingMutationSubclassTest *target = [[[ArrayCodingMutationSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@"Remove"];
    
    NSMutableArray* foo = [target mutableArrayValueForKey:@"foo"];
    [foo removeLastObject];
    
//    [SubclassTracker dumpVerification:target]
    BOOL verified = [SubclassTracker verify:target commands:@selector(foo), @selector(count), @selector(removeObjectFromFooAtIndex:), @selector(removeObjectAtIndex:), nil];
    testassert(verified);
    
    return YES;
}

test(Accessor_isEqualToArray_CallPattern)
{
    ArrayCodingAccessorSubclassTest *target = [[[ArrayCodingAccessorSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@(42)];
    
    NSMutableArray* foo = [target mutableArrayValueForKey:@"foo"];
    [foo isEqualToArray:@[@(42)]];
    
//    [SubclassTracker dumpVerification:target]
    BOOL verified = [SubclassTracker verify:target commands:@selector(foo), @selector(count), @selector(foo), @selector(count), @selector(objectAtIndex:), nil];
    testassert(verified);
    
    return YES;
}

test(Accessor_addObject_CallPattern)
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

test(Accessor_removeObjectAtIndex_CallPattern)
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
