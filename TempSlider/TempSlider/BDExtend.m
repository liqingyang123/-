//
//  BDExtend.m
//  NJBD
//
//  Created by 柏大韦 on 2017/3/31.
//  Copyright © 2017年 柏大韦. All rights reserved.
//

#import "BDExtend.h"

@implementation NSString(BDExtend)

- (BOOL)bd_isValue
{
    if (self != nil && ![self isKindOfClass:[NSNull class]] && self.length > 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end

@implementation NSData(BDExtend)

- (BOOL)bd_isValue
{
    if (self != nil && ![self isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    return NO;
}

@end

@implementation NSObject(BDExtend)

- (BOOL)bd_isValue
{
    if (self != nil && ![self isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    return NO;
}

@end

@implementation NSArray(BDExtend)

- (BOOL)bd_isValue
{
    if (self != nil && ![self isKindOfClass:[NSNull class]] && self.count > 0)
    {
        return YES;
    }
    return NO;
}

- (id)bd_safeObjectAtIndex:(NSUInteger)index
{
    if ([self bd_isValue] && index < self.count)
    {
        id value = [self objectAtIndex:index];
        return value;
    }
    return nil;
}

@end

@implementation NSMutableArray (BDExtend)

- (void)bd_addObject:(id)object
{
    if ([object bd_isValue])
    {
        [self addObject:object];
    }
}

- (void)bd_insertObject:(id)object atIndex:(NSUInteger)index
{
    if ([object bd_isValue] && index <= self.count)
    {
        [self insertObject:object atIndex:index];
    }
}

@end

@implementation NSDictionary(BDExtend)

- (BOOL)bd_isValue
{
    if (self != nil && ![self isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    return NO;
}

- (int)bd_safeIntForKey:(NSString *)key
{
    if ([self bd_isValue] && [key bd_isValue])
    {
        id value = [self objectForKey:key];
        if ([value bd_isValue])
        {
            return [value intValue];
        }
    }
    return 0;
}

- (BOOL)bd_safeBoolForKey:(NSString *)key
{
    if ([self bd_isValue] && [key bd_isValue])
    {
        id value = [self objectForKey:key];
        if ([value bd_isValue])
        {
            return [value boolValue];
        }
    }
    return NO;
}

- (float)bd_safeFloatForKey:(NSString *)key
{
    if ([self bd_isValue] && [key bd_isValue])
    {
        id value = [self objectForKey:key];
        if ([value bd_isValue])
        {
            return [value floatValue];
        }
    }
    return 0.0f;
}

- (double)bd_safeDoubleForKey:(NSString *)key
{
    if ([self bd_isValue] && [key bd_isValue])
    {
        id value = [self objectForKey:key];
        if ([value bd_isValue])
        {
            return [value doubleValue];
        }
    }
    return 0.0f;
}

- (long long)bd_safeLongLongForKey:(NSString *)key
{
    if ([self bd_isValue] && [key bd_isValue])
    {
        id value = [self objectForKey:key];
        if ([value bd_isValue])
        {
            return [value longLongValue];
        }
    }
    return 0.0f;
}

- (NSString *)bd_safeStringForKey:(NSString *)key
{
    if ([self bd_isValue] && [key bd_isValue])
    {
        id value = [self objectForKey:key];
        if ([value isKindOfClass:[NSString class]] && [value bd_isValue])
        {
            return [NSString stringWithFormat:@"%@",value];
        }
    }
    return @"";
}

- (NSDictionary *)bd_safeDictionaryForKey:(NSString *)key
{
    if ([self bd_isValue] && [key bd_isValue])
    {
        id value = [self objectForKey:key];
        if ([value isKindOfClass:[NSDictionary class]] && [value bd_isValue])
        {
            return value;
        }
    }
    return nil;
}

- (NSArray *)bd_safeArrayForKey:(NSString *)key
{
    if ([self bd_isValue] && [key bd_isValue])
    {
        id value = [self objectForKey:key];
        if ([value isKindOfClass:[NSArray class]] && [value bd_isValue])
        {
            return value;
        }
    }
    return nil;
}

- (id)bd_safeObjectForKey:(NSString *)key
{
    if ([self bd_isValue] && [key bd_isValue])
    {
        id value = [self objectForKey:key];
        if ([value isKindOfClass:[NSObject class]] && [value bd_isValue])
        {
            return value;
        }
    }
    return nil;
}

@end

@implementation NSMutableDictionary(BDExtend)

- (void)bd_setObject:(id)object Key:(NSString *)key
{
    if ([self bd_isValue] && [object bd_isValue] && [key bd_isValue])
    {
        [self setObject:object forKey:key];
    }
}

@end

@implementation NSNumber(NJBD_IsValue)

- (BOOL)bd_isValue
{
    if (self != nil && ![self isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    return NO;
}

@end
