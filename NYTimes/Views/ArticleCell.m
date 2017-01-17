//
//  ArticleCell.m
//  NYTimes
//
//  Created by Sida Wang on 1/15/17.
//  Copyright © 2017 Sida Wang. All rights reserved.
//

#import "ArticleCell.h"
/*
//!!! calling sequence is:
//nodeForRowAtIndex, constraintedSizeForRow -> in controller for all cells;
//then will call layoutSepcThatFits -> in Cell, so it knows content already;
 
 //!!! tricks: 
 //1. give image a preferred size
 //2. set textNode's style.flexShrink to YES; so it shrink to size that fit the spec
 */

@interface ArticleCell () <ASNetworkImageNodeDelegate>
@end

@implementation ArticleCell

+(NSString*) identifier {
    return NSStringFromClass(self);
}

-(instancetype) init {
    self = [super init];
    if(self) {
         [self setupUI];
    }
    return self;
}

-(ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    CGFloat ratio = (constrainedSize.min.height)/constrainedSize.max.width;
    NSLog(@"%f, %f-> ratio: %f", constrainedSize.min.height, constrainedSize.max.width, ratio);
    ASLayout * layout = [self.headlineLabel layoutThatFits:constrainedSize];
    NSLog(@"Layout: %@", layout);

    ASRatioLayoutSpec *imageRatioSpec = [ASRatioLayoutSpec
                                         ratioLayoutSpecWithRatio:1
                                         child: self.thumbnailView];
    ASStackLayoutSpec* stackSpec = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal spacing:20 justifyContent:ASStackLayoutJustifyContentStart alignItems:ASStackLayoutAlignItemsStart children:@[imageRatioSpec, self.headlineLabel]];
    ASInsetLayoutSpec* stackInset = [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(8, 8, 8, 8) child: stackSpec];
    return stackInset;
}


-(void)setupUI {
    self.thumbnailView = [[ASNetworkImageNode alloc] init];
    self.thumbnailView.style.preferredSize = CGSizeMake(80, 80);
    self.thumbnailView.delegate = self;
    self.thumbnailView.defaultImage = [UIImage imageNamed:@"placeholder"];

    self.headlineLabel  = [[ASTextNode alloc] init];
    self.headlineLabel.style.flexShrink = YES; //!!!This will make textNode auto resizing

    [self addSubnode:self.thumbnailView];
    [self addSubnode:self.headlineLabel];
    
    self.thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
    self.thumbnailView.clipsToBounds = YES;
}

@end

//MARK: NetworkImage delegate

@implementation ArticleCell (ASNetworkImageNodeDelegate)
- (void)imageNode:(ASNetworkImageNode *)imageNode didFailWithError:(NSError *)error {
    NSLog(@"Image failed to load with error: \n%@", error);
}

- (void)imageNode:(ASNetworkImageNode *)imageNode didLoadImage:(UIImage *)image {
    self.thumbnailView.image = image;
}
@end
