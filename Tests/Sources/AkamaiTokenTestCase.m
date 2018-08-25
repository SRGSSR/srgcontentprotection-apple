//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <SRGContentProtection/SRGContentProtection.h>
#import <XCTest/XCTest.h>

static NSString *TestURLParameter(NSURL *URL, NSString *parameter)
{
    NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSURLQueryItem * _Nullable queryItem, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [queryItem.name isEqualToString:@"hdnts"];
    }];
    return [components.queryItems filteredArrayUsingPredicate:predicate].firstObject.value;
}

@interface AkamaiTokenTestCase : XCTestCase

@end

@implementation AkamaiTokenTestCase

#pragma mark Tests

- (void)testTokenizeAkamaiURL
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request ended"];
    
    [[SRGAkamaiToken tokenizeURL:[NSURL URLWithString:@"https://srgssruni1ch-lh.akamaihd.net/i/enc1uni_ch@190951/master.m3u8"] withSession:[NSURLSession sharedSession] completionBlock:^(NSURL * _Nonnull URL, NSHTTPURLResponse * _Nonnull HTTPResponse) {
        XCTAssertNotNil(TestURLParameter(URL, @"hdnts"));
        XCTAssertEqual(HTTPResponse.statusCode, 200);
        [expectation fulfill];
    }] resume];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

- (void)testTokenizeAkamaiURLWithParameters
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request ended"];
    
    [[SRGAkamaiToken tokenizeURL:[NSURL URLWithString:@"https://srgssruni1ch-lh.akamaihd.net/i/enc1uni_ch@190951/master.m3u8&dw=0&__b__=800"] withSession:[NSURLSession sharedSession] completionBlock:^(NSURL * _Nonnull URL, NSHTTPURLResponse * _Nonnull HTTPResponse) {
        XCTAssertNotNil(TestURLParameter(URL, @"hdnts"));
        XCTAssertNotNil(TestURLParameter(URL, @"dw"));
        XCTAssertNotNil(TestURLParameter(URL, @"__b__"));
        XCTAssertEqual(HTTPResponse.statusCode, 200);
        [expectation fulfill];
    }] resume];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

- (void)testTokenizeNonAkamaiURL
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request ended"];
    
    // No specific measure is preventing tokenization of non-Akamai URLs
    [[SRGAkamaiToken tokenizeURL:[NSURL URLWithString:@"http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8"] withSession:[NSURLSession sharedSession] completionBlock:^(NSURL * _Nonnull URL, NSHTTPURLResponse * _Nonnull HTTPResponse) {
        XCTAssertNotNil(TestURLParameter(URL, @"hdnts"));
        XCTAssertEqual(HTTPResponse.statusCode, 200);
        [expectation fulfill];
    }] resume];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

@end
