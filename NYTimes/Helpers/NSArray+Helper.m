//
//  NSArray+Helper.m
//  NYTimes
//
//  Created by Sida Wang on 1/15/17.
//  Copyright © 2017 Sida Wang. All rights reserved.
//

#import "NSArray+Helper.h"

@implementation NSArray (Helper)
-(NSArray*)mapObjectsWithBlock: (id(^)(id)) block {
    __block NSMutableArray *results = [[NSMutableArray alloc] init];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [results addObject: block(obj)];
    }];
    return results;
}
@end
