#import "FoundationTests.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

struct PAIR
{
    unsigned long long first;
    unsigned long long second;
};

//////////////////////////////////////////////////////////////////////////////

@interface ForwardingTestsObjectBase : NSObject
@end

@implementation ForwardingTestsObjectBase

// Test the normal (non-stret code path).  Use long long to ensure
// that the four ARM argument registers are exhausted, pushing values
// out onto the stack.
- (unsigned long long)multiply:(unsigned long long)x and:(unsigned long long)y
{
    return x * y;
}

// Test the stret code paths.
- (struct PAIR)multiplyPair:(struct PAIR)x and:(struct PAIR)y
{
    struct PAIR ret;
    ret.first = x.first * y.first;
    ret.second = x.second * y.second;
    return ret;
}

@end

//////////////////////////////////////////////////////////////////////////////

@interface ForwardingTestsProxyBase : NSProxy
@end

@implementation ForwardingTestsProxyBase

- (id)init
{
    return self;
}

- (unsigned long long)multiply:(unsigned long long)x and:(unsigned long long)y
{
    return x * y;
}

- (struct PAIR)multiplyPair:(struct PAIR)x and:(struct PAIR)y
{
    struct PAIR ret;
    ret.first = x.first * y.first;
    ret.second = x.second * y.second;
    return ret;
}

@end

//////////////////////////////////////////////////////////////////////////////

@interface ForwardingTestsProxyForwardTarget : NSProxy
@end

@implementation ForwardingTestsProxyForwardTarget
{
    id _target;
}

- (id)initWithTarget:(id)target
{
    _target = target;
    return self;
}

- (id)forwardingTargetForSelector:(SEL)sel
{
    return _target;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"<ForwardingTestsProxyForwardTarget: %p, %@>", self, [_target description]];
}

@end

//////////////////////////////////////////////////////////////////////////////

@interface ForwardingTestsObjectForwardTarget : NSObject
@end

@implementation ForwardingTestsObjectForwardTarget
{
    id _target;
}

- (id)initWithTarget:(id)target
{
    self = [super init];
    if (self)
    {
        _target = target;
    }
    return self;
}

- (id)forwardingTargetForSelector:(SEL)sel
{
    return _target;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"<ForwardingTestsObjectForwardTarget: %p, %@>", self, [_target description]];
}

@end

//////////////////////////////////////////////////////////////////////////////

@interface ForwardingTestsProxyForwardInvocation : NSProxy
@end

@implementation ForwardingTestsProxyForwardInvocation
{
    id _target;
}

- (id)initWithTarget:(id)target
{
    _target = target;
    return self;
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)sel
{
    if (sel == @selector(multiply:and:))
    {
        return [NSMethodSignature signatureWithObjCTypes:"q@:qq"];
    }
    else if (sel == @selector(multiplyPair:and:))
    {
        return [NSMethodSignature signatureWithObjCTypes:"{PAIR=qq}@:{PAIR=qq}{PAIR=qq}"];
    }
    return [super methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation invokeWithTarget:_target];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"<ForwardingTestsProxyForwardInvocation: %p, %@>", self, [_target description]];
}

@end

//////////////////////////////////////////////////////////////////////////////

@interface ForwardingTestsObjectForwardInvocation : NSObject
@end

@implementation ForwardingTestsObjectForwardInvocation
{
    id _target;
}

- (id)initWithTarget:(id)target
{
    self = [super init];
    if (self)
    {
        _target = target;
    }
    return self;
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)sel
{
    if (sel == @selector(multiply:and:))
    {
        return [NSMethodSignature signatureWithObjCTypes:"q@:qq"];
    }
    else if (sel == @selector(multiplyPair:and:))
    {
        return [NSMethodSignature signatureWithObjCTypes:"{PAIR=qq}@:{PAIR=qq}{PAIR=qq}"];
    }
    return [super methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation invokeWithTarget:_target];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"<ForwardingTestsObjectForwardInvocation: %p, %@>", self, [_target description]];
}

@end

//////////////////////////////////////////////////////////////////////////////

@interface NSObject (ForwardingTestsMultiply)
- (unsigned long long)multiply:(unsigned long long)x and:(unsigned long long)y;
- (struct PAIR)multiplyPair:(struct PAIR)x and:(struct PAIR)y;
@end

//////////////////////////////////////////////////////////////////////////////

@testcase(Forwarding)

static id baseObject(int i)
{
    if (i == 0)
    {
        return [[[ForwardingTestsObjectBase alloc] init] autorelease];
    }
    else
    {
        return [[[ForwardingTestsProxyBase alloc] init] autorelease];
    }
}

static id forwardObject(int i, id base)
{
    switch (i)
    {
        case 0: return [[[ForwardingTestsProxyForwardTarget alloc] initWithTarget:base] autorelease];
        case 1: return [[[ForwardingTestsProxyForwardInvocation alloc] initWithTarget:base] autorelease];
        case 2: return [[[ForwardingTestsObjectForwardTarget alloc] initWithTarget:base] autorelease];
        case 3: return [[[ForwardingTestsObjectForwardInvocation alloc] initWithTarget:base] autorelease];
        default: return nil;
    }
}

- (BOOL)testForwardingObjectChains
{
    NSMutableArray *array = [NSMutableArray array];

    for (int gen1 = 0; gen1 < 2; ++gen1)
    {
        id base = baseObject(gen1);
        [array addObject:base];
        for (int gen2 = 0; gen2 < 4; ++gen2)
        {
            id step = forwardObject(gen2, base);
            [array addObject:step];
            for (int gen3 = 0; gen3 < 4; ++gen3)
            {
                id final = forwardObject(gen3, step);
                [array addObject:final];
            }
        }
    }

    unsigned long long x = 0x1122334455667788LL;
    unsigned long long y = 0x2233445566778899LL;
    struct PAIR xPair = { 0x33445566778899aaLL, 0x445566778899aabbLL };
    struct PAIR yPair = { 0x5566778899aabbccLL, 0x66778899aabbccddLL };

    for (id item in array)
    {
        //NSLog(@"testing item %@", [item description]);

        // Technically, half of these things are NSProxy's, not NSObject's.  Cast it to
        // NSObject anyway so the calls are declared via the NSObject(ForwardingTestsMultiply)
        // category.
        NSObject *const itemAsNSObject = (NSObject*)item;

        // Call multiply:and: directly.
        unsigned long long ret = [itemAsNSObject multiply:x and:y];
        testassert(ret == x * y);
        x += 0x100000001LL;
        y += 0x100000001LL;

        // Call multiplyPair:and: directly.
        struct PAIR retPair = [itemAsNSObject multiplyPair:xPair and:yPair];
        testassert(retPair.first == xPair.first * yPair.first);
        testassert(retPair.second == xPair.second * yPair.second);
        xPair.first += 0x100000001LL;
        xPair.second += 0x100000001LL;
        yPair.first += 0x100000001LL;
        yPair.second += 0x100000001LL;

        // Call multiply:and: via NSInvocation.
        NSInvocation *invScalar = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"q@:qq"]];
        [invScalar setSelector:@selector(multiply:and:)];
        [invScalar setArgument:&x atIndex:2];
        [invScalar setArgument:&y atIndex:3];
        [invScalar invokeWithTarget:item];
        [invScalar getReturnValue:&ret];
        testassert(ret == x * y);
        x += 0x100000001LL;
        y += 0x100000001LL;

        // Call multiplyPair:and: via NSInvocation.
        NSInvocation *invPair = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"{PAIR=qq}@:{PAIR=qq}{PAIR=qq}"]];
        [invPair setSelector:@selector(multiplyPair:and:)];
        [invPair setArgument:&xPair atIndex:2];
        [invPair setArgument:&yPair atIndex:3];
        [invPair invokeWithTarget:item];
        [invPair getReturnValue:&retPair];
        testassert(retPair.first == xPair.first * yPair.first);
        testassert(retPair.second == xPair.second * yPair.second);
        xPair.first += 0x100000001LL;
        xPair.second += 0x100000001LL;
        yPair.first += 0x100000001LL;
        yPair.second += 0x100000001LL;
    }

    return YES;
}

@end
