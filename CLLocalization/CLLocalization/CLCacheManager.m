//
//  CLCacheManager.m
//  数据存储
//
//  Created by JmoVxia on 2017/6/23.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import "CLCacheManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <zlib.h>


@interface CLCache ()

/**
 储存
 
 @param data 数据
 @param key 关键词
 */
+ (void)setObject:(NSData*)data forKey:(NSString*)key;

/**
 读取
 
 @param key 关键词
 @return 数据
 */
+ (NSData *)objectForKey:(NSString*)key;


/**
 data转字典
 
 @param data date
 @return 字典
 */
+ (NSDictionary *)dataToDic_Data:(NSData *)data;


/**
 字典转data
 
 @param dic 字典
 @return data
 */
+ (NSData *)dicToData_Dic:(NSDictionary *)dic;

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


@implementation CLCache

+ (BOOL) removeAll {
    return [[NSFileManager defaultManager] removeItemAtPath:[CLCache cacheDirectory] error:nil];
}

+ (BOOL)removeForKey:(NSString *)key{
    NSString *filename = [self.cacheDirectory stringByAppendingPathComponent:key];
    return [[NSFileManager defaultManager] removeItemAtPath:filename error:nil];
}

+ (NSString*) cacheDirectory {
    //储存路径
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    cacheDirectory = [cacheDirectory stringByAppendingPathComponent:@"CLCache"];
    return cacheDirectory;
}

+ (NSData*) objectForKey:(NSString*)key {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filename = [self.cacheDirectory stringByAppendingPathComponent:[key stringByAppendingString:@".cache"]];
    if ([fileManager fileExistsAtPath:filename]){
        NSData *data = [NSData dataWithContentsOfFile:filename];
        return [self decryptWithData:data key:key];
    }else{
        return nil;
    }
}

+ (void) setObject:(NSData*)data forKey:(NSString*)key {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filename = [self.cacheDirectory stringByAppendingPathComponent:[key stringByAppendingString:@".cache"]] ;
    NSLog(@"缓存文件地址------------%@",filename);
    BOOL isDir = YES;
    if (![fileManager fileExistsAtPath:self.cacheDirectory isDirectory:&isDir]) {
        //不是文件夹，创建
        [fileManager createDirectoryAtPath:self.cacheDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSError *error;
    @try {
        //写入文件
        NSData *newData = [self encryptionWithData:data key:key];
        [newData writeToFile:filename options:NSDataWritingAtomic error:&error];
    }
    @catch (NSException * e) {
        //TODO: error handling maybe
    }
}


// data --> dic
+ (NSDictionary *)dataToDic_Data:(NSData *)data {
    if (!data) {
        return nil;
    }
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if (!dic) {
        //解档
        dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return dic;
}

// dic ---> data
+ (NSData *)dicToData_Dic:(NSDictionary *)dic {
    if (!dic) {
        return nil;
    }
    NSData *data;
    if ([NSJSONSerialization isValidJSONObject:dic]) {
        data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    }else {
        //归档
        data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    }
    return data;
}

/**
 加密
 
 @param data 数据
 @param key 关键词
 @return 加密后数据
 */
+ (NSData *)encryptionWithData:(NSData *)data key:(NSString *)key{
    //压缩数据
    NSData *baseData = [[self gzippedDataWithCompressionLevel:0.1f data:data] base64EncodedDataWithOptions:0];
    //转化为字符串
    NSMutableString *baseString = [[NSMutableString alloc]initWithData:baseData encoding:NSUTF8StringEncoding];
    //加盐MD5-32位大写key
    NSString *newKey = [self MD5ForUpper32Bate:key];
    //MD5-32位大写key + MD5-32位小写key + 压缩后数据字符串
    NSString *string = [[newKey stringByAppendingString:[self MD5ForLower32Bate:newKey]] stringByAppendingString:baseString];
    //base64加密
    NSData *newData = [[string dataUsingEncoding:NSUTF8StringEncoding] base64EncodedDataWithOptions:0];
    //转化为字符串
    NSString *newString = [[NSString alloc]initWithData:newData encoding:NSUTF8StringEncoding];
    //MD5-16位大写 + 转化后的字符串 + MD5-16位小写
    NSString *lastString = [[[self MD5ForUpper16Bate:newKey] stringByAppendingString:newString] stringByAppendingString:[self MD5ForLower16Bate:newKey]];
    //返回base64加密数据
    return [[lastString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedDataWithOptions:0];
}

/**
 解密
 
 @param data 数据
 @param key 关键词
 @return 解密后数据
 */
+ (NSData *)decryptWithData:(NSData *)data key:(NSString *)key{
    //解base64数据
    NSData *lastData = [[NSData alloc] initWithBase64EncodedData:data options:0];
    //转化为字符串
    NSString *lastString = [[NSString alloc]initWithData:lastData encoding:NSUTF8StringEncoding];
    //去除MD5-16位大写
    NSString *string = [lastString substringFromIndex:[self MD5ForUpper16Bate:key].length];
    //去除MD5-16位小写
    NSString *newString = [string substringToIndex:(string.length - [self MD5ForLower16Bate:key].length)];
    //解base64数据
    NSData *newData = [[NSData alloc] initWithBase64EncodedData:[newString dataUsingEncoding:NSUTF8StringEncoding] options:0];
    //去除MD5-32位大写key + MD5-32位小写key，得到压缩后的字符串
    NSString *string1 = [[[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding] substringFromIndex:[[self MD5ForUpper32Bate:key] stringByAppendingString:[self MD5ForLower32Bate:key]].length];
    //转化为data
    NSData *data1 = [string1 dataUsingEncoding:NSUTF8StringEncoding];
    return [self gunzippedData:[[NSData alloc] initWithBase64EncodedData:data1 options:0]];
}

/**
 32位 小写
 */
+(NSString *)MD5ForLower32Bate:(NSString *)str{
    
    //要进行UTF8的转码
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return digest;
}

/**
 32位 大写
 */
+(NSString *)MD5ForUpper32Bate:(NSString *)str{
    
    //要进行UTF8的转码
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02X", result[i]];
    }
    
    return digest;
}

/**
 16位 大写
 */
+(NSString *)MD5ForUpper16Bate:(NSString *)str{
    
    NSString *md5Str = [self MD5ForUpper32Bate:str];
    
    NSString  *string;
    for (int i=0; i<24; i++) {
        string=[md5Str substringWithRange:NSMakeRange(8, 16)];
    }
    return string;
}

/**
 16位 小写
 */
+(NSString *)MD5ForLower16Bate:(NSString *)str{
    
    NSString *md5Str = [self MD5ForLower32Bate:str];
    
    NSString  *string;
    for (int i=0; i<24; i++) {
        string=[md5Str substringWithRange:NSMakeRange(8, 16)];
    }
    return string;
}

//MARK:JmoVxia---按等级压缩（0-1）
+ (nullable NSData *)gzippedDataWithCompressionLevel:(float)level data:(NSData *)data{
    if (data.length == 0 || [self isGzippedData:data])
    {
        return data;
    }
    
    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    stream.avail_in = (uint)data.length;
    stream.next_in = (Bytef *)(void *)data.bytes;
    stream.total_out = 0;
    stream.avail_out = 0;
    
    static const NSUInteger ChunkSize = 16384;
    
    NSMutableData *output = nil;
    int compression = (level < 0.0f)? Z_DEFAULT_COMPRESSION: (int)(roundf(level * 9));
    if (deflateInit2(&stream, compression, Z_DEFLATED, 31, 8, Z_DEFAULT_STRATEGY) == Z_OK)
    {
        output = [NSMutableData dataWithLength:ChunkSize];
        while (stream.avail_out == 0)
        {
            if (stream.total_out >= output.length)
            {
                output.length += ChunkSize;
            }
            stream.next_out = (uint8_t *)output.mutableBytes + stream.total_out;
            stream.avail_out = (uInt)(output.length - stream.total_out);
            deflate(&stream, Z_FINISH);
        }
        deflateEnd(&stream);
        output.length = stream.total_out;
    }
    
    return output;
}

+ (nullable NSData *)gzippedData:(NSData *)data {
    return [self gzippedDataWithCompressionLevel:-1.0f data:data];
    
}
//MARK:JmoVxia---解压,默认
+ (nullable NSData *)gunzippedData:(NSData *)data {
    if (data.length == 0 || ![self isGzippedData:data])
    {
        return data;
    }
    
    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.avail_in = (uint)data.length;
    stream.next_in = (Bytef *)data.bytes;
    stream.total_out = 0;
    stream.avail_out = 0;
    
    NSMutableData *output = nil;
    if (inflateInit2(&stream, 47) == Z_OK)
    {
        int status = Z_OK;
        output = [NSMutableData dataWithCapacity:data.length * 2];
        while (status == Z_OK)
        {
            if (stream.total_out >= output.length)
            {
                output.length += data.length / 2;
            }
            stream.next_out = (uint8_t *)output.mutableBytes + stream.total_out;
            stream.avail_out = (uInt)(output.length - stream.total_out);
            status = inflate (&stream, Z_SYNC_FLUSH);
        }
        if (inflateEnd(&stream) == Z_OK)
        {
            if (status == Z_STREAM_END)
            {
                output.length = stream.total_out;
            }
        }
    }
    
    return output;
}
//MARK:JmoVxia---是否是Gzip压缩数据
+ (BOOL)isGzippedData:(NSData *)data {
    const UInt8 *bytes = (const UInt8 *)data.bytes;
    return (data.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b);
}

@end


@implementation CLCacheManager

+ (void)setArray:(NSArray *)array forKey:(NSString *)key
{
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:array, key, nil];
    NSData *data = [CLCache dicToData_Dic:(NSDictionary *)mDic];
    [CLCache setObject:data forKey:key];
}

+ (NSArray *)arrayForKey:(NSString *)key
{
    NSData *data = [CLCache objectForKey:key];
    if (!data) {
        return nil;
    }
    NSDictionary *dic = (NSDictionary *)[CLCache dataToDic_Data:data];
    NSArray *array = [dic objectForKey:key];
    return array;
}

//dic
+ (void)setDic:(NSDictionary *)dic forKey:(NSString *)key
{
    NSData *data = [CLCache dicToData_Dic:dic];
    [CLCache setObject:data forKey:key];
}

+ (NSDictionary *)objectForkey:(NSString *)key {
    NSData *data = [CLCache objectForKey:key];
    if (!data) {
        return nil;
    }
    NSDictionary *dic = [CLCache dataToDic_Data:data];
    return dic;
}

+ (BOOL)removeForKey:(NSString *)key{
    return [CLCache removeForKey:key];
}

+ (BOOL)removeAll{
    return [CLCache removeAll];
}










@end
