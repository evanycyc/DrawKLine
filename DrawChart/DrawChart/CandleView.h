//
//  CandleView.h
//  DrawChart
//
//  Created by evan on 15/3/4.
//  Copyright (c) 2015年 evan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CandleView : UIView{
    float yMax,yMin;        //y轴上的最大值和最小值
    float candleWith;       //每根k线的宽度;
    UITouch *preTouch;      //拖动k线过程中距离当前位置最近的一次的位置
    CGFloat pre_x;          //拖动k线过程中距离当前位置最近的一次的位置的x坐标
    UITouch *preTouch1;     //缩放K线过程中距离最近一次处理时的左侧位置
    UITouch *preTouch2;     //缩放K线过程中距离最近一次处理时的右侧位置
    CGFloat pre_x1;         //缩放K线过程中距离最近一次处理时的左侧位置x坐标
    CGFloat pre_x2;         //缩放K线过程中距离最近一次处理时的右侧位置x坐标
    CGFloat points_distance;     //两个手指间的距离
}

@property(strong, nonatomic)NSArray *sourceData;//源数据
@property(strong, nonatomic)NSMutableArray *x_array;//坐标轴上的x坐标
@property(strong, nonatomic)NSMutableArray *y_array;//坐标轴上的y坐标

@property(assign, nonatomic)NSInteger rangeFrom;
@property(assign, nonatomic)NSInteger rangeTo;

@property(assign)NSInteger lineCount;//满屏显示多少根
@property(assign)NSInteger curLincCount;//当前屏幕要显示多少根

@end
