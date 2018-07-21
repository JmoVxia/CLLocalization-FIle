//
//  TestModelA.m
//  CLLocalization
//
//  Created by ios1 on 2018/7/21.
//  Copyright © 2018年 JmoVxia. All rights reserved.
//

#import "TestModelA.h"
#import "MJExtension.h"

@implementation TestModelA

-(instancetype)init {
    if (self = [super init]) {
        self.model = [TestModelB new];
    }
    return self;
}


MJCodingImplementation


@end
