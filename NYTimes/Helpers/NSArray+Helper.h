//
//  NSArray+Helper.h
//  NYTimes
//
//  Created by Sida Wang on 1/15/17.
//  Copyright © 2017 Sida Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Helper)
-(NSArray*)mapObjectsWithBlock: (id(^)(id)) block; //rbp

@end
