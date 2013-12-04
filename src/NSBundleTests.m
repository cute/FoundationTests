#import "FoundationTests.h"

@testcase(NSBundle)

#define RELEASEANDNIL(obj) \
{   \
    [obj release]; \
    obj = nil; \
} \

// Static vars to use in tests
NSString *mainBundlePath = nil;
static NSBundle *zeroLevelBundle, *firstLevelBundle, *secondLevelBundle;

#pragma mark - Instantiation Tests
- (BOOL)testMainBundle
{
    NSBundle *bundle = [NSBundle mainBundle];
    testassert(nil != bundle);
    
    return YES;
}

- (BOOL)testCFBundleGetMainBundle
{
    CFBundleRef cfBundle = CFBundleGetMainBundle();
    testassert(nil != cfBundle);
    
    return YES;
}

- (BOOL)testMainBundlePath
{
    mainBundlePath = [[NSBundle mainBundle] bundlePath];
    testassert(nil != mainBundlePath);
    testassert([mainBundlePath rangeOfString:@"FoundationTests"].location != NSNotFound);
    
    return YES;
}


- (BOOL)testMainBundleIdentifier
{
    NSString *s = [[NSBundle mainBundle] bundleIdentifier];
    testassert([s isEqualToString:@"com.apportable.FoundationTests"]);
    return YES;
}

- (BOOL)testValidNonMainBundleAllocInitCreation
{
    zeroLevelBundle = [[NSBundle alloc] initWithPath:[mainBundlePath stringByAppendingPathComponent:@"0.bundle"]];
    testassert(
        nil != zeroLevelBundle &&
        [[zeroLevelBundle bundlePath] isEqualToString:[mainBundlePath stringByAppendingPathComponent:@"0.bundle"]]
    );
    
    firstLevelBundle = [[NSBundle alloc] initWithPath:[zeroLevelBundle.bundlePath stringByAppendingPathComponent:@"0-0.bundle"]];
    testassert(
        nil != zeroLevelBundle &&
        nil != firstLevelBundle &&
        [[firstLevelBundle bundlePath] isEqualToString:[zeroLevelBundle.bundlePath stringByAppendingPathComponent:@"0-0.bundle"]]
    );
    
    secondLevelBundle = [[NSBundle alloc] initWithPath:[firstLevelBundle.bundlePath stringByAppendingPathComponent:@"0-0-0.bundle"]];
    testassert(
        nil != firstLevelBundle &&
        nil != secondLevelBundle &&
        [[secondLevelBundle bundlePath] isEqualToString:[firstLevelBundle.bundlePath stringByAppendingPathComponent:@"0-0-0.bundle"]]
    );
    
    return YES;
}

- (BOOL)testValidNonMainBundleClassMethodCreation
{
    if (zeroLevelBundle)
        RELEASEANDNIL(zeroLevelBundle);
    if (firstLevelBundle)
        RELEASEANDNIL(firstLevelBundle);
    if (secondLevelBundle)
        RELEASEANDNIL(secondLevelBundle);
    
    zeroLevelBundle = [[NSBundle alloc] initWithPath:[mainBundlePath stringByAppendingPathComponent:@"0.bundle"]];
    testassert(
       nil != zeroLevelBundle &&
       [[zeroLevelBundle bundlePath] isEqualToString:[mainBundlePath stringByAppendingPathComponent:@"0.bundle"]]
   );
    
    firstLevelBundle = [[NSBundle alloc] initWithPath:[zeroLevelBundle.bundlePath stringByAppendingPathComponent:@"0-0.bundle"]];
    testassert(
       nil != zeroLevelBundle &&
       nil != firstLevelBundle &&
       [[firstLevelBundle bundlePath] isEqualToString:[zeroLevelBundle.bundlePath stringByAppendingPathComponent:@"0-0.bundle"]]
    );
    
    secondLevelBundle = [[NSBundle alloc] initWithPath:[firstLevelBundle.bundlePath stringByAppendingPathComponent:@"0-0-0.bundle"]];
    testassert(
       nil != firstLevelBundle &&
       nil != secondLevelBundle &&
       [[secondLevelBundle bundlePath] isEqualToString:[firstLevelBundle.bundlePath stringByAppendingPathComponent:@"0-0-0.bundle"]]
    );
        
    return YES;
}

- (BOOL)testInvalidNonMainBundleCreation
{
    NSBundle *badZeroLevelBundle = [NSBundle bundleWithPath:@"0.bundle"];
    testassert(nil == badZeroLevelBundle);
    
    NSBundle *badFirstLevelBundle = [NSBundle bundleWithPath:@"0-0.bundle"];
    testassert(nil == badFirstLevelBundle);
    
    NSBundle *badSecondLevelBundle = [NSBundle bundleWithPath:@"0-0-0.bundle"];
    testassert(nil == badSecondLevelBundle);
    
    return YES;
}

- (BOOL)testLocalizedStrings
{
    NSString *localizedString = NSLocalizedString(@"Hello,\n“foo bar.”\n", @"a comment");
    testassert(localizedString != nil);
    testassert([localizedString isEqualToString:@"Hello,\n“foo bar.”\n"]);
    return YES;
}

@end
