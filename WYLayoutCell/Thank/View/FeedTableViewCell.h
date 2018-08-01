//
//  FeedTableViewCell.h
//  WYLayoutCell
//
//  Created by 薇谙 on 2018/7/27.
//  Copyright © 2018年 WY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDFeedEntity.h"

@interface FeedTableViewCell : UITableViewCell

- (void)setSelfDataWithIndexPath:(NSIndexPath *)indexPath feedEntity:(FDFeedEntity *)entity;

@end
