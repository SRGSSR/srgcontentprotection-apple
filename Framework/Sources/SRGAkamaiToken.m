//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGAkamaiToken.h"

static NSString * const SRGTokenServiceURLString = @"https://tp.srgssr.ch/akahd/token";

@interface SRGAkamaiToken ()

@property (nonatomic) NSURLSession *session;

@end

@implementation SRGAkamaiToken

#pragma mark Class methods

+ (SRGRequest *)tokenizeURL:(NSURL *)URL withSession:(NSURLSession *)session completionBlock:(nonnull void (^)(NSURL * _Nonnull, NSHTTPURLResponse * _Nonnull, NSError * _Nullable))completionBlock
{
    NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    NSString *acl = [URLComponents.path.stringByDeletingLastPathComponent stringByAppendingPathComponent:@"*"];
    
    NSURLComponents *tokenServiceURLComponents = [NSURLComponents componentsWithURL:[NSURL URLWithString:SRGTokenServiceURLString] resolvingAgainstBaseURL:NO];
    tokenServiceURLComponents.queryItems = @[ [NSURLQueryItem queryItemWithName:@"acl" value:acl] ];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:tokenServiceURLComponents.URL];
    return [SRGRequest JSONDictionaryRequestWithURLRequest:request session:session completionBlock:^(NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *HTTPResponse = [response isKindOfClass:NSHTTPURLResponse.class] ? (NSHTTPURLResponse *)response : nil;
        
        NSString *token = nil;
        id tokenDictionary = JSONDictionary[@"token"];
        if ([tokenDictionary isKindOfClass:NSDictionary.class]) {
            token = [tokenDictionary objectForKey:@"authparams"];
        }
        
        // On failure, just return the untokenized URL, which might be playable as is
        if (! token) {
            completionBlock(URL, HTTPResponse, error);
            return;
        }
        
        // Use components to properly extract the token as query items
        NSURLComponents *tokenURLComponents = [[NSURLComponents alloc] init];
        tokenURLComponents.query = token;
        
        // Build the tokenized URL, merging token components with existing ones
        NSURLComponents *tokenizedURLComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
        
        NSMutableArray *queryItems = [tokenizedURLComponents.queryItems mutableCopy] ?: [NSMutableArray array];
        if (tokenURLComponents.queryItems) {
            [queryItems addObjectsFromArray:tokenURLComponents.queryItems];
        }
        tokenizedURLComponents.queryItems = [queryItems copy];
        
        completionBlock(tokenizedURLComponents.URL, HTTPResponse, error);
    }];
}

@end
