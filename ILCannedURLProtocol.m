//
//  ILCannedURLProtocol.m
//
//  Created by Claus Broch on 10/09/11.
//  Copyright 2011 Infinite Loop. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted
//  provided that the following conditions are met:
//
//  - Redistributions of source code must retain the above copyright notice, this list of conditions 
//    and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright notice, this list of 
//    conditions and the following disclaimer in the documentation and/or other materials provided 
//    with the distribution.
//  - Neither the name of Infinite Loop nor the names of its contributors may be used to endorse or 
//    promote products derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR 
//  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND 
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY 
//  WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "ILCannedURLProtocol.h"

// Undocumented initializer obtained by class-dump - don't use this in production code destined for the App Store
@interface NSHTTPURLResponse(UndocumentedInitializer)
- (id)initWithURL:(NSURL*)URL statusCode:(NSInteger)statusCode headerFields:(NSDictionary*)headerFields requestTime:(double)requestTime;
@end

static NSData *gILCannedResponseData = nil;
static NSDictionary *gILCannedHeaders = nil;
static NSInteger gILCannedStatusCode = 200;
static NSError *gILCannedError = nil;
static NSArray *gILSupportedMethods = nil;
static NSArray *gILSupportedSchemes = nil;
static NSURL *gILSupportedBaseURL = nil;
static CGFloat gILResponseDelay = 0;

@implementation ILCannedURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
	
	BOOL canInit = (
					(!gILSupportedBaseURL || [request.URL.absoluteString hasPrefix:gILSupportedBaseURL.absoluteString]) &&
					(!gILSupportedMethods || [gILSupportedMethods containsObject:request.HTTPMethod]) &&
					(!gILSupportedSchemes || [gILSupportedSchemes containsObject:request.URL.scheme])
					);
	return canInit;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
	return request;
}

+ (void)setCannedResponseData:(NSData*)data {
	if(data != gILCannedResponseData) {
		[gILCannedResponseData release];
		gILCannedResponseData = [data retain];
	}
}

+ (void)setCannedHeaders:(NSDictionary*)headers {
	if(headers != gILCannedHeaders) {
		[gILCannedHeaders release];
		gILCannedHeaders = [headers retain];
	}
}

+ (void)setCannedStatusCode:(NSInteger)statusCode {
	gILCannedStatusCode = statusCode;
}

+ (void)setCannedError:(NSError*)error {
	if(error != gILCannedError) {
		[gILCannedError release];
		gILCannedError = [error retain];
	}
}

- (NSCachedURLResponse *)cachedResponse {
	return nil;
}

+ (void)setSupportedMethods:(NSArray*)methods {
	if(methods != gILSupportedMethods) {
		[gILSupportedMethods release];
		gILSupportedMethods = [methods retain];
	}
}

+ (void)setSupportedSchemes:(NSArray*)schemes {
	if(schemes != gILSupportedSchemes) {
		[gILSupportedSchemes release];
		gILSupportedSchemes = [schemes retain];
	}
}

+ (void)setSupportedBaseURL:(NSURL*)baseURL {
	if(baseURL != gILSupportedBaseURL) {
		[gILSupportedBaseURL release];
		gILSupportedBaseURL = [baseURL retain];
	}
}


+ (void)setResponseDelay:(CGFloat)responseDelay {
	gILResponseDelay = responseDelay;
}


- (void)startLoading {
    NSURLRequest *request = [self request];
	id<NSURLProtocolClient> client = [self client];
	
	if(gILCannedResponseData) {
		// Send the canned data
		NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[request URL]
																  statusCode:gILCannedStatusCode
																headerFields:gILCannedHeaders 
																 requestTime:0.0];
		
		[NSThread sleepForTimeInterval:gILResponseDelay];
		//NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:gILResponseDelay];
		//[[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:loopUntil];
		
		
		[client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
		[client URLProtocol:self didLoadData:gILCannedResponseData];
		[client URLProtocolDidFinishLoading:self];
		
		[response release];
	}
	else if(gILCannedError) {
		// Send the canned error
		[client URLProtocol:self didFailWithError:gILCannedError];
	}
}

- (void)stopLoading {
}

@end
