//
//  ArticleCell.h
//  NYTimes
//
//  Created by Sida Wang on 1/15/17.
//  Copyright © 2017 Sida Wang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ArticleCell : UITableViewCell
@property (nonatomic) NSString* headline;
@property (nonatomic) NSString* thumbnailUrl;
+(NSString*) identifier;
-(void)updateUI;
@end
