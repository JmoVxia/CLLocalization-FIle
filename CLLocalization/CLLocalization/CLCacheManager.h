//
//  CLCacheManager.h
//  数据存储
//
//  Created by JmoVxia on 2017/6/23.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLCache : NSObject

@end

@interface CLCacheManager : NSObject

/**
 储存数组
 
 @param array 数组
 @param key 关键词
 */
+ (void)setArray:(NSArray *)array forKey:(NSString *)key;

/**
 读取数组
 
 @param key 关键词
 @return 数组
 */
+ (NSArray *)arrayForKey:(NSString *)key;

/**
 储存字典
 
 @param dic 字典
 @param key 关键词
 */
+ (void)setDic:(NSDictionary *)dic forKey:(NSString *)key;

/**
 读取字典
 
 @param key 关键词
 @return 字典
 */
+ (NSDictionary *)objectForkey:(NSString *)key;


/**
 根据关键词删除

 @param key 关键词
 @return 是否删除成功
 */
+ (BOOL)removeForKey:(NSString *)key;

/**
 删除所有
 
 @return 删除是否成功
 */
+ (BOOL)removeAll;

@end
