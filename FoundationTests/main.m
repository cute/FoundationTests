//
//  main.m
//  ApportableTests
//
//  Created by George Kulakowski on 8/2/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"
#import "WebServer.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        
        [WebServer shared];
        
        runFoundationTests();
    }

    return 0;
}
