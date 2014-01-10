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
    mainBundlePath = [[[NSBundle mainBundle] bundlePath] copy];
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

- (BOOL)testLocalizedInfoDictionary
{
	NSDictionary *localizedInfoDictionary = [[NSBundle mainBundle] localizedInfoDictionary];
	testassert(localizedInfoDictionary != nil);
	return YES;
}

- (BOOL)testBuiltInPlugInsPath
{
	NSString *builtInPlugInsPath = [[NSBundle mainBundle] builtInPlugInsPath];
	testassert(builtInPlugInsPath != nil);
    testassert([builtInPlugInsPath isEqualToString:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"PlugIns"]]);
	return YES;
}

- (BOOL)testSharedSupportPath
{
	NSString *sharedSupportPath = [[NSBundle mainBundle] sharedSupportPath];
	testassert(sharedSupportPath != nil);
    testassert([sharedSupportPath isEqualToString:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"SharedSupport"]]);
	return YES;
}

- (BOOL)testSharedFrameworksPath
{
	NSString *sharedFrameworksPath = [[NSBundle mainBundle] sharedFrameworksPath];
	testassert(sharedFrameworksPath != nil);
    testassert([sharedFrameworksPath isEqualToString:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"SharedFrameworks"]]);
	return YES;
}

- (BOOL)testPrivateFrameworksPath
{
	NSString *privateFrameworksPath = [[NSBundle mainBundle] privateFrameworksPath];
	testassert(privateFrameworksPath != nil);
    testassert([privateFrameworksPath isEqualToString:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Frameworks"]]);
	return YES;
}

- (BOOL)testAppStoreReceiptURL
{
	NSURL *appStoreReceiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    testassert(appStoreReceiptURL != nil);
    testassert([appStoreReceiptURL isEqual:[[[[[NSBundle mainBundle] bundleURL] URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"StoreKit"] URLByAppendingPathComponent:@"receipt"]]);
	return YES;
}

@end
