//
//  ViewController.m
//  DrawChart
//
//  Created by evan on 15/3/4.
//  Copyright (c) 2015年 evan. All rights reserved.
//

#import "ViewController.h"
#import "CandleView.h"

@interface ViewController (){
    CandleView *candle;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated{
    NSDictionary *dict = [[NSDictionary alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]];
    NSMutableArray *array = [dict objectForKey:@"data"];
    candle = [[CandleView alloc]initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 300)];
    candle.sourceData = [array objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(array.count-100, 100)]];
    [self.view addSubview:candle];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10, self.view.frame.size.height-100, 60, 30);
    [btn setTitle:@"绘制" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor lightGrayColor];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

-(void)btnClick{
    [candle setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
