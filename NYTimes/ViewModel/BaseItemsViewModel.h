//
//  BaseItemsViewModel.h
//  NYTimes
//
//  Created by Sida Wang on 1/15/17.
//  Copyright © 2017 Sida Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkService.h"
#import "MessageManager.h"


@protocol ViewModelProtocol <NSObject>
@end

@interface BaseItemsViewModel : NSObject
@property (nonatomic) id<NetworkServiceProtocol> networkService;
@property (nonatomic) id<MessageManagerProtocol> messageManager;

-(instancetype) initWithNetworkService: (id<NetworkServiceProtocol>) networkService withMessageManager: (id<MessageManagerProtocol>) messageManager;
-(void) p_handleError:(NSError*)error;


@end
