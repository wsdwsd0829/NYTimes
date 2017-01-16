//
//  ArticleCell.m
//  NYTimes
//
//  Created by Sida Wang on 1/15/17.
//  Copyright © 2017 Sida Wang. All rights reserved.
//

#import "ArticleCell.h"

@interface ArticleCell ()
@end

@implementation ArticleCell

+(NSString*) identifier {
    return NSStringFromClass(self);
}

//diff from collectionView with is initWithFrame
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.thumbnailView = [[UIImageView alloc] init];
        self.headlineLabel  = [[UILabel alloc] init];
        self.headlineLabel.numberOfLines = 0;
        self.headlineLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        [self.contentView addSubview:self.thumbnailView];
        [self.contentView addSubview:self.headlineLabel];
        self.thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbnailView.clipsToBounds = YES;
        [self setupConstraints];
    }
    return self;
}

-(void) setupConstraints {
    [self.thumbnailView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@80);
        make.height.equalTo(@80);
        //make.
        make.trailing.equalTo(self.headlineLabel.mas_leading).offset(-20);
        make.leading.equalTo(self.contentView.mas_leading).offset(8);
        make.top.equalTo(self.contentView.mas_top).offset(8);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-8).with.priority(900);
        //make.edges.insets(padding);
    }];
    [self.headlineLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-8);
        make.top.equalTo(self.contentView.mas_top).offset(8);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-8);
        make.leading.equalTo(self.thumbnailView.mas_trailing).offset(20);
    }];
}

-(void)updateConstraints {
    [self setupConstraints];
    [super updateConstraints];
}

-(void)layoutSubviews {
    [super layoutSubviews];
}

@end
