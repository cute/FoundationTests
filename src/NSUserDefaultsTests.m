#import "FoundationTests.h"

#include <stdio.h>
#import <objc/runtime.h>

@testcase(NSUserDefaults)

- (BOOL)testSetAndGet
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"apportable" forKey:@"firstName"];
    [defaults setObject:@"smith" forKey:@"lastName"];
    [defaults setInteger:123 forKey:@"intKey"];
    [defaults setInteger:2 forKey:@"age"];
    [defaults setBool:YES forKey:@"boolKey"];
    [defaults setFloat:1.2f forKey:@"floatKey"];
    [defaults setDouble:-9.9 forKey:@"doubleKey"];

    [defaults synchronize];
    
    testassert([@"apportable" isEqualToString:[defaults stringForKey:@"firstName"]]);
    testassert([@"smith" isEqualToString:[defaults stringForKey:@"lastName"]]);
    testassert([defaults stringForKey:@"doesntexist"] == nil);
    NSInteger i = [defaults integerForKey:@"intKey"];
    testassert(i == 123);
    NSInteger age = [defaults integerForKey:@"age"];
    testassert(age == 2);
    testassert([defaults boolForKey:@"boolKey"]);
    testassert([defaults floatForKey:@"floatKey"] == 1.2f);
    testassert([defaults doubleForKey:@"doubleKey"] == -9.9);

    return YES;
}

- (BOOL)testSetAndGetURL  
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:@"www.apportable.com"];
    [defaults setURL:url forKey:@"urlKey"];
    testassert([[[defaults URLForKey:@"urlKey"] path] isEqualToString:@"/www.apportable.com"] );
    
    return YES;
}

- (BOOL) testRegisterDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults  = [NSDictionary dictionaryWithObjectsAndKeys:@"xyz", @"abc", @2, @"def", nil];
    [defaults registerDefaults:appDefaults];
    [defaults synchronize];
    testassert([[defaults stringForKey:@"abc"] isEqualToString:@"xyz"]);
    testassert([defaults integerForKey:@"def"] == 2);
    
    return YES;
}

                
- (BOOL) testRegisterDefaultsDontOverwrite
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"apportable" forKey:@"firstName"];
    NSDictionary *appDefaults  = [NSDictionary dictionaryWithObjectsAndKeys:@"xyz", @"abc", @2, @"firstName", nil];
    [defaults registerDefaults:appDefaults];
    testassert([[defaults stringForKey:@"abc"] isEqualToString:@"xyz"]);
    testassert([[defaults stringForKey:@"firstName"] isEqualToString:@"apportable"]);
    
    return YES;
}

- (BOOL)testStoreDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *date = [NSDate date];
    NSDate *orig = date;
    [defaults setObject:date forKey:@"now"];
    date = [defaults objectForKey:@"now"];
    testassert(date != nil);
    testassert(date != orig);
    return YES;
}

- (BOOL)testStoreData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSData dataWithBytes:"foo" length:3];
    NSData *orig = data;
    [defaults setObject:data forKey:@"dat"];
    data = [defaults objectForKey:@"dat"];
    testassert(data != nil);
    testassert(data != orig);
    return YES;
}


@end


