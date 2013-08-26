//
//  NSSetTests.m
//  FoundationTests
//
//  Created by Paul Beusterien on 8/26/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSSet)

- (BOOL)testBlankCreation
{
    NSSet *cs = [[NSSet alloc] init];
    
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
    
    NSSet *cs = [[NSSet alloc] initWithObjects:members count:2*count];
    
    // Default initializer with <count> objects should return a  set
    testassert(cs != nil);
    
    [cs release];
    
    free(members);
    
    return YES;
}

- (BOOL)testDefaultCreationWithArray
{
    NSSet *cs = [[NSSet alloc] initWithArray:@[@1, @2]];
    
    // Default initializer with <count> should return a countable set
    testassert(cs != nil);
    testassert([cs count] == 2);
    
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
    NSSet *cs = [[NSSet alloc] initWithSet:s];
    
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
    NSSet *cs = [[NSSet alloc] initWithSet:s copyItems:YES];
    
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
    NSSet *cs = [[NSSet alloc] initWithSet:s copyItems:NO];
    
    // Set initializer should return a countable set
    testassert(cs != nil);
    
    [s release];
    [cs release];
    
    return YES;
}

- (BOOL)testVarArgsCreation
{
    NSSet *cs = [[NSSet alloc] initWithObjects:
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
    NSSet *cs = [[NSSet alloc] initWithArray:@[
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        ]];
    
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
        
        NSSet *cs = [[[NSSet alloc] initWithSet:s] initWithSet:s];
        
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
    
    NSSet *cs = [[NSSet alloc] initWithObjects: o1, o2, o2, nil];
    
    // Count for object
    testassert(cs != nil);
    
    testassert([cs containsObject:o0] == NO);
    testassert([cs containsObject:o1] == YES);
    testassert([cs containsObject:o2] == YES);
    
    testassert([cs containsObject:nil] == NO);
    
    testassert([cs count] == 2);
    
    [cs release];
    
    return YES;
}

- (BOOL)testAddObject
{
    NSMutableSet *cs = [[NSMutableSet alloc] init];
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
        testassert([cs member:members[i]] == members[i]);
    }
    
    [cs release];
    
    free(members);
    
    return YES;
}

- (BOOL)testAddObjectNil
{
    void (^block)() = ^{
        NSMutableSet *cs = [[[NSMutableSet alloc] init] autorelease];
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
    
    NSMutableSet *cs = [[NSMutableSet alloc] initWithObjects: o1, o2, o2, nil];
    
    // Removing an object not in the countable set should not throw
    [cs removeObject:o0];
    [cs removeObject:o1];
    [cs removeObject:o1];
    
    testassert([cs member:o0] == nil);
    testassert([cs member:o1] == nil);
    testassert([cs member:o2] == o2);
    
    [cs release];
    
    return YES;
}

- (BOOL)testRemoveObjectNil
{
    void (^block)() = ^{
        NSMutableSet *cs = [[[NSMutableSet alloc] init] autorelease];
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
    
    NSSet *cs = [[NSSet alloc] initWithObjects: o1, o2, o2, nil];
    
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
    
    NSSet *cs = [[NSSet alloc] initWithObjects: o1, o2, o2, nil];
    
    testassert([cs count] == 2);
    
    [cs release];
    
    return YES;
}

- (BOOL)testObjectEnumerator
{
    NSMutableSet *cs = [[NSMutableSet alloc] init];
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
        testassert([cs member:members[i]] == members[i]);
    }
    
    id object;
    NSEnumerator *enumerator = [cs objectEnumerator];
    while ((object = [enumerator nextObject]) != nil)
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
    
    // If an object is added multiple times to an NSSet, it is
    // still only enumerated once.
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
    NSMutableSet *cs = [[NSMutableSet alloc] init];
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
        testassert([cs member:members[i]] == members[i]);
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
    
    // If an object is added multiple times to an NSSet, it is
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
    NSSet *cs = [[NSSet alloc] initWithObjects:
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        nil];
    
    NSSet *csCopy = [cs copyWithZone:nil];
    
    testassert(csCopy != nil);
    
    [csCopy release];
    [cs release];
    
    return YES;
}

- (BOOL)testMutableCopyWithZone
{
    NSSet *cs = [[NSSet alloc] initWithObjects:
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        nil];
    
    NSSet *csCopy = [cs mutableCopyWithZone:nil];
    
    testassert(csCopy != nil);
    
    [csCopy release];
    [cs release];
    
    return YES;
}

- (BOOL)testAnyObject
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSSet *cs = [[NSSet alloc] initWithObjects: o0, nil];
    testassert([cs anyObject] == o0);
    [cs release];
    
    cs = [[NSSet alloc] init];
    testassert([cs anyObject] == nil);
    [cs release];

    return YES;
}

@end
