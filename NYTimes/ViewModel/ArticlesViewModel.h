//
//  ArticleViewModel.h
//  NYTimes
//
//  Created by Sida Wang on 1/15/17.
//  Copyright © 2017 Sida Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseItemsViewModel.h"
#import "Article.h"

@protocol ArticlesViewModelDelegate
-(void)searchWillStart;
-(void)searchDidFinish;
-(void)updateUI;
-(void)didFinishWithNewItems:(NSArray*) items;
@end

@interface ArticlesViewModel : BaseItemsViewModel
@property (nonatomic, nullable) NSMutableArray<Article*>* articles;
@property (nonatomic, weak, nullable) id<ArticlesViewModelDelegate> delegate;

-(void)searchArticles: (nullable NSTimer*) timer;
-(void)startNewSearchForQuery:(nullable NSString * )q;
-(void)loadNextPage;
-(void) loadNextPageWithHandler: (void(^)(NSArray* items)) handler;
@end

