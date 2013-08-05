#import "FoundationTests.h"

@testcase(NSCountedSet)

- (BOOL)testBlankCreation
{
    NSCountedSet *cs = [[NSCountedSet alloc] init];

    // Blank initialization should return a counted set
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

    NSCountedSet *cs = [[NSCountedSet alloc] initWithObjects:members count:2*count];

    // Default initializer with <count> objects should return a countable set
    testassert(cs != nil);

    [cs release];

    free(members);

    return YES;
}

- (BOOL)testDefaultCreationWithCapacity
{
    int count = 10;
    NSCountedSet *cs = [[NSCountedSet alloc] initWithCapacity:count];

    // Default initializer with <count> should return a countable set
    testassert(cs != nil);

    [cs release];

    return YES;
}

- (BOOL)testSetCreation
{
    NSSet *s = [[NSSet alloc] initWithObjects:
                   [[[NSObject alloc] init] autorelease],
                   [[[NSObject alloc] init] autorelease],
                   [[[NSObject alloc] init] autorelease],
                   nil];
    NSCountedSet *cs = [[NSCountedSet alloc] initWithSet:s];

    // Set initializer should return a countable set
    testassert(cs != nil);

    [s release];
    [cs release];

    return YES;
}

- (BOOL)testSetWithCopyCreation
{
    // Ideally we would use just NSObjects for this test, but they are not copyable.
    NSSet *s = [[NSSet alloc] initWithObjects:
                   @"",
                   @"",
                   @"",
                   nil];
    NSCountedSet *cs = [[NSCountedSet alloc] initWithSet:s copyItems:YES];

    // Set initializer should return a countable set
    testassert(cs != nil);

    [s release];
    [cs release];

    return YES;
}

- (BOOL)testSetWithoutCopyCreation
{
    NSSet *s = [[NSSet alloc] initWithObjects:
                   [[[NSObject alloc] init] autorelease],
                   [[[NSObject alloc] init] autorelease],
                   [[[NSObject alloc] init] autorelease],
                   nil];
    NSCountedSet *cs = [[NSCountedSet alloc] initWithSet:s copyItems:NO];

    // Set initializer should return a countable set
    testassert(cs != nil);

    [s release];
    [cs release];

    return YES;
}

- (BOOL)testVarArgsCreation
{
    NSCountedSet *cs = [[NSCountedSet alloc] initWithObjects:
                           [[[NSObject alloc] init] autorelease],
                           [[[NSObject alloc] init] autorelease],
                           [[[NSObject alloc] init] autorelease],
                           nil];

    // Var args initializer should return a countable set
    testassert(cs != nil);

    [cs release];

    return YES;
}

- (BOOL)testArrayCreation
{
    NSCountedSet *cs = [[NSCountedSet alloc] initWithObjects:
                           [[[NSObject alloc] init] autorelease],
                           [[[NSObject alloc] init] autorelease],
                           [[[NSObject alloc] init] autorelease],
                           nil];

    // Array initializer should return a countable set
    testassert(cs != nil);

    [cs release];

    return YES;
}

- (BOOL)testDoubleInit
{
    void (^block)() = ^{
        NSSet *s = [[NSSet alloc] initWithObjects:
                       [[[NSObject alloc] init] autorelease],
                       [[[NSObject alloc] init] autorelease],
                       [[[NSObject alloc] init] autorelease],
                       nil];

        NSCountedSet *cs = [[[NSCountedSet alloc] initWithSet:s] initWithSet:s];

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

- (BOOL)testCountForObject
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSCountedSet *cs = [[NSCountedSet alloc] initWithObjects: o1, o2, o2, nil];

    // Count for object
    testassert(cs != nil);

    testassert([cs countForObject:o0] == 0);
    testassert([cs countForObject:o1] == 1);
    testassert([cs countForObject:o2] == 2);

    testassert([cs countForObject:nil] == 0);

    [cs release];

    return YES;
}

- (BOOL)testAddObject
{
    NSCountedSet *cs = [[NSCountedSet alloc] init];
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
    for (int i = 0; i < count; i++)
    {
        testassert([cs countForObject:members[i]] == i);
    }

    [cs release];

    free(members);

    return YES;
}

- (BOOL)testAddObjectNil
{
    void (^block)() = ^{
        NSCountedSet *cs = [[[NSCountedSet alloc] init] autorelease];
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

    NSCountedSet *cs = [[NSCountedSet alloc] initWithObjects: o1, o2, o2, nil];

    [cs removeObject:o2];

    // Removing an object not in the countable set should not throw
    [cs removeObject:o0];
    [cs removeObject:o1];
    [cs removeObject:o1];

    testassert([cs countForObject:o0] == 0);
    testassert([cs countForObject:o1] == 0);
    testassert([cs countForObject:o2] == 1);

    [cs release];

    return YES;
}

- (BOOL)testRemoveObjectNil
{
    void (^block)() = ^{
        NSCountedSet *cs = [[[NSCountedSet alloc] init] autorelease];
        [cs removeObject:nil];
    };

    // Removing nil should throw NSInvalidArgumentException
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

- (BOOL)testMember
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSCountedSet *cs = [[NSCountedSet alloc] initWithObjects: o1, o2, o2, nil];

    testassert([cs member:o0] == nil);
    testassert([cs member:o1] != nil);
    testassert([cs member:o2] != nil);

    testassert([cs member:nil] == nil);

    [cs release];

    return YES;
}

- (BOOL)testCount
{
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSCountedSet *cs = [[NSCountedSet alloc] initWithObjects: o1, o2, o2, nil];

    testassert([cs count] == 2);

    [cs release];

    return YES;
}

#warning TODO: enumerator
#if 0
- (BOOL)testObjectEnumerator
{
    NSCountedSet *cs = [[NSCountedSet alloc] init];
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
    for (int i = 0; i < count; i++)
    {
        testassert([cs countForObject:members[i]] == i);
    }

    id object;
    while (object = [[cs objectEnumerator] nextObject])
    {
        BOOL found = NO;
        for (int i = 0; i < count; i++)
            if ([object isEqual:members[i]])
            {
                found = YES;
                counts[i]++;
                break;
            }
        testassert(found);
    }

    for (int i = 0; i < count; i++)
    {
        testassert(counts[i] == i);
    }

    free(members);
    free(counts);

    return YES;
}

- (BOOL)testForIn
{
    NSCountedSet *cs = [[NSCountedSet alloc] init];
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
    for (int i = 0; i < count; i++)
    {
        testassert([cs countForObject:members[i]] == i);
    }

    for (id object in cs)
    {
        BOOL found = NO;
        for (int i = 0; i < count; i++)
            if ([object isEqual:members[i]])
            {
                found = YES;
                counts[i]++;
                break;
            }
        testassert(found);
    }

    for (int i = 0; i < count; i++)
    {
        testassert(counts[i] == i);
    }

    free(members);
    free(counts);

    return YES;
}
#endif

- (BOOL)testCopyWithZone
{
    NSCountedSet *cs = [[NSCountedSet alloc] initWithObjects:
                           [[[NSObject alloc] init] autorelease],
                           [[[NSObject alloc] init] autorelease],
                           [[[NSObject alloc] init] autorelease],
                           nil];

    NSCountedSet *csCopy = [cs copyWithZone:nil];

    testassert(csCopy != nil);

    [csCopy release];
    [cs release];

    return YES;
}

- (BOOL)testMutableCopyWithZone
{
    NSCountedSet *cs = [[NSCountedSet alloc] initWithObjects:
                           [[[NSObject alloc] init] autorelease],
                           [[[NSObject alloc] init] autorelease],
                           [[[NSObject alloc] init] autorelease],
                           nil];

    NSCountedSet *csCopy = [cs mutableCopyWithZone:nil];

    testassert(csCopy != nil);

    [csCopy release];
    [cs release];

    return YES;
}

@end
