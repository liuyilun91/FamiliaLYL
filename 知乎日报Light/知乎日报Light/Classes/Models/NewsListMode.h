//
//  NewsListMode.h
//  知乎日报Light
//
//  Created by 刘奕伦 on 15/11/21.
//  Copyright © 2015年 Yilun Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsListMode : NSObject

@property (nonatomic, strong) NSString * ga_prefix;

@property (nonatomic, copy) NSNumber * ID;

@property (nonatomic, strong) NSArray * images;

@property (nonatomic, strong) NSString * share_url;

@property (nonatomic, strong) NSString * title;

@property (nonatomic, copy) NSNumber * type;


@property (nonatomic, strong) NSString * image;
@property (nonatomic, strong) NSString * image_source;
@property (nonatomic, strong) NSString * body;
@property (nonatomic, strong) NSString * date;
@end
