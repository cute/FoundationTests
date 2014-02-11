//
//  ConnectionDelegate.h
//  FoundationTests
//
//  Created by Sean on 12/30/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionDelegate : NSObject<NSURLConnectionDelegate>

@property (nonatomic, retain) NSMutableData *resultData;

@property (nonatomic, retain) NSError *error;

@property (nonatomic, assign) BOOL done;

@property (nonatomic, assign) BOOL didRedirect;

@end
