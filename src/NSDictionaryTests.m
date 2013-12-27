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

- (BOOL)testDictionaryCreation
{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:(NSArray *)@[@"foo", @"bar", @"baz"] forKeys:(NSArray *)@[@"foo", @"bar", @"baz"]];

    // Array initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);

    [dict release];

    return YES;
}

- (BOOL)testMutableDictionaryCreation
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjects:(NSArray *)@[@"foo", @"bar", @"baz"] forKeys:(NSArray *)@[@"foo", @"bar", @"baz"]];

    // Array initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);
    testassert([dict isKindOfClass:[objc_getClass("NSMutableDictionary") class]]);

    [dict release];

    return YES;
}

- (BOOL)testMutable_setObject_forKey
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:@"foo" forKey:@"fooKey"];
    
    testassert([dict count] == 1);
    testassert([[dict objectForKey:@"fooKey"] isEqualToString:@"foo"]);
    
    return YES;
}

- (BOOL)testMutable_setObject_forNilKey
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    BOOL exception = NO;
    @try {
        [dict setObject:@"foo" forKey:nil];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
    }
    
    testassert([dict count] == 0);
    testassert(exception);
    
    return YES;
}

- (BOOL)testMutable_setNilObject_forKey
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    BOOL exception = NO;
    @try {
        [dict setObject:nil forKey:@"fooKey"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
    }
    
    testassert([dict count] == 0);
    testassert(exception);
    
    return YES;
}

- (BOOL)testMutableDictionary_removeObjectForKey
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"foo", @"fooKey", nil];
    
    [dict removeObjectForKey:@"fooKey"];
    
    testassert([dict count] == 0);
    
    return YES;
}

- (BOOL)testMutableDictionary_removeObjectForNilKey
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"foo", @"fooKey", nil];
    
    BOOL exception = NO;
    @try {
        [dict removeObjectForKey:nil];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
    }
    
    testassert([dict count] == 1);
    testassert(exception);
    
    return YES;
}

- (BOOL)testRemoveUnretainedObject
{
    NSMutableDictionary* m = [@{@"foo": @"bar"} mutableCopy];
    [self unretainedObjectInMutableDictionary:m forKey:@"baz"];

    /* Test that the removal of an unretained object doesn't crash */
    [m removeObjectForKey:@"baz"];
    [m release];

    return YES;
}
#warning TODO

- (BOOL)testFileCreation
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ATestPlist" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];

    // File initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);

    [dict release];

    return YES;
}

- (BOOL)testFileMutableCreation
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ATestPlist" ofType:@"plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];

    // File initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);
    testassert([dict isKindOfClass:[objc_getClass("NSMutableDictionary") class]]);

    BOOL exception = NO;
    @try {
        [dict setObject:@"foo" forKey:@"foo"];
    }
    @catch (NSException *e) {
        exception = YES;
    }
    testassert(exception == NO);

    [dict release];

    return YES;
}

- (BOOL)testFileMutableCreation_dictionaryWithContentsOfFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ATestPlist" ofType:@"plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:path];

    // File initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);
    testassert([dict isKindOfClass:[objc_getClass("NSMutableDictionary") class]]);

    BOOL exception = NO;
    @try {
        [dict setObject:@"foo" forKey:@"foo"];
    }
    @catch (NSException *e) {
        exception = YES;
    }
    testassert(exception == NO);

    return YES;
}

- (BOOL)testFileMutableCreation_dictionaryWithContentsOfNilFile
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:nil];

    testassert(dict == nil);

    return YES;
}

- (BOOL)testNSDictionary_writeToFileAtomicallyYes
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"fooObj", @"fooKey", nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"DictionaryTest0"];
    
    BOOL result = [dict writeToFile:filePath atomically:YES];
    testassert(result);

    NSDictionary *dict2 = [NSDictionary dictionaryWithContentsOfFile:filePath];
    testassert([dict isEqualToDictionary:dict2]);
    
    return YES;
}

- (BOOL)testNSDictionary_writeToFileAtomically_withNilValue
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"fooObj", @"fooKey", nil];
    BOOL result = [dict writeToFile:nil atomically:YES];
    testassert(!result);
    return YES;
}

- (BOOL)testNSDictionary_writeToFileAtomically_withEmptyValue
{
    NSDictionary *dict = [NSDictionary dictionary];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"DictionaryTest1"];
    
    BOOL result = [dict writeToFile:filePath atomically:YES];
    testassert(result);

    NSDictionary *dict2 = [NSDictionary dictionaryWithContentsOfFile:filePath];
    testassert([dict isEqualToDictionary:dict2]);
    
    return YES;
}

- (BOOL)testNSDictionary_writeToURLAtomicallyYes
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"fooObj", @"fooKey", nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"DictionaryTest2"];
    
    BOOL result = [dict writeToURL:[NSURL fileURLWithPath:filePath] atomically:YES];
    testassert(result);
    
    NSDictionary *dict2 = [NSDictionary dictionaryWithContentsOfFile:filePath];
    testassert([dict isEqualToDictionary:dict2]);
    
    return YES;
}

- (BOOL)testNSDictionary_writeToRULAtomically_withNilValue
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"fooObj", @"fooKey", nil];
    BOOL result = [dict writeToURL:nil atomically:YES];
    testassert(!result);
    return YES;
}

- (BOOL)testNSDictionary_writeToRULAtomically_withEmptyValue
{
    NSDictionary *dict = [NSDictionary dictionary];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"DictionaryTest3"];
    
    BOOL result = [dict writeToURL:[NSURL fileURLWithPath:filePath] atomically:YES];
    testassert(result);

    NSDictionary *dict2 = [NSDictionary dictionaryWithContentsOfFile:filePath];
    testassert([dict isEqualToDictionary:dict2]);
    
    return YES;
}

- (BOOL)testURLCreation
{
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"ATestPlist" withExtension:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfURL:URL];

    // File initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);

    [dict release];

    return YES;
}

- (BOOL)testURLNilCreation
{
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfURL:[NSURL URLWithString:nil]];

    testassert(dict == nil);

    return YES;
}

- (BOOL)testURLMutableCreation
{
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"ATestPlist" withExtension:@"plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfURL:URL];

    // File initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);
    testassert([dict isKindOfClass:[objc_getClass("NSMutableDictionary") class]]);

    BOOL exception = NO;
    @try {
        [dict setObject:@"foo" forKey:@"foo"];
    }
    @catch (NSException *e) {
        exception = YES;
    }
    testassert(exception == NO);

    [dict release];

    return YES;
}

- (BOOL)testURLMutableCreation_dictionaryWithContentsOfURL
{
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"ATestPlist" withExtension:@"plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfURL:URL];

    // File initializer should return a dictionary
    testassert(dict != nil);
    testassert([dict isKindOfClass:[objc_getClass("NSDictionary") class]]);
    testassert([dict isKindOfClass:[objc_getClass("NSMutableDictionary") class]]);

    BOOL exception = NO;
    @try {
        [dict setObject:@"foo" forKey:@"foo"];
    }
    @catch (NSException *e) {
        exception = YES;
    }
    testassert(exception == NO);

    return YES;
}

- (BOOL)testURLMutableCreation_dictionaryWithContentsOfNilURL
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfURL:nil];

    testassert(dict == nil);

    return YES;
}

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

- (BOOL)testKeysOfEntriesPassingTestWithEmptyDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSSet *set = [dict keysOfEntriesPassingTest:^(NSString* key, id obj, BOOL* stop) {
        return [key hasPrefix:@"foo"];
    }];
  
    testassert(set != nil);
    testassert(set.count == 0);

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

static Boolean strEqual(const void *a, const void *b)
{
	Boolean result = strcmp(a, b) == 0;
    return result;
}

static CFHashCode strHash(const void *a)
{
    const char *b = (const char *)a;
    int result = 0;
    while (*b++)
    {
        result += ((result << 8) - result) ^ *b;
    }
    return result;
}

static CFDictionaryKeyCallBacks cStringCallbacks = {
	/* CFIndex version; */ 0,
	/* CFDictionaryRetainCallBack retain;*/ NULL,
	/* CFDictionaryReleaseCallBack release;*/ NULL,
	/* CFDictionaryCopyDescriptionCallBack copyDescription;*/ NULL,
	/* CFDictionaryEqualCallBack equal;*/ strEqual,
	/* CFDictionaryHashCallBack hash;*/ strHash,
};

static CFDictionaryValueCallBacks dataCallbacks = {
	/* CFIndex version; */ 0,
	/* CFDictionaryRetainCallBack retain;*/ NULL,
	/* CFDictionaryReleaseCallBack release;*/ NULL,
	/* CFDictionaryCopyDescriptionCallBack copyDescription;*/ NULL,
	/* CFDictionaryEqualCallBack equal;*/ NULL,
};

static const char *allKeys[] = {
	"Europe/Vaduz",
	"Mideast/Riyadh89",
	"America/Jujuy",
	"Pacific/Pago_Pago",
	"Pacific/Port_Moresby",
	"US/Aleutian",
};

static const char *allData[] = {
	"Libya",
	"Pacific/Niue",
	"Mexico/BajaNorte",
	"Asia/Riyadh88",
	"Etc/GMT+2",
	"America/Jamaica",
};

- (BOOL)testCFDictionaryWithCStringKey
{
	CFDictionaryRef d = CFDictionaryCreate(NULL, (const void **)allKeys, (const void **)allData, 6, &cStringCallbacks, &dataCallbacks);
    char localCopy[15];   /* Make sure key value is different */
    char *base = "America/Jujuy";
    strcpy(localCopy, base);
    const char *value = CFDictionaryGetValue(d, localCopy);
    testassert(strcmp(value, "Mexico/BajaNorte") == 0);

    return YES;
}

- (BOOL)testBadCapacity
{
    __block BOOL raised = NO;
    __block NSMutableDictionary *dict = nil;
    void (^block)(void) = ^{
        dict = [[NSMutableDictionary alloc] initWithCapacity:1073741824];
    };
    @try {
        block();
    }
    @catch (NSException *e) {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        raised = YES;
    }
    testassert(raised);
    [dict release];
    return YES;
}

- (BOOL)testLargeCapacity
{
    __block BOOL raised = NO;
    __block NSMutableDictionary *dict = nil;
    void (^block)(void) = ^{
        dict = [[NSMutableDictionary alloc] initWithCapacity:1073741823];
    };
    @try {
        block();
    }
    @catch (NSException *e) {
        raised = YES;
    }
    testassert(!raised);
    [dict release];
    return YES;
}

#pragma mark Helpers

- (id)unretainedObjectInMutableDictionary:(NSMutableDictionary*)m forKey:(id)aKey
{
    /* Array must have previous contents for the test to work */
    testassert([m count] > 0);

    @autoreleasepool {
        id obj = @{@"foo": @"bar"};
        [m setObject:obj forKey:aKey];

        testassert([obj retainCount] == 2);
    }

    id obj = [m objectForKey:aKey];
    testassert([obj retainCount] == 1);
    return obj;
}

@end
