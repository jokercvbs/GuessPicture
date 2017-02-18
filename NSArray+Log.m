//
//  NSArray+Log.m
//  猜图游戏
//
//  Created by Li Rui on 16/1/20.
//  Copyright © 2016年 Li Rui. All rights reserved.
//

#import "NSArray+Log.h"

@implementation NSArray (Log)

-(NSString *)descriptionWithLocale:(nullable id)locale
{
    NSMutableString *strM=[NSMutableString stringWithString:@"(\n"];
    
    for (id obj in self) {
        
        [strM appendFormat:@"\t%@,\n",obj];
    }
    
    [strM appendString:@")\n"];
    
    return strM;
}
@end
