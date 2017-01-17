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
#import <AsyncDisplayKit/AsyncDisplayKit.h>

@interface ViewController () <ArticlesViewModelDelegate, MessageManagerDelegate>
//main items
@property (nonatomic) ASTableNode* tableNode;
@property (nonatomic) ArticlesViewModel* viewModel;
@property (nonatomic) id<NetworkServiceProtocol> networkService;
//search
@property (nonatomic) UISearchController* searchController;

@property (nonatomic) UIActivityIndicatorView* activityIndicator;
@end

@interface ViewController (TableViewHelper) <ASTableDelegate, ASTableDataSource>
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
    //[self.viewModel searchArticles: nil]; //batchUpdating Will handle it
    self.viewModel.delegate = self;
}

-(void) setupTableView {
    self.tableNode = [[ASTableNode alloc] init];
    self.tableNode.delegate = self;
    self.tableNode.dataSource = self;
    self.tableNode.frame = self.view.bounds;
    
    [self.view addSubnode: self.tableNode];
    
    //activity indicator
    CGRect footerRect = CGRectMake(0, 0, self.view.bounds.size.width, 40);
    UIView* footerView = [[UIView alloc] initWithFrame:footerRect];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [footerView addSubview: self.activityIndicator];
    self.activityIndicator.center = footerView.center;
    self.tableNode.view.tableFooterView = footerView;
}

-(void)setupBars {
    //search bar
    self.searchController = [[UISearchController alloc] initWithSearchResultsController: nil];
    self.tableNode.view.tableHeaderView = self.searchController.searchBar;
    
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
    [self.tableNode scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

//MARK: MessageManagerDelegate
-(void)didClickOk {
    self.searchController.active = false;
}
//MARK: ArticlesViewModelDelegate
-(void)updateUI{
    [self.tableNode reloadData];
}
-(void)didFinishWithNewItems:(NSArray *)items {
    NSMutableArray* arrIndexPaths = [[NSMutableArray alloc] init];
    NSUInteger count = self.viewModel.articles.count;
    for(__unused Article* item in items) {
        [arrIndexPaths addObject:[NSIndexPath indexPathForRow:count inSection:0]];
        count += 1;
    }
    [self.viewModel.articles addObjectsFromArray: items];
    [self.tableNode insertRowsAtIndexPaths:arrIndexPaths withRowAnimation:UITableViewRowAnimationFade];
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
    if(searchController == self.searchController && self.searchController.searchBar.text.length > 0) {
        [self.viewModel startNewSearchForQuery:self.searchController.searchBar.text];
    }
}
@end

//MARK: TableView
@implementation ViewController (TableViewHelper)

-(NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.articles.count;
}

//-(ASCellNodeBlock)tableNode:(ASTableNode *)tableNode nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return ^{
//        ASTextCellNode* cellNode = [[ASTextCellNode alloc] init];
//        cellNode.text = @"text";
//        return cellNode;
//    };
//}
-(ASCellNode *)tableNode:(ASTableNode *)tableNode nodeForRowAtIndexPath:(NSIndexPath *)indexPath {
    ArticleCell* cellNode = [[ArticleCell alloc] init];
    [self configCell:cellNode forIndexPath:indexPath];
    return cellNode;

}

- (ASSizeRange)tableNode:(ASTableView *)tableView constrainedSizeForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize min = CGSizeMake([UIScreen mainScreen].bounds.size.width, 56);
    CGSize max = CGSizeMake([UIScreen mainScreen].bounds.size.width, INFINITY);
    
    return ASSizeRangeMake(min, max);
}

-(void) configCell:(ASCellNode*) aCell forIndexPath:(NSIndexPath*) indexPath {
    if([aCell isKindOfClass: [ArticleCell class]]) {
        ArticleCell* cell = (ArticleCell*) aCell;
        UIFont *font = [UIFont fontWithName:@"Palatino-Roman" size:24.0];

        NSDictionary *descriptionNodeAttributes = @{NSForegroundColorAttributeName : [UIColor lightGrayColor], NSFontAttributeName: font};
        cell.headlineLabel.attributedText = [[NSAttributedString alloc] initWithString: self.viewModel.articles[indexPath.row].headline attributes:descriptionNodeAttributes];
        NSLog(@"headline: %@", self.viewModel.articles[indexPath.row].headline);
        NSLog(@"attr headline: %@", self.viewModel.articles[indexPath.row].headline);
        cell.thumbnailView.URL = self.viewModel.articles[indexPath.row].articleURL;
    }
}

- (BOOL)shouldBatchFetchForTableNode:(ASTableNode *)tableNode {
    return YES;
}

- (void)tableNode:(ASTableNode *)tableNode willBeginBatchFetchWithContext:(ASBatchContext *)context {
    [self.viewModel loadNextPageWithHandler:^(NSArray *items) {
        [context completeBatchFetching:YES];
    }];
}


-(void)tableNode:(ASTableNode *)tableNode didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableNode deselectRowAtIndexPath:indexPath animated:NO];
    Article* article = self.viewModel.articles[indexPath.row];
    DetailController* dc = [[DetailController alloc] initWithArticle:article];
    dc.navigationItem.title = article.headline;
    [self.navigationController pushViewController:dc animated:YES];
}

@end

