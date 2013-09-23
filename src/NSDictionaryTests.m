#import "FoundationTests.h"

#include <stdio.h>
#import <objc/runtime.h>

@interface NSDictionarySubclass : NSDictionary {
    NSDictionary *inner;
}
@property (nonatomic, readonly) BOOL didInit;
@end

@implementation NSDictionarySubclass

- (id)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt
{
    self = [super init];
    if (self)
    {
        inner = [[NSDictionary alloc] initWithObjects:objects forKeys:keys count:cnt];
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

@testcase(NSDictionary)

- (BOOL)testAllocate
{
    NSDictionary *d1 = [NSDictionary alloc];
    NSDictionary *d2 = [NSDictionary alloc];

    // Dictionary allocators return singletons
    testassert(d1 == d2);

    return YES;
}

- (BOOL)testAllocateMutable
{
    NSMutableDictionary *d1 = [NSMutableDictionary alloc];
    NSMutableDictionary *d2 = [NSMutableDictionary alloc];

    // Mutable dictionary allocators return singletons
    testassert(d1 == d2);

    return YES;
}

- (BOOL)testAllocateDifferential
{
    NSDictionary *d1 = [NSDictionary alloc];
    NSMutableDictionary *d2 = [NSMutableDictionary alloc];

    // Mutable and immutable allocators must be from the same class
    testassert([d1 class] == [d2 class]);

    return YES;
}

- (BOOL)testAllocatedRetainCount
{
    NSDictionary *d = [NSDictionary alloc];

    // Allocators are singletons and have this retain count
    testassert([d retainCount] == NSUIntegerMax);

    return YES;
}

- (BOOL)testAllocatedClass
{
    // Allocation must be a NSDictionary subclass
    testassert([[NSDictionary alloc] isKindOfClass:[NSDictionary class]]);

    // Allocation must be a NSDictionary subclass
    testassert([[NSMutableDictionary alloc] isKindOfClass:[NSDictionary class]]);

    // Allocation must be a NSMutableDictionary subclass
    testassert([[NSDictionary alloc] isKindOfClass:[NSMutableDictionary class]]);

    // Allocation must be a NSMutableDictionary subclass
    testassert([[NSMutableDictionary alloc] isKindOfClass:[NSMutableDictionary class]]);

    return YES;
}

- (BOOL)testRetainCount
{
    NSDictionary *d = [NSDictionary alloc];

    testassert([d retainCount] == NSUIntegerMax);

    return YES;
}

- (BOOL)testDoubleDeallocAllocate
{
    GNUSTEP_KNOWN_CRASHER();

    NSDictionary *d = [NSDictionary alloc];

    // Releasing twice should not throw
    [d release];
    [d release];

    return YES;
}

- (BOOL)testDoubleInit
{
    void (^block)() = ^{
        [[NSDictionary dictionaryWithObjectsAndKeys:@"foo", @"bar", nil] initWithObjectsAndKeys:@"bar", @"baz", nil];
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
    NSDictionary *dict = [[NSDictionary alloc] init];

    // Blank initialization should return a dictionary
    testassert(dict != nil);

    [dict release];

    return YES;
}

- (BOOL)testBlankMutableCreation
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    // Blank initialization should return a dictionary
    testassert(dict != nil);

    [dict release];

    return YES;
}

- (BOOL)testDefaultCreation
{
    NSString *key1 = @"key";
    id obj1 = [[NSObject alloc] init];
    NSDictionary *obj = [NSDictionary alloc];
    NSDictionary *dict = [obj initWithObjects:&obj1 forKeys:&key1 count:1];

    // Default initializer with one object should return a dictionary
    testassert(dict != nil);

    [dict release];

    return YES;
}

- (BOOL)testDefaultMutableCreation
{
    NSString *key1 = @"key";
    id obj1 = [[NSObject alloc] init];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjects:&obj1 forKeys:&key1 count:1];

    // Default initializer with one object should return a dictionary
    testassert(dict != nil);

    [dict release];

    return YES;
}

- (BOOL)testDefaultCreationMany
{
    int count = 10;
    id<NSCopying> *keys = malloc(sizeof(*keys) * count);
    id *values = malloc(sizeof(id) * count);
    for (int i = 0; i < count; i++)
    {
        keys[i] = [NSString stringWithFormat:@"%d", i];
        values[i] = [[[NSObject alloc] init] autorelease];
    }

    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:values forKeys:keys count:count];
    // Default initializer with <count> objects should return a dictionary
    testassert(dict != nil);

    [dict release];

    free(keys);
    free(values);

    return YES;
}

- (BOOL)testDefaultMutableCreationMany
{
    int count = 10;
    id<NSCopying> *keys = malloc(sizeof(*keys) * count);
    id *values = malloc(sizeof(id) * count);
    for (int i = 0; i < count; i++)
    {
        keys[i] = [NSString stringWithFormat:@"%d", i];
        values[i] = [[[NSObject alloc] init] autorelease];
    }

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjects:values forKeys:keys count:count];

    // Default initializer with <count> objects should return a dictionary
    testassert(dict != nil);

    [dict release];

    free(keys);
    free(values);

    return YES;
}

- (BOOL)testVarArgsCreation
{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"foo", @"bar", @"baz", @"bar", nil];

    // Var args initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);

    [dict release];

    return YES;
}

- (BOOL)testVarArgsMutableCreation
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"foo", @"bar", @"baz", @"bar", nil];

    // Var args initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);
    testassert([dict isKindOfClass:[objc_getClass("NSMutableDictionary") class]]);

    [dict release];

    return YES;
}

- (BOOL)testOtherDictionaryCreation
{
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:(NSDictionary *)@{
                                                                                    @"foo" : @"bar",
                                                                                    @"baz" : @"foo"
                                                                                    }];

    // Other dictionary initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);

    [dict release];

    return YES;
}

- (BOOL)testOtherDictionaryMutableCreation
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)@{
                                                                                                  @"foo" : @"bar",
                                                                                                  @"baz" : @"foo"
                                                                                                  }];
    // Other dictionary initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);
    testassert([dict isKindOfClass:[objc_getClass("NSMutableDictionary") class]]);

    [dict release];

    return YES;
}

- (BOOL)testOtherDictionaryCopyCreation
{
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:(NSDictionary *)@{
                                                                                    @"foo" : @"bar",
                                                                                    @"baz" : @"foo"
                                                                                    } copyItems:YES];

    // Other dictionary initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);

    [dict release];

    return YES;
}

- (BOOL)testOtherDictionaryCopyMutableCreation
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)@{
                                                                                                  @"foo" : @"bar",
                                                                                                  @"baz" : @"foo"
                                                                                                  } copyItems:YES];

    // Other dictionary initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);
    testassert([dict isKindOfClass:[objc_getClass("NSMutableDictionary") class]]);

    [dict release];

    return YES;
}

- (BOOL)testOtherDictionaryNoCopyCreation
{
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:(NSDictionary *)@{
                                                                                    @"foo" : @"bar",
                                                                                    @"baz" : @"foo"
                                                                                    } copyItems:NO];

    // Other dictionary initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);

    [dict release];

    return YES;
}

- (BOOL)testOtherDictionaryNoCopyMutableCreation
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)@{
                                                                                                  @"foo" : @"bar",
                                                                                                  @"baz" : @"foo"
                                                                                                  } copyItems:NO];

    // Other dictionary initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);
    testassert([dict isKindOfClass:[objc_getClass("NSMutableDictionary") class]]);

    [dict release];

    return YES;
}

- (BOOL)testArrayCreation
{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:(NSArray *)@[@"foo", @"bar", @"baz"] forKeys:(NSArray *)@[@"foo", @"bar", @"baz"]];

    // Array initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);

    [dict release];

    return YES;
}

- (BOOL)testArrayMutableCreation
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjects:(NSArray *)@[@"foo", @"bar", @"baz"] forKeys:(NSArray *)@[@"foo", @"bar", @"baz"]];

    // Array initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);
    testassert([dict isKindOfClass:[objc_getClass("NSMutableDictionary") class]]);

    [dict release];

    return YES;
}

#warning TODO
#if 0

- (BOOL)testFileCreation
{
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"Info.plist"];

    // File initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);

    [dict release];

    return YES;
}

- (BOOL)testFileMutableCreation
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:@"Info.plist"];

    // File initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);
    testassert([dict isKindOfClass:[objc_getClass("NSMutableDictionary") class]]);

    [dict release];

    return YES;
}

- (BOOL)testURLCreation
{
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfURL:[NSURL fileURLWithPath:@"Info.plist"]];

    // File initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);

    [dict release];

    return YES;
}

- (BOOL)testURLMutableCreation
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfURL:[NSURL fileURLWithPath:@"Info.plist"]];

    // File initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);
    testassert([dict isKindOfClass:[objc_getClass("NSMutableDictionary") class]]);

    [dict release];

    return YES;
}

#endif

- (BOOL)testSubclassCreation
{
    NSDictionarySubclass *dict = [[NSDictionarySubclass alloc] initWithObjectsAndKeys:@"foo", @"bar", @"baz", @"foo", nil];

    // Created dictionary should not be nil
    testassert(dict != nil);

    // Dictionary subclasses should funnel creation methods to initWithObjects:forKeys:count:
    testassert(dict.didInit);

    [dict release];

    return YES;
}

- (BOOL)testDescription
{
    // If all keys are same type and type is sortable, description should sort 
    
    NSDictionary *dict = @{ @"k2" : @1, @"k3" : @2, @"k1" : @3 };
    NSString *d = @"{\n    k1 = 3;\n    k2 = 1;\n    k3 = 2;\n}";
    testassert([d isEqualToString:[dict description]]);
    
    NSDictionary *nestedDict =  @{ @"k2" : @1, @"k1" : @2, @"k3": @{ @"kk1" : @11, @"kk2" : @22, @"kk3" : @33}, @"k4" : @3 };
    d = @"{\n    k1 = 2;\n    k2 = 1;\n    k3 =     {\n        kk1 = 11;\n        kk2 = 22;\n        kk3 = 33;\n    };\n    k4 = 3;\n}";
    testassert([d isEqualToString:[nestedDict description]]);
    
    NSDictionary *nestedArray =  @{ @"k3" : @1, @"k2" : @[ @111, @{ @"kk1" : @11, @"kk2" : @22, @"kk3" : @33}, @333], @"k1" : @3 };
    d = @"{\n    k1 = 3;\n    k2 =     (\n        111,\n                {\n            kk1 = 11;\n            kk2 = 22;\n            kk3 = 33;\n        },\n        333\n    );\n    k3 = 1;\n}";
    testassert([d isEqualToString:[nestedArray description]]);
    
    NSArray *nestedInArray =  @[ @1, @{ @"k1": @111, @"k2" : @{ @"kk1" : @11, @"kk2" : @22, @"kk3" : @33}, @"k3": @333}, @3 ];
    d = @"(\n    1,\n        {\n        k1 = 111;\n        k2 =         {\n            kk1 = 11;\n            kk2 = 22;\n            kk3 = 33;\n        };\n        k3 = 333;\n    },\n    3\n)";
    testassert([d isEqualToString:[nestedInArray description]]);
    
    dict = @{ @2 : @1, @3 : @2, @1 : @3};
    d = @"{\n    1 = 3;\n    2 = 1;\n    3 = 2;\n}";
    testassert([d isEqualToString:[dict description]]);
    
    dict = @{ @2 : @1, @3 : @2, @1 : @3, @"k1" : @9 };
    d = @"{\n    k1 = 9;\n    3 = 2;\n    1 = 3;\n    2 = 1;\n}";
    testassert([d isEqualToString:[dict description]]);
    
    return YES;
}

- (BOOL)testGetObjectsAndKeys
{
    GNUSTEP_KNOWN_CRASHER();

    NSDictionary *dict = @{ @"k2" : @1, @"k3" : @2, @"k1" : @3 };
    size_t size = sizeof(id) * [dict count] ;
    id *keys = (id *)malloc(size);
    id *objs = (id *)malloc(size);
    id *keys2 = (id *)malloc(size);
    id *objs2 = (id *)malloc(size);
    
    [dict getObjects:objs andKeys:keys];
    [dict getObjects:objs2 andKeys:nil];
    [dict getObjects:nil andKeys:keys2];
    
    testassert(memcmp(objs, objs2, size) == 0);
    testassert(memcmp(keys, keys2, size) == 0);
    testassert([@"k1" isEqualToString:keys[2]]);
    testassert([@1 isEqual : objs[1]]);
    free(keys);
    free(keys2);
    free(objs);
    free(objs2);
    
    return YES;
}

- (BOOL)testEnumerateKeysAndObject
{
    NSDictionary *dict = @{ @"k2" : @1, @"k3" : @2, @"k1" : @3 };
    static int sum = 0;
    [dict enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        sum += [obj intValue];
    }];
    
    testassert(sum == 6);
    
    return YES;
}

#pragma mark -
#pragma mark KVC testing

// https://developer.apple.com/library/ios/documentation/cocoa/conceptual/KeyValueCoding/Articles/CollectionOperators.html

- (BOOL)testValueForKeyPath
{
    BOOL exception = NO;
    // NOTE : this also tests encapsulated NSArray and NSSet
    
    NSMutableSet *subset = [[NSMutableSet alloc] initWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"42", @"42", nil];
    NSMutableArray *subarray = [[NSMutableArray alloc] initWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *loop = [[NSMutableDictionary alloc] initWithCapacity:2];
    NSMutableDictionary *subdict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", subarray, @"subarray", loop, @"loop", subset, @"subset", nil];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:subdict, @"subdict", nil];

    NSMutableArray *anArray = [[NSMutableArray alloc] initWithObjects:dict, nil];
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
    id anObj = [dict valueForKeyPath:nil];
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
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key ."]);
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
        testassert([[e reason] hasSuffix:@"this class does not implement the count operation."]);
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
        testassert([[e reason] hasSuffix:@"this class does not implement the count operation."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@anInvalidOperator.with.a.remainder.path"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"this class does not implement the anInvalidOperator operation."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@anInvalidOperator"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key anInvalidOperator."]);
    }
    testassert(exception);

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
            NSString *s = [NSString stringWithFormat:@"this class is not key value coding-compliant for the key %@.", op];
            testassert([[e reason] hasSuffix:s]);
        }
        testassert(exception);
        
        @try {
            exception = NO;
            anObj = [dict valueForKeyPath:[NSString stringWithFormat:@"subdict.@%@.intValue", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
            NSString *s = [NSString stringWithFormat:@"this class does not implement the %@ operation.", op];
            testassert([[e reason] hasSuffix:s]);
        }
        testassert(exception);

        @try {
            exception = NO;
            anObj = [dict valueForKeyPath:[NSString stringWithFormat:@"subdict.subarray.@%@.invalidKey", op]];
        }
        @catch (NSException *e) {
            exception = YES;
            testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
            testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key invalidKey."]);
        }
        testassert(exception);
        
        ++i;
    }

    // --------------------------------------------------
    // ALLOC another array for specific tests...
    
    NSMutableArray *anotherArray = [[NSMutableArray alloc] initWithCapacity:5];
    [anotherArray addObject:anArray];
    [anotherArray addObject:subarray];
    [anotherArray addObject:@[@"foo", @"bar"]];
    [anotherArray addObject:@[@"foo", @"bar"]];
    //[anotherArray addObject:anotherArray]; -- recursion will crash @{distinctU,u}nionOf{Objects,Arrays}
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
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key unionOfObjects."]);
    }
    testassert(exception);

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subset.@unionOfObjects.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"this class does not implement the unionOfObjects operation."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@distinctUnionOfObjects.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"this class does not implement the distinctUnionOfObjects operation."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@unionOfObjects.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"this class does not implement the unionOfObjects operation."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@distinctUnionOfObjects"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key distinctUnionOfObjects."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@unionOfObjects"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key unionOfObjects."]);
    }
    testassert(exception);
    
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
    NSMutableSet *anotherSet = [[NSMutableSet alloc] initWithCapacity:5];
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
        testassert([[e reason] hasSuffix:@"array argument is not an NSArray"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subarray.@unionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"array argument is not an NSArray"]);
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
        testassert([[e reason] hasSuffix:@"array argument is not an NSArray"]);
    }
    testassert(exception);

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subset.@unionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"this class does not implement the unionOfArrays operation."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@unionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"this class does not implement the unionOfArrays operation."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@distinctUnionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"this class does not implement the distinctUnionOfArrays operation."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@unionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key unionOfArrays."]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@distinctUnionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
        testassert([[e reason] hasSuffix:@"this class is not key value coding-compliant for the key distinctUnionOfArrays."]);
    }
    testassert(exception);

    // --------------------------------------------------
    // @distinctUnionOfSets
    // NOTE : seems to only work on an NSSet of NSSets (returns NSSet) --OR-- NSArray of NSSets (returns NSArray)
    
    [anotherArray removeAllObjects];
    [anotherArray addObject:[NSSet setWithArray:anArray]];
    [anotherArray addObject:[NSSet setWithArray:subarray]];
    [anotherArray addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    [anotherArray addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    
    [anotherSet removeAllObjects];
    [anotherSet addObject:[NSSet setWithArray:anArray]];
    [anotherSet addObject:[NSSet setWithArray:subarray]];
    [anotherSet addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    [anotherSet addObject:[NSSet setWithArray:@[@"foo", @"bar"]]];
    
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
        testassert([[e reason] hasSuffix:@"set argument is not an NSSet"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subarray.@distinctUnionOfSets.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"set argument is not an NSSet"]);
    }
    testassert(exception);
    
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.@distinctUnionOfSets.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
        testassert([[e reason] hasSuffix:@"this class does not implement the distinctUnionOfSets operation."]);
    }
    testassert(exception);

    // --------------------------------------------------
    
    [anotherSet release];
    [anotherArray release];

    [subset release];
    [subarray release];
    [loop release];
    [subdict release];
    [dict release];
    [anArray release];
    
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
