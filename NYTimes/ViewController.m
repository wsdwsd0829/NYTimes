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
#import "MessageManager.h"
#import "Article.h"
#import "ArticlesViewModel.h"
#import "ArticleCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ViewController () <ArticlesViewModelDelegate, MessageManagerDelegate>
//main items
@property (nonatomic) UITableView* tableView;
@property (nonatomic) ArticlesViewModel* viewModel;
@property (nonatomic) id<NetworkServiceProtocol> networkService;
//search
@property (nonatomic) UISearchController* searchController;

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
    [self setupNotifications];
    //prepare for loading data
    id<NetworkServiceProtocol> networkService = [[NetworkService alloc] init];
    id<MessageManagerProtocol> messageManager = [[MessageManager alloc] init];
    messageManager.delegate = self;
    self.viewModel = [[ArticlesViewModel alloc] initWithNetworkService:networkService withMessageManager:messageManager];
    [self.viewModel searchArticles: nil];
    self.viewModel.delegate = self;
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
    if(self.viewModel.articles.count == 0) {
        [self.viewModel searchArticles:nil];
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void) scrollToTop {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

//MARK: MessageManagerDelegate
-(void)didClickOk {
    self.searchController.active = false;
}
//MARK: ArticlesViewModelDelegate
-(void)updateUI{
    [self.tableView reloadData];
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
        [self.viewModel startNewSearchForQuery:self.searchController.searchBar.text];
    }
}
@end

//MARK: TableView
@implementation ViewController (TableViewHelper)
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.articles.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[ArticleCell identifier] forIndexPath:indexPath];
    [self configCell:cell forIndexPath:indexPath];
    return cell;
}

-(void) configCell:(UITableViewCell*) aCell forIndexPath:(NSIndexPath*) indexPath {
    if([aCell isKindOfClass: [ArticleCell class]]) {
        ArticleCell* cell = (ArticleCell*) aCell;
        cell.headlineLabel.text = self.viewModel.articles[indexPath.row].headline;
        [cell.thumbnailView sd_setImageWithURL:[NSURL URLWithString: self.viewModel.articles[indexPath.row].thumbnailUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        if(indexPath.row == self.viewModel.articles.count - 5) {
            [self.viewModel loadNextPage];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    Article* article = self.viewModel.articles[indexPath.row];
    DetailController* dc = [[DetailController alloc] initWithArticle:article];
    dc.navigationItem.title = article.headline;
    [self.navigationController pushViewController:dc animated:YES];
}

@end

