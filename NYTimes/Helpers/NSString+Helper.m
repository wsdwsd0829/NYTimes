//
//  NSString+Helper.m
//  NYTimes
//
//  Created by Sida Wang on 1/15/17.
//  Copyright © 2017 Sida Wang. All rights reserved.
//

#import "NSString+Helper.h"

@implementation NSString (Helper)
-(NSString*) trimSpace {
    return [self stringByTrimmingCharactersInSet:
     [NSCharacterSet whitespaceCharacterSet]];
}
@end
