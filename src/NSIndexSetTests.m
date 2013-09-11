//
//  NSIndexSetTests.m
//  FoundationTests
//
//  Created by Paul Beusterien on 9/9/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSIndexSet)
     
- (BOOL)testIndexSet
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:0];
    [indexSet addIndex:2];
    NSArray *a = @[@1, @20, @300, @4000];
    __block int sum = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 301);
    return YES;
}

- (BOOL)testIndexSet2
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:0];
    [indexSet addIndex:2];
    [indexSet addIndex:4];
    NSArray *a = @[@1, @20, @300, @4000, @50000];
    __block int sum = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 50301);
    return YES;
}

- (BOOL)testIndexSet3
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:2];
    [indexSet addIndex:4];
    [indexSet addIndex:0];  // insert at beginning
    NSArray *a = @[@1, @20, @300, @4000, @50000];
    __block int sum = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 50301);
    return YES;
}

- (BOOL)testIndexSet4
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:3];
    [indexSet addIndex:2];  // merging to single range
    NSArray *a = @[@1, @20, @300, @4000, @50000];
    __block int sum = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 4320);
    return YES;
}

- (BOOL)testIndexSetWithIndex
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:2];
    NSArray *a = @[@1, @20, @300, @4000];
    __block int sum = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 300);
    return YES;
}

- (BOOL)testIndexSetWithIndexesInRange
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    NSArray *a = @[@1, @20, @300, @4000];
    __block int sum = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 4320);
    return YES;
}


- (BOOL)testContainsIndex
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    testassert([indexSet containsIndex:2] == NO);
    [indexSet addIndexesInRange:NSMakeRange(1, 3)];
    testassert([indexSet containsIndex:1]);
    testassert([indexSet containsIndex:3]);
    testassert([indexSet containsIndex:0] == NO);
    testassert([indexSet containsIndex:43452342] == NO);
    return YES;
}

- (BOOL)testContainsIndexes
{
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet0 containsIndexes:nil] == YES);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 5)];
    testassert([indexSet containsIndexes:nil] == YES);
    NSIndexSet *indexSet2 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
    NSIndexSet *indexSet3 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)];
    NSIndexSet *indexSet4 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 4)];
    testassert([indexSet containsIndexes:indexSet]);
    testassert([indexSet containsIndexes:indexSet2]);
    testassert([indexSet containsIndexes:indexSet3]);
    testassert([indexSet0 containsIndexes:indexSet4] == NO);
    testassert([indexSet containsIndexes:indexSet4] == NO);
    testassert([indexSet containsIndexes:nil]);
    NSMutableIndexSet *indexSet5 = [NSMutableIndexSet indexSet];
    [indexSet5 addIndex:1];
    [indexSet5 addIndex:3];
    testassert([indexSet containsIndexes:indexSet5]);
    [indexSet5 addIndex:7];
    testassert([indexSet containsIndexes:indexSet5] == NO);
    return YES;
}

- (BOOL)testContainsIndexesInRange
{
    NSIndexSet *indexSet0 = [NSIndexSet indexSet];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    testassert([indexSet containsIndexesInRange:NSMakeRange(1, 3)]);
    testassert([indexSet containsIndexesInRange:NSMakeRange(1, 2)]);
    testassert([indexSet containsIndexesInRange:NSMakeRange(1, 0)] == NO);
    testassert([indexSet containsIndexesInRange:NSMakeRange(9, 0)] == NO);
    testassert([indexSet containsIndexesInRange:NSMakeRange(2, 3)] == NO);
    testassert([indexSet containsIndexesInRange:NSMakeRange(9, 3)] == NO);
    testassert([indexSet0 containsIndexesInRange:NSMakeRange(9, 3)] == NO);
    return YES;
}

- (BOOL)testContainsIndexesInRange2
{
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    [indexSet addIndexesInRange:NSMakeRange(100,4)];
    testassert([indexSet containsIndexesInRange:NSMakeRange(1, 3)]);
    testassert([indexSet containsIndexesInRange:NSMakeRange(1, 2)]);
    testassert([indexSet containsIndexesInRange:NSMakeRange(101, 2)]);
    testassert([indexSet containsIndexesInRange:NSMakeRange(2, 3)] == NO);
    testassert([indexSet containsIndexesInRange:NSMakeRange(9, 3)] == NO);
    return YES;
}


- (BOOL)testCount
{
    NSIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet0 count] == 0);
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    testassert([indexSet count] == 3);
    [indexSet addIndexesInRange:NSMakeRange(100,4)];
    testassert([indexSet count] == 7);
    [indexSet addIndex:2];
    testassert([indexSet count] == 7);
    [indexSet addIndex:2000];
    testassert([indexSet count] == 8);
    return YES;
}


- (BOOL)testCountOfIndexesInRange
{
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet0 countOfIndexesInRange:NSMakeRange(1,3)] == 0);
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    testassert([indexSet countOfIndexesInRange:NSMakeRange(1,3)] == 3);
    testassert([indexSet countOfIndexesInRange:NSMakeRange(1,2)] == 2);
    testassert([indexSet countOfIndexesInRange:NSMakeRange(3,7)] == 1);
    [indexSet addIndexesInRange:NSMakeRange(100,4)];
    testassert([indexSet countOfIndexesInRange:NSMakeRange(1,3)] == 3);
    testassert([indexSet countOfIndexesInRange:NSMakeRange(1,2)] == 2);
    testassert([indexSet countOfIndexesInRange:NSMakeRange(3,7)] == 1);
    testassert([indexSet countOfIndexesInRange:NSMakeRange(99,3)] == 2);
    testassert([indexSet count] == 7);
    [indexSet addIndex:2];
    testassert([indexSet count] == 7);
    [indexSet addIndex:2000];
    testassert([indexSet count] == 8);
    return YES;
}


- (BOOL)testFirstIndex
{
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet0 firstIndex] == NSNotFound);
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    testassert([indexSet firstIndex] == 1);
    [indexSet addIndexesInRange:NSMakeRange(100,4)];
    testassert([indexSet firstIndex] == 1);
    return YES;
}

- (BOOL)testIndexPassingTest
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    
    NSUInteger passedTest = [indexSet indexPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx == 2;
    }];
    testassert(passedTest == 2);
    return YES;
}

- (BOOL)testIndexPassingTest2
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    
    NSUInteger passedTest = [indexSet indexPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx == 20;
    }];
    testassert(passedTest == NSNotFound);
    return YES;
}

- (BOOL)testIndexesPassingTest
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    NSArray *a = @[@1, @20, @300, @4000];
    
    NSIndexSet *passedTest = [indexSet indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx & 1;
    }];
    
    __block int sum = 0;
    [passedTest enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 4020);
    return YES;
}

- (BOOL)testIndexGreaterThanIndex
{
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet0 indexGreaterThanIndex:2] == NSNotFound);
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    testassert([indexSet indexGreaterThanIndex:2] == 3);
    testassert([indexSet indexGreaterThanIndex:3] == NSNotFound);
    testassert([indexSet indexGreaterThanIndex:8] == NSNotFound);
    [indexSet addIndexesInRange:NSMakeRange(100,4)];
    testassert([indexSet indexGreaterThanIndex:8] == 100);
    testassert([indexSet indexGreaterThanIndex:101] == 102);
    testassert([indexSet indexGreaterThanIndex:1000] == NSNotFound);
    testassert([indexSet indexGreaterThanIndex:2] == 3);
    return YES;
}

- (BOOL)testIndexGreaterThanOrEqualToIndex
{
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet0 indexGreaterThanOrEqualToIndex:2] == NSNotFound);
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    testassert([indexSet indexGreaterThanOrEqualToIndex:2] == 2);
    testassert([indexSet indexGreaterThanOrEqualToIndex:3] == 3);
    testassert([indexSet indexGreaterThanOrEqualToIndex:8] == NSNotFound);
    [indexSet addIndexesInRange:NSMakeRange(100,4)];
    testassert([indexSet indexGreaterThanOrEqualToIndex:8] == 100);
    testassert([indexSet indexGreaterThanOrEqualToIndex:101] == 101);
    testassert([indexSet indexGreaterThanOrEqualToIndex:1000] == NSNotFound);
    testassert([indexSet indexGreaterThanOrEqualToIndex:2] == 2);
    return YES;
}

- (BOOL)testIndexLessThanIndex
{
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet0 indexLessThanIndex:2] == NSNotFound);
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    testassert([indexSet indexLessThanIndex:2] == 1);
    testassert([indexSet indexLessThanIndex:1] == NSNotFound);
    testassert([indexSet indexLessThanIndex:8] == 3);
    [indexSet addIndexesInRange:NSMakeRange(100,4)];
    testassert([indexSet indexLessThanIndex:8] == 3);
    testassert([indexSet indexLessThanIndex:101] == 100);
    testassert([indexSet indexLessThanIndex:1000] == 103);
    testassert([indexSet indexLessThanIndex:2] == 1);
    return YES;
}

- (BOOL)testIndexLessThanOrEqualToIndex
{
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet0 indexLessThanOrEqualToIndex:2] == NSNotFound);
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    testassert([indexSet indexLessThanOrEqualToIndex:2] == 2);
    testassert([indexSet indexLessThanOrEqualToIndex:3] == 3);
    testassert([indexSet indexLessThanOrEqualToIndex:8] == 3);
    [indexSet addIndexesInRange:NSMakeRange(100,4)];
    testassert([indexSet indexLessThanOrEqualToIndex:8] == 3);
    testassert([indexSet indexLessThanOrEqualToIndex:101] == 101);
    testassert([indexSet indexLessThanOrEqualToIndex:1000] == 103);
    testassert([indexSet indexLessThanOrEqualToIndex:2] == 2);
    return YES;
}

- (BOOL)testInitWithIndex
{
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:2];
    testassert([indexSet indexLessThanOrEqualToIndex:2] == 2);
    [indexSet release];
    return YES;
}

- (BOOL)testInitWithIndexesInRange
{
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(2,99)];
    testassert([indexSet indexLessThanOrEqualToIndex:2] == 2);
    [indexSet release];
    return YES;
}

- (BOOL)testInitWithIndexSet
{
    NSIndexSet *indexSetIniter = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(2,99)];
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndexSet:indexSetIniter];
    testassert([indexSet indexLessThanOrEqualToIndex:2] == 2);
    [indexSetIniter release];
    [indexSet release];
    return YES;
}


- (BOOL)testIntersectsIndexesInRange
{
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet0 intersectsIndexesInRange:NSMakeRange(4,2)] == NO);
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(0,1)] == NO);
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(0,2)] == YES);
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(1,6)] == YES);
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(3,22)] == YES);
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(5,100)] == NO);
    [indexSet addIndexesInRange:NSMakeRange(100,4)];
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(0,1)] == NO);
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(0,2)] == YES);
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(1,6)] == YES);
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(3,22)] == YES);
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(5,100)] == YES);
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(101,100)] == YES);
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(1010,100)] == NO);
    return YES;
}

- (BOOL)testIsEqualToIndexSet
{
    NSIndexSet *indexSetIniter = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(2,99)];
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndexSet:indexSetIniter];
    testassert([indexSet isEqualToIndexSet:indexSetIniter]);
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet isEqualToIndexSet:indexSet0] == NO);
    testassert([indexSet0 isEqualToIndexSet:indexSet] == NO);
    [indexSetIniter release];
    [indexSet release];
    return YES;
}

- (BOOL)testLastIndex
{
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet0 lastIndex] == NSNotFound);
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    testassert([indexSet lastIndex] == 3);
    [indexSet addIndexesInRange:NSMakeRange(100,4)];
    testassert([indexSet lastIndex] == 103);
    return YES;
}

- (BOOL)testRemoveAllIndexes
{
    NSIndexSet *indexSet0 = [NSIndexSet indexSet];
    NSMutableIndexSet *indexSet0m = [[indexSet0 mutableCopy] autorelease];
    [indexSet0m removeAllIndexes];
    testassert([indexSet0m isEqualToIndexSet:indexSet0]);
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    [indexSet removeAllIndexes];
    testassert([indexSet isEqualToIndexSet:indexSet0]);
    return YES;
}

- (BOOL)testRemoveIndex
{
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    [indexSet removeIndex:2];
    NSArray *a = @[@1, @20, @300, @4000];
    __block int sum = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 4020);
    [indexSet removeIndex:9999];
    testassert([indexSet count] == 2);
    [indexSet removeIndex:2];
    testassert([indexSet count] == 2);
    [indexSet removeIndex:1];
    testassert([indexSet count] == 1);
    [indexSet removeIndex:3];
    testassert([indexSet count] == 0);
    return YES;
}

- (BOOL)testRemoveIndexesInRange
{
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 4)] mutableCopy] autorelease];
    [indexSet removeIndexesInRange:NSMakeRange(2,2)];
    NSArray *a = @[@1, @20, @300, @4000, @50000];
    __block int sum = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 50020);
    [indexSet removeIndexesInRange:NSMakeRange(3,1)];
    testassert([indexSet count] == 2);
    [indexSet removeIndexesInRange:NSMakeRange(4,100)];
    testassert([indexSet count] == 1);
    [indexSet removeIndexesInRange:NSMakeRange(0,7)];
    testassert([indexSet count] == 0);
    return YES;
}

- (BOOL)testRemoveIndexesInRange2
{
    NSMutableIndexSet *indexSet0 = [[[NSIndexSet indexSet] mutableCopy] autorelease];
    [indexSet0 removeIndexesInRange:NSMakeRange(2,2)];
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 4)] mutableCopy] autorelease];
    [indexSet removeIndexesInRange:NSMakeRange(4,2)];
    NSArray *a = @[@1, @20, @300, @4000, @50000];
    __block int sum = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 4320);
    [indexSet removeIndexesInRange:NSMakeRange(4,2)];
    testassert([indexSet count] == 3);
    [indexSet removeIndexesInRange:NSMakeRange(1,1)];
    testassert([indexSet count] == 2);
    [indexSet removeIndexesInRange:NSMakeRange(2,1)];
    testassert([indexSet count] == 1);
    [indexSet removeIndexesInRange:NSMakeRange(1, 1000000)];
    testassert([indexSet count] == 0);
    return YES;
}

- (BOOL)testRemoveIndexes
{
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 4)] mutableCopy] autorelease];
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    [indexSet removeIndexes:indexSet0];
    testassert([indexSet count] == 4);
    NSMutableIndexSet *indexSet2 = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    [indexSet removeIndexes:indexSet2];
    testassert([indexSet count] == 1);
    return YES;
}


@end