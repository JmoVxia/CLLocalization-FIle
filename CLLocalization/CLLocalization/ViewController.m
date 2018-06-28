//
//  ViewController.m
//  CLLocalization
//
//  Created by ios1 on 2018/6/28.
//  Copyright © 2018年 JmoVxia. All rights reserved.
//

#import "ViewController.h"
#import "CLCacheManager.h"
#import "model.h"
#import "MJExtension.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    model *aa = [model new];
    aa.name = @"AAA";
    aa.isVideo = YES;
    aa.date = [@"testdata" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
//    NSDictionary *ddd = [aa mj_keyValues];
    
    for (NSInteger i = 0; i <= 10000; i++) {
        
        [dic setObject:aa forKey:[NSString stringWithFormat:@"%ld",(long)i]];
    }
    NSLog(@"------------------------------");
    [CLCacheManager setDic:dic forKey:@"AA"];
    NSLog(@"------------------------------");

    NSLog(@"%@",NSHomeDirectory());
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSDictionary *dic = [CLCacheManager objectForkey:@"AA"];
    NSLog(@"%@",dic);
}


@end
