#import "FoundationTests.h"

#include <stdio.h>
#import <objc/runtime.h>

#define kBestScore  @"bestScore"
#define kBestStars  @"bestStars"
#define kDetail1    @"detail1"
#define kDetail2    @"detail2"
#define kDetail3    @"detail3"

@interface FooBar : NSObject <NSCoding>
@property (nonatomic, readwrite) float bestScore;
- (id)init;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;
@end

@implementation FooBar
@synthesize bestScore;
- (id)init {
    if ((self = [super init])) {
        self.bestScore = 100.0f;
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {
        self.bestScore = [coder decodeFloatForKey:kBestScore];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeFloat:self.bestScore forKey:kBestScore];
}

@end

@testcase(NSKeyedArchiver)
test(ArchiveLargeKeySize)
{
    const int iters = 253;
    NSMutableArray* foobars = [NSMutableArray arrayWithCapacity:iters];
    for (int i = 0; i < iters; i++) {
        FooBar* foobar = [[[FooBar alloc] init] autorelease];
        [foobars addObject:foobar];
    }

    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    testassert([data length] == 0); // precondition!
    [archiver encodeObject:foobars forKey:@"Archive"];
    [archiver finishEncoding];
    [archiver release];
    testassert([data length] > 0);
    [data release];
    return YES;
}

@end