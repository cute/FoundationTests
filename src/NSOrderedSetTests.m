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

@end
