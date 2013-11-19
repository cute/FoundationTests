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
    if (![self.objectString isEqual:object.objectString])
    {
        return NO;
    }
    if (![self.objectValue isEqual:object.objectValue])
    {
        return NO;
    }
    if (![self.objectArray isEqual:object.objectArray])
    {
        return NO;
    }
    if (memcmp(self.memory, object.memory, self.memorySize) != 0)
    {
        return NO;
    }
    if (strcmp(self.cString, object.cString) != 0)
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
    [aCoder encodeBytes:(void*)self.cString length:strlen(self.cString) + 1 forKey:@"cString"];

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

- (NSArray *)NSCodingSupportedClasses
{
    return @[
        [^(){ return [NSDictionary new]; } copy],
        [^(){ return [NSArray new]; } copy],
        [^(){ return [[NSValue valueWithCGPoint:CGPointMake(13, 37)] retain]; } copy],
        [^(){ return [NSNull new]; } copy],
        [^(){ return [[NSNumber numberWithInt:1337] retain]; } copy],
        [^(){ return [NSString new]; } copy],
    ];
}

#pragma mark - Basic stuff


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

//"bplist00\xd4\x01\x02\x03\x04\x05\b\x1c\x1dT$topX$objectsX$versionY$archiver\xd1\x06\aTroot\x80\x01\xa6\t\n\x12\x13\x14\x15U$null\xd2\v\f\r\x0eV$classZNS.objects\x80\x05\xa3\x0f\x10\x11\x80\x02\x80\x03\x80\x04\x10\x01\x10\x02\x10\x03\xd2\x16\x17\x18\eX$classesZ$classname\xa2\x19\x1aWNSArrayXNSObjectWNSArray\x12"

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

// "bplist00\xd4\x01\x02\x03\x04\x05\b !T$topX$objectsX$versionY$archiver\xd1\x06\aTroot\x80\x01\xa7\t\n\x15\x16\x17\x18\x19U$null\xd3\v\f\r\x0e\x11\x12ZNS.objectsV$classWNS.keys\xa2\x0f\x10\x80\x04\x80\x05\x80\x06\xa2\x13\x14\x80\x02\x80\x03SabcSdef\x10\x04\x10\t\xd2\x1a\e\x1c\x1fX$classesZ$classname\xa2\x1d\x1e\NSDictionaryXNSObject\NSDictionary\x12"

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

- (BOOL)testEncodeDecodeOfDifferentTypes
{
    FoundationTestKeyedCoderTest* obj = [FoundationTestKeyedCoderTest new];
    obj.objectString = @"apportable is leet";
    obj.objectValue = [NSValue valueWithCGSize:(CGSize){100, 500}];
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

#pragma mark - Nested structures

#pragma mark - Corner cases

@end
