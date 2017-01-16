//
//  FlickrNetworkServiceProtocol.h
//  FlickrDemo
//
//  Created by Sida Wang on 12/26/16.
//  Copyright © 2016 Sida Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Paginator.h"

typedef void(^NetworkResultHandler)(NSArray* items, NSError* error);

@protocol NetworkServiceProtocol <NSObject>

-(void)loadImageWithUrlString: (NSString*) urlString withHandler:(void(^)(NSData* data, NSError* error))handler;
-(void)loadArticlesFromQuery:(NSString*) query withHandler: (NetworkResultHandler)handler;
-(void)loadArticlesFromQuery:(NSString*) query forPage:(NSString*) page  withHandler: (NetworkResultHandler)handler;

-(void)loadArticlesFromQuery:(NSString*) query withPaginator:(Paginator*) paginator  withHandler: (NetworkResultHandler)handler;
@end
