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

@testcase(NSArray)

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
    NSString *key1 = @"key";
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
    NSString *key1 = @"key";
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

@end
