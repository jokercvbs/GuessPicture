//
//  PicQuestion.h
//  猜图游戏
//
//  Created by Li Rui on 16/1/20.
//  Copyright © 2016年 Li Rui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PicQuestion : NSObject

@property(nonatomic,copy)NSString *answer;
@property(nonatomic,copy)NSString *icon;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,strong)NSArray *options;


//实例化方法
-(instancetype)initWithDict:(NSDictionary *)dict;
+(instancetype)questionWithDict:(NSDictionary *)dict;


//返回所有题目数组
+(NSArray *)questions;

/*
 打乱备选文字的数组
 */
-(void)randomOptions;
@end
