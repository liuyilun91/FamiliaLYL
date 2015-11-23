//
//  NewsListMode.m
//  知乎日报Light
//
//  Created by 刘奕伦 on 15/11/21.
//  Copyright © 2015年 Yilun Liu. All rights reserved.
//

#import "NewsListMode.h"

@implementation NewsListMode

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.ID = value;
    }
}

@end
