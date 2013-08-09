#import "FoundationTests.h"

@testcase(NSInvocation)

- (NSRange)methodReturningRange
{
    return NSMakeRange(500, 50);
}

- (NSString *)substringFromString:(NSString *)str withRange:(NSRange)range
{
    return [str substringWithRange:range];
}

- (BOOL)testIncorrectAllocInit
{
    NSInvocation *inv = [[NSInvocation alloc] init]; // should not throw
    
    testassert(inv == nil);
    return YES;
}

- (BOOL)testInvocationWithMethodSiganture
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    testassert(inv != nil);
    return YES;
}

- (BOOL)testSelectorUnset
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    SEL bad = [inv selector];
    testassert(bad == nil);
    return YES;
}

- (BOOL)testSelectorSet
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv setSelector:@selector(objectForKey:)];
    SEL good = [inv selector];
    testassert(good == @selector(objectForKey:));
    return YES;
}

- (BOOL)testTargetUnset
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    id target = [inv target];
    testassert(target == nil);
    return YES;
}

- (BOOL)testTargetSet
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    id target = [inv target];
    testassert(target == nil);
    [inv setTarget:dict];
    target = [inv target];
    testassert(target == dict);
    [inv setTarget:nil];
    target = [inv target];
    testassert(target == nil);
    return YES;
}

- (BOOL)testMethodSignature
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    NSMethodSignature *ms = [inv methodSignature];
    testassert(ms != nil);
    return YES;
}

- (BOOL)testArgumentsSetOutOfOrder
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    NSString *foo = [NSString stringWithUTF8String:"Foo"];
    [inv setArgument:&foo atIndex:2]; // odd that &@"Foo" doesn't work...
    id fooFrom;
    [inv getArgument:&fooFrom atIndex:2];
    testassert([fooFrom isEqual:foo]);
    
    return YES;
}

- (BOOL)testArgumentsRetainedUnretained
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    testassert([inv argumentsRetained] == NO);
    NSUInteger rc = [dict retainCount];
    [inv setTarget:dict];
    testassert(rc == [dict retainCount]); // target is not retained by the invocation except if the arguments are. 
    
    return YES;
}

- (BOOL)testArgumentsRetainedRetained
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv retainArguments];
    NSUInteger rc = [dict retainCount];
    testassert([inv argumentsRetained] == YES);
    [inv setTarget:dict];
    testassert(rc < [dict retainCount]);
    
    
    return YES;
}

- (BOOL)testSetArgumentAtIndexBeyondBounds
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    NSString *foo = [NSString string];
    void (^block)(void) = ^{
        [inv setArgument:&foo atIndex:6];
    };
    BOOL raised = NO;
    @try
    {
        block();
    }
    @catch (NSException *e)
    {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]); // why is this not an NSRangeException anyway?
        raised = YES;
    }
    testassert(raised == YES);
    
    return YES;
}

- (BOOL)testGetReturnValueUninvoked
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv setSelector:@selector(objectForKey:)];
    [inv setTarget:dict];
    NSString *str = @"Foo";
    [inv setArgument:&str atIndex:2];
    id result = nil;
    [inv getReturnValue:&result];
    testassert(result == nil);
    return YES;
}

- (BOOL)testGetReturnValueInvoked
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv setSelector:@selector(objectForKey:)];
    [inv setTarget:dict];
    NSString *str = @"Foo";
    [inv setArgument:&str atIndex:2];
    id result = nil;
    [inv invoke];
    [inv getReturnValue:&result];
    testassert([result isEqualToString:@"bar"]);
    return YES;
}

- (BOOL)testSetReturnValueUninvoked
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv setSelector:@selector(objectForKey:)];
    [inv setTarget:dict];
    NSString *str = @"Foo";
    [inv setArgument:&str atIndex:2];
    id result = nil;
    NSString *str2 = [dict objectForKey:@"Foo"];
    [inv setReturnValue:&str2];
    [inv getReturnValue:&result];
    testassert(result == str2);
    return YES;
}

- (BOOL)testSetReturnValueInvoked
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv setSelector:@selector(objectForKey:)];
    [inv setTarget:dict];
    NSString *str = @"Foo";
    [inv setArgument:&str atIndex:2];
    id result = nil;
    NSString *str2 = [dict objectForKey:@"Foo"];
    [inv setReturnValue:&str2];
    [inv getReturnValue:&result];
    testassert(result == str2);
    NSString *fake = @"qux";
    [inv setReturnValue:&fake];
    result = nil;
    [inv getReturnValue:&result];
    testassert(fake == result);
    return YES;
}

- (BOOL)testGetArgumentAtIndex
{
    NSString *unintedString = [NSString alloc];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[unintedString methodSignatureForSelector:@selector(initWithBytes:length:encoding:)]];
    char *bytesArg = "This is the dawning of the age of Aquarius!";
    [inv setTarget:unintedString];
    [inv setSelector:@selector(initWithBytes:length:encoding:)];
    [inv setArgument:&bytesArg atIndex:2];
    NSUInteger length = strlen(bytesArg);
    NSStringEncoding encoding = NSUTF8StringEncoding;
    [inv setArgument:&length atIndex:3];
    [inv setArgument:&encoding atIndex:4];
    NSUInteger outLen;
    [inv getArgument:&outLen atIndex:3];
    NSStringEncoding outEnc;
    [inv getArgument:&outEnc atIndex:4];
    testassert(outLen == length);
    testassert(outEnc == encoding);
    [inv invoke]; // should still work after invocation
    [inv getArgument:&outLen atIndex:3];
    [inv getArgument:&outEnc atIndex:4];
    testassert(outLen == length);
    testassert(outEnc == encoding);

    id result;
    [inv getReturnValue:&result];
    testassert([result isEqualToString:@"This is the dawning of the age of Aquarius!"]);
    result = nil;
    [inv getArgument:&result atIndex:-1];
    testassert([result isEqualToString:@"This is the dawning of the age of Aquarius!"]);
    [unintedString release];
    return YES;
}

- (BOOL)testCharStarBehaviorWithUnretainedArguments
{
    NSString *unintedString = [NSString alloc];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[unintedString methodSignatureForSelector:@selector(initWithBytes:length:encoding:)]];
    char *bytesArg = "This is the dawning of the age of Aquarius!";
    [inv setTarget:unintedString];
    [inv setSelector:@selector(initWithBytes:length:encoding:)];
    [inv setArgument:&bytesArg atIndex:2];
    NSUInteger length = strlen(bytesArg);
    NSStringEncoding encoding = NSUTF8StringEncoding;
    [inv setArgument:&length atIndex:3];
    [inv setArgument:&encoding atIndex:4];
    testassert([inv target] == unintedString);
    testassert([inv selector] == @selector(initWithBytes:length:encoding:));
    [inv invoke];
    id result;
    [inv getReturnValue:&result];
    testassert([result isEqualToString:@"This is the dawning of the age of Aquarius!"]);
    [unintedString release];
    return YES;
}
- (BOOL)testCharStarBehaviorWithRetainedArguments
{
    NSString *unintedString = [NSString alloc];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[unintedString methodSignatureForSelector:@selector(initWithBytes:length:encoding:)]];
    char *bytesArg = "This is the dawning of the age of Aquarius!";
    [inv setTarget:unintedString];
    [inv setSelector:@selector(initWithBytes:length:encoding:)];
    [inv setArgument:&bytesArg atIndex:2];
    NSUInteger length = strlen(bytesArg);
    NSStringEncoding encoding = NSUTF8StringEncoding;
    [inv setArgument:&length atIndex:3];
    [inv setArgument:&encoding atIndex:4];
    testassert([inv target] == unintedString);
    testassert([inv selector] == @selector(initWithBytes:length:encoding:));
    [inv retainArguments];
    [inv invoke];
    id result;
    [inv getReturnValue:&result];
    testassert([result isEqualToString:@"This is the dawning of the age of Aquarius!"]);
    [unintedString release];
    
    return YES;
}

- (BOOL)testInvokeAllUnset
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv invoke]; // doesn't crash or throw an exception, just silently fails. 
    id result = nil;
    [inv getReturnValue:&result];
    testassert(result == nil);
    
    return YES;
}
- (BOOL)testInvokeSelAndArgsUnset
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv setTarget:dict];
    id result = nil;
    [inv getReturnValue:&result];
    testassert(result == nil);
    return YES;

}
- (BOOL)testInvokeArgsUnset
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv setSelector:@selector(objectForKey:)];
    [inv setTarget:dict];
    id result = nil;
    [inv getReturnValue:&result];
    testassert(result == nil);
    return YES;

}
- (BOOL)testInvokeWithTarget
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv setSelector:@selector(objectForKey:)];
    NSString *str = @"Foo";
    [inv setArgument:&str atIndex:2];
    id result = nil;
    [inv invokeWithTarget:dict];
    NSString *str2 = [dict objectForKey:@"Foo"];
    [inv getReturnValue:&result];
    testassert([result isEqualToString:str2]);
    return YES;
}

- (BOOL)testStructParameter
{
    NSString *str = @"Foobarbazqux";
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[str methodSignatureForSelector:@selector(substringWithRange:)]];
    [inv setSelector:@selector(substringWithRange:)];
    NSRange range = NSMakeRange(3, 6);
    [inv setTarget:str];
    [inv setArgument:&range atIndex:2];
    id result = nil;
    [inv invoke];
    NSString *expected = @"barbaz";
    [inv getReturnValue:&result];
    testassert([result isEqualToString:expected]);
    
    return YES;
}

- (BOOL)testMixedParameters
{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(substringFromString:withRange:)]];
    [inv setSelector:@selector(substringFromString:withRange:)];
    [inv setTarget:self];
    NSRange range = NSMakeRange(6, 3);
    NSString *str = @"Foobarbazqux";
    [inv setArgument:&str atIndex:2];
    [inv setArgument:&range atIndex:3];
    [inv invoke];
    NSString *result = nil;
    [inv getReturnValue:&result];
    testassert([result isEqualToString:@"baz"]);
    
    return YES;
}

#warning TODO: fix NSInvocation trying to autorelease result (NSRange) below. 
#if 0
-(BOOL)testStructReturn
{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(methodReturningRange)]];
    [inv setSelector:@selector(methodReturningRange)];
    [inv setTarget:self];
    NSRange result;
    [inv invoke];
    [inv getReturnValue:&result];
    testassert(result.length = 50);
    testassert(result.location = 500);
    return YES;
}
#endif 
@end
