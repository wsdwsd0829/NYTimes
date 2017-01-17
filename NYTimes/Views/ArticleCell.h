//
//  ArticleCell.h
//  NYTimes
//
//  Created by Sida Wang on 1/15/17.
//  Copyright © 2017 Sida Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>

@interface ArticleCell : ASCellNode

@property (nonatomic) ASNetworkImageNode* thumbnailView;
@property (nonatomic) ASTextNode* headlineLabel;
+(NSString*) identifier;

@end
