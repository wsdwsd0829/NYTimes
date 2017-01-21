//
//  ArticleViewModel.m
//  NYTimes
//
//  Created by Sida Wang on 1/21/17.
//  Copyright © 2017 Sida Wang. All rights reserved.
//

#import "ArticleViewModel.h"
@interface ArticleViewModel()
@property (nonatomic) Article* article;
@end
@implementation ArticleViewModel
-(instancetype)initWithArticle:(Article*) article {
    self = [super init];
    if(self) {
        _article = article;
    }
    return self;
}
//-(void) setArticle:(Article *)article {
//    _article = article;
//}
//    
    
@end
