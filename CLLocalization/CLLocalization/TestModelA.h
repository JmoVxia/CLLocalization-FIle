//
//  TestModelA.h
//  CLLocalization
//
//  Created by ios1 on 2018/7/21.
//  Copyright © 2018年 JmoVxia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TestModelB.h"
@interface TestModelA : NSObject

@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)BOOL isVideo;
@property(nonatomic,strong)NSData *date;
/*newmodel*/
@property (nonatomic, strong) TestModelB *model;

@end
