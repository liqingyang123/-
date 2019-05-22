//
//  BDExtend.h
//  NJBD
//
//  Created by 柏大韦 on 2017/3/31.
//  Copyright © 2017年 柏大韦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(BDExtend)
/**
 验证NSString是否为空
 
 @return YES or NO
 */
- (BOOL)bd_isValue;

@end

@interface NSData(BDExtend)

/**
 验证NSData是否为空
 
 @return YES or NO
 */
- (BOOL)bd_isValue;

@end

@interface NSObject(BDExtend)

/**
 验证NSString是否为空
 
 @return YES or NO
 */
- (BOOL)bd_isValue;

@end

@interface NSArray(BDExtend)

/**
 验证NSArray是否为空
 
 @return YES or NO
 */
- (BOOL)bd_isValue;

/**
 获取数组中指定索引对应的对象
 @param index 索引值
 @return 对象
 */
- (id)bd_safeObjectAtIndex:(NSUInteger)index;

@end

@interface NSMutableArray (BDExtend)

/**
 添加对象
 @param object object对象
 */
- (void)bd_addObject:(id)object;

/**
 添加一个对象到指定位置
 @param object 对象
 @param index 索引位置
 */
- (void)bd_insertObject:(id)object atIndex:(NSUInteger)index;

@end

@interface NSDictionary(BDExtend)
/**
 验证NSDictionary是否为空
 
 @return YES or NO
 */
- (BOOL)bd_isValue;

/**
 根据key获取int值
 
 @param key key值
 @return int值
 */
- (int)bd_safeIntForKey:(NSString *)key;

/**
 根据key获取BOOL值
 
 @param key key值
 @return bool值
 */
- (BOOL)bd_safeBoolForKey:(NSString *)key;

/**
 根据key获取float值
 
 @param key key值
 @return float值
 */
- (float)bd_safeFloatForKey:(NSString *)key;

/**
 根据key获取double值
 
 @param key key值
 @return double值
 */
- (double)bd_safeDoubleForKey:(NSString *)key;

/**
 根据key值获取long long值
 
 @param key key值
 @return long long值
 */
- (long long)bd_safeLongLongForKey:(NSString *)key;

/**
 根据key获取NSString对象
 
 @param key key值
 @return NSString对象
 */
- (NSString *)bd_safeStringForKey:(NSString *)key;

/**
 根据key获取NSDictionary对象
 
 @param key key值
 @return NSDictionary对象
 */
- (NSDictionary *)bd_safeDictionaryForKey:(NSString *)key;

/**
 根据key获取NSArray对象
 
 @param key key值
 @return NSArray对象
 */
- (NSArray *)bd_safeArrayForKey:(NSString *)key;

/**
 根据key获取Object对象
 
 @param key key值
 @return Object对象
 */
- (id)bd_safeObjectForKey:(NSString *)key;

@end

@interface NSMutableDictionary(BDExtend)

/**
 根据key设置Object对象
 
 @param object Object对象
 @param key key值
 */
- (void)bd_setObject:(id)object Key:(NSString *)key;

@end

@interface NSNumber(NJBD_IsValue)

/**
 验证NSNumber是否为空
 
 @return YES or NO
 */
- (BOOL)bd_isValue;

@end

