//
//  model.h
//  数据存储
//
//  Created by JmoVxia on 2018/6/23.
//  Copyright © 2018年 JmoVxia. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface model : NSObject 

@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)BOOL isVideo;
@property(nonatomic,strong)NSData *date;

@end
