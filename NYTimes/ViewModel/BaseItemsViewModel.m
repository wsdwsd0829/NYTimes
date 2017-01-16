//
//  BaseItemsViewModel.m
//  NYTimes
//
//  Created by Sida Wang on 1/15/17.
//  Copyright © 2017 Sida Wang. All rights reserved.
//

#import "BaseItemsViewModel.h"

@implementation BaseItemsViewModel
-(instancetype) initWithNetworkService: (id<NetworkServiceProtocol>) networkService withMessageManager: (id<MessageManagerProtocol>) messageManager {
    self = [super init];
    if(self) {
        self.networkService = networkService;
        self.messageManager = messageManager;
    }
    return self;
}

-(void) p_handleError:(NSError*)error {
    [self.messageManager showError:error];
}

@end
