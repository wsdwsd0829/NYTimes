//
//  ViewController.m
//  NYTimes
//
//  Created by Sida Wang on 1/15/17.
//  Copyright © 2017 Sida Wang. All rights reserved.
//

#import "ViewController.h"
#import "DetailController.h"
#import "NetworkService.h"
#import "Article.h"
#import "ArticleCell.h"
#import "Paginator.h"
#import <SDWebImage/UIImageView+WebCache.h>

NSString* const defaultQuery = @"sing";
CGFloat const SearchInterval = 0.7;

@interface ViewController ()
//main items
@property (nonatomic) UITableView* tableView;
@property (nonatomic) id<NetworkServiceProtocol> networkService;
@property (nonatomic) NSMutableArray<Article*>* articles;
//search
@property (nonatomic) UISearchController* searchController;
@property (nonatomic) NSTimer* timer;
@property (nonatomic) Paginator* paginator;
@property (nonatomic) NSString* query;
@property (nonatomic) UIActivityIndicatorView* activityIndicator;
@end

@interface ViewController (TableViewHelper) <UITableViewDelegate, UITableViewDataSource>
@end
@interface ViewController (SearchViewController) <UISearchResultsUpdating>
@end

@implementation ViewController
//MARK: life cycle methods;
- (void)viewDidLoad {
    [super viewDidLoad];
    //table view
    [self setupTableView];
    [self setupBars];

    //prepare for loading data
    self.paginator = [[Paginator alloc] initWithPageNumber:0];
    self.query = defaultQuery;
    self.networkService = [[NetworkService alloc] init];
    [self searchArticles: nil];
}

-(void) setupTableView {
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerClass:[ArticleCell class] forCellReuseIdentifier:[ArticleCell identifier]];
    
    [self.view addSubview: self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    //activity indicator
    CGRect footerRect = CGRectMake(0, 0, self.view.bounds.size.width, 40);
    UIView* footerView = [[UIView alloc] initWithFrame:footerRect];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [footerView addSubview: self.activityIndicator];
    self.activityIndicator.center = footerView.center;
    self.tableView.tableFooterView = footerView;
}

-(void)setupBars {
    //search bar
    self.searchController = [[UISearchController alloc] initWithSearchResultsController: nil];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    //bar button item
    UIBarButtonItem* bbi = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"uparrow"] style:UIBarButtonItemStylePlain target:self action:@selector(scrollToTop)];
    self.navigationItem.rightBarButtonItem = bbi;
    self.searchController.searchResultsUpdater = self;
}
//notification
-(void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kNetworkOfflineToOnline object:nil];
}

-(void)networkChanged:(NSNotification*) notification {
    //will trigger next page loading if necessary
    [self.tableView reloadData];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}
//MARK: search loading and user actions
-(void) scrollToTop {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)searchArticles: (nullable NSTimer*) timer {
    [self searchWillStart];
    NSString* query = [timer.userInfo objectForKey:@"query"];
    if(!query || [query isEqualToString:@""]) {
        query = defaultQuery;
    }
    NSLog(@"Searched Query = %@", query);
    [self.networkService loadArticlesFromQuery: query withHandler:^(NSArray *items, NSError *error) {
        if(!error) {
            [self searchDidFinish];
            self.paginator.pageNumber = 0;
            self.articles = [NSMutableArray arrayWithArray: items];
            [self.tableView reloadData];
        }
    }];
}

-(void) loadNextPage {
    [self searchWillStart];
    self.paginator.pageNumber += 1;
    [self.networkService loadArticlesFromQuery:self.query  withPaginator:self.paginator withHandler:^(NSArray *items, NSError *error) {
        [self searchDidFinish];
        [self.articles addObjectsFromArray:items];
        [self.tableView reloadData];
    }];
}

-(void) searchWillStart {
    [self.activityIndicator startAnimating];
}

-(void) searchDidFinish {
    [self.activityIndicator stopAnimating];
}
@end

//MARK: SearchController
@implementation ViewController (SearchViewController)
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if(searchController == self.searchController) {
        NSLog(@"to search = %@", searchController.searchBar.text);
        NSString* q = searchController.searchBar.text;
        if(q == nil || [q isEqualToString:@""]) {
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
}
@end

//MARK: TableView
@implementation ViewController (TableViewHelper)
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.articles.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[ArticleCell identifier] forIndexPath:indexPath];
    [self configCell:cell forIndexPath:indexPath];
    return cell;
}

-(void) configCell:(UITableViewCell*) aCell forIndexPath:(NSIndexPath*) indexPath {
    if([aCell isKindOfClass: [ArticleCell class]]) {
        ArticleCell* cell = (ArticleCell*) aCell;
        cell.headlineLabel.text = self.articles[indexPath.row].headline;
        [cell.thumbnailView sd_setImageWithURL:[NSURL URLWithString: self.articles[indexPath.row].thumbnailUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        if(indexPath.row == self.articles.count - 5) {
            [self loadNextPage];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    Article* article = self.articles[indexPath.row];
    DetailController* dc = [[DetailController alloc] initWithArticle:article];
    dc.navigationItem.title = article.headline;
    [self.navigationController pushViewController:dc animated:YES];
}
@end

