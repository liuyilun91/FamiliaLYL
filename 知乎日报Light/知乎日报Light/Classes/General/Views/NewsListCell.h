//
//  NewsListCell.h
//  知乎日报Light
//
//  Created by 刘奕伦 on 15/11/21.
//  Copyright © 2015年 Yilun Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NewsListMode.h"

@interface NewsListCell : UITableViewCell

@property (nonatomic,retain)UIImageView *listCellImage;

@property (nonatomic,retain)UILabel * listCellTitleLabel;

@property (nonatomic, retain) NewsListMode *model;

@end
