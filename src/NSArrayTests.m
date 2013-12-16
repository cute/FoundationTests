#import "FoundationTests.h"

#include <stdio.h>
#import <objc/runtime.h>

@interface NSArraySubclass : NSArray {
    NSArray *inner;
}
@property (nonatomic, readonly) BOOL didInit;
@end

@implementation NSArraySubclass

- (id)init
{
    self = [super init];
    if (self)
    {
        inner = [@[ @1, @2] retain];
        _didInit = YES;
    }
    return self;
}

- (void)dealloc
{
    [inner release];
    [super dealloc];
}

@end

@interface NSMutableArraySubclass : NSMutableArray {
    NSMutableArray *inner;
}
@property (nonatomic, readonly) BOOL didInit;
@property (nonatomic, readwrite) int cnt;
@end

@implementation NSMutableArraySubclass

- (id)init
{
    self = [super init];
    if (self)
    {
        _didInit = YES;
        inner = [@[ @1, @2] mutableCopy];
    }
    return self;
}

- (void)dealloc
{
    [inner release];
    [super dealloc];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    [inner insertObject:anObject atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [inner removeObjectAtIndex:index];
}

- (void)addObject:(id)anObject
{
    [inner addObject:anObject];
}

- (void)removeLastObject
{
    [inner removeLastObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [inner replaceObjectAtIndex:index withObject:anObject];
}

- (NSUInteger)count
{
    return [inner count];
}
@end

@testcase(NSArray)

- (BOOL)testNSArrayICreate0
{
    NSArray *a = [NSArray new];
    testassert(strcmp(object_getClassName(a), "__NSArrayI") == 0);
    [a release];
    return YES;
}

- (BOOL)testNSArrayICreate1
{
    NSArray *a = [NSArray arrayWithObject:@91];
    testassert(strcmp(object_getClassName(a), "__NSArrayI") == 0);
    return YES;
}

- (BOOL)testNSArrayICreate0Unique
{
    NSArray *a = [NSArray new];
    NSArray *b = [NSArray new];
    NSArray *c = [b copy];
    testassert(a == b);
    testassert(a == c);
    [a release];
    [b release];
    [c release];
    return YES;
}

- (BOOL)testAllocate
{
    NSArray *d1 = [NSArray alloc];
    NSArray *d2 = [NSArray alloc];

    // Array allocators return singletons
    testassert(d1 == d2);

    return YES;
}

- (BOOL)testAllocateMutable
{
    NSMutableArray *d1 = [NSMutableArray alloc];
    NSMutableArray *d2 = [NSMutableArray alloc];

    // Mutable array allocators return singletons
    testassert(d1 == d2);

    return YES;
}

- (BOOL)testBadCapacity
{
    __block BOOL raised = NO;
    __block NSMutableArray *array = nil;
    void (^block)(void) = ^{
        array = [[NSMutableArray alloc] initWithCapacity:1073741824];
    };
    @try {
        block();
    }
    @catch (NSException *e) {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        raised = YES;
    }
    testassert(raised);
    [array release];
    return YES;
}

- (BOOL)testLargeCapacity
{
    __block BOOL raised = NO;
    __block NSMutableArray *array = nil;
    void (^block)(void) = ^{
        array = [[NSMutableArray alloc] initWithCapacity:1073741823];
    };
    @try {
        block();
    }
    @catch (NSException *e) {
        raised = YES;
    }
    testassert(!raised);
    [array release];
    return YES;
}

- (BOOL)testAllocateDifferential
{
    NSArray *d1 = [NSArray alloc];
    NSMutableArray *d2 = [NSMutableArray alloc];

    // Mutable and immutable allocators must be from the same class
    testassert([d1 class] == [d2 class]);

    return YES;
}

- (BOOL)testAllocatedRetainCount
{
    NSArray *d = [NSArray alloc];

    // Allocators are singletons and have this retain count
    testassert([d retainCount] == NSUIntegerMax);

    return YES;
}

- (BOOL)testAllocatedClass
{
    // Allocation must be a NSArray subclass
    testassert([[NSArray alloc] isKindOfClass:[NSArray class]]);

    // Allocation must be a NSArray subclass
    testassert([[NSMutableArray alloc] isKindOfClass:[NSArray class]]);

    // Allocation must be a NSMutableArray subclass
    testassert([[NSArray alloc] isKindOfClass:[NSMutableArray class]]);

    // Allocation must be a NSMutableArray subclass
    testassert([[NSMutableArray alloc] isKindOfClass:[NSMutableArray class]]);

    return YES;
}

- (BOOL)testRetainCount
{
    NSArray *d = [NSArray alloc];

    testassert([d retainCount] == NSUIntegerMax);

    return YES;
}

- (BOOL)testDoubleDeallocAllocate
{
    NSArray *d = [NSArray alloc];

    // Releasing twice should not throw
    [d release];
    [d release];

    return YES;
}

- (BOOL)testDoubleInit
{
    void (^block)() = ^{
        [[NSArray arrayWithObjects:@"foo", @"bar", nil] initWithArray:@[@1, @2]];
    };

    // Double initialization should throw NSInvalidArgumentException
    BOOL raised = NO;

    @try {
        block();
    }
    @catch (NSException *e) {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        raised = YES;
    }

    testassert(raised);

    return YES;
}

- (BOOL)testBlankCreation
{
    NSArray *arr = [[NSArray alloc] init];

    // Blank initialization should return a Array
    testassert(arr != nil);

    [arr release];

    return YES;
}

- (BOOL)testBlankMutableCreation
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];

    // Blank initialization should return a Array
    testassert(arr != nil);

    [arr release];

    return YES;
}

- (BOOL)testDefaultCreation
{
    id obj1 = [[NSObject alloc] init];
    NSArray *obj = [NSArray alloc];
    NSArray *arr = [obj initWithObjects:&obj1 count:1];

    // Default initializer with one object should return a Array
    testassert(arr != nil);

    [arr release];

    return YES;
}

- (BOOL)testDefaultMutableCreation
{
    id obj1 = [[NSObject alloc] init];
    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:&obj1 count:1];

    // Default initializer with one object should return a Array
    testassert(arr != nil);

    [arr release];

    return YES;
}

- (BOOL)testDefaultCreationMany
{
    int count = 10;
    id *values = malloc(sizeof(id) * count);
    for (int i = 0; i < count; i++)
    {
        values[i] = [[[NSObject alloc] init] autorelease];
    }

    NSArray *arr = [[NSArray alloc] initWithObjects:values count:count];
    // Default initializer with <count> objects should return a Array
    testassert(arr != nil);

    [arr release];

    free(values);

    return YES;
}

- (BOOL)testVarArgsCreation
{
    NSArray *arr = [[NSArray alloc] initWithObjects:@"foo", @"bar", @"baz", @"bar", nil];

    // Var args initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);

    [arr release];

    return YES;
}

- (BOOL)testVarArgsMutableCreation
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:@"foo", @"bar", @"baz", @"bar", nil];

    // Var args initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableArray") class]]);

    [arr release];

    return YES;
}

- (BOOL)testOtherArrayCreation
{
    NSArray *arr = [[NSArray alloc] initWithArray:(NSArray *)@[
                                                                                    @"bar",
                                                                                    @"foo"
                                                                                    ]];

    // Other Array initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);

    [arr release];

    return YES;
}

- (BOOL)testOtherArrayMutableCreation
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:(NSArray *)@[
                            @"bar",
                            @"foo"
                            ]];
    // Other Array initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableArray") class]]);

    [arr release];

    return YES;
}

- (BOOL)testOtherArrayCopyCreation
{
    NSArray *arr = [[NSArray alloc] initWithArray:(NSArray *)@[
                     @"bar",
                     @"foo"
                     ] copyItems:YES];

    // Other Array initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);

    [arr release];

    return YES;
}

- (BOOL)testOtherArrayCopyMutableCreation
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:(NSArray *)@[
                            @"bar",
                            @"foo"
                            ] copyItems:YES];

    // Other Array initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableArray") class]]);

    [arr release];

    return YES;
}

- (BOOL)testOtherArrayNoCopyCreation
{
    NSArray *arr = [[NSArray alloc] initWithArray:(NSArray *)@[
                     @"bar",
                     @"foo"
                     ] copyItems:NO];

    // Other Array initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);

    [arr release];

    return YES;
}

- (BOOL)testOtherArrayNoCopyMutableCreation
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:(NSArray *)@[
                                                                                                  @"bar",
                                                                                                  @"foo"
                                                                                                  ]];

    // Other Array initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableArray") class]]);

    [arr release];

    return YES;
}

- (BOOL)testArrayCreation
{
    NSArray *arr = [[NSArray alloc] initWithObjects:@"foo", @"bar", @"baz", nil];

    // Array initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);

    [arr release];

    return YES;
}

- (BOOL)testArrayMutableCreation
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:@"foo", @"bar", @"baz", nil];

    // Array initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableArray") class]]);

    [arr release];

    return YES;
}

#warning TODO
#if 0

- (BOOL)testFileCreation
{
    NSArray *arr = [[NSArray alloc] initWithContentsOfFile:@"Info.plist"];

    // File initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);

    [arr release];

    return YES;
}

- (BOOL)testFileMutableCreation
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithContentsOfFile:@"Info.plist"];

    // File initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableArray") class]]);

    [arr release];

    return YES;
}

- (BOOL)testURLCreation
{
    NSArray *arr = [[NSArray alloc] initWithContentsOfURL:[NSURL fileURLWithPath:@"Info.plist"]];

    // File initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);

    [arr release];

    return YES;
}

- (BOOL)testURLMutableCreation
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithContentsOfURL:[NSURL fileURLWithPath:@"Info.plist"]];

    // File initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableArray") class]]);

    [arr release];

    return YES;
}

#endif

- (BOOL)testSubclassCreation
{
    NSArraySubclass *arr = [[NSArraySubclass alloc] init];

    // Created Array should not be nil
    testassert(arr != nil);

    // Array subclasses should funnel creation methods to initWithObjects:count:
    testassert(arr.didInit);

    [arr release];

    return YES;
}

- (BOOL)testDescription
{
    // If all keys are same type and type is sortable, description should sort

    NSArray *arr = @[ @1, @2, @3 ];
    NSString *d = @"(\n    1,\n    2,\n    3\n)";
    testassert([d isEqualToString:[arr description]]);

    NSArray *nestedInArray =  @[ @1, @{ @"k1": @111, @"k2" : @{ @"kk1" : @11, @"kk2" : @22, @"kk3" : @33}, @"k3": @333}, @3 ];
    d = @"(\n    1,\n        {\n        k1 = 111;\n        k2 =         {\n            kk1 = 11;\n            kk2 = 22;\n            kk3 = 33;\n        };\n        k3 = 333;\n    },\n    3\n)";
    testassert([d isEqualToString:[nestedInArray description]]);

    return YES;
}

- (BOOL)testSortedArrayUsingSelector
{
    NSArray *p = @[@3, @1, @2];
    NSArray *p2 = [ p sortedArrayUsingSelector:@selector(compare:)];
    BOOL isEqual = [p2 isEqualToArray:@[@1, @2, @3]];
    testassert(isEqual);

    NSArray *a = @[@"b", @"c", @"a"];
    NSArray *a2 = [ a sortedArrayUsingSelector:@selector(compare:)];
    isEqual = [a2 isEqualToArray:@[@"a", @"b", @"c"]];
    testassert(isEqual);

    return YES;
}

static NSComparisonResult compare(id a, id b, void *context)
{
    BOOL isEqual = [(NSArray *)context isEqualToArray:@[@3, @1, @2]];
    testassert(isEqual);
    return (NSComparisonResult)CFNumberCompare((CFNumberRef)a, (CFNumberRef)b, NULL);
}


- (BOOL)testSortedArrayUsingFunction
{
    NSArray *p = @[@3, @1, @2];
    NSArray *p2 = [ p sortedArrayUsingFunction:compare context:p];
    BOOL isEqual = [p2 isEqualToArray:@[@1, @2, @3]];
    testassert(isEqual);

    return YES;
}

- (BOOL)testSortedArrayUsingComparator
{
    NSArray *p = @[@3, @1, @2];
    NSArray *p2 = [ p sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return (NSComparisonResult)CFNumberCompare((CFNumberRef)obj1, (CFNumberRef)obj2, NULL);
    }];
    BOOL isEqual = [p2 isEqualToArray:@[@1, @2, @3]];
    testassert(isEqual);

    return YES;
}

- (BOOL)testRemoveAllObjects
{
    NSMutableArray *m = [@[@3, @1, @2] mutableCopy];
    testassert([m count] == 3);

    [m removeAllObjects];
    testassert([m count] == 0);

    /* Check on empty array */
    [m removeAllObjects];
    testassert([m count] == 0);

    [m addObject:@1];
    testassert([m count] == 1);

    return YES;
}

- (BOOL)testSubclassRemoveAllObjects
{
    NSMutableArraySubclass *m = [[NSMutableArraySubclass alloc] init];
    testassert([m count] == 2);

    [m removeAllObjects];
    testassert([m count] == 0);

    /* Check on empty array */
    [m removeAllObjects];
    testassert([m count] == 0);

    [m addObject:@1];
    testassert([m count] == 1);

    return YES;
}

- (BOOL)testRemoveObject
{
    NSMutableArray *m = [@[@3, @1, @2] mutableCopy];
    testassert([m count] == 3);

    [m removeObject:@2];
    testassert([m count] == 2);

    m = [@[@1, @1, @2, @1] mutableCopy];
    [m removeObject:@1];
    testassert([m count] == 1);

    [m removeObject:@2];
    testassert([m count] == 0);

    return YES;
}

- (BOOL) testReplaceObjectsInRange1
{
    NSMutableArray *m = [@[@1, @2] mutableCopy];
    id ids[2];
    ids[0] = @10; ids[1] = @20;
    [m replaceObjectsInRange:NSMakeRange(0,2) withObjects:ids count:2];
    testassert([m count] == 2);
    testassert([[m objectAtIndex:0] intValue] + [[m objectAtIndex:1] intValue] == 30);
    [m release];

    return YES;
}

- (BOOL) testReplaceObjectsInRange2
{
    NSMutableArray *m = [@[@1, @2] mutableCopy];
    id ids[2];
    ids[0] = @10; ids[1] = @20;
    [m replaceObjectsInRange:NSMakeRange(0,1) withObjects:ids count:2];
    testassert([m count] == 3);
    testassert([[m objectAtIndex:0] intValue] + [[m objectAtIndex:1] intValue]  + [[m objectAtIndex:2] intValue] == 32);
    [m release];

    return YES;
}

- (BOOL) testReplaceObjectsInRange3
{
    NSMutableArray *m = [@[] mutableCopy];
    id ids[2];
    [m replaceObjectsInRange:NSMakeRange(0,0) withObjects:ids count:0];
    testassert([m count] == 0);
    [m release];

    return YES;
}

- (BOOL) testReplaceObjectsInRange4
{
    NSMutableArray *m = [@[@1, @2] mutableCopy];
    id ids[2];
    [m replaceObjectsInRange:NSMakeRange(0,1) withObjects:ids count:0];
    testassert([m count] == 1);
    [m release];

    return YES;
}

- (BOOL) testReplaceObjectsInRange5
{
    NSMutableArray *m = [@[] mutableCopy];
    id ids[2];
    ids[0] = @10; ids[1] = @20;
    [m replaceObjectsInRange:NSMakeRange(0,0) withObjects:ids count:1];
    testassert([m count] == 1);
    testassert([[m objectAtIndex:0] intValue] == 10);
    [m release];

    return YES;
}


- (BOOL)testAddObjectsFromArray
{
    NSMutableArray *cs = [@[@9] mutableCopy];
    NSArray *a = @[@1, @2];
    [cs addObjectsFromArray:a];
    testassert([cs count] == 3);
    [cs release];

    return YES;
}

- (BOOL) testEnumeration
{
    NSArray *a = @[ @1, @2, @3];
    int sum = 0;
    for (NSNumber *n in a)
    {
        sum += [n intValue];
    }
    testassert(sum == 6);
    return YES;
}

- (BOOL) testEnumeration2
{
    int sum = 0;
    NSNumber *n;
    NSArray *a = @[ @1, @2, @3];
    NSEnumerator *nse = [a objectEnumerator];

    while( (n = [nse nextObject]) )
    {
        sum += [n intValue];
    }
    testassert(sum == 6);
    return YES;
}

- (BOOL) testEnumeration3
{
    NSString *s = @"a Z b Z c";

    NSArray *a = [[NSArray alloc] initWithArray:[s componentsSeparatedByString:@"Z"]];

    int sum = 0;
    NSEnumerator *nse = [a objectEnumerator];

    while([nse nextObject])
    {
        sum ++;
    }
    testassert(sum == 3);
    [a release];
    return YES;
}

- (BOOL)testRemoveRangeExceptions
{
    NSMutableArray *cs = [@[@9] mutableCopy];
    BOOL raised = NO;
    @try {
        [cs removeObjectAtIndex:NSNotFound];
    }
    @catch (NSException *caught) {
        raised = YES;
        testassert([[caught name] isEqualToString:NSRangeException]);
    }
    testassert(raised);

    raised = NO;
    @try {
        [cs removeObjectAtIndex:[cs count]];
    }
    @catch (NSException *caught) {
        raised = YES;
        testassert([[caught name] isEqualToString:NSRangeException]);
    }
    [cs release];
    testassert(raised);

    return YES;
}


- (BOOL)testContainsValue
{
    NSValue *bodyPoint = [NSValue valueWithPointer:(int *)0x12345678];
    NSArray *array = [NSArray arrayWithObject:bodyPoint];
    testassert([array containsObject:bodyPoint]);

    NSValue *bodyPoint2 = [NSValue valueWithPointer:(int *)0x12345678];
    testassert([array containsObject:bodyPoint2]);
    return YES;
}


- (BOOL) testIndexesOfObjectsPassingTest
{
    NSMutableArray *cs = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    NSIndexSet *is = [cs indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return ([obj intValue] & 1) == 0;
    }];
    testassert([is count] == 2);
    return YES;
}

- (BOOL) testEnumerateObjects
{
    NSMutableArray *cs = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [cs enumerateObjectsUsingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        sum += [obj intValue];
        *stop = idx == 2;
    }];
    testassert(sum == 6);
    return YES;
}

- (BOOL) testEnumerateObjectsWithOptions
{
    NSMutableArray *cs = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [cs enumerateObjectsWithOptions:0 usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        sum += [obj intValue];
        *stop = idx == 2;
    }];
    testassert(sum == 6);
    return YES;
}

- (BOOL) testEnumerateObjectsWithOptionsReverse
{
    NSMutableArray *cs = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [cs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        sum += [obj intValue];
        *stop = idx == 2;
    }];
    testassert(sum == 7);
    return YES;
}

- (BOOL) testEnumerateObjectsWithOptionsConcurrent
{
    NSMutableArray *cs = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [cs enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        @synchronized(self) {
            sum += [obj intValue];
        }
    }];
    testassert(sum == 10);
    return YES;
}

- (BOOL) testEnumerateObjectsWithOptionsReverseConcurrent
{
    NSMutableArray *cs = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [cs enumerateObjectsWithOptions:NSEnumerationReverse | NSEnumerationConcurrent usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        @synchronized(self) {
            sum += [obj intValue];
        }
    }];
    testassert(sum == 10);
    return YES;
}

//- (BOOL) testEnumerateObjectsAtIndexes
//{
//    NSIndexSet *is = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(2,2)];
//    NSMutableArray *cs = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
//    __block int sum = 0;
//    [cs enumerateObjectsAtIndexes:is options:0 usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
//        sum += [obj intValue];
//        *stop = idx == 2;
//    }];
//    testassert(sum == 3);
//    return YES;
//}
//
//- (BOOL) testEnumerateObjectsAtIndexesException
//{
//    NSIndexSet *is = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(3,2)];
//    NSMutableArray *cs = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
//    BOOL raised = NO;
//    __block int sum = 0;
//@try {
//    [cs enumerateObjectsAtIndexes:is options:0 usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
//        sum += [obj intValue];
//        *stop = idx == 2;
//    }];
//    }
//    @catch (NSException *caught) {
//        raised = YES;
//        testassert([[caught name] isEqualToString:NSRangeException]);
//    }
//    testassert(raised);
//
//    raised = NO;
//    @try {
//        [cs enumerateObjectsAtIndexes:is options:0 usingBlock:nil];
//    }
//    @catch (NSException *caught) {
//        raised = YES;
//        testassert([[caught name] isEqualToString:NSRangeException]);
//    }
//    testassert(raised);
//    return YES;
//}
//
//- (BOOL) testEnumerateObjectsAtIndexesReverse
//{
//    NSIndexSet *is = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(1,3)];
//    NSMutableArray *cs = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
//    __block int sum = 0;
//    [cs enumerateObjectsAtIndexes:is options:NSEnumerationReverse usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
//        sum += [obj intValue];
//        *stop = idx == 2;
//    }];
//    testassert(sum == 7);
//    return YES;
//}

@end
