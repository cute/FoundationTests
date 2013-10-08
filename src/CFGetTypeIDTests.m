//
//  CFGetTypeIDTests.m
//  FoundationTests
//
//  Created by Paul Beusterien on 10/1/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"
#include <CoreFoundation/CoreFoundation.h>
#include <objc/runtime.h>

typedef struct __CFRuntimeClass {
    CFIndex version;
    const char *className;
    void (*init)(CFTypeRef cf);
    CFTypeRef (*copy)(CFAllocatorRef allocator, CFTypeRef cf);
    void (*finalize)(CFTypeRef cf);
    Boolean (*equal)(CFTypeRef cf1, CFTypeRef cf2);
    CFHashCode (*hash)(CFTypeRef cf);
    CFStringRef (*copyFormattingDesc)(CFTypeRef cf, CFDictionaryRef formatOptions);  // str with retain
    CFStringRef (*copyDebugDesc)(CFTypeRef cf);	// str with retain
    void (*reclaim)(CFTypeRef cf);
} CFRuntimeClass;

typedef struct __CFRuntimeBase {
    uintptr_t _cfisa;
    uint8_t _cfinfo[4];
#if __LP64__
    uint32_t _rc;
#endif
} CFRuntimeBase;

extern CFTypeID _CFRuntimeRegisterClass(const CFRuntimeClass* const cls);

extern CFTypeRef _CFRuntimeCreateInstance(CFAllocatorRef allocator,
                                          CFTypeID typeID, CFIndex extraBytes,
                                          unsigned char* category);

// =============================================== _cfTypeID swizzling

static BOOL CFTypeIDCalled = NO;
static IMP OriginalCFTypeID = NULL;
static CFTypeID MyCFTypeID(id self, SEL _cmd)
{
    CFTypeIDCalled = YES;
    return ((CFTypeID(*)(id,SEL))OriginalCFTypeID)(self, _cmd);
}

static void SwizzleCFTypeID(Class class, BOOL swizzle)
{
    Method method = class_getInstanceMethod(class, @selector(_cfTypeID));
    NSCAssert(method, @"There is no _cfTypeID in %s", class_getName(class));
    
    if (swizzle)
    {
        OriginalCFTypeID = method_getImplementation(method);
        method_setImplementation(method, (IMP)&MyCFTypeID);
    }
    else
    {
        method_setImplementation(method, OriginalCFTypeID);
        OriginalCFTypeID = NO;
    }
}

@interface NSObject (_cfTypeID)
- (CFTypeID)_cfTypeID;
@end

@testcase(CFGetTypeID)

// =============================================== tests


static BOOL TestCFGetTypeID(CFTypeRef object, CFTypeID expectedTypeID)
{
    Class class = (Class)((const CFRuntimeBase*)object)->_cfisa;
    SwizzleCFTypeID(class, YES);
    
    CFTypeIDCalled = NO;
    CFTypeID typeID = CFGetTypeID(object);
    
    testassert(typeID == expectedTypeID);
    // NSCAssert(typeID == expectedTypeID, @"CFGetTypeID() returned bad type ID %ld (expected %ld)", typeID, expectedTypeID);
    
    testassert(!CFTypeIDCalled);
    // NSCAssert(!CFTypeIDCalled, @"_cfTypeID was called during CFGetTypeID() call on %p of objc type %s", object, class_getName(class));
    
    CFTypeIDCalled = NO;
    [(id)object _cfTypeID];
    testassert(CFTypeIDCalled);
    // NSCAssert(CFTypeIDCalled, @"_cfTypeID was NOT called during [_cfTypeID] message to %p of objc type %s", object, class_getName(class));
    
    SwizzleCFTypeID(class, NO);
    return YES;
}

typedef struct
{
    CFRuntimeBase base;
} MyObject;

static CFRuntimeClass MyObjectClass = {
    0,
    "MyObject"
};

- (BOOL)testCFTypeIDCustom
{
    // Custom object
    CFTypeID myTypeID = _CFRuntimeRegisterClass(&MyObjectClass);
    NSCAssert(myTypeID != 0, @"Failed to register custom CF class");
    
    MyObject* object = (MyObject*)_CFRuntimeCreateInstance(
                                                           kCFAllocatorDefault,
                                                           myTypeID,
                                                           sizeof(MyObject) - sizeof(CFRuntimeBase),
                                                           NULL);
    
    BOOL retVal = TestCFGetTypeID(object, myTypeID);
    CFRelease(object);
    
    return retVal;
}

- (BOOL)testCFTypeIDString
// CFString
{
    CFStringRef string = (CFStringRef)@"test";
    return TestCFGetTypeID(string, CFStringGetTypeID());
}

- (BOOL)testCFTypeIDArray
// CFArray
{
    CFArrayRef array = CFArrayCreate(kCFAllocatorDefault, NULL, 0, NULL);
    BOOL retVal = TestCFGetTypeID(array, CFArrayGetTypeID());
    CFRelease(array);
    return retVal;
}

- (BOOL) testDataCFTypeID
{
    NSData *data = [NSData data];
    testassert((int)[data _cfTypeID] == CFDataGetTypeID());
    testassert(CFGetTypeID(data) == CFDataGetTypeID());
    return YES;
}

- (BOOL) testMutableDataCFTypeID
{
    NSMutableData *data = [NSMutableData dataWithLength:7];
    testassert((int)[data _cfTypeID] == CFDataGetTypeID());
    testassert(CFGetTypeID(data) == CFDataGetTypeID());
    return YES;
}

@end
