//
//  NSFileHandleTests.m
//  FoundationTests
//
//  Created by Paul Beusterien on 10/12/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSFileHandle)


- (BOOL)testNSFileHandleWriteRead
{
    NSString *filename = @"testNSFileHandle";
    NSData *data = [NSData dataWithBytes:"abc" length:3];
    
    NSFileHandle *f = [NSFileHandle fileHandleForWritingAtPath: [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@", filename]];
    
    if (f == nil)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@", filename] error:nil];
        testassert(YES); // Should have been deleted by previous run
    }
    
    [[NSFileManager defaultManager] createFileAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@", filename] contents:nil attributes:nil];
    f = [NSFileHandle fileHandleForWritingAtPath: [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@", filename]];
    
    testassert(f != nil);

    [f writeData:data];
    [f closeFile];
    
    NSData *checkData = [NSData dataWithContentsOfFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@", filename]];
    
    testassert([checkData isEqualToData:data]);
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@", filename] error:&error];
    testassert(error == nil);
    
    return YES;
}

@end
