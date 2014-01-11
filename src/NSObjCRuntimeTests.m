#import "FoundationTests.h"

#import <objc/message.h>
#import <objc/runtime.h>

@interface TestEncodingSource : NSObject {
    NSRange range;
    CGPoint point;
    CGSize size;
    CGAffineTransform transform;
    CGRect rect;
}
@end

@implementation TestEncodingSource
@end

@testcase(NSObjCRuntime)

- (BOOL)testChar
{
    const char *encoding = @encode(char);
    NSUInteger size = -1;
    NSUInteger alignment = -1;

    const char *end = NSGetSizeAndAlignment(encoding, &size, &alignment);

    testassert(size == sizeof(char));
    testassert(alignment == __alignof(char));
    testassert(*end == '\0');

    return YES;
}

- (BOOL)testShort
{
    const char *encoding = @encode(short);
    NSUInteger size = -1;
    NSUInteger alignment = -1;

    const char *end = NSGetSizeAndAlignment(encoding, &size, &alignment);

    testassert(size == sizeof(short));
    testassert(alignment == __alignof(short));
    testassert(*end == '\0');

    return YES;
}

- (BOOL)testInt
{
    const char *encoding = @encode(int);
    NSUInteger size = -1;
    NSUInteger alignment = -1;

    const char *end = NSGetSizeAndAlignment(encoding, &size, &alignment);

    testassert(size == sizeof(int));
    testassert(alignment == __alignof(int));
    testassert(*end == '\0');

    return YES;
}

- (BOOL)testLong
{
    const char *encoding = @encode(long);
    NSUInteger size = -1;
    NSUInteger alignment = -1;

    const char *end = NSGetSizeAndAlignment(encoding, &size, &alignment);

    testassert(size == sizeof(long));
    testassert(alignment == __alignof(long));
    testassert(*end == '\0');

    return YES;
}

- (BOOL)testLongLong
{
    const char *encoding = @encode(long long);
    NSUInteger size = -1;
    NSUInteger alignment = -1;

    const char *end = NSGetSizeAndAlignment(encoding, &size, &alignment);

    testassert(size == sizeof(long long));
    testassert(alignment == __alignof(long long));
    testassert(*end == '\0');

    return YES;
}

- (BOOL)testUnsignedChar
{
    const char *encoding = @encode(unsigned char);
    NSUInteger size = -1;
    NSUInteger alignment = -1;

    const char *end = NSGetSizeAndAlignment(encoding, &size, &alignment);

    testassert(size == sizeof(unsigned char));
    testassert(alignment == __alignof(unsigned char));
    testassert(*end == '\0');

    return YES;
}

- (BOOL)testUnsignedShort
{
    const char *encoding = @encode(unsigned short);
    NSUInteger size = -1;
    NSUInteger alignment = -1;

    const char *end = NSGetSizeAndAlignment(encoding, &size, &alignment);

    testassert(size == sizeof(unsigned short));
    testassert(alignment == __alignof(unsigned short));
    testassert(*end == '\0');

    return YES;
}

- (BOOL)testUnsignedInt
{
    const char *encoding = @encode(unsigned int);
    NSUInteger size = -1;
    NSUInteger alignment = -1;

    const char *end = NSGetSizeAndAlignment(encoding, &size, &alignment);

    testassert(size == sizeof(unsigned int));
    testassert(alignment == __alignof(unsigned int));
    testassert(*end == '\0');

    return YES;
}

- (BOOL)testUnsignedLong
{
    const char *encoding = @encode(unsigned long);
    NSUInteger size = -1;
    NSUInteger alignment = -1;

    const char *end = NSGetSizeAndAlignment(encoding, &size, &alignment);

    testassert(size == sizeof(unsigned long));
    testassert(alignment == __alignof(unsigned long));
    testassert(*end == '\0');

    return YES;
}

- (BOOL)testUnsignedLongLong
{
    const char *encoding = @encode(unsigned long long);
    NSUInteger size = -1;
    NSUInteger alignment = -1;

    const char *end = NSGetSizeAndAlignment(encoding, &size, &alignment);

    testassert(size == sizeof(unsigned long long));
    testassert(alignment == __alignof(unsigned long long));
    testassert(*end == '\0');

    return YES;
}

- (BOOL)testBOOL
{
    const char *encoding = @encode(BOOL);
    NSUInteger size = -1;
    NSUInteger alignment = -1;

    const char *end = NSGetSizeAndAlignment(encoding, &size, &alignment);

    testassert(size == sizeof(BOOL));
    testassert(alignment == __alignof(BOOL));
    testassert(*end == '\0');

    return YES;
}

- (BOOL)testDouble
{
    const char *encoding = @encode(double);
    NSUInteger size = -1;
    NSUInteger alignment = -1;

    const char *end = NSGetSizeAndAlignment(encoding, &size, &alignment);

    testassert(size == sizeof(double));
    testassert(alignment == __alignof(double));
    testassert(*end == '\0');

    return YES;
}

- (BOOL)testFloat
{
    const char *encoding = @encode(float);
    NSUInteger size = -1;
    NSUInteger alignment = -1;

    const char *end = NSGetSizeAndAlignment(encoding, &size, &alignment);

    testassert(size == sizeof(float));
    testassert(alignment == __alignof(float));
    testassert(*end == '\0');

    return YES;
}

- (BOOL)testId
{
    const char *encoding = @encode(id);
    NSUInteger size = -1;
    NSUInteger alignment = -1;

    const char *end = NSGetSizeAndAlignment(encoding, &size, &alignment);

    testassert(size == sizeof(id));
    testassert(alignment == __alignof(id));
    testassert(*end == '\0');

    return YES;
}

- (BOOL)testClass
{
    const char *encoding = @encode(Class);
    NSUInteger size = -1;
    NSUInteger alignment = -1;

    const char *end = NSGetSizeAndAlignment(encoding, &size, &alignment);

    testassert(size == sizeof(Class));
    testassert(alignment == __alignof(Class));
    testassert(*end == '\0');

    return YES;
}

- (BOOL)testSEL
{
    const char *encoding = @encode(SEL);
    NSUInteger size = -1;
    NSUInteger alignment = -1;

    const char *end = NSGetSizeAndAlignment(encoding, &size, &alignment);

    testassert(size == sizeof(SEL));
    testassert(alignment == __alignof(SEL));
    testassert(*end == '\0');

    return YES;
}

- (BOOL)testCharPtr
{
    const char *encoding = @encode(char *);
    NSUInteger size = -1;
    NSUInteger alignment = -1;

    const char *end = NSGetSizeAndAlignment(encoding, &size, &alignment);

    testassert(size == sizeof(char *));
    testassert(alignment == __alignof(char *));
    testassert(*end == '\0');

    return YES;
}

// In all of the previous cases, @encode(type) is a single character,
// with size and alignment equal to sizeof(type). The following are
// the more complicated cases.

- (BOOL)testVoid
{
    const char *encoding = @encode(void);
    NSUInteger size = -1;
    NSUInteger alignment = -1;

    const char *end = NSGetSizeAndAlignment(encoding, &size, &alignment);

    // A GCCism does permit sizeof(void), but it does not match the
    // behavior of NSGetSizeAndAlignment.
    testassert(size == 0);
    testassert(alignment == 0);
    testassert(*end == '\0');

    return YES;
}

- (BOOL)testPtr
{
    // All (non-function) pointers have the same size and alignment,
    // so we just have to test that NSGetSizeAndAlignment correctly
    // walks over the remainder of the pointer type.

    const char *ptrs[] = {
        @encode(int *),
        @encode(unsigned short *),
        @encode(void *),
        @encode(int (*)[42]),
        @encode(int (*)[]),
        @encode(struct { int i; } *),
        @encode(union { int i; double d; } *),
    };

    for (int i = 0; i < sizeof(ptrs) / sizeof(*ptrs); i++) {
        NSUInteger size = -1;
        NSUInteger alignment = -1;
        const char *end = NSGetSizeAndAlignment(ptrs[i], &size, &alignment);

        testassert(size == sizeof(void *));
        testassert(alignment == __alignof(void *));
        testassert(*end == '\0');
    }

    return YES;
}

- (BOOL)testArray
{
    // For all arrays, the alignment is the alignment of the element
    // type, and the size is the element size times the element
    // count. This includes arrays of length 0.

#warning TODO: A**** checks the array size and throws when too large

    NSUInteger size;
    NSUInteger alignment;
    const char *type, *end;

    size = -1;
    alignment = -1;
    type = @encode(int[42]);
    end = NSGetSizeAndAlignment(type, &size, &alignment);
    testassert(size == 42 * sizeof(int));
    testassert(alignment == __alignof(int));
    testassert(*end == '\0');

    size = -1;
    alignment = -1;
    type = @encode(int[0]);
    end = NSGetSizeAndAlignment(type, &size, &alignment);
    testassert(size == 0);
    testassert(alignment == __alignof(int));
    testassert(*end == '\0');

    size = -1;
    alignment = -1;
    type = @encode(int[16][16]);
    end = NSGetSizeAndAlignment(type, &size, &alignment);
    testassert(size == sizeof(int[16][16]));
    testassert(alignment == __alignof(int));
    testassert(*end == '\0');

    typedef struct {
        int i;
        double d;
        char c;
    } s;

    size = -1;
    alignment = -1;
    type = @encode(s[42]);
    end = NSGetSizeAndAlignment(type, &size, &alignment);
    testassert(size == 42 * sizeof(s));

    testassert(alignment == __alignof(s));
    testassert(*end == '\0');

    return YES;
}

- (BOOL)testStruct
{
    NSUInteger size;
    NSUInteger alignment;
    const char *type, *end;

    size = -1;
    alignment = -1;
    type = @encode(struct {});
    end = NSGetSizeAndAlignment(type, &size, &alignment);
    testassert(size == 0);
    testassert(alignment == 0);
    testassert(*end == '\0');

    // It is legal for the '=' to be missing.
    size = -1;
    alignment = -1;
    type = "{}";
    end = NSGetSizeAndAlignment(type, &size, &alignment);
    testassert(size == 0);
    testassert(alignment == 0);
    testassert(*end == '\0');

    typedef struct {
        int i;
        double d;
    } s;

    size = -1;
    alignment = -1;
    type = @encode(s);
    end = NSGetSizeAndAlignment(type, &size, &alignment);
    testassert(size == sizeof(s));
    testassert(alignment == __alignof(s));
    testassert(*end == '\0');

    // It is legal to include field names.
    size = -1;
    alignment = -1;
    type = "{foo=\"i\"i\"d\"d}"; // The same struct as above.
    end = NSGetSizeAndAlignment(type, &size, &alignment);
    testassert(size == sizeof(s));
    testassert(alignment == __alignof(s));
    testassert(*end == '\0');

    return YES;
}

- (BOOL)testUnion
{
    NSUInteger size;
    NSUInteger alignment;
    const char *type, *end;

    size = -1;
    alignment = -1;
    type = @encode(union {});
    end = NSGetSizeAndAlignment(type, &size, &alignment);
    testassert(size == 0);
    testassert(alignment == 0);
    testassert(*end == '\0');

    // It is legal for the '=' to be missing.
    size = -1;
    alignment = -1;
    type = "()";
    end = NSGetSizeAndAlignment(type, &size, &alignment);
    testassert(size == 0);
    testassert(alignment == 0);
    testassert(*end == '\0');

    typedef union {
        int i;
        double d;
    } u;

    size = -1;
    alignment = -1;
    type = @encode(u);
    end = NSGetSizeAndAlignment(type, &size, &alignment);
    testassert(size == sizeof(u));
    testassert(alignment == __alignof(u));
    testassert(*end == '\0');

    // It is legal to include field names.
    size = -1;
    alignment = -1;
    type = "(foo=\"i\"i\"d\"d)"; // The same union as above.
    end = NSGetSizeAndAlignment(type, &size, &alignment);
    testassert(size == sizeof(u));
    testassert(alignment == __alignof(u));
    testassert(*end == '\0');

    return YES;
}

- (BOOL)testBitfield
{
    // NSGetSizeAndAlignment should throw NSInvalidArgumentException on bitfields

    void (^block)() = ^{
        const char *type = @encode(struct { int b:23; });
        NSUInteger size;
        NSUInteger alignment;
        NSGetSizeAndAlignment(type, &size, &alignment);
    };

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

- (BOOL)testComplex
{
    // NSGetSizeAndAlignment should throw NSInvalidArgumentException on _Complex types

    void (^block)(const char *) = ^(const char *type){
        NSUInteger size;
        NSUInteger alignment;
        NSGetSizeAndAlignment(type, &size, &alignment);
    };

    BOOL raised = NO;

    @try {
        block(@encode(float _Complex));
    }
    @catch (NSException *e) {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        raised = YES;
    }

    testassert(raised);

    raised = NO;

    @try {
        block(@encode(double _Complex));
    }
    @catch (NSException *e) {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        raised = YES;
    }

    testassert(raised);

    return YES;
}

- (BOOL)testTypeQualifiersAndComments
{
    // NSGetSizeAndAlignment should walk over type qualifiers,
    // represented by any of the characters in "nNoOrRV". It should
    // also skip over any string contained within double quotes.

    // This represents four (qualified) ints.
    const char *types = "niNio\"XXX\"Oir\"XXX\"RVi";
    int count = 0;

    while (*types != '\0') {
        NSUInteger size = -1;
        NSUInteger alignment = -1;
        types = NSGetSizeAndAlignment(types, &size, &alignment);

        testassert(size == sizeof(int));
        testassert(alignment == __alignof(int));
        count++;
    }

    testassert(count == 4);
    testassert(*types == '\0');

    return YES;
}

- (BOOL)testEmpty
{
    const char *type = "";
    NSUInteger size = -1;
    NSUInteger alignment = -1;

    const char *end = NSGetSizeAndAlignment(type, &size, &alignment);

    testassert(size == 0);
    testassert(alignment == 0);
    testassert(*end == '\0');

    return YES;
}

#if CF_BUILDING_CF
extern const char *__NSGetSizeAndAlignment(const char *, NSUInteger *, NSUInteger *, BOOL);

- (BOOL)testSizeHints
{
    // Type encodings such as "c1{=@}8" are emitted by
    // method_getTypeEncoding, in which the '1' and '8' are supposed
    // to be the sizes of the types, presumably to aid in
    // debugging. NSGetSizeAndAlignment's actualy implementation
    // (__NSGetSizeAndAlignment) can be told to walk over any
    // nonnegative decimal following a type. It will not check that
    // the number matches the size of the type.

    const char *type = "i42{=i23c4}0";

    // NSGetSizeAndAlignment sets the size and alignment pointers to
    // zero before calling __NSGetSizeAndAlignment, so this test,
    // unlike the others, must set them to 0 rather than -1 or any
    // other value.
    NSUInteger size = 0;
    NSUInteger alignment = 0;

    typedef struct {
        int i;
        char c;
    } s;

    type = __NSGetSizeAndAlignment(type, &size, &alignment, YES);
    testassert(size == sizeof(int));
    testassert(alignment == __alignof(int));

    size = 0;
    alignment = 0;
    type = __NSGetSizeAndAlignment(type, &size, &alignment, YES);
    testassert(size == sizeof(s));
    testassert(alignment == __alignof(int));
    testassert(*type == '\0');

    return YES;
}
#endif

- (BOOL)testNSStringFromSelectorEmpty
{
    SEL sel = NULL;
    NSString *str = NSStringFromSelector(sel);
    testassert(str == nil);

    return YES;
}

- (BOOL)testNSStringFromSelectorCreated
{
    SEL sel = sel_registerName("thisIsATestSelector:");
    NSString *str = NSStringFromSelector(sel);
    testassert(str != nil);

    return YES;
}

- (BOOL)testNSStringFromSelectorCompiled
{
    SEL sel = @selector(testNSStringFromSelectorCompiled);
    NSString *str = NSStringFromSelector(sel);
    testassert(str != nil);

    return YES;
}

- (BOOL)testNSSelectorFromStringEmpty
{
    NSString *str = nil;
    SEL sel = NSSelectorFromString(str);

    testassert(sel == NULL);

    return YES;
}

- (BOOL)testNSSelectorFromStringExisting
{
    NSString *str = @"testNSSelectorFromStringExisting";
    SEL sel = NSSelectorFromString(str);
    testassert(sel != NULL);

    return YES;
}

- (BOOL)testNSSelectorFromStringNotExisting
{
    NSString *str = @"thisSelectorDoesNotExistBecauseItHasNotBeenCompiledOrRegistered::::::";
    SEL sel = NSSelectorFromString(str);
    testassert(sel != NULL);

    return YES;
}

- (BOOL)testNSStringFromClassEmpty
{
    Class cls = nil;
    NSString *str = NSStringFromClass(cls);
    testassert(str == nil);

    return YES;
}

- (BOOL)testNSStringFromClassNotNil
{
    Class cls = [self class];
    NSString *str = NSStringFromClass(cls);
    testassert(str != nil);

    return YES;
}

- (BOOL)testNSStringFromProtocolLookup
{
    Protocol *p = objc_getProtocol("NSObject");
    NSString *str = NSStringFromProtocol(p);
    testassert(str != nil);

    return YES;
}

- (BOOL)testNSStringFromProtocolCompiled
{
    Protocol *p = @protocol(NSObject);
    NSString *str = NSStringFromProtocol(p);
    testassert(str != nil);

    return YES;
}

- (BOOL)testNSProtocolFromStringNil
{
    NSString *str = nil;
    Protocol *p = NSProtocolFromString(str);
    testassert(p == NULL);

    return YES;
}

- (BOOL)testNSProtocolFromStringNotNil
{
    NSString *str = @"NSObject";
    Protocol *p = NSProtocolFromString(str);
    testassert(p != NULL);

    return YES;
}

- (BOOL)testNSExtraRefCount
{
    NSObject *o = [[NSObject alloc] init];
    testassert([o retainCount] == NSExtraRefCount(o) + 1);
    [o retain];
    testassert([o retainCount] == NSExtraRefCount(o) + 1);
    [o release];
    testassert([o retainCount] == NSExtraRefCount(o) + 1);
    [o release];

    return YES;
}

- (BOOL)testIvarEncodings
{
    const char *range = ivar_getTypeEncoding(class_getInstanceVariable([TestEncodingSource class], "range"));
    const char *point = ivar_getTypeEncoding(class_getInstanceVariable([TestEncodingSource class], "point"));
    const char *size = ivar_getTypeEncoding(class_getInstanceVariable([TestEncodingSource class], "size"));
    const char *transform = ivar_getTypeEncoding(class_getInstanceVariable([TestEncodingSource class], "transform"));
    const char *rect = ivar_getTypeEncoding(class_getInstanceVariable([TestEncodingSource class], "rect"));
    NSUInteger sz;
    NSUInteger align;
    NSGetSizeAndAlignment(range, &sz, &align);
    testassert(sz == sizeof(NSRange));
    testassert(align == 4);
    NSGetSizeAndAlignment(point, &sz, &align);
    testassert(sz == sizeof(CGPoint));
    testassert(align == 4);
    NSGetSizeAndAlignment(size, &sz, &align);
    testassert(sz == sizeof(CGSize));
    testassert(align == 4);
    NSGetSizeAndAlignment(transform, &sz, &align);
    testassert(sz == sizeof(CGAffineTransform));
    testassert(align == 4);
    NSGetSizeAndAlignment(rect, &sz, &align);
    testassert(sz == sizeof(CGRect));
    testassert(align == 4);
    return YES;
}

@end
