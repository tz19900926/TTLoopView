//
//  ViewController.m
//  Demo
//
//  Created by TianZhen on 16/4/21.
//  Copyright © 2016年 TianZhen. All rights reserved.
//
#import "TTLoopView.h"

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic,strong) NSArray *titles;
@property (nonatomic,strong) NSArray *images;
@property (weak, nonatomic) IBOutlet TTLoopView *lpView;

@end

@implementation ViewController

#define screenH [UIScreen mainScreen].bounds.size.height
#define screenW [UIScreen mainScreen].bounds.size.width
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // storyBoard创建
    self.lpView.images = self.images;
    
//    // 代码创建
//    TTLoopView *lpView = [TTLoopView LoopViewWithImages:self.images titles:self.titles didSelected:^(NSInteger itemIndex) {
//        NSLog(@"%zd",itemIndex);
//    }];
//    // 添加
//    [self.view addSubview:lpView];
//    // 设置frame或约束
//    lpView.frame = CGRectMake(0, screenH / 3, screenW, screenH / 3);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)images
{
    if (!_images) {
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testimage" ofType:@"jpg"]];
        _images = @[image,image,image];
    }
    return _images;
}

- (NSArray *)titles
{
    if (!_titles) {
        _titles = @[@"第一条信息",@"第二条信息",@"第三条信息"];
    }
    return _titles;
}
@end