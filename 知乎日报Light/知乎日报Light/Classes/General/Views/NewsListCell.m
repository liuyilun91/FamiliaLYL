//
//  NewsListCell.m
//  知乎日报Light
//
//  Created by 刘奕伦 on 15/11/21.
//  Copyright © 2015年 Yilun Liu. All rights reserved.
//

#import "NewsListCell.h"
#import "UIImageView+WebCache.h"
#define kW [UIScreen mainScreen].bounds.size.width
@implementation NewsListCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setView];
    }
    return self;
}

-(void)setView{
    //设置列表页cell上的图片大小
    self.listCellImage = [[UIImageView alloc]initWithFrame:CGRectMake(kW/4*3-10, 7.5, kW/4, 77)];
    _listCellImage.backgroundColor = [UIColor blackColor];
    [self addSubview:_listCellImage];
    
    
    //设置列表页面label标题大小
    self.listCellTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 7.5, kW/4*3-30, 77)];
    _listCellTitleLabel.backgroundColor = [UIColor whiteColor];
    _listCellTitleLabel.numberOfLines = 0;
    [self addSubview:_listCellTitleLabel];
}

- (void)setModel:(NewsListMode *)model{
    self.listCellTitleLabel.text = model.title;
    //获取图片
    [_listCellImage sd_setImageWithURL:model.images[0]];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
