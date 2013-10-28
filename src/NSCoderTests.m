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
