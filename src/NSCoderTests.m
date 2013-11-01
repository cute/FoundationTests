//
//  NSCoderTests.m
//  FoundationTests
//
//  Created by George Kulakowski on 10/26/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

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
    return YES;
}

- (BOOL) testInitForWritingWithMutableDataInt32
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeInt32:123 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 136);
    const char *bytes = [data bytes];
    // "bplist00\xd4\x01\x02\x03\x04\x05\b\n\vT$topX$objectsX$versionY$archiver\xd1\x06\aUmyKey\x10{\xa1\tU$null\x12"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\n\vT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aUmyKey", 7) == 0);
    testassert(bytes[60] == 123);
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
