//
//  Paginator.m
//  NYTimes
//
//  Created by Sida Wang on 1/15/17.
//  Copyright © 2017 Sida Wang. All rights reserved.
//

#import "Paginator.h"

@implementation Paginator

-(instancetype)initWithPageNumber:(NSUInteger) pageNumber {
    self = [super init];
    if(self) {
        self.pageNumber = pageNumber;
    }
    return self;
}

@end
