//
//  CandleView.m
//  DrawChart
//
//  Created by evan on 15/3/4.
//  Copyright (c) 2015年 evan. All rights reserved.
//

#import "CandleView.h"

#define Y_COUNT 6
#define X_COUNT 6
#define LINE_COUNT 40
#define LEFT_BORDER 50
#define RIGHT_BORDER 20
#define BOTTOM_BORDER 30
#define TOP_BORDER 10

#define PERIOD 35

#define LINE_COLOR [UIColor blackColor]
#define TEXT_COLOR [UIColor whiteColor]
#define RED_COLOR [UIColor redColor]
#define GREEN_COLOR [UIColor greenColor]

@implementation CandleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.y_array = [[NSMutableArray alloc]init];
        self.x_array = [[NSMutableArray alloc]init];
        candleWith = (frame.size.width-LEFT_BORDER-RIGHT_BORDER-2)/LINE_COUNT;//-2是为了去除最左边和最右边的竖线导致的误差
        self.lineCount = LINE_COUNT;
        _curLincCount = _lineCount;
        self.multipleTouchEnabled = YES;
    }

    return self;
}

-(void)drawRect:(CGRect)rect{
    [self createCoordinateData];
    [self drawCoordinate];
    [self drawCandleLine];
}

-(void)setSourceData:(NSArray *)sourceData{
    _sourceData = sourceData;
    
    //默认位置为最后
    self.rangeTo = _sourceData.count;
    self.rangeFrom = self.rangeTo - _lineCount;
}

//组装坐标轴数据
-(void)createCoordinateData{
    if (_sourceData.count <= 0)
        return;
//    _showData = [_sourceData objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(_sourceData.count-_lineCount, _lineCount)]];
    
    [self.y_array removeAllObjects];
    [self.x_array removeAllObjects];
    
    //数组中值的顺序为 时间 开 收 高 低
    yMax = [[[_sourceData objectAtIndex:0]objectAtIndex:3]floatValue];
    yMin = [[[_sourceData objectAtIndex:0]objectAtIndex:4]floatValue];
    for (NSInteger i=self.rangeFrom; i<self.rangeTo; i++) {
        NSArray *arr = [_sourceData objectAtIndex:i];
        float val = [[arr objectAtIndex:3] floatValue];
        if (val > yMax)
            yMax = val;
        val = [[arr objectAtIndex:4] floatValue];
        if (val < yMin)
            yMin = val;
    }
    for (NSInteger i=self.rangeFrom; i<self.rangeTo; i++) {
        NSArray *arr = [_sourceData objectAtIndex:i];
        float val = [[arr objectAtIndex:3] floatValue];
        if (val > yMax)
            yMax = val;
        val = [[arr objectAtIndex:4] floatValue];
        if (val < yMin)
            yMin = val;
    }
    
    //存储y坐标值
    float difference = (yMax - yMin) / (Y_COUNT-1);
    
    for (int i=0; i<Y_COUNT; i++) {
        NSString *y = [NSString stringWithFormat:@"%.2f",yMin+difference*i];
        [_y_array addObject:y];
    }
    //存储x坐标值
    NSString *x = [[_sourceData objectAtIndex:self.rangeFrom]objectAtIndex:0];
    [_x_array addObject:[[x componentsSeparatedByString:@" "] lastObject]];
   
    //如果k线不满屏的话，则x坐标显示的值减少
//    for (int i=1; i<X_COUNT; i++) {
//        x = [[_sourceData objectAtIndex:_lineCount/(X_COUNT-1)*i-1 + self.rangeFrom]objectAtIndex:0];
//        
//        x = [[x componentsSeparatedByString:@" "]lastObject];
//        [_x_array addObject:x];
//    }
    for (int i=X_COUNT-1; i>0; i--) {
        NSInteger index = _lineCount/(X_COUNT-1)*i-1 + self.rangeFrom;
        if (index < _sourceData.count) {
            x = [[_sourceData objectAtIndex:_lineCount/(X_COUNT-1)*i-1 + self.rangeFrom]objectAtIndex:0];
            x = [[x componentsSeparatedByString:@" "]lastObject];
        }else{
            x =@"";
        }

        [_x_array insertObject:x atIndex:1];
    }
}

//组装过去6天，10天，14的平均价格数据
-(void)createMAdata{
    
}

//绘制坐标轴和网格
-(void)drawCoordinate{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    float y_diff = (self.frame.size.height-BOTTOM_BORDER-TOP_BORDER)/(Y_COUNT-1);
    float x_diff = (self.frame.size.width-LEFT_BORDER-RIGHT_BORDER)/(X_COUNT-1);
    for (NSInteger i=0; i<Y_COUNT; i++) {
        //绘制横线
//        CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 0.5);//线条颜色
        [LINE_COLOR setStroke];
        CGContextSetLineWidth(context, 1);
        float y = self.frame.size.height-BOTTOM_BORDER-y_diff*i;
        CGContextMoveToPoint(context, LEFT_BORDER, y);
        CGContextAddLineToPoint(context, self.frame.size.width-RIGHT_BORDER, y);
        CGContextStrokePath(context);
        
        //绘制y值
        UIFont  *font = [UIFont systemFontOfSize:12.0];
        [[self.y_array objectAtIndex:i] drawInRect:CGRectMake(5, y-7.5, LEFT_BORDER-5, 10) withFont:font];
        
        //绘制竖线
        float x = LEFT_BORDER+x_diff*i;
        CGContextMoveToPoint(context, x, self.frame.size.height-BOTTOM_BORDER);
        CGContextAddLineToPoint(context, x, TOP_BORDER);
        CGContextStrokePath(context);

        //绘制x值
        [[self.x_array objectAtIndex:i] drawInRect:CGRectMake(x-15, self.frame.size.height-BOTTOM_BORDER+3, 60, 10) withFont:font];
    }
}

//绘制K线
-(void)drawCandleLine{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    float open,close,high,low;
    float scale = (self.frame.size.height-BOTTOM_BORDER-TOP_BORDER)/(yMax-yMin);//每单位值对应的高度
    for (NSInteger i=0; i<_curLincCount; i++) {
        NSArray *arr = [_sourceData objectAtIndex:i+self.rangeFrom];
        open = [[arr objectAtIndex:1]floatValue];
        close = [[arr objectAtIndex:2]floatValue];
        high = [[arr objectAtIndex:3]floatValue];
        low = [[arr objectAtIndex:4]floatValue];
        
        float y_start = (yMax-high)*scale + TOP_BORDER;
        float y_end;
        //开盘高于收盘，绿色，矩形顶部为开盘价，底部为收盘价
        if (open > close)
            y_end = (yMax-open)*scale + TOP_BORDER;
        else
            y_end = (yMax-close)*scale + TOP_BORDER;
        [LINE_COLOR setStroke];
        CGContextSetLineWidth(context, 1);
        CGFloat x = LEFT_BORDER+1 + (candleWith-1)/2 + candleWith*i;
        if (self.rangeFrom == 0) {
            x = LEFT_BORDER+1 + (candleWith-1)/2 + candleWith*(i+_lineCount-_curLincCount);
        }
        CGContextMoveToPoint(context, x, y_start);
        CGContextAddLineToPoint(context, x, y_end);
        CGContextStrokePath(context);
        
        y_start = y_end;
        if (open > close) {
            [RED_COLOR setFill];
            y_end = (yMax-close)*scale + TOP_BORDER;
        }else{
            [GREEN_COLOR setFill];
            y_end = (yMax-open)*scale + TOP_BORDER;
        }
        x = LEFT_BORDER+1 + candleWith*i;
        if (self.rangeFrom == 0) {
            x = LEFT_BORDER+1 + candleWith*(i+_lineCount-_curLincCount);
        }
        CGContextFillRect(context, CGRectMake(x, y_start, candleWith, (y_end-y_start)));
        CGContextStrokePath(context);
        
        y_start = y_end;
        y_end = (yMax-low)*scale + TOP_BORDER;
        [LINE_COLOR setStroke];
        x = LEFT_BORDER+1 + (candleWith-1)/2 + candleWith*i;
        if (self.rangeFrom == 0) {
            x = LEFT_BORDER+1 + (candleWith-1)/2 + candleWith*(i+_lineCount-_curLincCount);
        }
        CGContextMoveToPoint(context, x, y_start);
        CGContextAddLineToPoint(context, x, y_end);
        CGContextStrokePath(context);
        
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSArray *points = [touches allObjects];
    if (points.count == 1){
        preTouch = [points objectAtIndex:0];
        pre_x = [preTouch locationInView:self].x;
    }else if (points.count == 2){
        preTouch1 = [points objectAtIndex:0];
        preTouch2 = [points objectAtIndex:1];
        pre_x1 = [preTouch1 locationInView:self].x;
        pre_x2 = [preTouch2 locationInView:self].x;
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSArray *points = [touches allObjects];
    if (points.count == 1) {
        UITouch *touch = [points objectAtIndex:0];
        CGFloat distance = [touch locationInView:self].x - pre_x;
        
        [self moveKline:touch Distance:distance];
        
    }else if (points.count == 2){
        [self zoomKline:points];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSArray *points = [touches allObjects];
    if (points.count == 1){
//        preTouch = [points objectAtIndex:0];
//        pre_X = [preTouch locationInView:self].x;
    }else if (points.count == 2){
        
    }
}

-(void)moveKline:(UITouch*)touch Distance:(CGFloat)distance{
    //向右滑动 distance > 0,左划 distance < 0
    CGFloat lineWidth = (self.frame.size.width-LEFT_BORDER-RIGHT_BORDER)/_lineCount;//每根k线的宽度
    NSInteger moveCount = (NSInteger)distance/lineWidth;//移动几根
    if (moveCount != 0) {
        preTouch = touch;
        pre_x = [preTouch locationInView:self].x;
    }
    
    //右侧有空缺的情况
    if (self.rangeTo == _sourceData.count) {
        //向右滑动
        if (moveCount > 0) {
            //移动的根数加上当前显示的根数小于等于满屏的根数
            if (moveCount + _curLincCount <= _lineCount) {
                _curLincCount += moveCount;
                self.rangeFrom = self.rangeTo - _curLincCount;
            }else{
                self.rangeFrom = self.rangeTo - (moveCount + _curLincCount);
                _curLincCount = _lineCount;
                self.rangeTo = self.rangeFrom + _curLincCount;
            }
        }
        //向左移动
        if (moveCount < 0) {
            //移动的根数大于等于当前显示的根数
            if (labs(moveCount) >=  _curLincCount) {
                _curLincCount = 1;
                self.rangeFrom = self.rangeTo - _curLincCount;
            }else{
                _curLincCount -= labs(moveCount);
                self.rangeFrom = self.rangeTo - _curLincCount;
            }
        }
    }
    //左侧有空缺的情况
    if (self.rangeFrom == 0) {
        //向右滑动
        if (moveCount > 0) {
            //移动的根数大于等于当前显示的根数
            if (moveCount >= _curLincCount) {
                _curLincCount = 1;
                self.rangeTo = self.rangeFrom + _curLincCount;
            }else{
                _curLincCount -= moveCount;
                self.rangeTo = self.rangeFrom + _curLincCount;
            }
        }
        //向左移动
        if (moveCount < 0) {
            //动的根数加上当前显示的根数小于等于满屏的根数
            if (labs(moveCount) + _curLincCount <= _lineCount) {
                _curLincCount += labs(moveCount);
                self.rangeTo = self.rangeFrom + _curLincCount;
            }else{
                //                    撒的发生
                self.rangeTo = self.rangeFrom + labs(moveCount) + _curLincCount;
                _curLincCount = _lineCount;
                self.rangeFrom = self.rangeTo - _curLincCount;
            }
        }
    }
    
    if (self.rangeFrom > 0 && self.rangeTo < _sourceData.count) {
        //向右滑动
        if (moveCount > 0) {
            if (moveCount >= self.rangeFrom) {
                self.rangeFrom = 0;
                self.rangeTo -= moveCount;
            }else{
                self.rangeFrom -= moveCount;
                self.rangeTo -= moveCount;
            }
        }
        //向左移动
        if (moveCount < 0) {
            if (self.rangeFrom + labs(moveCount) >= _sourceData.count) {
                self.rangeFrom += labs(moveCount);
                self.rangeTo = _sourceData.count;
                _curLincCount = self.rangeTo - self.rangeFrom;
            }else{
                self.rangeFrom += labs(moveCount);
                self.rangeTo += labs(moveCount);
                if (self.rangeTo > _sourceData.count) {
                    self.rangeTo = _sourceData.count;
                    _curLincCount = self.rangeTo-self.rangeFrom;
                }
            }
        }
    }
    if (self.rangeFrom == 100) {
        NSLog(@"不好");
    }
    if (self.rangeFrom+_curLincCount>100) {
        NSLog(@"不好");
    }
    [self setNeedsDisplay];
}

-(void)zoomKline:(NSArray*)points{
    CGFloat left = [[points objectAtIndex:0]locationInView:self].x;
    CGFloat right = [[points objectAtIndex:1]locationInView:self].x;
}



@end
