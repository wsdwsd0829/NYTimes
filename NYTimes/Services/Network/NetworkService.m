//
//  NetworkManager.m
//  Created by Sida Wang on 12/25/16.
//  Copyright © 2016 Sida Wang. All rights reserved.
//
#import "ApiClientProtocol.h"
#import "ParserProtocol.h"
#import "Reachability.h"
#import "NetworkService.h"
#import "ApiClient.h"
#import "Parser.h"
#import "Paginator.h"

NSString* const APIKey = @"60aeaeae7fff4477958cfe2a8a6a76f5";

typedef NS_ENUM(NSUInteger, NYTimesAPI) {
 Article
};

@interface NetworkService () {
    id<ApiClientProtocol> apiClient;
    id<ParserProtocol> parser;
    Reachability* reachability;
}
@end

@implementation NetworkService

- (instancetype)init
{
    self = [super init];
    if (self) {
        apiClient = [ApiClient defaultClient];
        parser = [[Parser alloc] init]; //? can this be singeton, can I just use static method to parse data
        
        //setup reachability
        reachability = [Reachability reachabilityForInternetConnection];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kReachabilityChangedNotification object:nil];
        [reachability startNotifier];
        [self networkChanged:nil];
        
    }
    return self;
}

-(void)loadImageWithUrlString: (NSString*) urlString withHandler:(void(^)(NSData* data, NSError* error))handler{
    //GCD or Operation
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString: urlString]];
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(imageData);
        });
    });
     */
    [apiClient fetchWithUrlString:urlString withHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        handler(responseObject, error);
    }];
}

-(void)loadArticlesFromQuery:(NSString*) query withPaginator:(Paginator*) paginator  withHandler: (NetworkResultHandler)handler {
    NSString* pageNumber = [NSString stringWithFormat: @"%lu", (unsigned long)paginator.pageNumber];
    [self loadArticlesFromQuery:query forPage:pageNumber withHandler: handler];
}

-(void)loadArticlesFromQuery:(NSString*) query  withHandler: (NetworkResultHandler)handler {
    [self loadArticlesFromQuery:query forPage: @"0" withHandler: handler];
}

-(void)loadArticlesFromQuery:(NSString*) query forPage:(NSString*) page  withHandler: (NetworkResultHandler)handler {
    NSDictionary* params = @{@"q": query, @"page": page, @"api-key": APIKey};
   // [self.apiClient fetchWithParams: params withApi: apiUrl withHandler:(HttpHandler)
    [apiClient fetchWithParams:params withApi: [self p_apiStr: Article] withHandler: ^(NSURLResponse *response, id responseObject, NSError *error) {
        if (!error && ((NSHTTPURLResponse*)response).statusCode == 200) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //Parse result in background thread
                [parser parse: responseObject withHandler: ^(NSArray* items, NSError* error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        handler(items, error);
                    });
                    //!!!cannot increase page num here cause, same page may load multiple times
                }];
            });
            
        } else {
            // if status Code 401, need re-auth;
            handler(nil, error);
        }
    }];
}

//MARK: ReactiveCocoa
-(RACSignal*)loadArticlesFromQuery:(NSString*) query withPaginator:(Paginator*) paginator {
    NSString* pageNumber = [NSString stringWithFormat: @"%lu", (unsigned long)paginator.pageNumber];
    return [self loadArticlesFromQuery:query forPage:pageNumber];
}
    
-(RACSignal*)loadArticlesFromQuery:(NSString*) query {
    return [self loadArticlesFromQuery:query forPage: @"0"];
}
-(RACSignal*)loadArticlesFromQuery:(NSString*) query forPage:(NSString*) page {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSDictionary* params = @{@"q": query, @"page": page, @"api-key": APIKey};
        // [self.apiClient fetchWithParams: params withApi: apiUrl withHandler:(HttpHandler)
        [apiClient fetchWithParams:params withApi: [self p_apiStr: Article] withHandler: ^(NSURLResponse *response, id responseObject, NSError *error) {
            if (!error && ((NSHTTPURLResponse*)response).statusCode == 200) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    //Parse result in background thread
                    [parser parse: responseObject withHandler: ^(NSArray* items, NSError* error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //handler(items, error);
                            if(!error) {
                                [subscriber sendNext:items];
                                [subscriber sendCompleted];
                            } else {
                                [subscriber sendError:error];
                            }
                        });
                        //!!!cannot increase page num here cause, same page may load multiple times
                    }];
                });
                
            } else {
                // if status Code 401, need re-auth;
                [subscriber sendError:error];
            }
        }];
        return nil;
    }];
}
    
-(NSString*)p_apiStr:(NYTimesAPI) api {
    switch (api) {
        case Article:
            return @"svc/search/v2/articlesearch.json";
            break;
    }
}

//Mark: Reachability Protocol
-(void)networkChanged:(NSNotification*) notification {
    if(notification == nil) {
        if([reachability currentReachabilityStatus] == NotReachable) {
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"kNotReachable"];
        }
        return;
    }
    Reachability* reach = notification.object;
    if([reach currentReachabilityStatus] == ReachableViaWiFi || [reach currentReachabilityStatus] == ReachableViaWWAN) {
        NSString* isFromNotReachable = [[NSUserDefaults standardUserDefaults] stringForKey:@"kNotReachable"];
        if([isFromNotReachable isEqualToString:@"YES"]) {
            [self networkChangedFromOfflineToOnline:notification];
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"kNotReachable"];
        }
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"kNotReachable"];
    }
}

-(void)networkChangedFromOfflineToOnline:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkOfflineToOnline object: notification.object];
}

-(void)dealloc {
    [reachability stopNotifier];
}
@end
