//
//  Article.m
//  NYTimes
//
//  Created by Sida Wang on 1/15/17.
//  Copyright © 2017 Sida Wang. All rights reserved.
//

#import "Article.h"

@implementation Article

-(instancetype)initWithHeadline:(NSString*) headline withArticleUrl:(NSString*) url {
    self = [super init];
    if (self) {
        _articleUrl = url;
        _headline = headline;
    }
    return self;
}



@end
