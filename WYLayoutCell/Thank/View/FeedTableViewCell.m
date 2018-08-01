

//
//  FeedTableViewCell.m
//  WYLayoutCell
//
//  Created by 薇谙 on 2018/7/27.
//  Copyright © 2018年 WY. All rights reserved.
//

#import "FeedTableViewCell.h"
#import <Masonry/Masonry.h>


@interface FeedTableViewCell()

@property (nonatomic,strong)UILabel *titleLabel;

@property (nonatomic,strong)UILabel *contentLabel;

@property (nonatomic,strong)UIImageView *contentImageView;

@property (nonatomic,strong)UILabel *usernameLabel;

@property (nonatomic,strong)UILabel *timeLabel;
@end


@implementation FeedTableViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.contentImageView];
    [self.contentView addSubview:self.usernameLabel];
    [self.contentView addSubview:self.timeLabel];    
}

- (void)setSelfDataWithIndexPath:(NSIndexPath *)indexPath feedEntity:(FDFeedEntity *)entity
{
    [self setupSubViews];
    self.titleLabel.text = entity.title;
    self.contentLabel.text = entity.content;
    self.contentImageView.image = entity.imageName.length > 0 ? [UIImage imageNamed:entity.imageName] : nil;
    self.usernameLabel.text = entity.username;
    self.timeLabel.text = entity.time;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat totalHeight = 0;
    totalHeight += [self.titleLabel sizeThatFits:size].height;
    totalHeight += [self.contentLabel sizeThatFits:size].height;
    totalHeight += [self.contentImageView sizeThatFits:size].height;
    totalHeight += [self.usernameLabel sizeThatFits:size].height;
    totalHeight += 40; // margins
    return CGSizeMake(size.width, totalHeight);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)configCurrentViewsWithFrame
{
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(10);
        make.top.equalTo(self.mas_top).with.offset(10);
        make.right.equalTo(self.mas_right).with.offset(-10);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_left).with.offset(0);
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(5);
        make.right.equalTo(self.titleLabel.mas_right).with.offset(0);
    }];
    
    [self.contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_left).with.offset(0);
        make.top.equalTo(self.contentLabel.mas_bottom).with.offset(5);
        make.right.equalTo(self.titleLabel.mas_right).with.offset(0);
    }];
    
    [self.usernameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_left).with.offset(0);
        make.top.equalTo(self.contentImageView.mas_bottom).with.offset(10);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.usernameLabel.mas_top).with.offset(0);
        make.right.equalTo(self.mas_right).with.offset(-10);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self configCurrentViewsWithFrame];
}

#pragma mark --- lazy ---
- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textColor = [UIColor grayColor];
        _contentLabel.font = [UIFont systemFontOfSize:13];
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (UIImageView *)contentImageView
{
    if (!_contentImageView) {
        _contentImageView = [[UIImageView alloc] init];
        
    }
    return _contentImageView;
}

- (UILabel *)usernameLabel
{
    if (!_usernameLabel) {
        _usernameLabel = [[UILabel alloc] init];
        _usernameLabel.font = [UIFont systemFontOfSize:12];
        _usernameLabel.textColor = [UIColor grayColor];
    }
    return _usernameLabel;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor grayColor];
    }
    return _timeLabel;
}


@end
