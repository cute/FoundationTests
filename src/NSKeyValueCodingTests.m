//
//  NSKeyValueCodingTests.m
//  FoundationTests
//
//  Created by Philippe Hausler on 10/18/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"
#import <objc/runtime.h>

@interface RetainTestObject : NSObject
@end

@implementation RetainTestObject {
    BOOL wasRetained;
    BOOL wasReleased;
}

- (id)retain
{
    wasRetained = YES;
    return [super retain];
}

- (oneway void)release
{
    wasReleased = YES;
    [super release];
}

- (BOOL)wasReleased
{
    return wasReleased;
}

- (BOOL)wasRetained
{
    return wasRetained;
}

@end

@interface Direct : NSObject {
    BOOL interfaceIvar;
    BOOL _underscorePrefix;
    BOOL __doubleUnderscorePrefix;
    BOOL underscorePostfix_;
    BOOL isPrefixed;
    BOOL _isUnderscoredPrefix;
    BOOL property;
    id object;
    __weak id weakObject;
    __strong id strongObject;

    BOOL isFoo1;
    BOOL foo1;
    BOOL _isFoo1;
    BOOL _foo1;
    
    BOOL foo2;
    BOOL isFoo2;
    BOOL _isFoo2;
    
    BOOL foo3;
    BOOL isFoo3;
}
@property (nonatomic) BOOL property;
@end

@implementation Direct {
    BOOL implementationIvar;
}

@synthesize property=property;

+ (BOOL)accessInstanceVariablesDirectly
{
    return YES;
}

- (BOOL)interfaceIsSet
{
    return interfaceIvar;
}

- (BOOL)implementationIsSet
{
    return implementationIvar;
}

- (BOOL)underscorePrefixIsSet
{
    return _underscorePrefix;
}

- (BOOL)doubleUnderscorePrefixIsSet
{
    return __doubleUnderscorePrefix;
}

- (BOOL)underscorePostfixIsSet
{
    return underscorePostfix_;
}

- (BOOL)isPrefixedIsSet
{
    return isPrefixed;
}

- (BOOL)isUnderscoredPrefixedIsSet
{
    return _isUnderscoredPrefix;
}

- (NSArray *)foo1IvarsSet
{
    NSMutableArray *ivars = [[NSMutableArray alloc] init];
    if (_foo1)
    {
        [ivars addObject:@"_foo1"];
    }
    if (_isFoo1)
    {
        [ivars addObject:@"_isFoo1"];
    }
    if (foo1)
    {
        [ivars addObject:@"foo1"];
    }
    if (isFoo1)
    {
        [ivars addObject:@"isFoo1"];
    }
    return [ivars autorelease];
}

- (NSArray *)foo2IvarsSet
{
    NSMutableArray *ivars = [[NSMutableArray alloc] init];
    if (_isFoo2)
    {
        [ivars addObject:@"_isFoo2"];
    }
    if (foo2)
    {
        [ivars addObject:@"foo2"];
    }
    if (isFoo2)
    {
        [ivars addObject:@"isFoo2"];
    }
    return [ivars autorelease];
}

- (NSArray *)foo3IvarsSet
{
    NSMutableArray *ivars = [[NSMutableArray alloc] init];
    if (foo3)
    {
        [ivars addObject:@"foo3"];
    }
    if (isFoo3)
    {
        [ivars addObject:@"isFoo3"];
    }
    return [ivars autorelease];
}

@end

@testcase(NSKeyValueCoding)

- (BOOL)testDefaultAccessor
{
    BOOL accessor = [NSObject accessInstanceVariablesDirectly];
    testassert(accessor == YES);
    return YES;
}

- (BOOL)testInterfaceIvar
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"interfaceIvar"];
    testassert([d interfaceIsSet]);
    [d release];
    return YES;
}

- (BOOL)testImplementationIvar
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"implementationIvar"];
    testassert([d implementationIsSet]);
    [d release];
    return YES;
}

- (BOOL)testDirectUknown
{
    Direct *d = [[Direct alloc] init];
    BOOL thrown = NO;
    @try {
        [d setValue:@YES forKey:@"unknownIvar"];
    } @catch(NSException *e) {
        thrown = [[e name] isEqualToString:NSUndefinedKeyException];
    }
    
    testassert(thrown == YES);
    [d release];
    return YES;
}

- (BOOL)testDirectProperty
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"property"];
    testassert(d.property == YES);
    [d release];
    return YES;
}

- (BOOL)testDirectUnderscorePrefix
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"underscorePrefix"];
    testassert([d underscorePrefixIsSet]);
    [d release];
    return YES;
}

- (BOOL)testDirectUnderscorePrefix2
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"_underscorePrefix"];
    testassert([d underscorePrefixIsSet]);
    [d release];
    return YES;
}

- (BOOL)testDirectDoubleUnderscorePrefix
{
    Direct *d = [[Direct alloc] init];
    BOOL thrown = NO;
    @try {
        [d setValue:@YES forKey:@"doubleUnderscorePrefix"];
    } @catch(NSException *e) {
        thrown = [[e name] isEqualToString:NSUndefinedKeyException];
    }
    testassert(thrown = YES);
    testassert(![d doubleUnderscorePrefixIsSet]);
    [d release];
    return YES;
}

- (BOOL)testDirectDoubleUnderscorePrefix2
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"_doubleUnderscorePrefix"];
    testassert([d doubleUnderscorePrefixIsSet]);
    [d release];
    return YES;
}

- (BOOL)testDirectUnderscorePostfix
{
    Direct *d = [[Direct alloc] init];
    BOOL thrown = NO;
    @try {
        [d setValue:@YES forKey:@"underscorePostfix"];
    } @catch(NSException *e) {
        thrown = [[e name] isEqualToString:NSUndefinedKeyException];
    }
    testassert(thrown = YES);
    testassert(![d underscorePostfixIsSet]);
    [d release];
    return YES;
}

- (BOOL)testDirectIsPrefix
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"prefixed"];
    testassert([d isPrefixedIsSet]);
    [d release];
    return YES;
}

- (BOOL)testDirectIsUnderscorePrefix
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"underscoredPrefix"];
    testassert([d isUnderscoredPrefixedIsSet]);
    [d release];
    return YES;
}

- (BOOL)testDirectIncorrectFirstLetterCaseSetter
{
    Direct *d = [[Direct alloc] init];
    BOOL thrown = NO;
    @try {
        [d setValue:@YES forKey:@"InterfaceIvar"];
    } @catch(NSException *e) {
        thrown = [[e name] isEqualToString:NSUndefinedKeyException];
    }
    testassert(thrown = YES);
    testassert(![d interfaceIsSet]);
    [d release];
    return YES;
}

- (BOOL)testDirectIncorrectCaseSetter
{
    Direct *d = [[Direct alloc] init];
    BOOL thrown = NO;
    @try {
        [d setValue:@YES forKey:@"interfaceivar"];
    } @catch(NSException *e) {
        thrown = [[e name] isEqualToString:NSUndefinedKeyException];
    }
    testassert(thrown = YES);
    testassert(![d interfaceIsSet]);
    [d release];
    return YES;
}

- (BOOL)testDirectObjectSetter
{
    Direct *d = [[Direct alloc] init];
    RetainTestObject *retainTest = [[RetainTestObject alloc] init];
    [d setValue:retainTest forKey:@"object"];
    testassert([retainTest wasRetained]);
    [retainTest release];
    [d release];
    return YES;
}

- (BOOL)testDirectWeakObjectSetter
{
    Direct *d = [[Direct alloc] init];
    RetainTestObject *retainTest = [[RetainTestObject alloc] init];
    [d setValue:retainTest forKey:@"weakObject"];
    testassert([retainTest wasRetained]);
    [retainTest release];
    [d release];
    return YES;
}

- (BOOL)testDirectStrongObjectSetter
{
    Direct *d = [[Direct alloc] init];
    RetainTestObject *retainTest = [[RetainTestObject alloc] init];
    [d setValue:retainTest forKey:@"strongObject"];
    testassert([retainTest wasRetained]);
    [retainTest release];
    [d release];
    return YES;
}

- (BOOL)testDirectLeakedObjectSetter
{
    Direct *d = [[Direct alloc] init];
    RetainTestObject *retainTest1 = [[RetainTestObject alloc] init];
    RetainTestObject *retainTest2 = [[RetainTestObject alloc] init];
    [d setValue:retainTest1 forKey:@"object"];
    [d setValue:retainTest2 forKey:@"object"];
    testassert(![retainTest1 wasReleased]);
    [retainTest1 release];
    [retainTest2 release];
    [d release];
    return YES;
}

- (BOOL)testDirectOrder1
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"foo1"];
    NSArray *ivars = [d foo1IvarsSet];
    testassert([ivars isEqualToArray:@[@"_foo1"]]);
    return YES;
}

- (BOOL)testDirectOrder2
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"foo2"];
    NSArray *ivars = [d foo2IvarsSet];
    testassert([ivars isEqualToArray:@[@"_isFoo2"]]);
    return YES;
}

- (BOOL)testDirectOrder3
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"foo3"];
    NSArray *ivars = [d foo3IvarsSet];
    testassert([ivars isEqualToArray:@[@"foo3"]]);
    return YES;
}

@end
