//
//  NSCoderTests.m
//  FoundationTests
//
//  Created by George Kulakowski on 10/26/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@interface SimpleClass : NSObject <NSCoding>
@property int a;
@property BOOL didEncode;
@property BOOL didDecode;
@end
@implementation SimpleClass
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _a = [aDecoder decodeIntForKey:@"ABC"];
        _didDecode = YES;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    _a = 123;
    [aCoder encodeInt:_a forKey:@"ABC"];
    _didEncode = YES;
}

@end

@interface SimpleClassWithString : SimpleClass
@property (assign) NSString *myString;
@end

@implementation SimpleClassWithString
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _myString = [aDecoder decodeObjectForKey:@"string"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_myString forKey:@"string"];
}
@end

@interface SimpleClassWithCString : SimpleClass
@property char *myString;
@end

@implementation SimpleClassWithCString

- (id) initWithCString:(char *)str
{
    self = [super init];
    if (self)
    {
        if (str)
        {
            _myString = malloc(strlen(str) + 1);
            strcpy(_myString, str);
        }
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        NSUInteger len;
        _myString = (char *)[aDecoder decodeBytesForKey:@"string" returnedLength:&len];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    if (_myString)
    {
        [aCoder encodeBytes:(const uint8_t *)_myString length:strlen(_myString) + 1 forKey:@"string"];
    }
    else
    {
        [aCoder encodeBytes:nil length:0 forKey:@"string"];
    }
}
@end

@interface FoundationTestKeyedCoderTest : NSObject <NSCoding>
@property (strong, nonatomic) NSString* objectString;
@property (strong, nonatomic) NSArray* objectArray;
@property (strong, nonatomic) NSValue* objectValue;
@property (strong, nonatomic) NSDictionary* objectDictionary;
@property (assign, nonatomic) void*     memory;
@property (assign, nonatomic) char*     cString;
@property (assign, nonatomic) CGRect rect;
@property (assign, nonatomic) BOOL boolean;
@property (assign, nonatomic) short shortNumber;
@property (assign, nonatomic) NSUInteger memorySize;
@property (assign, nonatomic) NSInteger integerSigned;
@property (assign, nonatomic) float floatNumber;
@property (assign, nonatomic) double doubleNumber;
@end

@implementation FoundationTestKeyedCoderTest

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (nil != self) {
        self.objectString = [aDecoder decodeObjectForKey:@"objectString"];
        self.objectValue = [aDecoder decodeObjectForKey:@"objectValue"];
        self.objectArray = [aDecoder decodeObjectForKey:@"objectArray"];

        self.objectDictionary = [aDecoder decodeObjectForKey:@"objectDictionary"];
        self.memorySize = [aDecoder decodeIntegerForKey:@"memorySize"];
        self.integerSigned = [aDecoder decodeIntegerForKey:@"integerSigned"];
        self.shortNumber = [aDecoder decodeIntegerForKey:@"shortNumber"];

        self.rect = [aDecoder decodeCGRectForKey:@"rect"];
        self.boolean = [aDecoder decodeBoolForKey:@"boolean"];
        self.memory = (void*)[aDecoder decodeBytesForKey:@"memory" returnedLength:&_memorySize];
        NSUInteger cStringSize = 0;
        self.cString = (char*)[aDecoder decodeBytesForKey:@"cString" returnedLength:&cStringSize];

        self.floatNumber = [aDecoder decodeFloatForKey:@"floatNumber"];
        self.doubleNumber = [aDecoder decodeDoubleForKey:@"doubleNumber"];
    }
    return self;
}

- (BOOL)isEqual:(FoundationTestKeyedCoderTest*)object
{
    if (self.objectString && ![self.objectString isEqual:object.objectString])
    {
        return NO;
    }
    if (self.objectValue && ![self.objectValue isEqual:object.objectValue])
    {
        return NO;
    }
    if (self.objectArray && ![self.objectArray isEqual:object.objectArray])
    {
        return NO;
    }
    if (self.memory && memcmp(self.memory, object.memory, self.memorySize) != 0)
    {
        return NO;
    }
    if (self.cString && strcmp(self.cString, object.cString) != 0)
    {
        return NO;
    }
    if (!(self.rect.origin.x == object.rect.origin.x && self.rect.origin.y == object.rect.origin.y &&
          self.rect.size.width == object.rect.size.width && self.rect.size.height == object.rect.size.height))
    {
        return NO;
    }
    if (self.boolean != object.boolean)
    {
        return NO;
    }
    if (self.shortNumber != object.shortNumber)
    {
        return NO;
    }
    if (self.memorySize != object.memorySize)
    {
        return NO;
    }
    if (self.integerSigned != object.integerSigned)
    {
        return NO;
    }
    if (self.floatNumber != object.floatNumber)
    {
        return NO;
    }
    if (self.doubleNumber != object.doubleNumber)
    {
        return NO;
    }

    return YES;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.objectString forKey:@"objectString"];
    [aCoder encodeObject:self.objectValue forKey:@"objectValue"];
    [aCoder encodeObject:self.objectArray forKey:@"objectArray"];
    [aCoder encodeObject:self.objectDictionary forKey:@"objectDictionary"];

    [aCoder encodeInteger:self.memorySize forKey:@"memorySize"];
    [aCoder encodeInteger:self.integerSigned forKey:@"integerSigned"];

    [aCoder encodeBytes:self.memory length:self.memorySize forKey:@"memory"];
    if (self.cString) [aCoder encodeBytes:(void*)self.cString length:strlen(self.cString) + 1 forKey:@"cString"];

    [aCoder encodeCGRect:self.rect forKey:@"rect"];
    [aCoder encodeBool:self.boolean forKey:@"boolean"];

    [aCoder encodeInteger:self.shortNumber forKey:@"shortNumber"];
    [aCoder encodeFloat:self.floatNumber forKey:@"floatNumber"];
    [aCoder encodeDouble:self.doubleNumber forKey:@"doubleNumber"];
}

- (void)dealloc
{
    self.objectString = nil;
    self.objectArray = nil;
    self.objectDictionary = nil;
    self.objectValue = nil;

    [super dealloc];
}

@end


@testcase(NSCoder)

#pragma mark - Class for coder

- (BOOL)testCoderVersion
{
    NSCoder *coder = [[NSCoder alloc] init];
    testassert([coder systemVersion] == 1000);
    [coder release];
    return YES;
}

- (BOOL)testKeyedArchiverVersion
{
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:[NSMutableData data]];
    testassert([archiver systemVersion] == 2000);
    [archiver release];
    return YES;
}

- (BOOL)testInternalClassForCoder
{
    // These are the classes that will actually create some internal
    // subclass, and thus different class and classForCoder.
    NSArray *classes = @[
        [NSArray self],
        [NSAttributedString self],
        [NSCharacterSet self],
        [NSData self],
        [NSDate self],
        [NSDictionary self],
        [NSMutableArray self],
        [NSMutableData self],
        [NSMutableDictionary self],
        [NSMutableOrderedSet self],
        [NSMutableSet self],
        [NSMutableString self],
        [NSOrderedSet self],
        [NSSet self],
        [NSString self],
        [NSUUID self],
    ];

    for (Class class in classes)
    {
        id obj = [[[class alloc] init] autorelease];
        Class actualClass = [obj class];
        Class classForCoder = [obj classForCoder];

        testassert(classForCoder == class);
        testassert(classForCoder != actualClass);
    }

    return YES;
}

- (BOOL)testActualClassForCoder
{
    // These are the classes that have the same class and classForCoder.
    NSArray *classes = @[
        [NSCountedSet self],
        [NSError self],
        [NSIndexSet self],
        [NSMutableIndexSet self],
        [NSObject self],
    ];

    for (Class class in classes)
    {
        id obj = [[[class alloc] init] autorelease];
        Class actualClass = [obj class];
        Class classForCoder = [obj classForCoder];

        testassert(classForCoder == class);
        testassert(classForCoder == actualClass);
    }

    return YES;
}

- (BOOL)testOtherClassForCoder
{
    // These classes cannot be directly inited, and so are tested separately.

    {
        NSDecimalNumber *decimalNumber = [NSDecimalNumber one];

        Class class = [NSDecimalNumber self];
        Class actualClass = [decimalNumber class];
        Class classForCoder = [decimalNumber classForCoder];

        testassert(classForCoder != class);
        testassert(classForCoder != actualClass);
    }

    {
        NSLocale *locale = [NSLocale systemLocale];

        Class class = [NSLocale self];
        Class actualClass = [locale class];
        Class classForCoder = [locale classForCoder];

        testassert(classForCoder == class);
        testassert(classForCoder != actualClass);
    }

    {
        NSNotification *notification = [NSNotification notificationWithName:@"foo" object:@"bar"];

        Class class = [NSNotification self];
        Class actualClass = [notification class];
        Class classForCoder = [notification classForCoder];

        testassert(classForCoder == class);
        testassert(classForCoder != actualClass);
    }

    {
        NSNumber *number = [NSNumber numberWithInt:42];

        Class class = [NSNumber self];
        Class actualClass = [number class];
        Class classForCoder = [number classForCoder];

        testassert(classForCoder == class);
        testassert(classForCoder != actualClass);
    }

    {
        NSPort *port = [NSPort port];

        Class class = [NSPort self];
        Class actualClass = [port class];

        BOOL raised = NO;

        @try {
            [port classForCoder];
        }
        @catch (NSException *e) {
            raised = YES;
            testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        }

        testassert(raised);

        testassert(actualClass != class);
    }

    {
        NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];

        Class class = [NSTimeZone self];
        Class actualClass = [timeZone class];
        Class classForCoder = [timeZone classForCoder];

        testassert(classForCoder == class);
        testassert(classForCoder != actualClass);
    }

    {
        NSValue *value = [NSValue valueWithRange:NSMakeRange(23, 42)];

        Class class = [NSValue self];
        Class actualClass = [value class];
        Class classForCoder = [value classForCoder];

        testassert(classForCoder == class);
        testassert(classForCoder != actualClass);
    }

    return YES;
}


#pragma mark - Supported classes

- (NSArray *)NSCodingSupportedClassesWithoutCGPoint
{
    return @[
             [^(){ return [NSDictionary new]; } copy],
             [^(){ return [NSArray new]; } copy],
             [^(){ return [NSNull new]; } copy],
             [^(){ return [[NSNumber numberWithInt:1337] retain]; } copy],
             [^(){ return [NSString new]; } copy],
             [^(){ return [[NSDate date] retain]; } copy],
             ];
}

- (NSArray *)NSCodingSupportedClasses
{
    return @[
        [^(){ return [NSDictionary new]; } copy],
        [^(){ return [NSArray new]; } copy],
        [^(){ return [[NSValue valueWithCGPoint:CGPointMake(13, 37)] retain]; } copy],
        [^(){ return [NSNull new]; } copy],
        [^(){ return [[NSNumber numberWithInt:1337] retain]; } copy],
        [^(){ return [NSString new]; } copy],
        [^(){ return [[NSDate date] retain]; } copy],
    ];
}

#pragma mark - Basic stuff

// Uncomment this to test decoding a mom file that's added to the main bundle.

//- (BOOL) testMomDecode
//{
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"DotsDataModel" ofType:@"bin"];
//    NSURL                *url = [NSURL fileURLWithPath:path];
//    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
//    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
//    testassert([unarchiver decodeObjectForKey:@"root"] != nil);
//
//    return YES;
//}

- (BOOL) testInitForWritingWithNil
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:nil forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 136);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    id nil2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert(nil2 == nil);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithNilXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:nil forKey:@"myKey"];
    [archive finishEncoding];
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    id nil2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert(nil2 == nil);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithNilXMLLength
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:nil forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 474);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    id nil2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert(nil2 == nil);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL)testEmptyArchive
{
    NSData* objectEncoded = [NSKeyedArchiver archivedDataWithRootObject:nil];
    testassert([objectEncoded length] == 135);
    const char *bytes = [objectEncoded bytes];
    // should be "bplist00\xd4\x01\x02\x03\x04\x05\b\n\vT$topX$objectsX$versionY$archiver\xd1\x06\aTroot\x80"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\n\vT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aTroot", 6) == 0);
    return YES;
}

- (BOOL)testBasicObjectsNScodingIsImplemented
{
    for (id (^c)(void) in [self NSCodingSupportedClasses])
    {
        id object = c();
        testassert([object respondsToSelector:@selector(initWithCoder:)]);
        testassert([object respondsToSelector:@selector(encodeWithCoder:)]);
        [object release];
    }
    return YES;
}

- (BOOL)testEmptyArchiveDecoded
{
    NSData *objectEncoded = [NSKeyedArchiver archivedDataWithRootObject:nil];
    NSKeyedUnarchiver *unarchive = [NSKeyedUnarchiver unarchiveObjectWithData:objectEncoded];
    testassert([unarchive decodeObjectForKey:@"alsfdj"] == nil);

    return YES;
}

- (BOOL) testInitForWritingWithMutableDataEmpty
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive finishEncoding];
    testassert([data length] == 124);
    const char *bytes = [data bytes];
//    0x08c45210: "bplist00\xffffffd4\x01\x02\x03\x04\x05\x06\b\tT$topX$objectsX$versionY$archiver\xffffffd0\xffffffa1\aU$null\x12"
//    0x08c4524d: "\x01\xffffff86\xffffffa0_\x10\x0fNSKeyedArchiver\b\x11\x16\x1f(235;@"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[15], "\b\tT$topX$objectsX$versionY$archiver", 35) == 0);
    testassert(strncmp(&bytes[67], "NSKeyedArchiver", 15) == 0);
    
    return YES;
}


- (BOOL) testInitForWritingWithMutableDataInt
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeInt:123 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 136);
    const char *bytes = [data bytes];
    // "bplist00\xd4\x01\x02\x03\x04\x05\b\n\vT$topX$objectsX$versionY$archiver\xd1\x06\aUmyKey\x10{\xa1\tU$null\x12"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\n\vT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aUmyKey", 7) == 0);
    testassert(bytes[60] == 123);
    
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeIntForKey:@"myKey"] == 123);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataIntXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeInt:123 forKey:@"myKey"];
    [archive finishEncoding];
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeIntForKey:@"myKey"] == 123);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataIntBigger
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeInt:30000 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 137);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeIntForKey:@"myKey"] == 30000);
    [unarchive finishDecoding];

    return YES;
}

- (BOOL) testInitForWritingWithMutableDataIntBiggerXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeInt:30000 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 437);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeIntForKey:@"myKey"] == 30000);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataIntMax
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeInt:INT_MAX forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 139);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeIntForKey:@"myKey"] == INT_MAX);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataIntMaxXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeInt:INT_MAX forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 442);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeIntForKey:@"myKey"] == INT_MAX);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataIntNegative
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeInt:-5 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 143);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeIntForKey:@"myKey"] == -5);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataIntNegativeXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeInt:-5 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 434);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeIntForKey:@"myKey"] == -5);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataIntMin
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeInt:INT_MIN forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 143);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeIntForKey:@"myKey"] == INT_MIN);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataIntMinXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeInt:INT_MIN forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 443);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeIntForKey:@"myKey"] == INT_MIN);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataBool
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeBool:YES forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 135);
    const char *bytes = [data bytes];
    // "bplist00\xd4\x01\x02\x03\x04\x05\b\n\vT$topX$objectsX$versionY$archiver\xd1\x06\aUmyKey\t\xa1\tU$null\x12"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\n\vT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aUmyKey", 7) == 0);
    testassert(bytes[59] == 9);
    testassert(strncmp(&bytes[76], "NSKeyedArchiver", 15) == 0);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeBoolForKey:@"myKey"]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataBoolXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeBool:YES forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 420);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeBoolForKey:@"myKey"]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataBytes
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeBytes:(const uint8_t *)"abcdefghijklmop" length:10 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 145);
    const char *bytes = [data bytes];
//  "bplist00\xffffffd4\x01\x02\x03\x04\x05\b\n\vT$topX$objectsX$versionY$archiver\xffffffd1\x06\aUmyKeyJabcdefghij\xffffffa1\tU$null\x12"
//  "\x01\xffffff86\xffffffa0_\x10\x0fNSKeyedArchiver\b
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\n\vT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aUmyKeyJabcdefghij", 18) == 0);
    testassert(strncmp(&bytes[86], "NSKeyedArchiver", 15) == 0);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSUInteger returnedLength;
    const uint8_t *decodeBytes = [unarchive decodeBytesForKey:@"myKey" returnedLength:&returnedLength];
    testassert(returnedLength == 10);
    testassert(strncmp((const char *)decodeBytes,  "abcdefghijklmop", returnedLength) == 0);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataBytesXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeBytes:(const uint8_t *)"abcdefghijklmop" length:10 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 448);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSUInteger returnedLength;
    const uint8_t *decodeBytes = [unarchive decodeBytesForKey:@"myKey" returnedLength:&returnedLength];
    testassert(returnedLength == 10);
    testassert(strncmp((const char *)decodeBytes,  "abcdefghijklmop", returnedLength) == 0);
    [unarchive finishDecoding];
    
    return YES;
}


- (BOOL) testInitForWritingWithMutableDataBytes15
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeBytes:(const uint8_t *)"abcdefghijklmop" length:15 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 152);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSUInteger returnedLength;
    const uint8_t *decodeBytes = [unarchive decodeBytesForKey:@"myKey" returnedLength:&returnedLength];
    testassert(returnedLength == 15);
    testassert(strncmp((const char *)decodeBytes,  "abcdefghijklmop", returnedLength) == 0);
    [unarchive finishDecoding];

    return YES;
}


- (BOOL) testInitForWritingWithMutableDataBytes15XML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeBytes:(const uint8_t *)"abcdefghijklmop" length:15 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 452);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSUInteger returnedLength;
    const uint8_t *decodeBytes = [unarchive decodeBytesForKey:@"myKey" returnedLength:&returnedLength];
    testassert(returnedLength == 15);
    testassert(strncmp((const char *)decodeBytes,  "abcdefghijklmop", returnedLength) == 0);
    [unarchive finishDecoding];
    
    return YES;
}


- (BOOL) testInitForWritingWithMutableDataBytesLong
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeBytes:(const uint8_t *)"abcdefghijklmopqrstuvwzyz" length:25 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 162);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSUInteger returnedLength;
    const uint8_t *decodeBytes = [unarchive decodeBytesForKey:@"myKey" returnedLength:&returnedLength];
    testassert(returnedLength == 25);
    testassert(strncmp((const char *)decodeBytes, "abcdefghijklmopqrstuvwzyz", returnedLength) == 0);
    [unarchive finishDecoding];
    
    return YES;
}


- (BOOL) testInitForWritingWithMutableDataBytesLongXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeBytes:(const uint8_t *)"abcdefghijklmopqrstuvwzyz" length:25 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 468);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSUInteger returnedLength;
    const uint8_t *decodeBytes = [unarchive decodeBytesForKey:@"myKey" returnedLength:&returnedLength];
    testassert(returnedLength == 25);
    testassert(strncmp((const char *)decodeBytes, "abcdefghijklmopqrstuvwzyz", returnedLength) == 0);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataDouble
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeDouble:-91.73 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 143);
    const char *bytes = [data bytes];
    // "bplist00\xd4\x01\x02\x03\x04\x05\b\n\vT$topX$objectsX$versionY$archiver\xd1\x06\aUmyKey#\xc0V\xee\xb8Q\xeb\x85\x1f\xa1\tU$null\x12"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\n\vT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aUmyKey", 7) == 0);
    testassert(bytes[59] == 35);
    testassert(bytes[61] == 86);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeDoubleForKey:@"myKey"] == -91.73);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataDoubleXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeDouble:-91.73 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 445);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeDoubleForKey:@"myKey"] == -91.73);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataFloat
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeFloat:3.14159f forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 139);
    const char *bytes = [data bytes];
    // "bplist00\xd4\x01\x02\x03\x04\x05\b\n\vT$topX$objectsX$versionY$archiver\xd1\x06\aUmyKey"@I\x0f\xd0\xa1\tU$null\x12"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\n\vT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aUmyKey", 7) == 0);
    testassert(bytes[60] == 64);
    testassert(bytes[62] == 15);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeFloatForKey:@"myKey"] == 3.14159f);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataFloatXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeFloat:3.14159f forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 444);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeFloatForKey:@"myKey"] == 3.14159f);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataInt32
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeInt32:-65000 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 143);
    const char *bytes = [data bytes];
    // "bplist00\xd4\x01\x02\x03\x04\x05\b\n\vT$topX$objectsX$versionY$archiver\xd1\x06\aUmyKey\x10{\xa1\tU$null\x12"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\n\vT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aUmyKey", 7) == 0);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeInt32ForKey:@"myKey"] == -65000);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataInt32XML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeInt32:-65000 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 438);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeInt32ForKey:@"myKey"] == -65000);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataInt64
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeInt64:LONG_LONG_MAX forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 143);
    const char *bytes = [data bytes];
    // "bplist00\xd4\x01\x02\x03\x04\x05\b\n\vT$topX$objectsX$versionY$archiver\xd1\x06\aUmyKey\x13\x7f\xff\xff\xff\xff\xff\xff\xff\xa1\tU$null\x12"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\n\vT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aUmyKey", 7) == 0);
    testassert(bytes[60] == 127);
    for (int i = 61; i <= 67; i++)
    {
        testassert((unsigned char)bytes[i] == 0xff);
    }

    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeInt64ForKey:@"myKey"] == LONG_LONG_MAX);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataInt64XML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeInt64:LONG_LONG_MAX forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 451);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeInt64ForKey:@"myKey"] == LONG_LONG_MAX);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableMultiple
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeDouble:3.14 forKey:@"doubleKey"];
    [archive encodeFloat:-30.5 forKey:@"floatKey"];
    [archive encodeInteger:987 forKey:@"integerKey"];
    [archive finishEncoding];
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeDoubleForKey:@"myKey"] == 0.0);
    testassert([unarchive decodeDoubleForKey:@"doubleKey"] == 3.14);
    testassert([unarchive decodeFloatForKey:@"floatKey"] == -30.5);
    testassert([unarchive decodeIntegerForKey:@"integerKey"] == 987);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableMultipleXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeDouble:3.14 forKey:@"doubleKey"];
    [archive encodeFloat:-30.5 forKey:@"floatKey"];
    [archive encodeInteger:987 forKey:@"integerKey"];
    [archive finishEncoding];
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeDoubleForKey:@"myKey"] == 0.0);
    testassert([unarchive decodeDoubleForKey:@"doubleKey"] == 3.14);
    testassert([unarchive decodeFloatForKey:@"floatKey"] == -30.5);
    testassert([unarchive decodeIntegerForKey:@"integerKey"] == 987);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableOverwrite
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeDouble:3.14 forKey:@"doubleKey"];
    [archive encodeDouble:9.5 forKey:@"doubleKey"];  // Should generate warning in log like
    // 2013-11-06 11:44:51.622 FoundationTests[98844:a0b] *** NSKeyedArchiver warning: replacing existing value for key 'doubleKey'; probable duplication of encoding keys in class hierarchy
    [archive finishEncoding];
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeDoubleForKey:@"doubleKey"] == 9.5);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableOverwriteXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeDouble:3.14 forKey:@"doubleKey"];
    [archive encodeDouble:9.5 forKey:@"doubleKey"];  // Should generate warning in log like
    // 2013-11-06 11:44:51.622 FoundationTests[98844:a0b] *** NSKeyedArchiver warning: replacing existing value for key 'doubleKey'; probable duplication of encoding keys in class hierarchy
    [archive finishEncoding];
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeDoubleForKey:@"doubleKey"] == 9.5);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataBytesTwiceLong
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeBytes:(const uint8_t *)"abcdefghijklmopqrstuvwzyz" length:25 forKey:@"myKey"];
    [archive encodeBytes:(const uint8_t *)"abcdefghijklmopqrstuvwzyz" length:25 forKey:@"myKey2"];
    [archive finishEncoding];
    testassert([data length] == 201);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSUInteger returnedLength;
    const uint8_t *decodeBytes = [unarchive decodeBytesForKey:@"myKey" returnedLength:&returnedLength];
    testassert(returnedLength == 25);
    testassert(strncmp((const char *)decodeBytes, "abcdefghijklmopqrstuvwzyz", returnedLength) == 0);
    
    const uint8_t *decodeBytes2 = [unarchive decodeBytesForKey:@"myKey" returnedLength:&returnedLength];
    testassert(returnedLength == 25);
    testassert(strncmp((const char *)decodeBytes2, "abcdefghijklmopqrstuvwzyz", returnedLength) == 0);

    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataBytesTwiceLongXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeBytes:(const uint8_t *)"abcdefghijklmopqrstuvwzyz" length:25 forKey:@"myKey"];
    [archive encodeBytes:(const uint8_t *)"abcdefghijklmopqrstuvwzyz" length:25 forKey:@"myKey2"];
    [archive finishEncoding];
    testassert([data length] == 546);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSUInteger returnedLength;
    const uint8_t *decodeBytes = [unarchive decodeBytesForKey:@"myKey" returnedLength:&returnedLength];
    testassert(returnedLength == 25);
    testassert(strncmp((const char *)decodeBytes, "abcdefghijklmopqrstuvwzyz", returnedLength) == 0);
    
    const uint8_t *decodeBytes2 = [unarchive decodeBytesForKey:@"myKey" returnedLength:&returnedLength];
    testassert(returnedLength == 25);
    testassert(strncmp((const char *)decodeBytes2, "abcdefghijklmopqrstuvwzyz", returnedLength) == 0);
    
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithString
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSString *s = @"myString";
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 147);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSString *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqualToString:s]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithStringXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSString *s = @"myString";
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 502);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSString *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqualToString:s]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSpecialStringDollarNull
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSString *s = @"$null";
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 235);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSString *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqualToString:s]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSpecialStringDollarNullXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSString *s = @"$null";
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    //testassert([data length] == 235);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSString *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqualToString:s]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testEncodeValueOfCFBooleanType
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    
    [archive encodeObject:(id)kCFBooleanTrue forKey:@"boolTrue"];
    [archive encodeObject:(id)kCFBooleanFalse forKey:@"boolFalse"];
    [archive finishEncoding];
    
    NSKeyedUnarchiver *unarchive = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
    id boolTrue = [unarchive decodeObjectForKey:@"boolTrue"];
    id boolFalse = [unarchive decodeObjectForKey:@"boolFalse"];
    testassert([boolTrue isKindOfClass:objc_getClass("__NSCFBoolean")]);
    testassert([boolFalse isKindOfClass:objc_getClass("__NSCFBoolean")]);
    
    testassert(CFBooleanGetValue((CFBooleanRef)boolTrue));
    testassert(!CFBooleanGetValue((CFBooleanRef)boolFalse));
    return YES;
    
}

- (BOOL) testEncodeValueOfCFBooleanTypeXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:(id)kCFBooleanTrue forKey:@"boolTrue"];
    [archive encodeObject:(id)kCFBooleanFalse forKey:@"boolFalse"];
    [archive finishEncoding];
    
    NSKeyedUnarchiver *unarchive = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
    id boolTrue = [unarchive decodeObjectForKey:@"boolTrue"];
    id boolFalse = [unarchive decodeObjectForKey:@"boolFalse"];
    testassert([boolTrue isKindOfClass:objc_getClass("__NSCFBoolean")]);
    testassert([boolFalse isKindOfClass:objc_getClass("__NSCFBoolean")]);
    
    testassert(CFBooleanGetValue((CFBooleanRef)boolTrue));
    testassert(!CFBooleanGetValue((CFBooleanRef)boolFalse));
    return YES;
    
}

- (BOOL) testEncodeValueOfObjType1
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    char *s = "i";
    [archive encodeValueOfObjCType:"*" at:&s];
    [archive finishEncoding];
    testassert([data length] == 137);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    char *s2;
    [unarchive decodeValueOfObjCType:"*" at:&s2];
    testassert(strcmp(s, s2) == 0);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testEncodeValueOfObjType1XML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    char *s = "i";
    [archive encodeValueOfObjCType:"*" at:&s];
    [archive finishEncoding];
    testassert([data length] == 492);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    char *s2;
    [unarchive decodeValueOfObjCType:"*" at:&s2];
    testassert(strcmp(s, s2) == 0);
    [unarchive finishDecoding];
    
    return YES;
}


- (BOOL) testEncodeValueOfObjType2
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    char *s = "i";
    int a = 0xdd;
    [archive encodeValueOfObjCType:s at:&a];
    [archive finishEncoding];
    testassert([data length] == 133);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    int a2;
    [unarchive decodeValueOfObjCType:s at:&a2];
    testassert(a2 == 0xdd);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testEncodeValueOfObjType2XML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    char *s = "i";
    int a = 0xdd;
    [archive encodeValueOfObjCType:s at:&a];
    [archive finishEncoding];
    testassert([data length] == 432);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    int a2;
    [unarchive decodeValueOfObjCType:s at:&a2];
    testassert(a2 == 0xdd);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testEncodeValueOfObjType3
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    char *s = "i";
    int a = 0xdd;
    [archive encodeValueOfObjCType:"*" at:&s];
    [archive encodeValueOfObjCType:s at:&a];
    [archive finishEncoding];
    testassert([data length] == 146);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    char *s2;
    [unarchive decodeValueOfObjCType:"*" at:&s2];
    int a2;
    [unarchive decodeValueOfObjCType:s at:&a2];
    testassert(strcmp(s, s2) == 0);
    testassert(a2 == 0xdd);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testEncodeValueOfObjType3XML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    char *s = "i";
    int a = 0xdd;
    [archive encodeValueOfObjCType:"*" at:&s];
    [archive encodeValueOfObjCType:s at:&a];
    [archive finishEncoding];
    testassert([data length] == 533);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    char *s2;
    [unarchive decodeValueOfObjCType:"*" at:&s2];
    int a2;
    [unarchive decodeValueOfObjCType:s at:&a2];
    testassert(strcmp(s, s2) == 0);
    testassert(a2 == 0xdd);
    [unarchive finishDecoding];
    
    return YES;
}


- (BOOL) testInitForWritingWithValue
{
    static uint8_t bytes[] = {
        0x62, 0x70, 0x6c, 0x69, 0x73, 0x74, 0x30, 0x30,
        0xd4, 0x01, 0x02, 0x03, 0x04, 0x05, 0x08, 0x19,
        0x1a, 0x54, 0x24, 0x74, 0x6f, 0x70, 0x58, 0x24,
        0x6f, 0x62, 0x6a, 0x65, 0x63, 0x74, 0x73, 0x58,
        0x24, 0x76, 0x65, 0x72, 0x73, 0x69, 0x6f, 0x6e,
        0x59, 0x24, 0x61, 0x72, 0x63, 0x68, 0x69, 0x76,
        0x65, 0x72, 0xd1, 0x06, 0x07, 0x55, 0x6d, 0x79,
        0x4b, 0x65, 0x79, 0x80, 0x01, 0xa4, 0x09, 0x0a,
        0x11, 0x12, 0x55, 0x24, 0x6e, 0x75, 0x6c, 0x6c,
        0xd3, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x52,
        0x24, 0x31, 0x52, 0x24, 0x30, 0x56, 0x24, 0x63,
        0x6c, 0x61, 0x73, 0x73, 0x10, 0xee, 0x80, 0x02,
        0x80, 0x03, 0x51, 0x69, 0xd2, 0x13, 0x14, 0x15,
        0x18, 0x58, 0x24, 0x63, 0x6c, 0x61, 0x73, 0x73,
        0x65, 0x73, 0x5a, 0x24, 0x63, 0x6c, 0x61, 0x73,
        0x73, 0x6e, 0x61, 0x6d, 0x65, 0xa2, 0x16, 0x17,
        0x57, 0x4e, 0x53, 0x56, 0x61, 0x6c, 0x75, 0x65,
        0x58, 0x4e, 0x53, 0x4f, 0x62, 0x6a, 0x65, 0x63,
        0x74, 0x57, 0x4e, 0x53, 0x56, 0x61, 0x6c, 0x75,
        0x65, 0x12, 0x00, 0x01, 0x86, 0xa0, 0x5f, 0x10,
        0x0f, 0x4e, 0x53, 0x4b, 0x65, 0x79, 0x65, 0x64,
        0x41, 0x72, 0x63, 0x68, 0x69, 0x76, 0x65, 0x72,
        0x08, 0x11, 0x16, 0x1f, 0x28, 0x32, 0x35, 0x3b,
        0x3d, 0x42, 0x48, 0x4f, 0x52, 0x55, 0x5c, 0x5e,
        0x60, 0x62, 0x64, 0x69, 0x72, 0x7d, 0x80, 0x88,
        0x91, 0x99, 0x9e, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x1b, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0xb0
    };

    static int foo = 0xee;
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSValue *v = [NSValue value:(const void *)&foo withObjCType:@encode(int)];
    [archive encodeObject:v forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 235);
    NSData *expectedData = [NSData dataWithBytes:bytes length:235];
    testassert([data isEqualToData:expectedData]);
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSValue *v2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([v2 isEqualToValue:v]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithValueXML
{
    static int foo = 0xee;
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSValue *v = [NSValue value:(const void *)&foo withObjCType:@encode(int)];
    [archive encodeObject:v forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 908);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSValue *v2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([v2 isEqualToValue:v]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSimpleClass
{
    NSMutableData *data = [NSMutableData data];
    SimpleClass *obj = [[SimpleClass alloc] init];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:obj forKey:@"myKey"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    testassert([data length] == 231);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClass *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSimpleClassXML
{
    NSMutableData *data = [NSMutableData data];
    SimpleClass *obj = [[SimpleClass alloc] init];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:obj forKey:@"myKey"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    testassert([data length] == 811);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClass *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}


- (BOOL) testSimpleClassContainsValueForKeyXML
{
    NSMutableData *data = [NSMutableData data];
    SimpleClass *obj = [[SimpleClass alloc] init];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:obj forKey:@"myKey"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive containsValueForKey:@"myKey"]);
    testassert(![unarchive containsValueForKey:@"yourKey"]);
    
    return YES;
}

- (BOOL) testSimpleClassContainsValueForKey
{
    NSMutableData *data = [NSMutableData data];
    SimpleClass *obj = [[SimpleClass alloc] init];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:obj forKey:@"myKey"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive containsValueForKey:@"myKey"]);
    testassert(![unarchive containsValueForKey:@"yourKey"]);
    
    return YES;
}

- (BOOL) testInitForWritingWithSimpleClassWithString
{
    NSMutableData *data = [NSMutableData data];
    SimpleClassWithString *obj = [[SimpleClassWithString alloc] init];
    obj.myString = @"apportable is leeter";
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:obj forKey:@"myKey"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    testassert([data length] == 307);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClassWithString *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert([obj2.myString isEqualToString:@"apportable is leeter"]);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSimpleClassWithStringXML
{
    NSMutableData *data = [NSMutableData data];
    SimpleClassWithString *obj = [[SimpleClassWithString alloc] init];
    obj.myString = @"apportable is leeter";
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:obj forKey:@"myKey"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    //testassert([data length] == 307);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClassWithString *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert([obj2.myString isEqualToString:@"apportable is leeter"]);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSimpleClassWithCString
{
    NSMutableData *data = [NSMutableData data];
    SimpleClassWithCString *obj = [[SimpleClassWithCString alloc] initWithCString:"abcdef"];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:obj forKey:@"myKey"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    testassert([data length] == 290);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClassWithCString *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert(strcmp(obj2.myString, "abcdef") == 0);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSimpleClassWithCStringXML
{
    NSMutableData *data = [NSMutableData data];
    SimpleClassWithCString *obj = [[SimpleClassWithCString alloc] initWithCString:"abcdef"];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:obj forKey:@"myKey"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    //testassert([data length] == 290);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClassWithCString *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert(strcmp(obj2.myString, "abcdef") == 0);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSimpleClassWithCStringAutorelease
{
    NSMutableData *data = [NSMutableData data];
    @autoreleasepool {
        SimpleClassWithCString *obj = [[SimpleClassWithCString alloc] initWithCString:"abcdef"];
        NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
        [archive encodeObject:obj forKey:@"myKey"];
        testassert([obj didEncode]);
        [archive finishEncoding];
    }
    testassert([data length] == 290);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClassWithCString *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert(strcmp(obj2.myString, "abcdef") == 0);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSimpleClassWithCStringAutoreleaseXML
{
    NSMutableData *data = [NSMutableData data];
    @autoreleasepool {
        SimpleClassWithCString *obj = [[SimpleClassWithCString alloc] initWithCString:"abcdef"];
        NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
        [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
        [archive encodeObject:obj forKey:@"myKey"];
        testassert([obj didEncode]);
        [archive finishEncoding];
    }
    testassert([data length] == 924);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClassWithCString *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert(strcmp(obj2.myString, "abcdef") == 0);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSimpleClassWithCStringAutoreleaseEmpty
{
    NSMutableData *data = [NSMutableData data];
    @autoreleasepool {
        SimpleClassWithCString *obj = [[SimpleClassWithCString alloc] initWithCString:""];
        NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
        [archive encodeObject:obj forKey:@"myKey"];
        testassert([obj didEncode]);
        [archive finishEncoding];
    }
    testassert([data length] == 284);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClassWithCString *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert(strcmp(obj2.myString, "") == 0);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSimpleClassWithCStringAutoreleaseEmptyXML
{
    NSMutableData *data = [NSMutableData data];
    @autoreleasepool {
        SimpleClassWithCString *obj = [[SimpleClassWithCString alloc] initWithCString:""];
        NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
        [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
        [archive encodeObject:obj forKey:@"myKey"];
        testassert([obj didEncode]);
        [archive finishEncoding];
    }
    testassert([data length] == 916);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClassWithCString *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert(strcmp(obj2.myString, "") == 0);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSimpleClassWithCStringAutoreleaseNULL
{
    NSMutableData *data = [NSMutableData data];
    @autoreleasepool {
        SimpleClassWithCString *obj = [[SimpleClassWithCString alloc] initWithCString:NULL];
        NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
        [archive encodeObject:obj forKey:@"myKey"];
        testassert([obj didEncode]);
        [archive finishEncoding];
    }
    testassert([data length] == 281);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClassWithCString *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert(obj2.myString == NULL);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSimpleClassWithCStringAutoreleaseNULLXML
{
    NSMutableData *data = [NSMutableData data];
    @autoreleasepool {
        SimpleClassWithCString *obj = [[SimpleClassWithCString alloc] initWithCString:NULL];
        NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
        [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
        [archive encodeObject:obj forKey:@"myKey"];
        testassert([obj didEncode]);
        [archive finishEncoding];
    }
    testassert([data length] == 913);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClassWithCString *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert(obj2.myString == NULL);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSimpleClassToFile
{
    SimpleClass *obj = [[SimpleClass alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *saveFile = [documentsDirectory stringByAppendingPathComponent:@"testKeyedArchiver.bin"];
    
    [NSKeyedArchiver archiveRootObject:obj toFile:saveFile];
    
    SimpleClass *obj2 = [NSKeyedUnarchiver unarchiveObjectWithFile:saveFile];
    
    testassert([obj2 a] == 123);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    
    return YES;
}

- (BOOL) testInitForWritingWithSameNSNumber
{
    NSMutableData *data = [NSMutableData data];
    NSNumber *num = [NSNumber numberWithInt:123];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:num forKey:@"myKey"];
    [archive encodeObject:num forKey:@"myKey2"];
    [archive finishEncoding];
    testassert([data length] == 153);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSNumber *num2 = [unarchive decodeObjectForKey:@"myKey"];
    NSNumber *num3 = [unarchive decodeObjectForKey:@"myKey2"];
    testassert([num2 intValue] == 123);
    testassert([num3 intValue] == 123);
    [unarchive finishDecoding];
    
    return YES;
}


- (BOOL) testInitForWritingWithSameNSNumberXML
{
    NSMutableData *data = [NSMutableData data];
    NSNumber *num = [NSNumber numberWithInt:123];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:num forKey:@"myKey"];
    [archive encodeObject:num forKey:@"myKey2"];
    [archive finishEncoding];
    testassert([data length] == 583);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSNumber *num2 = [unarchive decodeObjectForKey:@"myKey"];
    NSNumber *num3 = [unarchive decodeObjectForKey:@"myKey2"];
    testassert([num2 intValue] == 123);
    testassert([num3 intValue] == 123);
    [unarchive finishDecoding];
    
    return YES;
}


- (BOOL) testInitForWritingWithSimpleClassSame
{
    NSMutableData *data = [NSMutableData data];
    SimpleClass *obj = [[SimpleClass alloc] init];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:obj forKey:@"myKey"];
    [archive encodeObject:obj forKey:@"myKey2"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    testassert([data length] == 244);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClass *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    SimpleClass *obj3 = [unarchive decodeObjectForKey:@"myKey2"];
    testassert([obj2 a] == 123);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    testassert([obj3 a] == 123);
    testassert([obj3 didDecode] == YES);
    testassert([obj3 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}


- (BOOL) testInitForWritingWithSimpleClassSameXML
{
    NSMutableData *data = [NSMutableData data];
    SimpleClass *obj = [[SimpleClass alloc] init];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:obj forKey:@"myKey"];
    [archive encodeObject:obj forKey:@"myKey2"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    testassert([data length] == 895);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClass *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    SimpleClass *obj3 = [unarchive decodeObjectForKey:@"myKey2"];
    testassert([obj2 a] == 123);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    testassert([obj3 a] == 123);
    testassert([obj3 didDecode] == YES);
    testassert([obj3 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithDictionary
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSDictionary *dict = @{};
    [archive encodeObject:dict forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 252);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([dict isEqualToDictionary:dict2]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithDictionaryXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSDictionary *dict = @{};
    [archive encodeObject:dict forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 840);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([dict isEqualToDictionary:dict2]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSimpleDictionary3
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSDictionary *dict = @{@"myDictKey" : @"myValue", @"keyTwo" : @"valueTwo", @"keyThree" : @"valueThree"};
    [archive encodeObject:dict forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 380);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([dict isEqualToDictionary:dict2]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSimpleDictionary3XML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSDictionary *dict = @{@"myDictKey" : @"myValue", @"keyTwo" : @"valueTwo", @"keyThree" : @"valueThree"};
    [archive encodeObject:dict forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 1462);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([dict isEqualToDictionary:dict2]);
    [unarchive finishDecoding];
    
    return YES;
}


- (BOOL) testInitForWritingWithSimpleDictionary
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSDictionary *dict = @{@"myDictKey" : @"myValue"};
    [archive encodeObject:dict forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 282);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([dict isEqualToDictionary:dict2]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSimpleDictionaryXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSDictionary *dict = @{@"myDictKey" : @"myValue"};
    [archive encodeObject:dict forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 1062);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([dict isEqualToDictionary:dict2]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSimpleClassWithStringInDictionary
{
    NSMutableData *data = [NSMutableData data];
    SimpleClassWithString *obj = [[SimpleClassWithString alloc] init];
    obj.myString = @"apportable is leeter";
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:obj forKey:@"myDictKey"];
    [archive encodeObject:dict forKey:@"myKey"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    testassert([data length] == 455);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict2 =[unarchive decodeObjectForKey:@"myKey"];
    SimpleClassWithString *obj2 = [dict2 objectForKey:@"myDictKey"];
    testassert([obj2 a] == 123);
    testassert([obj2.myString isEqualToString:@"apportable is leeter"]);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSimpleClassWithStringInDictionaryXML
{
    NSMutableData *data = [NSMutableData data];
    SimpleClassWithString *obj = [[SimpleClassWithString alloc] init];
    obj.myString = @"apportable is leeter";
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:obj forKey:@"myDictKey"];
    [archive encodeObject:dict forKey:@"myKey"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    testassert([data length] == 1554);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict2 =[unarchive decodeObjectForKey:@"myKey"];
    SimpleClassWithString *obj2 = [dict2 objectForKey:@"myDictKey"];
    testassert([obj2 a] == 123);
    testassert([obj2.myString isEqualToString:@"apportable is leeter"]);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithValueCGSize
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSValue *v = [NSValue valueWithCGSize:CGSizeMake(1.1f, 2.2f)];
    [archive encodeObject:v forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 260);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSValue *v2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([v2 isEqualToValue:v]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithValueCGSizeXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSValue *v = [NSValue valueWithCGSize:CGSizeMake(1.1f, 2.2f)];
    [archive encodeObject:v forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 931);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSValue *v2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([v2 isEqualToValue:v]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithArray
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSArray *a = @[@"one", @"two", @"three"];
    [archive encodeObject:a forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 261);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSArray *a2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([a2 isEqualToArray:a]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithArrayXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSArray *a = @[@"one", @"two", @"three"];
    [archive encodeObject:a forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 1094);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSArray *a2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([a2 isEqualToArray:a]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithNSNull
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:[NSNull null] forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 211);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    id obj = [unarchive decodeObjectForKey:@"myKey"];
    testassert(obj == [NSNull null]);
    testassert(obj == [NSNull new]);
    [unarchive finishDecoding];
    
    return YES;
}


- (BOOL) testInitForWritingWithNSNullXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:[NSNull null] forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 757);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    id obj = [unarchive decodeObjectForKey:@"myKey"];
    testassert(obj == [NSNull null]);
    testassert(obj == [NSNull new]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL)testSimpleArchiveNumber
{
    NSData* objectEncoded = [NSKeyedArchiver archivedDataWithRootObject:@123];
    testassert([objectEncoded length] == 139);
    const char *bytes = [objectEncoded bytes];
    // should be "bplist00\xd4\x01\x02\x03\x04\x05\b\v\fT$topX$objectsX$versionY$archiver\xd1\x06\aTroot\x80\x01\xa2\t\nU$null\x10{\x12"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\v\fT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aTroot", 6) == 0);
    testassert(bytes[70] == 123);
    return YES;
}

- (BOOL)testSimpleArchiveString
{
    NSData* objectEncoded = [NSKeyedArchiver archivedDataWithRootObject:@"abcdefg"];
    testassert([objectEncoded length] == 145);
    const char *bytes = [objectEncoded bytes];
    // should be "bplist00\xd4\x01\x02\x03\x04\x05\b\v\fT$topX$objectsX$versionY$archiver\xd1\x06\aTroot\x80\x01\xa2\t\nU$nullWabcdefg\x12"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\v\fT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aTroot", 6) == 0);
    testassert(strncmp(&bytes[70], "abcdefg", 7) == 0);
    return YES;
}

- (BOOL)testSimpleArchiveNSDate
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:1387931403.0];
    NSData *objectEncoded = [NSKeyedArchiver archivedDataWithRootObject:date];
    testassert([objectEncoded length] == 231);
    const char *bytes = [objectEncoded bytes];
    testassert(strncmp(bytes, "bplist00\xd4\x01\x02\x03\x04\x05", 14) == 0);
    testassert(strncmp(&bytes[14], "\x08\x16\x17T$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[50], "\xd1\x06\x07Troot\x80\x01\xa3\x09\x0a\x0fU$null", 20) == 0);
    testassert(strncmp(&bytes[70], "\xd2\x0b\x0c\x0d\x0eV$classWNS.time", 20) == 0);
    return YES;
}

- (BOOL) testInitForWritingWithStringNonAscii
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSString *s = @"myStß©∆¬ååœ∑ring";
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 173);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSString *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqualToString:s]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithStringNonAsciiXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSString *s = @"myStß©∆¬ååœ∑ring";
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    //testassert([data length] == 173);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSString *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqualToString:s]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithNSNumber
{
    NSMutableData *data = [NSMutableData data];
    NSNumber *num = [NSNumber numberWithInt:123];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:num forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 140);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSNumber *num2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([num2 intValue] == 123);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithNSDate
{
    NSMutableData *data = [NSMutableData data];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:131180400.0];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:date forKey:@"myDate"];
    [archive finishEncoding];
    testassert([data length] == 233);

    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDate *date2 = [unarchive decodeObjectForKey:@"myDate"];
    testassert([date2 timeIntervalSince1970] == 131180400.0);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithNSNumberXML
{
    NSMutableData *data = [NSMutableData data];
    NSNumber *num = [NSNumber numberWithInt:123];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:num forKey:@"myKey"];
    [archive finishEncoding];
    //testassert([data length] == 140);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSNumber *num2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([num2 intValue] == 123);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithNSNumberReal
{
    NSMutableData *data = [NSMutableData data];
    NSNumber *num = [NSNumber numberWithDouble:1234567.5];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:num forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 147);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSNumber *num2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([num2 doubleValue] == 1234567.5);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithNSNumberRealXML
{
    NSMutableData *data = [NSMutableData data];
    NSNumber *num = [NSNumber numberWithDouble:1234567.5];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:num forKey:@"myKey"];
    [archive finishEncoding];
    //testassert([data length] == 147);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSNumber *num2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([num2 doubleValue] == 1234567.5);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithNSData
{
    NSMutableData *data = [NSMutableData data];
    NSData *d = [NSData dataWithBytes:"abc" length:3];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:d forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 142);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSData *d2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([d isEqualToData:d2]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithNSDataXML
{
    NSMutableData *data = [NSMutableData data];
    NSData *d = [NSData dataWithBytes:"abc" length:3];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:d forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 500);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSData *d2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([d isEqualToData:d2]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithNestedArray
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSArray *a = [NSArray arrayWithObjects:@[@170, @187], nil];  // 0xaa 0xbb
    [archive encodeObject:a forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 261);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSArray *a2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([a2 isEqualToArray:a]);
    [unarchive finishDecoding];
    
    return YES;
}


- (BOOL) testInitForWritingWithNestedArrayXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSArray *a = [NSArray arrayWithObjects:@[@170, @187], nil];  // 0xaa 0xbb
    [archive encodeObject:a forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 1229);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSArray *a2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([a2 isEqualToArray:a]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSimpleSet
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSSet *s = [NSSet setWithObjects:@"abc", @"xyz", nil];
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 245);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSValue *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqual:s]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSimpleSetXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSSet *s = [NSSet setWithObjects:@"abc", @"xyz", nil];
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 993);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSValue *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqual:s]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSet
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSSet *s = [NSSet setWithObjects:@1, @"abc", @[@3, @4], nil];
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 314);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSValue *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqual:s]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSetXML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSSet *s = [NSSet setWithObjects:@1, @"abc", @[@3, @4], nil];
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 1588);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSValue *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqual:s]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSet2
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSSet *s = [NSSet setWithObjects:@[@7, @9], nil];
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 296);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSSet *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqual:s]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL) testInitForWritingWithSet2XML
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSSet *s = [NSSet setWithObjects:@[@7, @9], nil];
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    //testassert([data length] == 296);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSSet *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqual:s]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL)testSimpleArchiveArray
{
    NSData* objectEncoded = [NSKeyedArchiver archivedDataWithRootObject:@[ @4, @5, @6]];
    testassert([objectEncoded length] == 252);
    const char *bytes = [objectEncoded bytes];
    // should be "bplist00\xd4\x01\x02\x03\x04\x05\b\v\fT$topX$objectsX$versionY$archiver\xd1\x06\aTroot\x80\x01\xa2\t\nU$nullWabcdefg\x12"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\x1c\x1dT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aTroot", 6) == 0);
    testassert(strncmp(&bytes[80], "classZNS.objects", 16) == 0);
    testassert(strncmp(&bytes[119], "X$classesZ$classname", 20) == 0);
    testassert(strncmp(&bytes[142], "WNSArrayXNSObjectWNSArray", 25) == 0);
    testassert(bytes[109] == 4);
    testassert(bytes[111] == 5);
    testassert(bytes[113] == 6);
    return YES;
}

- (BOOL)testSimpleArchiveDictionary
{
    NSData* objectEncoded = [NSKeyedArchiver archivedDataWithRootObject:@{ @"abc": @4, @"def": @9}];
    testassert([objectEncoded length] == 287);
    const char *bytes = [objectEncoded bytes];
    // should be "bplist00\xd4\x01\x02\x03\x04\x05\b\v\fT$topX$objectsX$versionY$archiver\xd1\x06\aTroot\x80\x01\xa2\t\nU$nullWabcdefg\x12"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[17], "T$topX$objectsX$versionY$archiver", 33) == 0);
    testassert(strncmp(&bytes[52], "\aTroot", 6) == 0);
    testassert(strncmp(&bytes[81], "ZNS.objectsV$classWNS.keys", 25) == 0);
    testassert(strncmp(&bytes[123], "SabcSdef", 8) == 0);
    testassert(strncmp(&bytes[140], "X$classesZ$classname", 20) == 0);
    testassert(strncmp(&bytes[164], "NSDictionaryXNSObject", 21) == 0);
    testassert(bytes[132] == 4);
    testassert(bytes[134] == 9);
    return YES;
}

- (BOOL)testBasicObjectsEncodeDecodeWithoutCGPoint
{
    for (id (^c)(void) in [self NSCodingSupportedClassesWithoutCGPoint])
    {
        id object = c();
        NSData* objectEncoded = [NSKeyedArchiver archivedDataWithRootObject:object];
        testassert(objectEncoded != nil);
        id objectDecoded = [NSKeyedUnarchiver unarchiveObjectWithData:objectEncoded];
        testassert(objectDecoded != nil);
        
        testassert([object isEqual:objectDecoded]);
        
        [object release];
    }
    return YES;
}

- (BOOL)testBasicObjectsEncodeDecode
{
    for (id (^c)(void) in [self NSCodingSupportedClasses])
    {
        id object = c();
        NSData* objectEncoded = [NSKeyedArchiver archivedDataWithRootObject:object];
        testassert(objectEncoded != nil);
        id objectDecoded = [NSKeyedUnarchiver unarchiveObjectWithData:objectEncoded];
        testassert(objectDecoded != nil);

        testassert([object isEqual:objectDecoded]);

        [object release];
    }
    return YES;
}

- (BOOL) testInitForWritingWithNullString
{
    NSMutableData *data = [NSMutableData data];
    
    FoundationTestKeyedCoderTest *obj = [FoundationTestKeyedCoderTest new];
    obj.cString = "sdfgsdfg";
    
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    
    [archive encodeObject:obj forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 558);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    FoundationTestKeyedCoderTest *decodedObject = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj isEqual:decodedObject]);
    [unarchive finishDecoding];
    
    return YES;
}

- (BOOL)testEncodeDecodeOfDifferentTypes0
{
    FoundationTestKeyedCoderTest* obj = [FoundationTestKeyedCoderTest new];
    obj.objectString = @"apportable is leet";
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    testassert([data length] == 557);
    FoundationTestKeyedCoderTest* decodedObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    testassert([obj isEqual:decodedObject]);
    free(obj.memory);
    [obj release];
    return YES;
}

- (BOOL)testEncodeDecodeOfDifferentTypes1
{
    FoundationTestKeyedCoderTest* obj = [FoundationTestKeyedCoderTest new];
    obj.objectString = @"apportable is leet";
    obj.objectDictionary = @{@"hello": @(12345)};
    obj.objectArray = @[@"1", @(2), @{@"hello": @(12345)}];
    obj.memorySize = 1024;
    obj.memory = malloc(obj.memorySize);
    obj.cString = "sdfgsdfg";
    obj.rect = CGRectMake(1, 2, 1024, 512);
    obj.doubleNumber = 123234534.045f;
    obj.floatNumber = 1234.12f;
    obj.integerSigned = 10000;
    obj.shortNumber = 127;
    obj.boolean = YES;
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    FoundationTestKeyedCoderTest* decodedObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    testassert([obj isEqual:decodedObject]);
    free(obj.memory);
    [obj release];
    return YES;
}

- (BOOL)testEncodeDecodeOfDifferentTypes2
{
    FoundationTestKeyedCoderTest* obj = [FoundationTestKeyedCoderTest new];
    obj.objectValue = [NSValue valueWithCGSize:(CGSize){100, 500}];

    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    FoundationTestKeyedCoderTest* decodedObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    testassert([obj isEqual:decodedObject]);
    free(obj.memory);
    [obj release];
    return YES;
}

- (BOOL)testRoundTripChar
{
    char val = 'A';
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeValueOfObjCType:@encode(char) at:&val];
    [coder finishEncoding];
    [coder release];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [data release];
    char dval = '\0';
    [decoder decodeValueOfObjCType:@encode(char) at:&dval];
    [decoder finishDecoding];
    [decoder release];
    testassert(val == dval);
    return YES;
}

- (BOOL)testRoundTripUnsignedChar
{
    unsigned char val = 5;
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeValueOfObjCType:@encode(unsigned char) at:&val];
    [coder finishEncoding];
    [coder release];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [data release];
    unsigned char dval = 0;
    [decoder decodeValueOfObjCType:@encode(unsigned char) at:&dval];
    [decoder finishDecoding];
    [decoder release];
    testassert(val == dval);
    return YES;
}

- (BOOL)testRoundTripShort
{
    short val = 888;
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeValueOfObjCType:@encode(short) at:&val];
    [coder finishEncoding];
    [coder release];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [data release];
    short dval = 0;
    [decoder decodeValueOfObjCType:@encode(short) at:&dval];
    [decoder finishDecoding];
    [decoder release];
    testassert(val == dval);
    return YES;
}

- (BOOL)testRoundTripUnsignedShort
{
    unsigned short val = -888;
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeValueOfObjCType:@encode(unsigned short) at:&val];
    [coder finishEncoding];
    [coder release];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [data release];
    unsigned short dval = 0;
    [decoder decodeValueOfObjCType:@encode(unsigned short) at:&dval];
    [decoder finishDecoding];
    [decoder release];
    testassert(val == dval);
    return YES;
}

- (BOOL)testRoundTripInt
{
    int val = -383838383;
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeValueOfObjCType:@encode(int) at:&val];
    [coder finishEncoding];
    [coder release];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [data release];
    int dval = 0;
    [decoder decodeValueOfObjCType:@encode(int) at:&dval];
    [decoder finishDecoding];
    [decoder release];
    testassert(val == dval);
    return YES;
}

- (BOOL)testRoundTripUnsignedInt
{
    unsigned int val = 383838383;
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeValueOfObjCType:@encode(unsigned int) at:&val];
    [coder finishEncoding];
    [coder release];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [data release];
    unsigned int dval = 0;
    [decoder decodeValueOfObjCType:@encode(unsigned int) at:&dval];
    [decoder finishDecoding];
    [decoder release];
    testassert(val == dval);
    return YES;
}

- (BOOL)testRoundTripLong
{
    long val = -383838383;
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeValueOfObjCType:@encode(long) at:&val];
    [coder finishEncoding];
    [coder release];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [data release];
    long dval = 0;
    [decoder decodeValueOfObjCType:@encode(long) at:&dval];
    [decoder finishDecoding];
    [decoder release];
    testassert(val == dval);
    return YES;
}

- (BOOL)testRoundTripUnsignedLong
{
    unsigned long val = 383838383;
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeValueOfObjCType:@encode(unsigned long) at:&val];
    [coder finishEncoding];
    [coder release];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [data release];
    unsigned long dval = 0;
    [decoder decodeValueOfObjCType:@encode(unsigned long) at:&dval];
    [decoder finishDecoding];
    [decoder release];
    testassert(val == dval);
    return YES;
}

- (BOOL)testRoundTripLongLong
{
    long long val = -3838383383383838383LL;
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeValueOfObjCType:@encode(long long) at:&val];
    [coder finishEncoding];
    [coder release];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [data release];
    long long dval = 0;
    [decoder decodeValueOfObjCType:@encode(long long) at:&dval];
    [decoder finishDecoding];
    [decoder release];
    testassert(val == dval);
    return YES;
}

- (BOOL)testRoundTripUnsignedLongLong
{
    unsigned long long val = 3838388383383838383ULL;
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeValueOfObjCType:@encode(unsigned long long) at:&val];
    [coder finishEncoding];
    [coder release];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [data release];
    unsigned long long dval = 0;
    [decoder decodeValueOfObjCType:@encode(unsigned long long) at:&dval];
    [decoder finishDecoding];
    [decoder release];
    testassert(val == dval);
    return YES;
}

- (BOOL)testNilData
{
    id obj = [NSKeyedUnarchiver unarchiveObjectWithData:nil];
    testassert(obj == nil);
    return YES;
}

- (BOOL)testNilData2
{
    NSKeyedUnarchiver *archiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:nil];
    testassert(archiver == nil);
    return YES;
}

- (BOOL)testNilPath
{
    id obj = [NSKeyedUnarchiver unarchiveObjectWithFile:nil];
    testassert(obj == nil);
    return YES;
}

#pragma mark - Nested structures

#pragma mark - Corner cases

@end
