#import "FoundationTests.h"

@testcase(NSOrderedSet)

- (BOOL)testBlankCreation
{
    NSOrderedSet *os = [[NSOrderedSet alloc] init];

    // Blank initialization should return an ordered set
    testassert(os != nil);

    [os release];

    return YES;
}

- (BOOL)testDefaultCreationMany
{
    int count = 10;
    NSObject **members = malloc(2 * sizeof(*members) * count);
    for (int i = 0; i < count; i++)
    {
        members[i] = [[NSObject alloc] init];
        members[i + count] = members[i];
    }

    NSOrderedSet *os = [[NSOrderedSet alloc] initWithObjects:members count:2*count];

    // Default initializer with <count> objects should return an ordered set
    testassert(os != nil);

    [os release];

    free(members);

    return YES;
}

- (BOOL)testDefaultCreationWithArray
{
    NSOrderedSet *os = [[NSOrderedSet alloc] initWithArray:@[@1, @2]];

    // Default initializer with <count> should return a countable ordered set
    testassert(os != nil);
    testassert([os count] == 2);

    [os release];

    return YES;
}

- (BOOL)testOrderedSetCreation
{
    NSOrderedSet *s = [[NSOrderedSet alloc] initWithObjects:
                [[[NSObject alloc] init] autorelease],
                [[[NSObject alloc] init] autorelease],
                [[[NSObject alloc] init] autorelease],
                nil];
    NSOrderedSet *os = [[NSOrderedSet alloc] initWithOrderedSet:s];

    // OrderedSet initializer should return a countable ordered set
    testassert(os != nil);

    [s release];
    [os release];

    return YES;
}

- (BOOL)testOrderedSetWithCopyCreation
{
    // Ideally we would use just NSObjects for this test, but they are not copyable.
    NSOrderedSet *s = [[NSOrderedSet alloc] initWithObjects:
                @"",
                @"",
                @"",
                nil];
    NSOrderedSet *os = [[NSOrderedSet alloc] initWithOrderedSet:s copyItems:YES];

    // OrderedSet initializer should return an ordered set
    testassert([os count] == 1);
    testassert(os != nil);

    [s release];
    [os release];

    return YES;
}

- (BOOL)testOrderedSetWithoutCopyCreation
{
    NSOrderedSet *s = [[NSOrderedSet alloc] initWithObjects:
                [[[NSObject alloc] init] autorelease],
                [[[NSObject alloc] init] autorelease],
                [[[NSObject alloc] init] autorelease],
                nil];
    NSOrderedSet *os = [[NSOrderedSet alloc] initWithOrderedSet:s copyItems:NO];

    // OrderedSet initializer should return a countable ordered set
    testassert(os != nil);

    [s release];
    [os release];

    return YES;
}

- (BOOL)testVarArgsCreation
{
    NSOrderedSet *os = [[NSOrderedSet alloc] initWithObjects:
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        nil];

    // Var args initializer should return a countable ordered set
    testassert(os != nil);

    [os release];

    return YES;
}

- (BOOL)testArrayCreation
{
    NSOrderedSet *os = [[NSOrderedSet alloc] initWithArray:@[
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        ]];

    // Array initializer should return a countable ordered set
    testassert(os != nil);

    [os release];

    return YES;
}

- (BOOL)testDoubleInit
{
    void (^block)() = ^{
        NSOrderedSet *s = [[NSOrderedSet alloc] initWithObjects:
                    [[[NSObject alloc] init] autorelease],
                    [[[NSObject alloc] init] autorelease],
                    [[[NSObject alloc] init] autorelease],
                    nil];

        NSOrderedSet *os = [[[NSOrderedSet alloc] initWithOrderedSet:s] initWithOrderedSet:s];

        [s release];
        [os release];
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

#warning MINOR: Make double initialization raise an exception
    // testassert(raised);

    return YES;
}

- (BOOL)testContainsObject
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSOrderedSet *os = [[NSOrderedSet alloc] initWithObjects: o1, o2, o2, nil];

    // Count for object
    testassert(os != nil);

    testassert(![os containsObject:o0]);
    testassert([os containsObject:o1]);
    testassert([os containsObject:o2]);

    testassert(![os containsObject:nil]);

    testassert([os count] == 2);

    [os release];

    return YES;
}

- (BOOL)testAddObject
{
    NSMutableOrderedSet *os = [[NSMutableOrderedSet alloc] init];
    int count = 10;
    NSObject **members = malloc(sizeof(*members) * count);

    for (int i = 0; i < count; i++)
    {
        members[i] = [[NSObject alloc] init];
        for (int inserts = 0; inserts < i; inserts++)
        {
            [os addObject:members[i]];
        }
    }

    // Count for object
    for (int i = 1; i < count; i++)
    {
        testassert([os containsObject:members[i]]);
    }

    [os release];

    free(members);

    return YES;
}

- (BOOL)testAddObjectNil
{
    void (^block)() = ^{
        NSMutableOrderedSet *os = [[[NSMutableOrderedSet alloc] init] autorelease];
        [os addObject:nil];
    };

    // Adding nil should throw NSInvalidArgumentException
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

- (BOOL)testRemoveObject
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSMutableOrderedSet *os = [[NSMutableOrderedSet alloc] initWithObjects: o1, o2, o2, nil];

    // Removing an object not in the countable ordered set should not throw
    [os removeObject:o0];
    [os removeObject:o1];
    [os removeObject:o1];

    testassert(![os containsObject:o0]);
    testassert(![os containsObject:o1]);
    testassert([os containsObject:o2]);

    [os release];

    return YES;
}

- (BOOL)testRemoveObjectNil
{
    // Removing nil should not throw
    NSMutableOrderedSet *os = [[[NSMutableOrderedSet alloc] init] autorelease];
    [os removeObject:nil];

    return YES;
}

- (BOOL)testNilContainsObject
{
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSOrderedSet *os = [[NSOrderedSet alloc] initWithObjects: o1, o2, o2, nil];

    testassert(![os containsObject:nil]);

    [os release];

    return YES;
}

- (BOOL)testCount
{
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSOrderedSet *os = [[NSOrderedSet alloc] initWithObjects: o1, o2, o2, nil];

    testassert([os count] == 2);

    [os release];

    return YES;
}

- (BOOL)testObjectEnumerator
{
    NSMutableOrderedSet *os = [[NSMutableOrderedSet alloc] init];
    int count = 10;
    NSObject **members = malloc(sizeof(*members) * count);
    int *counts = calloc(sizeof(*counts), count);

    for (int i = 0; i < count; i++)
    {
        members[i] = [[NSObject alloc] init];
        for (int inserts = 0; inserts < i; inserts++)
        {
            [os addObject:members[i]];
        }
    }

    // Count for object
    for (int i = 1; i < count; i++)
    {
        testassert([os containsObject:members[i]]);
    }

    id object;
    NSEnumerator *enumerator = [os objectEnumerator];
    while ((object = [enumerator nextObject]) != nil)
    {
        BOOL found = NO;
        for (int i = 0; i < count; i++)
        {
            if ([object isEqual:members[i]])
            {
                found = YES;
                counts[i]++;
                break;
            }
        }
        testassert(found);
    }

    for (int i = 0; i < count; i++)
    {
        testassert(counts[i] == i > 0 ? 1 : 0);
    }

    free(members);
    free(counts);

    return YES;
}

- (BOOL)testFastEnumeration
{
    NSMutableOrderedSet *os = [[NSMutableOrderedSet alloc] init];
    int count = 10;
    NSObject **members = malloc(sizeof(*members) * count);
    int *counts = calloc(sizeof(*counts), count);

    for (int i = 0; i < count; i++)
    {
        members[i] = [[NSObject alloc] init];
        for (int inserts = 0; inserts < i; inserts++)
        {
            [os addObject:members[i]];
        }
    }

    // Count for object
    for (int i = 1; i < count; i++)
    {
        testassert([os containsObject:members[i]]);
    }

    for (id object in os)
    {
        BOOL found = NO;
        for (int i = 0; i < count; i++)
        {
            if ([object isEqual:members[i]])
            {
                found = YES;
                counts[i]++;
                break;
            }
        }
        testassert(found);
    }

    // If an object is added multiple times to an NSOrderedSet, it is
    // still only enumerated once.
    for (int i = 0; i < count; i++)
    {
        testassert(counts[i] == i > 0 ? 1 : 0);
    }

    free(members);
    free(counts);

    return YES;
}

- (BOOL)testCopyWithZone
{
    NSOrderedSet *os = [[NSOrderedSet alloc] initWithObjects:
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        nil];

    NSOrderedSet *osCopy = [os copyWithZone:nil];

    testassert(osCopy != nil);

    [osCopy release];
    [os release];

    return YES;
}

- (BOOL)testMutableCopyWithZone
{
    NSOrderedSet *os = [[NSOrderedSet alloc] initWithObjects:
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        nil];

    NSOrderedSet *osCopy = [os mutableCopyWithZone:nil];

    testassert(osCopy != nil);

    [osCopy release];
    [os release];

    return YES;
}

- (BOOL)testAddObjectsFromArray
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSMutableOrderedSet *os = [[NSMutableOrderedSet alloc] initWithObjects: o0, nil];
    NSArray *a = @[@1, @2];
    [os addObjectsFromArray:a];
    testassert([os count] == 3);

    return YES;
}

- (BOOL)testOrderedSetCreationWithVariousObjectsAndDuplicates
{
    NSMutableOrderedSet *aOrderedSet = [[NSMutableOrderedSet alloc] initWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"42", @"42", nil];
    testassert([aOrderedSet count] == 5);
    [aOrderedSet release];
    return YES;
}

- (BOOL)testMinusOrderedSet
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];
    NSObject *o3 = [[[NSObject alloc] init] autorelease];

    NSMutableOrderedSet *os = [[NSMutableOrderedSet alloc] initWithObjects: o1, o2, o0, nil];
    NSOrderedSet *s = [[NSOrderedSet alloc] initWithObjects:o0, o3, o2, nil];

    [os minusOrderedSet:s];
    testassert([os count] == 1);
    testassert([os containsObject:o1]);
    testassert(![os containsObject:o2]);
    [os release];
    [s release];
    return YES;
}

- (BOOL)testIntersectOrderedSet
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];
    NSObject *o3 = [[[NSObject alloc] init] autorelease];

    NSMutableOrderedSet *os = [[NSMutableOrderedSet alloc] initWithObjects: o1, o2, o0, nil];
    NSOrderedSet *s = [[NSOrderedSet alloc] initWithObjects:o0, o2, o3, nil];

    [os intersectOrderedSet:s];
    testassert([os count] == 2);
    testassert(![os containsObject:o1]);
    testassert([os containsObject:o2]);
    [os release];
    [s release];
    return YES;
}


- (BOOL)testUnionOrderedSet
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];
    NSObject *o3 = [[[NSObject alloc] init] autorelease];

    NSMutableOrderedSet *os = [[NSMutableOrderedSet alloc] initWithObjects: o1, o2, o0, nil];
    NSOrderedSet *s = [[NSOrderedSet alloc] initWithObjects:o0, o2, o3, nil];

    [os unionOrderedSet:s];
    testassert([os count] == 4);
    testassert([os containsObject:o1]);
    testassert([os containsObject:o2]);
    [os release];
    [s release];
    return YES;
}

- (BOOL)testNSOrderedSetICreate0
{
    NSOrderedSet *os = [NSOrderedSet new];
    testassert(strcmp(object_getClassName(os), "__NSOrderedSetI") == 0);
    [os release];
    return YES;
}

- (BOOL)testNSOrderedSetICreate1
{
    NSOrderedSet *os = [NSOrderedSet orderedSetWithObject:@91];
    testassert(strcmp(object_getClassName(os), "__NSOrderedSetI") == 0);
    return YES;
}

- (BOOL)testNSOrderedSetICreate0Unique
{
    NSOrderedSet *os1 = [NSOrderedSet new];
    NSOrderedSet *os2 = [NSOrderedSet new];
    NSOrderedSet *os3 = [os2 copy];
    testassert(os1 == os2);
    testassert(os1 == os3);
    [os1 release];
    [os2 release];
    [os3 release];
    return YES;
}

- (BOOL)testAllocate
{
    NSOrderedSet *d1 = [NSOrderedSet alloc];
    NSOrderedSet *d2 = [NSOrderedSet alloc];

    // OrderedSet allocators return singletons
    testassert(d1 == d2);

    return YES;
}

- (BOOL)testAllocateMutable
{
    NSMutableOrderedSet *d1 = [NSMutableOrderedSet alloc];
    NSMutableOrderedSet *d2 = [NSMutableOrderedSet alloc];

    // Mutable orderedSet allocators return singletons
    testassert(d1 == d2);

    return YES;
}

- (BOOL)testBadCapacity
{
    __block BOOL raised = NO;
    __block NSMutableOrderedSet *orderedSet = nil;
    void (^block)(void) = ^{
        orderedSet = [[NSMutableOrderedSet alloc] initWithCapacity:1073741824];
    };
    @try {
        block();
    }
    @catch (NSException *e) {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        raised = YES;
    }
    testassert(raised);
    [orderedSet release];
    return YES;
}

- (BOOL)testLargeCapacity
{
    __block BOOL raised = NO;
    __block NSMutableOrderedSet *orderedSet = nil;
    void (^block)(void) = ^{
        orderedSet = [[NSMutableOrderedSet alloc] initWithCapacity:1073741823];
    };
    @try {
        block();
    }
    @catch (NSException *e) {
        raised = YES;
    }
    testassert(!raised);
    [orderedSet release];
    return YES;
}

- (BOOL)testAllocateDifferential
{
    NSOrderedSet *d1 = [NSOrderedSet alloc];
    NSMutableOrderedSet *d2 = [NSMutableOrderedSet alloc];

    // Mutable and immutable allocators must be from the same class
    testassert([d1 class] == [d2 class]);

    return YES;
}

- (BOOL)testAllocatedRetainCount
{
    NSOrderedSet *d = [NSOrderedSet alloc];

    // Allocators are singletons and have this retain count
    testassert([d retainCount] == NSUIntegerMax);

    return YES;
}

- (BOOL)testAllocatedClass
{
    // Allocation must be a NSOrderedSet subclass
    testassert([[NSOrderedSet alloc] isKindOfClass:[NSOrderedSet class]]);

    // Allocation must be a NSOrderedSet subclass
    testassert([[NSMutableOrderedSet alloc] isKindOfClass:[NSOrderedSet class]]);

    // Allocation must be a NSMutableOrderedSet subclass
    testassert([[NSOrderedSet alloc] isKindOfClass:[NSMutableOrderedSet class]]);

    // Allocation must be a NSMutableOrderedSet subclass
    testassert([[NSMutableOrderedSet alloc] isKindOfClass:[NSMutableOrderedSet class]]);

    return YES;
}

- (BOOL)testRetainCount
{
    NSOrderedSet *d = [NSOrderedSet alloc];

    testassert([d retainCount] == NSUIntegerMax);

    return YES;
}

- (BOOL)testDoubleDeallocAllocate
{
    NSOrderedSet *d = [NSOrderedSet alloc];

    // Releasing twice should not throw
    [d release];
    [d release];

    return YES;
}

- (BOOL)testBlankMutableCreation
{
    NSMutableOrderedSet *arr = [[NSMutableOrderedSet alloc] init];

    // Blank initialization should return a OrderedSet
    testassert(arr != nil);

    [arr release];

    return YES;
}

- (BOOL)testDefaultCreation
{
    id obj1 = [[NSObject alloc] init];
    NSOrderedSet *obj = [NSOrderedSet alloc];
    NSOrderedSet *arr = [obj initWithObjects:&obj1 count:1];

    // Default initializer with one object should return a OrderedSet
    testassert(arr != nil);

    [arr release];

    return YES;
}

- (BOOL)testDefaultMutableCreation
{
    id obj1 = [[NSObject alloc] init];
    NSMutableOrderedSet *arr = [[NSMutableOrderedSet alloc] initWithObjects:&obj1 count:1];

    // Default initializer with one object should return a OrderedSet
    testassert(arr != nil);

    [arr release];

    return YES;
}

- (BOOL)testVarArgsMutableCreation
{
    NSMutableOrderedSet *arr = [[NSMutableOrderedSet alloc] initWithObjects:@"foo", @"bar", @"baz", @"bar", nil];

    // Var args initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableOrderedSet") class]]);

    [arr release];

    return YES;
}

- (BOOL)testOtherOrderedSetCreation
{
    NSOrderedSet *arr = [[NSOrderedSet alloc] initWithOrderedSet:
                         [NSOrderedSet orderedSetWithArray:@[@"bar", @"foo"]]];

    // Other OrderedSet initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);

    [arr release];

    return YES;
}

- (BOOL)testOtherOrderedSetMutableCreation
{
    NSMutableOrderedSet *arr = [[NSMutableOrderedSet alloc] initWithOrderedSet:
                                [NSOrderedSet orderedSetWithArray:@[@"bar", @"foo"]]];
    // Other OrderedSet initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableOrderedSet") class]]);

    [arr release];

    return YES;
}

- (BOOL)testOtherOrderedSetCopyCreation
{
    NSOrderedSet *arr = [[NSOrderedSet alloc] initWithOrderedSet:
                         [NSOrderedSet orderedSetWithArray:@[@"bar", @"foo"]] copyItems:YES];

    // Other OrderedSet initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);

    [arr release];

    return YES;
}

- (BOOL)testOtherOrderedSetCopyMutableCreation
{
    NSMutableOrderedSet *arr = [[NSMutableOrderedSet alloc] initWithOrderedSet:
                                [NSOrderedSet orderedSetWithArray:@[@"bar", @"foo"]] copyItems:YES];

    // Other OrderedSet initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableOrderedSet") class]]);

    [arr release];

    return YES;
}

- (BOOL)testOtherOrderedSetNoCopyCreation
{
    NSOrderedSet *arr = [[NSOrderedSet alloc] initWithOrderedSet:
                         [NSOrderedSet orderedSetWithArray:@[@"bar", @"foo"]] copyItems:NO];

    // Other OrderedSet initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);

    [arr release];

    return YES;
}

- (BOOL)testOtherOrderedSetNoCopyMutableCreation
{
    NSMutableOrderedSet *arr = [[NSMutableOrderedSet alloc] initWithOrderedSet:
                                [NSOrderedSet orderedSetWithArray:@[@"bar", @"foo"]]];

    // Other OrderedSet initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableOrderedSet") class]]);

    [arr release];

    return YES;
}

- (BOOL)testOrderedSetMutableCreation
{
    NSMutableOrderedSet *arr = [[NSMutableOrderedSet alloc] initWithObjects:@"foo", @"bar", @"baz", nil];

    // OrderedSet initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableOrderedSet") class]]);

    [arr release];

    return YES;
}

#warning TODO
#if 0

- (BOOL)testFileCreation
{
    NSOrderedSet *arr = [[NSOrderedSet alloc] initWithContentsOfFile:@"Info.plist"];

    // File initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);

    [arr release];

    return YES;
}

- (BOOL)testFileMutableCreation
{
    NSMutableOrderedSet *arr = [[NSMutableOrderedSet alloc] initWithContentsOfFile:@"Info.plist"];

    // File initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableOrderedSet") class]]);

    [arr release];

    return YES;
}

- (BOOL)testURLCreation
{
    NSOrderedSet *arr = [[NSOrderedSet alloc] initWithContentsOfURL:[NSURL fileURLWithPath:@"Info.plist"]];

    // File initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);

    [arr release];

    return YES;
}

- (BOOL)testURLMutableCreation
{
    NSMutableOrderedSet *arr = [[NSMutableOrderedSet alloc] initWithContentsOfURL:[NSURL fileURLWithPath:@"Info.plist"]];

    // File initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableOrderedSet") class]]);

    [arr release];

    return YES;
}

#endif

- (BOOL)testDescription
{
    NSOrderedSet *arr = [NSOrderedSet orderedSetWithArray:@[ @1, @2, @3 ]];
    NSString *d = @"{(\n    1,\n    2,\n    3\n)}";
    testassert([d isEqualToString:[arr description]]);

    NSOrderedSet *nestedInOrderedSet = [NSOrderedSet orderedSetWithArray:@[ @1, @{ @"k1": @111, @"k2" : @{ @"kk1" : @11, @"kk2" : @22, @"kk3" : @33}, @"k3": @333}, @3 ]];
    d = @"{(\n    1,\n        {\n        k1 = 111;\n        k2 =         {\n            kk1 = 11;\n            kk2 = 22;\n            kk3 = 33;\n        };\n        k3 = 333;\n    },\n    3\n)}";
    testassert([d isEqualToString:[nestedInOrderedSet description]]);

    return YES;
}

- (BOOL)testRemoveAllObjects
{
    NSMutableOrderedSet *m = [@[@3, @1, @2] mutableCopy];
    testassert([m count] == 3);

    [m removeAllObjects];
    testassert([m count] == 0);

    /* Check on empty orderedSet */
    [m removeAllObjects];
    testassert([m count] == 0);

    [m addObject:@1];
    testassert([m count] == 1);

    return YES;
}

- (BOOL) testReplaceObjectsInRange1
{
    NSMutableOrderedSet *m = [@[@1, @2] mutableCopy];
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
    NSMutableOrderedSet *m = [@[@1, @2] mutableCopy];
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
    NSMutableOrderedSet *m = [@[] mutableCopy];
    id ids[2];
    [m replaceObjectsInRange:NSMakeRange(0,0) withObjects:ids count:0];
    testassert([m count] == 0);
    [m release];

    return YES;
}

- (BOOL) testReplaceObjectsInRange4
{
    NSMutableOrderedSet *m = [@[@1, @2] mutableCopy];
    id ids[2];
    [m replaceObjectsInRange:NSMakeRange(0,1) withObjects:ids count:0];
    testassert([m count] == 1);
    [m release];

    return YES;
}

- (BOOL) testReplaceObjectsInRange5
{
    NSMutableOrderedSet *m = [@[] mutableCopy];
    id ids[2];
    ids[0] = @10; ids[1] = @20;
    [m replaceObjectsInRange:NSMakeRange(0,0) withObjects:ids count:1];
    testassert([m count] == 1);
    testassert([[m objectAtIndex:0] intValue] == 10);
    [m release];

    return YES;
}

- (BOOL) testEnumeration
{
    NSOrderedSet *os = [NSOrderedSet orderedSetWithArray:@[ @1, @2, @3 ]];
    int sum = 0;
    for (NSNumber *n in os)
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
    NSOrderedSet *os = [NSOrderedSet orderedSetWithArray:@[ @1, @2, @3 ]];
    NSEnumerator *nse = [os objectEnumerator];

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

    NSOrderedSet *os = [[NSOrderedSet alloc] initWithArray:[s componentsSeparatedByString:@"Z"]];

    int sum = 0;
    NSEnumerator *nse = [os objectEnumerator];

    while([nse nextObject])
    {
        sum ++;
    }
    testassert(sum == 3);
    [os release];
    return YES;
}

- (BOOL)testRemoveRangeExceptions
{
    NSMutableOrderedSet *os = [@[@9] mutableCopy];
    BOOL raised = NO;
    @try {
        [os removeObjectAtIndex:NSNotFound];
    }
    @catch (NSException *caught) {
        raised = YES;
        testassert([[caught name] isEqualToString:NSRangeException]);
    }
    testassert(raised);

    raised = NO;
    @try {
        [os removeObjectAtIndex:[os count]];
    }
    @catch (NSException *caught) {
        raised = YES;
        testassert([[caught name] isEqualToString:NSRangeException]);
    }
    [os release];
    testassert(raised);

    return YES;
}


- (BOOL)testContainsValue
{
    NSValue *bodyPoint = [NSValue valueWithPointer:(int *)0x12345678];
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithObject:bodyPoint];
    testassert([orderedSet containsObject:bodyPoint]);

    NSValue *bodyPoint2 = [NSValue valueWithPointer:(int *)0x12345678];
    testassert([orderedSet containsObject:bodyPoint2]);
    return YES;
}


- (BOOL) testIndexesOfObjectsPassingTest
{
    NSMutableOrderedSet *os = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    NSIndexSet *is = [os indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return ([obj intValue] & 1) == 0;
    }];
    testassert([is count] == 2);
    return YES;
}

- (BOOL) testEnumerateObjects
{
    NSMutableOrderedSet *os = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [os enumerateObjectsUsingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        sum += [obj intValue];
        *stop = idx == 2;
    }];
    testassert(sum == 6);
    return YES;
}

- (BOOL) testEnumerateObjectsWithOptions
{
    NSMutableOrderedSet *os = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [os enumerateObjectsWithOptions:0 usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        sum += [obj intValue];
        *stop = idx == 2;
    }];
    testassert(sum == 6);
    return YES;
}

- (BOOL) testEnumerateObjectsWithOptionsReverse
{
    NSMutableOrderedSet *os = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [os enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        sum += [obj intValue];
        *stop = idx == 2;
    }];
    testassert(sum == 7);
    return YES;
}

- (BOOL) testEnumerateObjectsWithOptionsConcurrent
{
    NSMutableOrderedSet *os = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [os enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        @synchronized(self) {
            sum += [obj intValue];
        }
    }];
    testassert(sum == 10);
    return YES;
}

- (BOOL) testEnumerateObjectsWithOptionsReverseConcurrent
{
    NSMutableOrderedSet *os = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [os enumerateObjectsWithOptions:NSEnumerationReverse | NSEnumerationConcurrent usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        @synchronized(self) {
            sum += [obj intValue];
        }
    }];
    testassert(sum == 10);
    return YES;
}

- (BOOL)testInequalObjects1
{
    InequalObject *o1 = [InequalObject new];
    InequalObject *o2 = [InequalObject new];

    NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
    testassert([orderedSet count] == 0);
    [orderedSet addObject:o1];
    testassert([orderedSet count] == 1);
    testassert([orderedSet indexOfObject:o1] == 0);
    testassert([orderedSet indexOfObject:o2] == NSNotFound);
    testassert([orderedSet containsObject:o1]);
    testassert(![orderedSet containsObject:o2]);
    [orderedSet addObject:o2];
    testassert([orderedSet count] == 2);
    [orderedSet removeObject:o1];
    testassert([orderedSet count] == 1);
    [orderedSet removeObject:o2];
    testassert([orderedSet count] == 0);

    return YES;
}

- (BOOL)testInequalObjects2
{
    InequalObject *o1 = [InequalObject new];
    InequalObject *o2 = [InequalObject new];

    NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[NSOrderedSet orderedSet]];
    testassert([orderedSet count] == 0);
    [orderedSet addObject:o1];
    testassert([orderedSet count] == 1);
    testassert([orderedSet indexOfObject:o1] == 0);
    testassert([orderedSet indexOfObject:o2] == NSNotFound);
    testassert([orderedSet containsObject:o1]);
    testassert(![orderedSet containsObject:o2]);
    [orderedSet addObject:o2];
    testassert([orderedSet count] == 2);
    [orderedSet removeObject:o1];
    testassert([orderedSet count] == 1);
    [orderedSet removeObject:o2];
    testassert([orderedSet count] == 0);

    return YES;
}

- (BOOL)testInequalObjects3
{
    InequalObject *o1 = [InequalObject new];
    InequalObject *o2 = [InequalObject new];

    NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
    testassert([orderedSet count] == 0);
    [orderedSet addObject:o1];
    testassert([orderedSet count] == 1);
    orderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:orderedSet];
    testassert([orderedSet count] == 1);
    testassert([orderedSet indexOfObject:o1] == 0);
    testassert([orderedSet indexOfObject:o2] == NSNotFound);
    testassert([orderedSet containsObject:o1]);
    testassert(![orderedSet containsObject:o2]);
    [orderedSet addObject:o2];
    testassert([orderedSet count] == 2);
    [orderedSet removeObject:o1];
    testassert([orderedSet count] == 1);
    [orderedSet removeObject:o2];
    testassert([orderedSet count] == 0);

    return YES;
}

- (BOOL) testEnumerateObjectsAtIndexes
{
    NSIndexSet *is = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(2,2)];
    NSMutableOrderedSet *os = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [os enumerateObjectsAtIndexes:is options:0 usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        sum += [obj intValue];
        *stop = idx == 2;
    }];
    testassert(sum == 3);
    return YES;
}

- (BOOL) testEnumerateObjectsAtIndexesException
{
    NSIndexSet *is = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(3,2)];
    NSMutableOrderedSet *os = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    BOOL raised = NO;
    __block int sum = 0;
    @try {
        [os enumerateObjectsAtIndexes:is options:0 usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
            sum += [obj intValue];
            *stop = idx == 2;
        }];
    }
    @catch (NSException *caught) {
        raised = YES;
        testassert([[caught name] isEqualToString:NSRangeException]);
    }
    testassert(raised);

    raised = NO;
    @try {
        [os enumerateObjectsAtIndexes:is options:0 usingBlock:nil];
    }
    @catch (NSException *caught) {
        raised = YES;
        testassert([[caught name] isEqualToString:NSInvalidArgumentException]);
    }
    testassert(raised);
    return YES;
}

- (BOOL) testEnumerateObjectsAtIndexesReverse
{
    NSIndexSet *is = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(1,3)];
    NSMutableOrderedSet *os = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [os enumerateObjectsAtIndexes:is options:NSEnumerationReverse usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        sum += [obj intValue];
        *stop = idx == 2;
    }];
    testassert(sum == 7);
    return YES;
}

@end
