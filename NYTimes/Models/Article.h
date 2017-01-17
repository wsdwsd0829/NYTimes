//
//  Article.h
//  NYTimes
//
//  Created by Sida Wang on 1/15/17.
//  Copyright © 2017 Sida Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Article : NSObject

@property (nonatomic, readonly, copy) NSString* headline;
@property (nonatomic, readonly, copy) NSString* articleUrl;
@property (nonatomic, copy) NSString* thumbnailUrl;
-(NSURL*) articleURL;
-(instancetype)initWithHeadline:(NSString*) headline withArticleUrl:(NSString*) url;

@end
