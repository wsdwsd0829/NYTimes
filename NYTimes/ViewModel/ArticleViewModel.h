//
//  ArticleViewModel.h
//  NYTimes
//
//  Created by Sida Wang on 1/21/17.
//  Copyright © 2017 Sida Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Article.h"

@interface ArticleViewModel : NSObject
@property (nonatomic, readonly) Article* article;
-(instancetype)initWithArticle:(Article*) article;
@end
