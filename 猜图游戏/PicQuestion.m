//
//  PicQuestion.m
//  猜图游戏
//
//  Created by Li Rui on 16/1/20.
//  Copyright © 2016年 Li Rui. All rights reserved.
//

#import "PicQuestion.h"

@implementation PicQuestion

//在成员中，如果给self赋值，只能在initXX方法中进行
/*
    语法约定：
    1.所有的方法首字母小写
    2.当单词切换时，单词首字母大写（驼峰发）
    3.类名要大写
 */

-(instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
        
        //方法二：对备选按钮进行乱序,只在加载的时候做一次乱序，
        [self randomOptions];
    }
    
    return self;
}

+(instancetype)questionWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

+(NSArray *)questions
{
    NSArray *array =[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"questions.plist" ofType:nil]];
    
    NSMutableArray *arrayM =[NSMutableArray array];
    for (NSDictionary *dict in array) {
        
        [arrayM addObject:[self questionWithDict:dict]];
    }
    
    return arrayM;
    
}

-(void)randomOptions
{
    //对option数组乱序
  self.options = [self.options sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString  *obj2) {
        
        int seed = arc4random_uniform(2);
        if (seed) {
            return [obj1 compare:obj1];
        }else{
             return [obj2 compare:obj1];
        }
        
    }];
    NSLog(@"%@",self.options);
}
//对象描述方法，类似于java中的toString()，便于跟踪调试
//如果是自定义的模型，最好编写description方法，可以方便调试。
-(NSString *)description
{
    
    return [NSString stringWithFormat:@"==<%@: %p>{answer:%@,icon:%@,title:%@,options:%@}",self.class,self,self.answer,self.icon,self.title,self.options];
}
@end
