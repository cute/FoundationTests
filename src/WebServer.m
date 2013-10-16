//
//  WebServer.m
//  FoundationTests
//
//  Created by Dustin Dettmer on 10/15/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "WebServer.h"
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <pthread.h>

static void *webserver_thread(void *ctx);

@implementation WebServer {
    int sock;
    pthread_t thread;
}

+ (WebServer *)shared
{
    static WebServer *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [WebServer new];
    });
    
    return instance;
}

- (id)init
{
    if((self = [super init]))
    {
        sock = socket(AF_INET, SOCK_STREAM, 0);
        
        int res = listen(sock, 10);
        
        NSParameterAssert(res == 0);
        
        pthread_create(&thread, NULL, webserver_thread, (void*)self);
    }
    
    return self;
}

- (NSString *)hostnameString
{
    struct sockaddr_in sin;
    socklen_t len = sizeof(sin);
    
    getsockname(sock, (void*)&sin, &len);
    
    char ip[INET_ADDRSTRLEN];
    
    inet_ntop(AF_INET, &sin.sin_addr, ip, sizeof(ip));
    
    return [NSString stringWithFormat:@"%s:%u", ip, ntohs(sin.sin_port)];
}

- (NSString*)readHeader:(int)sessionSock
{
    NSMutableData *data = [NSMutableData data];
    
    while(1)
    {
        char buf[2048];
        
        int ret = recv(sessionSock, buf, sizeof(buf) - 1, MSG_PEEK);
        
        if(ret < 1)
        {
            return nil;
        }
        
        buf[ret] = '0';
        
        char *res = strstr(buf, "\r\n\r\n");
        
        if(res)
        {
            ret = recv(sessionSock, buf, buf - res + 4, 0);
        }
        else
        {
            ret = recv(sessionSock, buf, ret, 0);
        }
        
        [data appendBytes:buf length:ret];
        
        if(res)
        {
            break;
        }
    }
    
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

- (void)sendHeader:(int)sessionSock length:(int)length
{
    const char *response = "HTTP/1.0 200 OK\r\n"
    "Date: Wed, 16 Oct 2013 03:54:28 GMT\r\n"
    "Expires: -1\r\n"
    "Cache-Control: private, max-age=0\r\n"
    "Content-Type: text/html; charset=ISO-8859-1\r\n"
    "Content-Length: %d\r\n"
    "\r\n";
    
    char buf[2048];
    
    snprintf(buf, sizeof(buf), response, length);
    
    send(sessionSock, buf, strlen(buf), 0);
}

- (NSData*)body
{
    return [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"website" ofType:@"html"]];
}

- (void)handleRequest:(int)sessionSock
{
    NSString *header = [self readHeader:sessionSock];
    
    if(!header)
    {
        return;
    }
    
    NSData *data = [self body];
    
    [self sendHeader:sessionSock length:data.length];
    
    send(sessionSock, data.bytes, data.length, 0);
}

static void *webserver_thread(void *ctx)
{
    WebServer *instance = (WebServer*)ctx;
    
    while(1)
    {
        @autoreleasepool {
            
            int sessionSock = accept(instance->sock, NULL, NULL);
            
            [instance handleRequest:sessionSock];
            
            close(sessionSock);
        }
    }
}

@end
