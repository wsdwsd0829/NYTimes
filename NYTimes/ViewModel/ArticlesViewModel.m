//
//  ArticleViewModel.m
//  NYTimes
//
//  Created by Sida Wang on 1/15/17.
//  Copyright © 2017 Sida Wang. All rights reserved.
//

#import "ArticlesViewModel.h"
#import "Paginator.h"

NSString* const defaultQuery = @"sing";
CGFloat const SearchInterval = 0.7;

@interface ArticlesViewModel()
@property (nonatomic) Paginator* paginator;
@property (nonatomic) NSTimer* timer;
@property (nonatomic) NSString* query;
@end

@implementation ArticlesViewModel

-(instancetype) initWithNetworkService: (id<NetworkServiceProtocol>) networkService withMessageManager: (id<MessageManagerProtocol>) messageManager {
    self = [super initWithNetworkService:networkService withMessageManager:messageManager];
    if(self) {
        self.paginator = [[Paginator alloc] initWithPageNumber: 0];
        self.query = defaultQuery;
    }
    return self;
}

-(void)searchArticles: (nullable NSTimer*) timer {
    [self.delegate searchWillStart];
    NSString* query = [timer.userInfo objectForKey:@"query"];
    if(!query || [query isEqualToString:@""]) {
        query = defaultQuery;
    }
    NSLog(@"Searched Query = %@", query);
    [self.networkService loadArticlesFromQuery: query withHandler:^(NSArray *items, NSError *error) {
        if(!error) {
            [self.delegate searchDidFinish];
            self.paginator.pageNumber = 0;
            self.articles = [NSMutableArray arrayWithArray: items];
            [self.delegate updateUI];
        } else {
            [self p_handleError: error];
        }
    }];
}

-(void)startNewSearchForQuery:(NSString*)q {
    if(q == nil || [q isEqualToString: @""]) {
        self.query = defaultQuery;
        return;
    }
    if(self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.query = q;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:SearchInterval target:self selector:@selector(searchArticles:) userInfo:@{@"query": self.query} repeats:NO];
}

-(void) loadNextPage {
    [self.delegate searchWillStart];
    self.paginator.pageNumber += 1;
    [self.networkService loadArticlesFromQuery:self.query  withPaginator:self.paginator withHandler:^(NSArray *items, NSError *error) {
        [self.delegate searchDidFinish];
        [self.articles addObjectsFromArray:items];
        [self.delegate updateUI];
    }];
}

@end
