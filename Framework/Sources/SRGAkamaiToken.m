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
    
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:tokenServiceURLComponents.URL];
    return [SRGRequest objectRequestWithURLRequest:URLRequest session:session parser:^id _Nullable(NSData * _Nonnull data, NSError * _Nullable __autoreleasing * _Nullable pError) {
        NSDictionary *JSONDictionary = SRGNetworkJSONDictionaryParser(data, pError);
        id tokenDictionary = JSONDictionary[@"token"];
        if (! [tokenDictionary isKindOfClass:NSDictionary.class]) {
            return nil;
        }
        
        NSString *token = [tokenDictionary objectForKey:@"authparams"];
        if (! token) {
            return nil;
        }
        
        // Use components to properly extract the token as query items
        NSURLComponents *tokenURLComponents = [[NSURLComponents alloc] init];
        tokenURLComponents.query = token;
        
        // Build the tokenized URL, merging token components with existing ones
        NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
        
        NSMutableArray *queryItems = [URLComponents.queryItems mutableCopy] ?: [NSMutableArray array];
        if (tokenURLComponents.queryItems) {
            [queryItems addObjectsFromArray:tokenURLComponents.queryItems];
        }
        URLComponents.queryItems = [queryItems copy];
        
        return URLComponents.URL;
    } completionBlock:^(id _Nullable object, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // On failure, just return the untokenized URL, which might be playable as is
        NSHTTPURLResponse *HTTPResponse = [response isKindOfClass:NSHTTPURLResponse.class] ? (NSHTTPURLResponse *)response : nil;
        completionBlock(object ?: URL, HTTPResponse, error);
    }];
}

@end
