//
//  ViewController.m
//  CLLocalization
//
//  Created by ios1 on 2018/6/28.
//  Copyright © 2018年 JmoVxia. All rights reserved.
//

#import "ViewController.h"
#import "CLCacheManager.h"
#import "TestModelA.h"
#import "MJExtension.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TestModelA *model = [TestModelA new];
    model.name = @"AAA";
    model.isVideo = YES;
    model.date = [@"testdata" dataUsingEncoding:NSUTF8StringEncoding];
    model.model.name = @"BBB";
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    for (NSInteger i = 0; i <= 100; i++) {
//        [dic setObject:model forKey:[NSString stringWithFormat:@"%ld",(long)i]];
//    }
    dic = model.mj_keyValues;
    [CLCacheManager setDic:dic forKey:@"AAAAAAAA"];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSDictionary *dic = [CLCacheManager objectForkey:@"AAAAAAAA"];
    NSLog(@"%@",dic);
}


@end
