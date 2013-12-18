#import "FoundationTests.h"

@testcase(NSOrderedSet)


- (BOOL)testBlankCreation
{
    NSOrderedSet *cs = [[NSOrderedSet alloc] init];

    // Blank initialization should return an ordered set
    testassert(cs != nil);

    [cs release];

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

    NSOrderedSet *cs = [[NSOrderedSet alloc] initWithObjects:members count:2*count];

    // Default initializer with <count> objects should return an ordered set
    testassert(cs != nil);

    [cs release];

    free(members);

    return YES;
}

- (BOOL)testDefaultCreationWithArray
{
    NSOrderedSet *cs = [[NSOrderedSet alloc] initWithArray:@[@1, @2]];

    // Default initializer with <count> should return a countable ordered set
    testassert(cs != nil);
    testassert([cs count] == 2);

    [cs release];

    return YES;
}

- (BOOL)testOrderedSetCreation
{
    NSOrderedSet *s = [[NSOrderedSet alloc] initWithObjects:
                [[[NSObject alloc] init] autorelease],
                [[[NSObject alloc] init] autorelease],
                [[[NSObject alloc] init] autorelease],
                nil];
    NSOrderedSet *cs = [[NSOrderedSet alloc] initWithOrderedSet:s];

    // OrderedSet initializer should return a countable ordered set
    testassert(cs != nil);

    [s release];
    [cs release];

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
    NSOrderedSet *cs = [[NSOrderedSet alloc] initWithOrderedSet:s copyItems:YES];

    // OrderedSet initializer should return an ordered set
    testassert([cs count] == 1);
    testassert(cs != nil);

    [s release];
    [cs release];

    return YES;
}

- (BOOL)testOrderedSetWithoutCopyCreation
{
    NSOrderedSet *s = [[NSOrderedSet alloc] initWithObjects:
                [[[NSObject alloc] init] autorelease],
                [[[NSObject alloc] init] autorelease],
                [[[NSObject alloc] init] autorelease],
                nil];
    NSOrderedSet *cs = [[NSOrderedSet alloc] initWithOrderedSet:s copyItems:NO];

    // OrderedSet initializer should return a countable ordered set
    testassert(cs != nil);

    [s release];
    [cs release];

    return YES;
}

- (BOOL)testVarArgsCreation
{
    NSOrderedSet *cs = [[NSOrderedSet alloc] initWithObjects:
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        nil];

    // Var args initializer should return a countable ordered set
    testassert(cs != nil);

    [cs release];

    return YES;
}

- (BOOL)testArrayCreation
{
    NSOrderedSet *cs = [[NSOrderedSet alloc] initWithArray:@[
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        ]];

    // Array initializer should return a countable ordered set
    testassert(cs != nil);

    [cs release];

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

        NSOrderedSet *cs = [[[NSOrderedSet alloc] initWithOrderedSet:s] initWithOrderedSet:s];

        [s release];
        [cs release];
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

    NSOrderedSet *cs = [[NSOrderedSet alloc] initWithObjects: o1, o2, o2, nil];

    // Count for object
    testassert(cs != nil);

    testassert(![cs containsObject:o0]);
    testassert([cs containsObject:o1]);
    testassert([cs containsObject:o2]);

    testassert(![cs containsObject:nil]);

    testassert([cs count] == 2);

    [cs release];

    return YES;
}

- (BOOL)testAddObject
{
    NSMutableOrderedSet *cs = [[NSMutableOrderedSet alloc] init];
    int count = 10;
    NSObject **members = malloc(sizeof(*members) * count);

    for (int i = 0; i < count; i++)
    {
        members[i] = [[NSObject alloc] init];
        for (int inserts = 0; inserts < i; inserts++)
        {
            [cs addObject:members[i]];
        }
    }

    // Count for object
    for (int i = 1; i < count; i++)
    {
        testassert([cs containsObject:members[i]]);
    }

    [cs release];

    free(members);

    return YES;
}

- (BOOL)testAddObjectNil
{
    void (^block)() = ^{
        NSMutableOrderedSet *cs = [[[NSMutableOrderedSet alloc] init] autorelease];
        [cs addObject:nil];
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

    NSMutableOrderedSet *cs = [[NSMutableOrderedSet alloc] initWithObjects: o1, o2, o2, nil];

    // Removing an object not in the countable ordered set should not throw
    [cs removeObject:o0];
    [cs removeObject:o1];
    [cs removeObject:o1];

    testassert(![cs containsObject:o0]);
    testassert(![cs containsObject:o1]);
    testassert([cs containsObject:o2]);

    [cs release];

    return YES;
}

- (BOOL)testRemoveObjectNil
{
    // Removing nil should not throw
    NSMutableOrderedSet *cs = [[[NSMutableOrderedSet alloc] init] autorelease];
    [cs removeObject:nil];

    return YES;
}

- (BOOL)testNilContainsObject
{
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSOrderedSet *cs = [[NSOrderedSet alloc] initWithObjects: o1, o2, o2, nil];

    testassert(![cs containsObject:nil]);

    [cs release];

    return YES;
}

- (BOOL)testCount
{
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSOrderedSet *cs = [[NSOrderedSet alloc] initWithObjects: o1, o2, o2, nil];

    testassert([cs count] == 2);

    [cs release];

    return YES;
}

- (BOOL)testObjectEnumerator
{
    NSMutableOrderedSet *cs = [[NSMutableOrderedSet alloc] init];
    int count = 10;
    NSObject **members = malloc(sizeof(*members) * count);
    int *counts = calloc(sizeof(*counts), count);

    for (int i = 0; i < count; i++)
    {
        members[i] = [[NSObject alloc] init];
        for (int inserts = 0; inserts < i; inserts++)
        {
            [cs addObject:members[i]];
        }
    }

    // Count for object
    for (int i = 1; i < count; i++)
    {
        testassert([cs containsObject:members[i]]);
    }

    id object;
    NSEnumerator *enumerator = [cs objectEnumerator];
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
    NSMutableOrderedSet *cs = [[NSMutableOrderedSet alloc] init];
    int count = 10;
    NSObject **members = malloc(sizeof(*members) * count);
    int *counts = calloc(sizeof(*counts), count);

    for (int i = 0; i < count; i++)
    {
        members[i] = [[NSObject alloc] init];
        for (int inserts = 0; inserts < i; inserts++)
        {
            [cs addObject:members[i]];
        }
    }

    // Count for object
    for (int i = 1; i < count; i++)
    {
        testassert([cs containsObject:members[i]]);
    }

    for (id object in cs)
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
    NSOrderedSet *cs = [[NSOrderedSet alloc] initWithObjects:
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        nil];

    NSOrderedSet *csCopy = [cs copyWithZone:nil];

    testassert(csCopy != nil);

    [csCopy release];
    [cs release];

    return YES;
}

- (BOOL)testMutableCopyWithZone
{
    NSOrderedSet *cs = [[NSOrderedSet alloc] initWithObjects:
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        nil];

    NSOrderedSet *csCopy = [cs mutableCopyWithZone:nil];

    testassert(csCopy != nil);

    [csCopy release];
    [cs release];

    return YES;
}

- (BOOL)testAddObjectsFromArray
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSMutableOrderedSet *cs = [[NSMutableOrderedSet alloc] initWithObjects: o0, nil];
    NSArray *a = @[@1, @2];
    [cs addObjectsFromArray:a];
    testassert([cs count] == 3);

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

    NSMutableOrderedSet *cs = [[NSMutableOrderedSet alloc] initWithObjects: o1, o2, o0, nil];
    NSOrderedSet *s = [[NSOrderedSet alloc] initWithObjects:o0, o3, o2, nil];

    [cs minusOrderedSet:s];
    testassert([cs count] == 1);
    testassert([cs containsObject:o1]);
    testassert(![cs containsObject:o2]);
    [cs release];
    [s release];
    return YES;
}

- (BOOL)testIntersectOrderedSet
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];
    NSObject *o3 = [[[NSObject alloc] init] autorelease];

    NSMutableOrderedSet *cs = [[NSMutableOrderedSet alloc] initWithObjects: o1, o2, o0, nil];
    NSOrderedSet *s = [[NSOrderedSet alloc] initWithObjects:o0, o2, o3, nil];

    [cs intersectOrderedSet:s];
    testassert([cs count] == 2);
    testassert(![cs containsObject:o1]);
    testassert([cs containsObject:o2]);
    [cs release];
    [s release];
    return YES;
}


- (BOOL)testUnionOrderedSet
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];
    NSObject *o3 = [[[NSObject alloc] init] autorelease];

    NSMutableOrderedSet *cs = [[NSMutableOrderedSet alloc] initWithObjects: o1, o2, o0, nil];
    NSOrderedSet *s = [[NSOrderedSet alloc] initWithObjects:o0, o2, o3, nil];

    [cs unionOrderedSet:s];
    testassert([cs count] == 4);
    testassert([cs containsObject:o1]);
    testassert([cs containsObject:o2]);
    [cs release];
    [s release];
    return YES;
}

@end
