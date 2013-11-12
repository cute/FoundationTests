#import "FoundationTests.h"

#include <stdio.h>
#import <objc/runtime.h>

@interface RetainTestObject : NSObject
@end

@implementation RetainTestObject {
    BOOL wasRetained;
    BOOL wasReleased;
    BOOL wasAutoreleased;
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

- (id)autorelease
{
    wasAutoreleased = YES;
    return [super autorelease];
}

- (BOOL)wasReleased
{
    return wasReleased;
}

- (BOOL)wasRetained
{
    return wasRetained;
}

- (BOOL)wasAutoreleased
{
    return wasAutoreleased;
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

- (BOOL)testDirectUnknown
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

- (BOOL)testDirectReassignObjectSetter
{
    Direct *d = [[Direct alloc] init];
    RetainTestObject *retainTest1 = [[RetainTestObject alloc] init];
    RetainTestObject *retainTest2 = [[RetainTestObject alloc] init];
    [d setValue:retainTest1 forKey:@"object"];
    [d setValue:retainTest2 forKey:@"object"];
    testassert(![retainTest1 wasReleased]);
    testassert([retainTest1 wasAutoreleased]);
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

// [NSMutableDictionary setValue:forKeyPath:] silent FAIL cases ...

- (BOOL) test_setValueForKeyPath_onNSMutableDictionary_PathWithAtSymbols
{
    id anObj = nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"barVal", @"barKey", @"fooVal", @"fooKey", nil];
    [dict setObject:dict forKey:@"self"];
    NSUInteger dictCount = [dict count];
    
    NSString *aPathWithAts = @"a@.@path@with.at@symbols@.";
    [dict setValue:@"foo" forKeyPath:aPathWithAts];
    testassert([dict count] == dictCount);
    anObj = [dict valueForKeyPath:aPathWithAts];
    testassert(anObj == nil);
    
    return YES;
}

- (BOOL) test_setValueForKeyPath_onNSMutableDictionary_ValidYetNonexistentASCIIKeyPath
{
    id anObj = nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"barVal", @"barKey", @"fooVal", @"fooKey", nil];
    [dict setObject:dict forKey:@"self"];
    NSUInteger dictCount = [dict count];
    
    NSString *validYetNonexistentKeyPath = @"a.valid.yet.nonexistent.key.path";
    [dict setValue:@"foo" forKeyPath:validYetNonexistentKeyPath];
    testassert([dict count] == dictCount);
    anObj = [dict valueForKeyPath:validYetNonexistentKeyPath];
    testassert(anObj == nil);
    
    return YES;
}

- (BOOL) test_setValueForKeyPath_onNSMutableDictionary_ValidYetNonexistentKeyPathWithSomeUnicodeSymbols
{
    id anObj = nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"barVal", @"barKey", @"fooVal", @"fooKey", nil];
    [dict setObject:dict forKey:@"self"];
    NSUInteger dictCount = [dict count];

    NSString *validYetNonexistentKeyPath = @"a.väl|d.yét.n0nEx1$t3nt.kéy´.p@th!";
    [dict setValue:@"foo" forKeyPath:validYetNonexistentKeyPath];
    testassert([dict count] == dictCount);
    anObj = [dict valueForKeyPath:validYetNonexistentKeyPath];
    testassert(anObj == nil);
    
    return YES;
}

- (BOOL) test_setValueForKeyPath_onNSMutableDictionary_AnotherWhackyKeyPathWithMoarUnicodeSymbols
{
    id anObj = nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"barVal", @"barKey", @"fooVal", @"fooKey", nil];
    [dict setObject:dict forKey:@"self"];
    NSUInteger dictCount = [dict count];
    
    NSString *anotherWhackyKeyPath = @"!#$@aasdf}.\\[-$uiå∑œΩ≈©†®´√ˆ¨∆äopio`~/?.,<>><.<;:'\"{#$@#$l.k@rqADF|+_w^ier.23]]]48&*(*&()";
    [dict setValue:@"foo" forKeyPath:anotherWhackyKeyPath];
    testassert([dict count] == dictCount);
    anObj = [dict valueForKeyPath:anotherWhackyKeyPath];
    testassert(anObj == nil);
    
    return YES;
}

- (BOOL) test_setValueForKeyPath_onNSMutableDictionary_LeadingDot
{
    id anObj = nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"barVal", @"barKey", @"fooVal", @"fooKey", nil];
    [dict setObject:dict forKey:@"self"];
    NSUInteger dictCount = [dict count];
    
    NSString *beginDot = @".self.subdict";
    [dict setValue:@"foo" forKeyPath:beginDot];
    testassert([dict count] == dictCount);
    anObj = [dict valueForKeyPath:beginDot];
    testassert(anObj == nil);
    
    return YES;
}

- (BOOL) test_setValueForKeyPath_onNSMutableDictionary_UnaryDot
{
    id anObj = nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"barVal", @"barKey", @"fooVal", @"fooKey", nil];
    [dict setObject:dict forKey:@"self"];
    NSUInteger dictCount = [dict count];
    
    NSString *unaryDot = @".";
    [dict setValue:@"foo" forKeyPath:unaryDot];
    testassert([dict count] == dictCount);
    anObj = [dict valueForKeyPath:unaryDot];
    testassert(anObj == nil);
    
    return YES;
}

- (BOOL) test_setValueForKeyPath_onNSMutableDictionary_DotsBros
{
    id anObj = nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"barVal", @"barKey", @"fooVal", @"fooKey", nil];
    [dict setObject:dict forKey:@"self"];
    NSUInteger dictCount = [dict count];
    
    NSString *dotsBros = @"........................................................................................";
    [dict setValue:@"foo" forKeyPath:dotsBros];
    testassert([dict count] == dictCount);
    anObj = [dict valueForKeyPath:dotsBros];
    testassert(anObj == nil);
    
    return YES;
}

// [NSMutableDictionary setValue:forKeyPath:] success cases ...

- (BOOL) test_setValueForKeyPath_onNSMutableDictionary_EmptyPath
{
    id anObj = nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"barVal", @"barKey", @"fooVal", @"fooKey", nil];
    [dict setObject:dict forKey:@"self"];
    NSUInteger dictCount = [dict count];
    
    NSString *emptyPath = @"";
    [dict setValue:@"foo" forKeyPath:emptyPath];
    ++dictCount;
    testassert([dict count] == dictCount);
    anObj = [dict valueForKeyPath:emptyPath];
    testassert([anObj isEqualToString:@"foo"]);
    
    return YES;
}

- (BOOL) test_setValueForKeyPath_onNSMutableDictionary_LastDot
{
    id anObj = nil;
    
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subarray, @"subarray", [NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", @"fooVal", @"fooKey", nil];
    
    [subdict setObject:dict forKey:@"parent"];
    [dict setObject:dict forKey:@"self"];
    
    NSUInteger dictCount = [dict count];
    NSUInteger subdictCount = [subdict count];

    NSString *lastDot = @"self.subdict.parent.subdict.";
    [dict setValue:@"foo" forKeyPath:lastDot];
    ++subdictCount;
    testassert([dict count] == dictCount);
    testassert([subdict count] == subdictCount);
    anObj = [dict valueForKeyPath:lastDot];
    testassert([anObj isEqualToString:@"foo"]);
    testassert([anObj isEqualToString:@"foo"]);
    
    return YES;
}

- (BOOL) test_setValueForKeyPath_onNSMutableDictionary_SelfReferentialPath
{
    id anObj = nil;
    
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subarray, @"subarray", [NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", @"fooVal", @"fooKey", nil];
    
    [subdict setObject:dict forKey:@"parent"];
    [dict setObject:dict forKey:@"self"];
    
    NSUInteger dictCount = [dict count];
    NSUInteger subdictCount = [subdict count];
    
    NSString *fooKeyPath = @"self.self.subdict.parent.fooKey";
    [dict setValue:@"bar" forKeyPath:fooKeyPath];
    testassert([dict count] == dictCount);
    testassert([subdict count] == subdictCount);
    anObj = [dict valueForKeyPath:fooKeyPath];
    testassert([anObj isEqualToString:@"bar"]);
    
    return YES;
}

- (BOOL) test_setValueForKeyPath_onNSMutableDictionary_LongerSelfReferentialPath
{
    id anObj = nil;
    
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subarray, @"subarray", [NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", @"fooVal", @"fooKey", nil];
    
    [subdict setObject:dict forKey:@"parent"];
    [dict setObject:dict forKey:@"self"];
    
    NSUInteger dictCount = [dict count];
    NSUInteger subdictCount = [subdict count];
    
    NSString *bazKeyPath = @"subdict.bazKey";
    NSString *aLongRecursiveBazKeyPath = @"self.self.subdict.parent.self.self.self.subdict.parent.subdict.bazKey";
    [dict setValue:@"foo" forKeyPath:aLongRecursiveBazKeyPath];
    testassert([dict count] == dictCount);
    testassert([subdict count] == subdictCount);
    anObj = [dict valueForKeyPath:bazKeyPath];
    testassert([anObj isEqualToString:@"foo"]);
    
    [dict setValue:@"bazVal" forKeyPath:bazKeyPath];
    testassert([dict count] == dictCount);
    testassert([subdict count] == subdictCount);
    anObj = [dict valueForKeyPath:aLongRecursiveBazKeyPath];
    testassert([anObj isEqualToString:@"bazVal"]);
    
    return YES;
}

- (BOOL) test_setValueForKeyPath_onNSMutableDictionary_AddingNewSubKey
{
    id anObj = nil;
    
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subarray, @"subarray", [NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", @"fooVal", @"fooKey", nil];
    
    [subdict setObject:dict forKey:@"parent"];
    [dict setObject:dict forKey:@"self"];
    
    NSUInteger dictCount = [dict count];
    NSUInteger subdictCount = [subdict count];
    
    NSString *aNewKeyPath = @"subdict.aNewKey";
    [dict setValue:@"aNewKeyVal" forKeyPath:aNewKeyPath];
    ++subdictCount;
    testassert([dict count] == dictCount);
    testassert([subdict count] == subdictCount);
    anObj = [dict valueForKeyPath:aNewKeyPath];
    testassert([anObj isEqualToString:@"aNewKeyVal"]);
    
    return YES;
}

- (BOOL) test_setValueForKeyPath_onNSMutableDictionary_RediculouslyLongRecursiveKeyPath
{
    id anObj = nil;
    
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subarray, @"subarray", [NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", @"fooVal", @"fooKey", nil];
    
    [subdict setObject:dict forKey:@"parent"];
    [dict setObject:dict forKey:@"self"];
    
    NSUInteger dictCount = [dict count];
    NSUInteger subdictCount = [subdict count];
    
    NSString *aSomewhatRidiculouslyLongRecursivePath = @"self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.fooKey";
    [dict setValue:@"bazz" forKeyPath:aSomewhatRidiculouslyLongRecursivePath];
    testassert([dict count] == dictCount);
    testassert([subdict count] == subdictCount);
    anObj = [dict valueForKeyPath:aSomewhatRidiculouslyLongRecursivePath];
    testassert([anObj isEqualToString:@"bazz"]);
    
    return YES;
}

// [NSMutableDictionary setValue:forKeyPath:] special operators tests ...

- (BOOL) test_setValueForKeyPath_onNSMutableDictionary_MaxOperator
{
    id anObj = nil;
    
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subarray, @"subarray", [NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", @"fooVal", @"fooKey", nil];
    
    [subdict setObject:dict forKey:@"parent"];
    [dict setObject:dict forKey:@"self"];
    
    NSUInteger dictCount = [dict count];
    NSUInteger subdictCount = [subdict count];
    
    NSString *maxValuePath = @"subdict.@max";
    [dict setValue:@"altMax" forKeyPath:maxValuePath];
    ++subdictCount;
    testassert([dict count] == dictCount);
    testassert([subdict count] == subdictCount);
    // valueForKey{,Path} should prolly be tested here and elsewhere
    anObj = [subdict objectForKey:@"@max"];
    testassert([anObj isEqualToString:@"altMax"]);
    
    return YES;
}

- (BOOL) test_setValueForKeyPath_onNSMutableDictionary_CountOperator
{
    id anObj = nil;
    
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subarray, @"subarray", [NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", @"fooVal", @"fooKey", nil];
    
    [subdict setObject:dict forKey:@"parent"];
    [dict setObject:dict forKey:@"self"];
    
    NSUInteger dictCount = [dict count];
    NSUInteger subdictCount = [subdict count];
    
    NSString *aPathWithCountOperator = @"@count";
    [dict setValue:@"hmm" forKeyPath:aPathWithCountOperator];
    ++dictCount;
    testassert([dict count] == dictCount);
    testassert([subdict count] == subdictCount);
    anObj = [dict valueForKeyPath:aPathWithCountOperator];
    testassert([anObj intValue] == 4);
    anObj = [dict valueForKey:aPathWithCountOperator];
    testassert([anObj intValue] == 4);
    anObj = [dict objectForKey:aPathWithCountOperator];
    testassert([anObj isEqualToString:@"hmm"]);
    
    return YES;
}

- (BOOL) test_setValueForKeyPath_onNSMutableDictionary_SubPathCountOperator
{
    id anObj = nil;
    
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subarray, @"subarray", [NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", @"fooVal", @"fooKey", nil];
    
    [subdict setObject:dict forKey:@"parent"];
    [dict setObject:dict forKey:@"self"];
    
    NSUInteger dictCount = [dict count];
    NSUInteger subdictCount = [subdict count];
    
    NSString *anotherPathWithCountOperator = @"subdict.@count";
    [dict setValue:@"yea" forKeyPath:anotherPathWithCountOperator];
    ++subdictCount;
    testassert([dict count] == dictCount);
    testassert([subdict count] == subdictCount);
    anObj = [dict valueForKeyPath:anotherPathWithCountOperator];
    testassert([anObj intValue] == 6);
    anObj = [dict valueForKey:anotherPathWithCountOperator];
    testassert(anObj == nil);
    anObj = [dict objectForKey:anotherPathWithCountOperator];
    testassert(anObj == nil);
    anObj = [subdict objectForKey:@"@count"];
    testassert([anObj isEqualToString:@"yea"]);
    
    return YES;
}

// TODO : More @operator tests ...

// [NSMutableDictionary setValue:forKeyPath:] assertion cases ...

- (BOOL) test_setValueForKeyPath_onNSMutableDictionary_Assertion1
{
    BOOL exception = NO;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"barVal", @"barKey", @"fooVal", @"fooKey", nil];
    [dict setObject:dict forKey:@"self"];
    
    @try {
        exception = NO;
        [dict setValue:@"foo" forKeyPath:nil];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    return YES;
}

- (BOOL) test_setValueForKeyPath_onNSMutableDictionary_Assertion2
{
    BOOL exception = NO;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"barVal", @"barKey", @"fooVal", @"fooKey", nil];
    [dict setObject:dict forKey:@"self"];
    
    NSString *atDotPath = @"@.";
    @try {
        exception = NO;
        [dict setValue:@"foo" forKeyPath:atDotPath];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    return YES;
}
    
- (BOOL) test_setValueForKeyPath_onNSMutableDictionary_Assertion3
{
    BOOL exception = NO;
    id anObj = nil;
    
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subarray, @"subarray", [NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", @"fooVal", @"fooKey", nil];
    
    [subdict setObject:dict forKey:@"parent"];
    [dict setObject:dict forKey:@"self"];
    
    NSUInteger dictCount = [dict count];
    NSUInteger subdictCount = [subdict count];
    
    NSString *setValueOutFromUnderItselfPath = @"subdict.parent.subdict";
    [dict setValue:@"gone" forKeyPath:setValueOutFromUnderItselfPath];
    testassert([dict count] == dictCount);
    testassert([subdict count] == subdictCount);
    anObj = [dict valueForKeyPath:@"subdict"];
    testassert([anObj isEqualToString:@"gone"]);
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:setValueOutFromUnderItselfPath];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    [dict setObject:subdict forKey:@"subdict"];// reset

    return YES;
}

// TODO : NSMutableArray , NSMutableSet setValue:forKeyPath: tests ...


// https://developer.apple.com/library/ios/documentation/cocoa/conceptual/KeyValueCoding/Articles/CollectionOperators.html

- (BOOL)test_NSDictionary_valueForKeyPath_Basics
{
    BOOL exception = NO;
    id anObj;
    NSMutableSet *subset = [NSMutableSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"42", @"42", nil];
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *loop = [NSMutableDictionary dictionary];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", subarray, @"subarray", loop, @"loop", subset, @"subset", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:dict, nil];
    [dict setObject:anArray forKey:@"anArray"];
    
    // inf loop ...
    [loop setObject:dict forKey:@"dict"];
    [loop setObject:loop forKey:@"loop"];

    // Created collections should not be nil
    testassert(subset != nil);
    testassert(loop != nil);
    testassert(subarray != nil);
    testassert(subdict != nil);
    testassert(dict != nil);
    testassert(anArray != nil);
    
    // --------------------------------------------------
    // test getting objects with various keyPaths
    anObj = [dict valueForKeyPath:nil];
    testassert(anObj == nil);

    anObj = [dict valueForKeyPath:@"subdict.subarray"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSMutableArray class]]);
    testassert([anObj isEqual:subarray]);
    
    anObj = [dict valueForKeyPath:@".subdict.subarray"];
    testassert(anObj == nil);
    
    anObj = [dict valueForKeyPath:@"subdict."];
    testassert(anObj == nil);
    
    [subdict setObject:@"foo" forKey:@""];
    anObj = [dict valueForKeyPath:@"subdict."];
    testassert([anObj isKindOfClass:[NSString class]]);
    testassert([anObj isEqualToString:@"foo"]);
    [subdict removeObjectForKey:@""];
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subarray."];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    anObj = [dict valueForKeyPath:@"subdict.bazKey"];
    testassert([anObj isEqualToString:@"bazVal"]);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.bazKey.invalid"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    anObj = [dict valueForKeyPath:@"subdict.loop"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSMutableDictionary class]]);
    testassert([anObj isEqual:loop]);
    
    anObj = [dict valueForKeyPath:@"subdict.loop.loop"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSMutableDictionary class]]);
    testassert([anObj isEqual:loop]);

    anObj = [dict valueForKeyPath:@"subdict.loop.dict"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSMutableDictionary class]]);
    testassert([anObj isEqual:dict]);
    
    anObj = [dict valueForKeyPath:@"subdict.loop.loop.loop.dict.subdict.loop.dict.subdict.subarray"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSMutableArray class]]);
    testassert([anObj isEqual:subarray]);

    anObj = [dict valueForKeyPath:@"a.completely.wrong.path.that.is.syntactically.correct"];
    testassert(anObj == nil);
    
    anObj = [dict valueForKeyPath:@"#!/bin/sh -c 'echo hello.world'"];
    testassert(anObj == nil);

    // --------------------------------------------------
    // @count tests
    anObj = [dict valueForKeyPath:@"@count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 2);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@count.subdict"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    anObj = [dict valueForKeyPath:@"subdict.@count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 6);
    
    anObj = [dict valueForKeyPath:@"subdict.loop.@count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 2);
    
    anObj = [dict valueForKeyPath:@"subdict.subarray.@count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 6);
    
    anObj = [dict valueForKeyPath:@"subdict.subarray.@count.right.hand.path.here.should.be.ignored"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 6);
    
    anObj = [dict valueForKeyPath:@"subdict.subset.@count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 5);

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.@count.subarray"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@anInvalidOperator.with.a.remainder.path"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@anInvalidOperator"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@."];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    return YES;
}

- (BOOL)test_NSDictionary_valueForKeyPath_AvgMaxMinSum
{
    BOOL exception = NO;
    id anObj;
    NSMutableSet *subset = [NSMutableSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"42", @"42", nil];
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *loop = [NSMutableDictionary dictionary];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", subarray, @"subarray", loop, @"loop", subset, @"subset", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:dict, nil];
    [dict setObject:anArray forKey:@"anArray"];

    // --------------------------------------------------
    // @avg, @max, @min, @sum
    
    NSArray *operators = @[@"avg", @"max", @"min", @"sum"];
    NSArray *results = @[
                         @{@"valResults": @[@17, @33, @0, @0],
                           @"valClasses": @[[NSDecimalNumber class], [NSDecimalNumber class], [NSDecimalNumber class], [NSDecimalNumber class]]
                           },
                         @{@"valResults": @[@101, @127, @0, @0],
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSNull class], [NSNull class]]
                           },
                         @{@"valResults": @[@-2, @-6, @0, @0],
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSNull class], [NSNull class]]
                           },
                         @{@"valResults": @[@103, @166, @0, @0],
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSDecimalNumber class], [NSDecimalNumber class]]
                           },
                         ];
    unsigned int i=0;
    for (NSString *op in operators)
    {
        NSLog(@"testing for operator : %@", op);
        unsigned int j=0;
        NSDictionary *cribSheet = [results objectAtIndex:i];
        NSArray *valClasses = [cribSheet objectForKey:@"valClasses"];
        NSArray *valResults = [cribSheet objectForKey:@"valResults"];
        
        anObj = [dict valueForKeyPath:[NSString stringWithFormat:@"subdict.subarray.@%@.intValue", op]];
        testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
        testassert([anObj intValue] == [[valResults objectAtIndex:j] intValue]);
        ++j;

        anObj = [dict valueForKeyPath:[NSString stringWithFormat:@"subdict.subset.@%@.floatValue", op]];
        testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
        testassert([anObj intValue] == [[valResults objectAtIndex:j] intValue]);
        ++j;

        anObj = [dict valueForKeyPath:[NSString stringWithFormat:@"anArray.@%@.dict.subdict.subset.floatValue", op]];
        testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
        testassert([anObj intValue] == [[valResults objectAtIndex:j] intValue]);
        ++j;

        anObj = [dict valueForKeyPath:[NSString stringWithFormat:@"anArray.@%@.dict.subdict.subset", op]];
        testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
        testassert([anObj intValue] == [[valResults objectAtIndex:j] intValue]);
        ++j;
        
        @try {
            exception = NO;
            anObj = [dict valueForKeyPath:[NSString stringWithFormat:@"subdict.@%@", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        }
        testassert(exception);
        
        @try {
            exception = NO;
            anObj = [dict valueForKeyPath:[NSString stringWithFormat:@"subdict.@%@.intValue", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        }
        testassert(exception);

        @try {
            exception = NO;
            anObj = [dict valueForKeyPath:[NSString stringWithFormat:@"subdict.subarray.@%@.invalidKey", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        }
        testassert(exception);
        
        ++i;
    }
    
    return YES;
}

- (BOOL)test_NSDictionary_valueForKeyPath_unionOfObjects_distinctUnionOfObjects
{
    BOOL exception = NO;
    id anObj;
    NSMutableSet *subset = [NSMutableSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"42", @"42", nil];
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *loop = [NSMutableDictionary dictionary];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", subarray, @"subarray", loop, @"loop", subset, @"subset", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:dict, nil];
    [dict setObject:anArray forKey:@"anArray"];
    
    NSMutableArray *anotherArray = [NSMutableArray array];
    [anotherArray addObject:anArray];
    [anotherArray addObject:subarray];
    [anotherArray addObject:@[@"foo", @"bar"]];
    [anotherArray addObject:@[@"foo", @"bar"]];
    [subdict setObject:anotherArray forKey:@"anotherArray"];

    // --------------------------------------------------
    // @unionOfObjects @distinctUnionOfObjects

    anObj = [dict valueForKeyPath:@"subdict.subarray.@unionOfObjects.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 6);
    
    anObj = [dict valueForKeyPath:@"subdict.subarray.@distinctUnionOfObjects.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 4);
    
    anObj = [dict valueForKeyPath:@"subdict.subset.@distinctUnionOfObjects.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 5);
    
    anObj = [dict valueForKeyPath:@"subdict.anotherArray.@distinctUnionOfObjects.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 3);
    
    anObj = [dict valueForKeyPath:@"subdict.anotherArray.@unionOfObjects.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 4);

    // @operator as last element in path ...
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subarray.@unionOfObjects"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subset.@unionOfObjects.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@distinctUnionOfObjects.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@unionOfObjects.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@distinctUnionOfObjects"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@unionOfObjects"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    return YES;
}

- (BOOL)test_NSDictionary_valueForKeyPath_unionOfArrays_distinctUnionOfArrays
{
    BOOL exception = NO;
    id anObj;
    NSMutableSet *subset = [NSMutableSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"42", @"42", nil];
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *loop = [NSMutableDictionary dictionary];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", subarray, @"subarray", loop, @"loop", subset, @"subset", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:dict, nil];
    [dict setObject:anArray forKey:@"anArray"];
    
    NSMutableArray *anotherArray = [NSMutableArray array];
    [anotherArray addObject:anArray];
    [anotherArray addObject:subarray];
    [anotherArray addObject:@[@"foo", @"bar"]];
    [anotherArray addObject:@[@"foo", @"bar"]];
    [subdict setObject:anotherArray forKey:@"anotherArray"];
    
    // --------------------------------------------------
    // @unionOfArrays @distinctUnionOfArrays
    // NOTE : seems to only work on an NSArray of NSArrays (returns NSArray) --OR-- NSSet of NSArrays (returns NSSet)

    anObj = [dict valueForKeyPath:@"subdict.anotherArray.@unionOfArrays.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 11);
    
    anObj = [dict valueForKeyPath:@"subdict.anotherArray.@distinctUnionOfArrays.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 7);
    
    // NSSet positive test
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:anArray];
    [anotherSet addObject:subarray];
    [anotherSet addObject:@[@"foo", @"bar"]];
    [anotherSet addObject:@[@"foo", @"bar"]];
    [subdict setObject:anotherSet forKey:@"anotherSet"];
    
    anObj = [dict valueForKeyPath:@"subdict.anotherSet.@distinctUnionOfArrays.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 7);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subarray.@distinctUnionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subarray.@unionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    // Also verify exception occurs on NSSet
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subset.@distinctUnionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subset.@unionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@unionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@distinctUnionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@unionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@distinctUnionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
}

- (BOOL)test_NSDictionary_valueForKeyPath_distinctUnionOfSets
{
    BOOL exception = NO;
    id anObj;
    NSMutableSet *subset = [NSMutableSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"42", @"42", nil];
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *loop = [NSMutableDictionary dictionary];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", subarray, @"subarray", loop, @"loop", subset, @"subset", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:dict, nil];
    [dict setObject:anArray forKey:@"anArray"];
    
    NSMutableArray *anotherArray = [NSMutableArray array];
    [anotherArray addObject:[NSSet setWithArray:anArray]];
    [anotherArray addObject:[NSSet setWithArray:subarray]];
    [anotherArray addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    [anotherArray addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    [subdict setObject:anotherArray forKey:@"anotherArray"];
    
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:[NSSet setWithArray:anArray]];
    [anotherSet addObject:[NSSet setWithArray:subarray]];
    [anotherSet addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    [anotherSet addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    [subdict setObject:anotherSet forKey:@"anotherSet"];

    // --------------------------------------------------
    // @distinctUnionOfSets
    // NOTE : seems to only work on an NSSet of NSSets (returns NSSet) --OR-- NSArray of NSSets (returns NSArray)
    
    anObj = [dict valueForKeyPath:@"subdict.anotherSet.@distinctUnionOfSets.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 6);
    
    anObj = [dict valueForKeyPath:@"subdict.anotherArray.@distinctUnionOfSets.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 6);

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subset.@distinctUnionOfSets.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subarray.@distinctUnionOfSets.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.@distinctUnionOfSets.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    // --------------------------------------------------
    
    return YES;
}

- (BOOL)test_NSArray_valueForKeyPath_Basics
{
    BOOL exception = NO;
    id anObj;
    NSDictionary *subdict = [NSDictionary dictionaryWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];
    
    // --------------------------------------------------
    // random path tests
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:nil];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"lastObject"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@""];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"."];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"1"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@1"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@@@@@@@"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    // --------------------------------------------------
    // @count tests
    anObj = [anArray valueForKeyPath:@"@count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 11);
    
    anObj = [anArray valueForKeyPath:@"@count.should.ignore.right.hand.path"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 11);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"foo@count"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    return YES;
}

- (BOOL)test_NSArray_valueForKeyPath_Recursion
{
    NSMutableArray *recursiveArray = [NSMutableArray array];
    [recursiveArray addObject:recursiveArray];
    [recursiveArray addObject:@[@"foo", @"bar"]];
    [recursiveArray addObject:@[@"foo", @"bar"]];
    
    //anObj = [recursiveArray valueForKeyPath:@"@max.count"]; -- stack overflow in iOS simulator
    //anObj = [recursiveArray valueForKeyPath:@"@min.count"]; -- ditto
    //anObj = [recursiveArray valueForKeyPath:@"@avg.count"]; -- ditto
    //anObj = [recursiveArray valueForKeyPath:@"@sum.count"]; -- ditto
    
    return YES;
}

- (BOOL)test_NSArray_valueForKeyPath_MaxMinAvgSum
{
    BOOL exception = NO;
    id anObj;
    NSDictionary *subdict = [NSDictionary dictionaryWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];
    NSMutableArray *anotherArray = [NSMutableArray array];
    
    // --------------------------------------------------
    // @max, @min, @avg, @sum
    
    NSArray *operators = @[@"max", @"min", @"avg", @"sum"];
    NSArray *results = @[
                         @{@"valResults": @[@127, @127, [NSNull null], @"another constant NSString with a long description"],
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSNumber class], [NSString class]]
                           },
                         @{@"valResults": @[@-127, @-127, [NSNull null], @""],
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSNumber class], [NSString class]]
                           },
                         @{@"valResults": @[@7, @7],
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSNumber class], [NSNull class]]
                           },
                         @{@"valResults": @[@82, @81, @0, @"NaN"],
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSNumber class], [NSDecimalNumber class]]
                           },
                         ];
    unsigned int i=0;
    for (NSString *op in operators)
    {
        NSLog(@"testing for operator : %@", op);
        
        unsigned int j=0;
        NSDictionary *cribSheet = [results objectAtIndex:i];
        NSArray *valClasses = [cribSheet objectForKey:@"valClasses"];
        NSArray *valResults = [cribSheet objectForKey:@"valResults"];
        
        anObj = [anArray valueForKeyPath:[NSString stringWithFormat:@"@%@.intValue", op]];
        testassert(anObj != nil);
        testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
        testassert([anObj intValue] == [[valResults objectAtIndex:j] intValue]);
        ++j;
        
        anObj = [anArray valueForKeyPath:[NSString stringWithFormat:@"@%@.floatValue", op]];
        testassert(anObj != nil);
        testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
        testassert([anObj intValue] == [[valResults objectAtIndex:j] intValue]);
        ++j;
        
        // array of arrays
        anObj = [anotherArray valueForKeyPath:[NSString stringWithFormat:@"@%@.count", op]]; // HACK use anArray instead?
        if ([op isEqualToString:@"sum"])
        {
            testassert(anObj != nil);
            testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
            testassert([anObj intValue] == [[valResults objectAtIndex:j] intValue]);
        }
        else
        {
            testassert(anObj == nil);
        }
        ++j;
        
        if ([op isEqualToString:@"avg"])
        {
            // cannot call @avg.description && @sum.description
            @try {
                exception = NO;
                anObj = [anArray valueForKeyPath:[NSString stringWithFormat:@"@%@.description", op]];
            }
            @catch (NSException *e) {
                exception = YES;
                testassert([[e name] isEqualToString:@"NSDecimalNumberOverflowException"]);
            }
            testassert(exception);
        }
        else
        {
            anObj = [anArray valueForKeyPath:[NSString stringWithFormat:@"@%@.description", op]];
            testassert(anObj != nil);
            testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
            testassert([[anObj description] isEqual:[[valResults objectAtIndex:j] description]]);
        }
        
        // throw exception with invalid prefix --
        @try {
            exception = NO;
            anObj = [anArray valueForKeyPath:[NSString stringWithFormat:@"foo@%@.description", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        }
        testassert(exception);
        
        // throw exception for no suffix --
        @try {
            exception = NO;
            anObj = [anArray valueForKeyPath:[NSString stringWithFormat:@"@%@", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        }
        testassert(exception);
        
        // throw exception for invalid suffix --
        @try {
            exception = NO;
            anObj = [anArray valueForKeyPath:[NSString stringWithFormat:@"@%@.foobar", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        }
        testassert(exception);
        
        ++i;
    }
    
    return YES;
}

- (BOOL)test_NSArray_valueForKeyPath_unionOfObjects_distinctUnionOfObjects
{
    BOOL exception = NO;
    id anObj;
    NSDictionary *subdict = [NSDictionary dictionaryWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];
    NSMutableArray *anotherArray = [NSMutableArray array];
    
    // --------------------------------------------------
    // @unionOfObjects @distinctUnionOfObjects
    
    anObj = [anArray valueForKeyPath:@"@unionOfObjects.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 10);
    
    anObj = [anArray valueForKeyPath:@"@distinctUnionOfObjects.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 9);
    
    anObj = [anotherArray valueForKeyPath:@"@unionOfObjects.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 0);

    // @operator as last element in path ...
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@unionOfObjects"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    return YES;
}

- (BOOL)test_NSArray_valueForKeyPath_unionOfArrays_distinctUnionOfArrays
{
    BOOL exception = NO;
    id anObj;
    NSDictionary *subdict = [NSDictionary dictionaryWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];
    NSMutableArray *anotherArray = [NSMutableArray array];
    [anotherArray addObject:[NSArray arrayWithObjects:@[@1, @2, @42], @[@1, @2, @42], @3.3, @[@1, @2, @3], nil]];
    [anotherArray addObject:[NSArray arrayWithObjects:@"hello", @"world", @"-23", nil]];
    
    // --------------------------------------------------
    // @unionOfArrays @distinctUnionOfArrays
    // NOTE : seems to only work on an NSSet of NSArrays (returns NSArray) --OR-- NSArray of NSArray (returns NSArray)
    
    //anObj = [recursiveArray valueForKeyPath:@"@unionOfArrays.description"]; -- stack overflow in iOS simulator
    
    anObj = [anotherArray valueForKeyPath:@"@unionOfArrays.doubleValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 7);
    id subObj = [anObj objectAtIndex:0];
    testassert([subObj isKindOfClass:[NSArray class]]);
    testassert([subObj count] == 3);
    
    anObj = [anotherArray valueForKeyPath:@"@distinctUnionOfArrays.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 6);
    subObj = [anObj objectAtIndex:0];
    testassert([subObj isKindOfClass:[NSArray class]]);
    testassert([subObj count] == 3);
    
    @try {
        exception = NO;
        anObj = [anotherArray valueForKeyPath:@"@distinctUnionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anotherArray valueForKeyPath:@"@unionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@distinctUnionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@unionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    return YES;
}

- (BOOL)test_NSArray_valueForKeyPath_distinctUnionOfSets
{
    BOOL exception = NO;
    id anObj;
    NSDictionary *subdict = [NSDictionary dictionaryWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];
    NSMutableArray *anotherArray = [NSMutableArray array];
    [anotherArray addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    [anotherArray addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    
    // --------------------------------------------------
    // @distinctUnionOfSets
    // NOTE : seems to only work on an NSSet of NSSets (returns NSSet) --OR-- NSArray of NSSets (returns NSArray)
    
    
    anObj = [anotherArray valueForKeyPath:@"@distinctUnionOfSets.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 2);
    
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@distinctUnionOfSets.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    // --------------------------------------------------
    
    return YES;
}

- (BOOL)test_NSSet_valueForKeyPath_Basics
{
    BOOL exception = NO;
    id anObj;
    NSDictionary *subdict = [NSDictionary dictionaryWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    NSSet *aSet = [NSSet setWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];
    
    // Created collections should not be nil
    testassert(subdict != nil);
    testassert(aSet != nil);
    
    // --------------------------------------------------
    // random path tests
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:nil];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"lastObject"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@""];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"."];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"1"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@1"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@@@@@@@"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    // --------------------------------------------------
    // @count tests
    anObj = [aSet valueForKeyPath:@"@count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 10);
    
    anObj = [aSet valueForKeyPath:@"@count.should.ignore.right.hand.path"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 10);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"foo@count"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    return YES;
}

- (BOOL)test_NSSet_valueForKeyPath_recursion
{
    NSMutableSet *recursiveSet = [NSMutableSet set];
    [recursiveSet addObject:@[@"foo", @"bar"]];
    [recursiveSet addObject:@[@"foo", @"bar"]];
    [recursiveSet addObject:recursiveSet];
    //anObj = [recursiveSet valueForKeyPath:@"@max.count"]; //-- stack overflow in iOS simulator
    //anObj = [recursiveSet valueForKeyPath:@"@min.count"]; //-- ditto
    //anObj = [recursiveSet valueForKeyPath:@"@avg.count"]; //-- ditto
    //anObj = [recursiveSet valueForKeyPath:@"@sum.count"]; //-- ditto
    
    return YES;
}

- (BOOL)test_NSSet_valueForKeyPathMaxMinAvgSumOperators
{
    BOOL exception = NO;
    id anObj;
    NSDictionary *subdict = [NSDictionary dictionaryWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    NSSet *aSet = [NSSet setWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];
    NSMutableSet *anotherSet = [NSMutableSet set];
    
    // --------------------------------------------------
    // @max, @min, @avg, @sum
    
    NSArray *operators = @[@"max", @"min", @"avg", @"sum"];
    NSArray *results = @[
                         @{@"valResults": @[@127, @127, [NSNull null], @"another constant NSString with a long description"],
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSNumber class], [NSString class]]
                           },
                         @{@"valResults": @[@-127, @-127, [NSNull null], @""],
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSNumber class], [NSString class]]
                           },
                         @{@"valResults": @[@4, @3],
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSNumber class], [NSNull class]]
                           },
                         @{@"valResults": @[@40, @39, @0, @"NaN"],
                           //@"valClasses": @[[NSNumber class], [NSNumber class], [NSNumber class], [NSDecimalNumber class]]
                           @"valClasses": @[[NSNumber class], [NSNumber class], [NSNumber class], [NSNumber class]]
                           },
                         ];
    unsigned int i=0;
    for (NSString *op in operators)
    {
        NSLog(@"testing for operator : %@", op);
        
        unsigned int j=0;
        NSDictionary *cribSheet = [results objectAtIndex:i];
        NSArray *valClasses = [cribSheet objectForKey:@"valClasses"];
        NSArray *valResults = [cribSheet objectForKey:@"valResults"];
        
        anObj = [aSet valueForKeyPath:[NSString stringWithFormat:@"@%@.intValue", op]];
        testassert(anObj != nil);
        testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
        testassert([anObj intValue] == [[valResults objectAtIndex:j] intValue]);
        ++j;
        
        anObj = [aSet valueForKeyPath:[NSString stringWithFormat:@"@%@.floatValue", op]];
        testassert(anObj != nil);
        testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
        testassert([anObj intValue] == [[valResults objectAtIndex:j] intValue]);
        ++j;
        
        // array of arrays
        anObj = [anotherSet valueForKeyPath:[NSString stringWithFormat:@"@%@.count", op]];//FIXME... aSet?
        if ([op isEqualToString:@"sum"])
        {
            testassert(anObj != nil);
            testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
            testassert([anObj intValue] == [[valResults objectAtIndex:j] intValue]);
        }
        else
        {
            testassert(anObj == nil);
        }
        ++j;
        
        if ([op isEqualToString:@"avg"])
        {
            // cannot call @avg.description && @sum.description
/* HACK !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            @try {
                exception = NO;
                anObj = [aSet valueForKeyPath:[NSString stringWithFormat:@"@%@.description", op]];
            }
            @catch (NSException *e) {
                exception = YES;
                testassert([[e name] isEqualToString:@"NSDecimalNumberOverflowException"]);
            }
            testassert(exception);
 */
        }
        else
        {
            anObj = [aSet valueForKeyPath:[NSString stringWithFormat:@"@%@.description", op]];
            testassert(anObj != nil);
            testassert([self _assertClass:[valClasses objectAtIndex:j] forObject:anObj]);
            // HACK !!!!!!!!!!!!!!!!
            if (![op isEqualToString:@"sum"])
            {
                testassert([[anObj description] isEqual:[[valResults objectAtIndex:j] description]]);
            }
        }
        
        // throw exception with invalid prefix --
        @try {
            exception = NO;
            anObj = [aSet valueForKeyPath:[NSString stringWithFormat:@"foo@%@.description", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        }
        testassert(exception);
        
        // throw exception for no suffix --
        @try {
            exception = NO;
            anObj = [aSet valueForKeyPath:[NSString stringWithFormat:@"@%@", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        }
        testassert(exception);
        
        // throw exception for invalid suffix --
        @try {
            exception = NO;
            anObj = [aSet valueForKeyPath:[NSString stringWithFormat:@"@%@.foobar", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        }
        testassert(exception);
        
        ++i;
    }
    
    return YES;
}

- (BOOL)test_NSSet_valueForKeyPath_extraMinMaxAvgSum
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"fooVal", @"fooKey", @"barVal", @"barKey", @101, @"101Key", nil];
    NSMutableSet *set = [NSMutableSet setWithObject:dict];
    
    id aValue = [set valueForKeyPath:@"@max.intValue"];
    testassert(aValue == nil);
    
    aValue = [set valueForKeyPath:@"@min.intValue"];
    testassert(aValue == nil);
    
    aValue = [set valueForKeyPath:@"@avg.intValue"];
    testassert([aValue intValue] == 0);
    
    aValue = [set valueForKeyPath:@"@sum.intValue"];
    testassert([aValue intValue] == 0);
    
    [set addObject:[NSNumber numberWithInt:42]];
    
    aValue = [set valueForKeyPath:@"@max.intValue"];
    testassert([aValue intValue] == 42);
    
    aValue = [set valueForKeyPath:@"@min.intValue"];
    testassert([aValue intValue] == 42);
    
    aValue = [set valueForKeyPath:@"@sum.intValue"];
    testassert([aValue intValue] == 42);
    
    aValue = [set valueForKeyPath:@"@avg.intValue"];
    testassert([aValue intValue] == 21);
    
    [set addObject:[NSNumber numberWithInt:-10]];
    
    aValue = [set valueForKeyPath:@"@avg.intValue"];
    testassert([aValue intValue] == 10);
    
    return YES;
}

- (BOOL)test_NSSet_valueForKeyPath_unionOfObjects_distinctUnionOfObjects
{
    BOOL exception = NO;
    id anObj;
    NSDictionary *subdict = [NSDictionary dictionaryWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    NSSet *aSet = [NSSet setWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", [NSSet setWithObjects:@"subsetobj", @"subsetobj", [NSSet setWithObjects:@"subsubsetobj", nil], nil], nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    NSArray *subAry = [NSArray arrayWithObjects:@[ @"helloset", @"helloset" ], @"helloset", @"helloset", @"arrayobj", nil];
    [anotherSet addObject:subAry];

    // --------------------------------------------------
    // @unionOfObjects @distinctUnionOfObjects
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@unionOfObjects.intValue"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    // ---
    testassert([anotherSet count] == 3);

    anObj = [anotherSet valueForKeyPath:@"@distinctUnionOfObjects.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 3);
    testassert([anObj isEqual:anotherSet]);
    
    anObj = [anotherSet valueForKeyPath:@"@distinctUnionOfObjects.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 3);
    
    // @operator as last element in path ...
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@distinctUnionOfObjects"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@distinctUnionOfObjects.intValue"];
    }
    @catch (NSException *e) {
        // why exactly is this happening?  can't seem to make it happen with NSArray...
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    return YES;
}

- (BOOL)test_NSSet_valueForKeyPath_unionOfArrays_distinctUnionOfArrays
{
    BOOL exception = NO;
    id anObj;
    NSDictionary *subdict = [NSDictionary dictionaryWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    NSSet *aSet = [NSSet setWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", [NSSet setWithObjects:@"subsetobj", @"subsetobj", [NSSet setWithObjects:@"subsubsetobj", nil], nil], nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    NSArray *subAry = [NSArray arrayWithObjects:@[ @"helloset", @"helloset" ], @"helloset", @"helloset", @"arrayobj", nil];
    [anotherSet addObject:subAry];
    
    // --------------------------------------------------
    // @unionOfArrays @distinctUnionOfArrays
    // NOTE : seems to only work on an NSSet of NSArray/NSSet (returns NSArray/NSSet) --OR-- NSArray of NSArray/NSSet (returns NSArray/NSSet)
    
    @try {
        exception = NO;
        anObj = [anotherSet valueForKeyPath:@"@unionOfArrays.intValue"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [anotherSet valueForKeyPath:@"@unionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    anObj = [anotherSet valueForKeyPath:@"@distinctUnionOfArrays.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 9);
#warning TODO: iterate/verify subobjects

    anObj = [anotherSet valueForKeyPath:@"@distinctUnionOfArrays.doubleValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 5);
#warning TODO: iterate/verify subobjects

    @try {
        exception = NO;
        anObj = [anotherSet valueForKeyPath:@"@distinctUnionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    
    NSNumber *aNumber = [NSNumber numberWithInt:1001];
    [anotherSet addObject:aNumber];
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@distinctUnionOfArrays.intValue"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    [anotherSet removeObject:aNumber];
    
    return YES;
}

- (BOOL)test_NSSet_valueForKeyPath_distinctUnionOfSets
{
    BOOL exception = NO;
    id anObj;
    NSDictionary *subdict = [NSDictionary dictionaryWithObjects:@[@"fooVal", @"barVal"] forKeys:@[@"fooKey", @"barKey"]];
    NSSet *aSet = [NSSet setWithObjects:subdict, [NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", [NSSet setWithObjects:@"subsetobj", @"subsetobj", [NSSet setWithObjects:@"subsubsetobj", nil], nil], nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    // --------------------------------------------------
    // @distinctUnionOfSets
    // NOTE : seems to only work on an NSSet of NSSets (returns NSSet) --OR-- NSArray of NSSets (returns NSArray)
    
    anObj = [anotherSet valueForKeyPath:@"@distinctUnionOfSets.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 7);    
    
    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@distinctUnionOfSets.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);
    
    // --------------------------------------------------
    
    return YES;
}

- (BOOL)test_valueForKeyPath_strangeExceptions
{
    NSSet *aSet = [NSSet setWithObjects:[NSMutableString stringWithString:@"an NSMutableString"], nil];
    NSArray *anArray = [NSArray arrayWithObjects:[NSMutableString stringWithString:@"an NSMutableString"], nil];
    BOOL exception = NO;
    id aValue;

    @try {
        exception = NO;
        aValue = [anArray valueForKeyPath:@"@avg.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSDecimalNumberOverflowException"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        aValue = [aSet valueForKeyPath:@"@avg.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSDecimalNumberOverflowException"]);
    }
    testassert(exception);

    return YES;
}

- (BOOL)test_valueForKeyPath_onEmptySet
{
    NSMutableSet *set = [NSMutableSet set];
    
    id aValue = [set valueForKeyPath:@"max.intValue"];
    testassert([aValue isKindOfClass:[NSSet class]]);
    testassert([aValue isEqual:set]);
    testassert([aValue count] == 0);
    
    aValue = [set valueForKeyPath:@"min.intValue"];
    testassert([aValue isKindOfClass:[NSSet class]]);
    testassert([aValue isEqual:set]);
    testassert([aValue count] == 0);
    
    aValue = [set valueForKeyPath:@"avg.intValue"];
    testassert([aValue isKindOfClass:[NSSet class]]);
    testassert([aValue isEqual:set]);
    testassert([aValue count] == 0);
    
    aValue = [set valueForKeyPath:@"sum.intValue"];
    testassert([aValue isKindOfClass:[NSSet class]]);
    testassert([aValue isEqual:set]);
    testassert([aValue count] == 0);
    return YES;
}

- (BOOL) _assertClass:(Class)clazz forObject:(NSObject*)anObj
{
    if ([clazz isEqual:[NSNull class]])
    {
        testassert((anObj == nil) || [anObj isKindOfClass:[NSNull class]]);
    }
    else
    {
        testassert([anObj isKindOfClass:clazz]);
    }
    
    return YES;
}

@end
