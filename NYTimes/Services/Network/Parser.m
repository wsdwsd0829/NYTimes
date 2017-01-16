//
//  PhotoParser.m
//  FlickrDemo
//
//  Created by Sida Wang on 12/25/16.
//  Copyright © 2016 Sida Wang. All rights reserved.
//

#import "Parser.h"
#import "Article.h"

NSString* const ImageHostUrl = @"http://www.nytimes.com/";
@implementation Parser

-(void)parse:(id)responseObject withHandler:(void (^)(NSArray *, NSError *))handler {
    [self parseToItemsWith:responseObject withHandler:handler];
}

-(void)parseToItemsWith: (id) responseObject withHandler: (void(^)(NSArray* items, NSError* error)) handler {
    NSMutableArray* results = [NSMutableArray new];
    if(![responseObject isKindOfClass: [NSDictionary class]]) {
        return;
    }
    NSDictionary* responseObjects = responseObject; //[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&serialError];

    if(![[responseObjects objectForKey: @"status"] isEqualToString:@"OK"]) {
        return;
    }
    NSArray* objs = [[responseObjects objectForKey: @"response"] objectForKey: @"docs"];
    if(objs != nil && [objs isKindOfClass: [NSArray class]] && objs.count > 0) {
        for(id obj in objs) {
            @autoreleasepool {
                NSString* headline = [[obj objectForKey: @"headline"] objectForKey: @"main"];
                NSArray* components = [[headline componentsSeparatedByString: @";"] mapObjectsWithBlock: ^(NSString* obj){
                    return [obj trimSpace];
                }];
                
                NSString* newHeadline = [components componentsJoinedByString: @"\n"];
                NSString* webUrl = [obj objectForKey: @"web_url"];
                if(headline && webUrl) {
                    Article* result = [[Article alloc] initWithHeadline: newHeadline  withArticleUrl:webUrl];
                    //try get thumbnail
                    result.thumbnailUrl = [self thumbnailUrlFrom:obj];
                    
                    [results addObject:result];
                }
            }
        }
    }
    
    if(results.count > 0) {
        handler(results, nil);
    } else {
        NSError* err = [NSError errorWithDomain:kErrorDomainParse code:ErrorParseFailed userInfo: @{kErrorDisplayUserInfoKey: @"Fail to parse profiles"}];
        handler(nil, err);
    }
}

-(NSString*) thumbnailUrlFrom: (NSDictionary*) obj {
    NSArray* medias = [obj objectForKey: @"multimedia"];
    for(id media in medias) {
        NSString* url = [media objectForKey: @"url"];
        if(url) {
            return [NSString stringWithFormat: @"%@%@", ImageHostUrl, url];
        }
    }
    return nil;
}
@end
