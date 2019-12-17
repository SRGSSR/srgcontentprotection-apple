//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "Media.h"

@interface Media ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSURL *URL;
@property (nonatomic) NSURL *certificateURL;

@end

@implementation Media

+ (NSArray<Media *> *)mediasFromFileAtPath:(NSString *)filePath
{
    NSArray<NSDictionary *> *mediaDictionaries = [NSDictionary dictionaryWithContentsOfFile:filePath][@"medias"];
    
    NSMutableArray<Media *> *medias = [NSMutableArray array];
    for (NSDictionary *mediaDictionary in mediaDictionaries) {
        Media *media = [[self alloc] initWithDictionary:mediaDictionary];
        if (media) {
            [medias addObject:media];
        }
    }
    return medias.copy;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        self.name = dictionary[@"name"];
        if (! self.name) {
            return nil;
        }
        
        NSString *URLString = dictionary[@"url"];
        self.URL = URLString ? [NSURL URLWithString:URLString] : nil;
        if (! self.URL) {
            return nil;
        }
        
        NSString *certificateURLString = dictionary[@"certificateUrl"];
        self.certificateURL = certificateURLString ? [NSURL URLWithString:certificateURLString] : nil;
    }
    return self;
}

@end
