//
//  BBWebViewSSLProtocol.m
//  BBUIExample
//
//  Created by Arron Zhang on 15/3/16.
//  Copyright (c) 2015年 Arron Zhang. All rights reserved.
//

#import "BBWebViewSSLProtocol.h"

static NSString *kRequestUsed = @"requestUsed";
static NSMutableDictionary *kTrustedDomainList = nil;

@implementation BBWebViewSSLProtocol

@synthesize connection;

+(void)load{
    [BBWebViewSSLProtocol registerProtocol];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if (request.URL.host && kTrustedDomainList && kTrustedDomainList[request.URL.host] && [[request.URL.scheme lowercaseString] isEqualToString:@"https"]) {
        if ([NSURLProtocol propertyForKey:kRequestUsed inRequest:request]) {
            return NO;
        }
#ifdef DEBUG_BBUI
        NSLog(@"Truested request to: %@", request.URL.absoluteString);
#endif
        return YES;
    }
    return NO;
}

+ (void)addTrustedDomain:(id)domain{
    if ([domain isKindOfClass:[NSArray class]]) {
        for (NSString *k in domain) {
            kTrustedDomainList[k] = @YES;
        }
    } else if([domain isKindOfClass:[NSString class]]){
        kTrustedDomainList[domain] = @YES;
    }
}
+ (BOOL)isTrustedDomain:(NSString *)domain{
    return kTrustedDomainList[domain]?YES:NO;
}
+ (void)registerProtocol
{
    kTrustedDomainList = [[NSMutableDictionary alloc] init];
    [NSURLProtocol registerClass:[self class]];
}

+ (void)unregisterProtocol
{
    [NSURLProtocol unregisterClass:[self class]];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client
{
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:kRequestUsed inRequest:mutableRequest];
    if(self = [super initWithRequest:mutableRequest cachedResponse:cachedResponse client:client]){
    }
    return self;
}

- (void)startLoading
{
    self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
}

- (void)stopLoading
{
    [self.connection cancel];
    self.connection = nil;
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection{
    return TRUE;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    [[self client] URLProtocol:self didReceiveAuthenticationChallenge: challenge];
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [[self client] URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

#pragma mark -
#pragma mark NSURLConnectionDataDelegate

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse{
    NSMutableURLRequest* req = [request mutableCopy];
    if (redirectResponse)
    {
        [[self client] URLProtocol:self wasRedirectedToRequest:req redirectResponse:redirectResponse];
    }
    return req;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [[self client] URLProtocol:self didLoadData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
    if (cachedResponse)
    {
        [[self client] URLProtocol:self cachedResponseIsValid:cachedResponse];
    }
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[self client] URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[self client] URLProtocol:self didFailWithError:error];
}

@end


