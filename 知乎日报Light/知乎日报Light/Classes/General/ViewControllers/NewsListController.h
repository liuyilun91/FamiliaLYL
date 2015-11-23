//
//  NewsListController.h
//  知乎日报Light
//
//  Created by 刘奕伦 on 15/11/21.
//  Copyright © 2015年 Yilun Liu. All rights reserved.

#import <UIKit/UIKit.h>
#import "RESideMenu.h"
typedef void(^myBlock)(id block);

@interface NewsListController : UITableViewController

@property (nonatomic, copy) myBlock block;

@end
