//
//  WebServer.h
//  FoundationTests
//
//  Created by Dustin Dettmer on 10/15/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

enum WebServerBehavior {
    WebServerBehaviorNormal,
    WebServerBehaviorSlow,
    WebServerBehaviorPauseInMiddle,
    WebServerBehaviorSlowToClose,
    WebServerBehaviorHangingConnection,
    WebServerRejectInexactUserAgent,
    };

@interface WebServer : NSObject

+ (WebServer*)shared;

@property (nonatomic, assign) enum WebServerBehavior behavior;

@property (nonatomic, readonly) NSString *hostnameString;

@end
