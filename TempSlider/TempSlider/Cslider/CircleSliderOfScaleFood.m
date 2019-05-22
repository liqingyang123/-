//
//  CircleChooseSlider.m
//  OutdoorChef
//
//  Created by 李青阳 on 2019/1/28.
//  Copyright © 2019年 mac. All rights reserved.
//

#import "CircleSliderOfScaleFood.h"
#import "XMCircleTypeView.h"
#import "BaseDefine.h"

#define ToRad(deg)        ((M_PI * (deg)) / 180.0 )
#define ToDeg(rad)        ((180.0 * (rad)) / M_PI )
#define SQR(x)            ((x) * (x))

@interface CircleSliderOfScaleFood()
{
    /* 不需要改变 */
    double radiusChoose; // 外环半径
    double radiusSlider; // 内环半径
    double lineChooseWidth;   // 外环边宽
    double lineSliderWidth;   // 内环边宽
    double circleSliderWidth; // 滑块边宽
    /* 需传递过来的参数 */
    // 一种类型封装一个滑杆，否则代码量带大，可读性下降
    NSInteger *sliderType;     // 0:外环是几分熟温度  1:外环是建议温度具体值  2: 外环是建议温度范围(1,2可归为一类)
    NSArray *scaleTempArry;    // 几分熟对应温度数组 (type为0)
    NSArray *recommendTempArry;// 建议温度数组(type为1时,元素为1个.type为2时,元素有2个.)
    CGFloat minTemp,maxTemp;   // 温度 min,max
    /* 需要改变 */
    int angle;                     // 实心圆滑块角度（自定义温度时，动态改变angle，绘制滑块位置）
    NSMutableArray *scaleAngleArry;// 存储几分熟温度/建议温度对应的角度，便于规定响应的角度区域（向两边扩散 20 度）
    int currentChooseTempIndex;    // 当前选择几分熟温度/建议温度的数组索引 (-1:代表自定义温度，此时使用 angle 绘制滑块位置)
    NSMutableArray *xmArry;        // 存储环形字体view
    UITextField *tempfield;//现在不确定温度是否可输入
    UILabel *tempLabel;
    UILabel *rangeLabel;
    
    // 重复 remove 和 add
    // 不重复 remove 和 add 都是可以的，但 layer 的 path 要一直是改变的
    CAShapeLayer *sliderShaperLayer;// 滑块 layer
    CAShapeLayer *chooseShaperLayer;// 选中外环 layer
    
    BOOL isCustom;   //是否自选温度
    BOOL isCustomCircleTextShow;// CUSTOMIZED 环形文字是否显示
    BOOL isSSD;      //是否是摄氏度 (否则为华氏度) 1 摄氏度 = 33.8 华氏度
    int currentTemp; //当前温度（摄氏度），便于切换温度类型时直接计算，否则只能根据angle计算
}
@end
@implementation CircleSliderOfScaleFood

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
       
        lineChooseWidth = kHeight(25);
        lineSliderWidth = kHeight(3);
        circleSliderWidth = 6*lineSliderWidth;
        // 圆环的边 是在圆环上向圆内外绘制 lineWidth/2 的边
        radiusChoose = (self.boundsWidth-lineChooseWidth)/2 - kHeight(10);
        radiusSlider = radiusChoose - kHeight(30);
        
        // 动态参数(后续需要传递过来)
        minTemp = 46;
        maxTemp = 70;
        sliderType = 0;
        scaleTempArry = @[@(48),@(54),@(60),@(65),@(68)];// 绿圈对应温度
        recommendTempArry = @[@(60)];
        
        //
        scaleAngleArry = [[NSMutableArray alloc]init];
        xmArry = [[NSMutableArray alloc] init];
        angle = 120;
        isCustom = NO; // 默认不是自定义温度
        isCustomCircleTextShow = NO;
        isSSD = YES;   // 默认温度类型为-摄氏度
        if(sliderType == 0){
            for(int i=0;i<[scaleTempArry count];i++){
                int temp = [[scaleTempArry objectAtIndex:i] intValue];
                int scaleAngle =  (int)roundf((float)((temp - minTemp) / (maxTemp - minTemp)) * 300);
                // 根据温度，确定角度
                scaleAngle +=  120;
                if(scaleAngle >= 360){
                    scaleAngle -= 360;
                }
                // 将温度对应的角度添加进数组，方便绘制选中时外环
                [scaleAngleArry addObject:@(scaleAngle)];
            }
            // 默认选中的温度下标
            currentChooseTempIndex = 2;
           
        }
        else{
            for(int i=0;i<[recommendTempArry count];i++){
                int temp = [[recommendTempArry objectAtIndex:i] intValue];
                int scaleAngle =  ((temp - minTemp) / (maxTemp - minTemp)) * 300;
                // 根据温度，确定角度
                scaleAngle +=  120;
                if(scaleAngle >= 360){
                    scaleAngle -= 360;
                }
                // 将温度对应的角度添加进数组，方便绘制选中时外环
                [scaleAngleArry addObject:@(scaleAngle)];
            }
            // 默认选中的温度下标
            currentChooseTempIndex = 1;
        }
        [self addChildView];
        [self setChooseBgPath];     //绘制外环
        [self setChooseStatusPath]; //绘制选中外环
        [self setSliderBgPath];     //绘制内环
        [self setGreenArc];         //绘制小绿圈
        [self setArcSlider];        //绘制实心圆滑块
        
    }
    return self;
}
-(void)addChildView{
    {//添加 中间的显示温度的 textfield
        CGFloat fieldheight = self.boundsHeight / 3;
        CGFloat fieldwidth = self.boundsHeight / 2;
//        tempfield = [[UITextField alloc] initWithFrame:CGRectMake((self.boundsWidth-fieldwidth)/2, (self.boundsHeight-fieldheight)/2, fieldwidth, fieldheight)];
//        [tempfield setTextAlignment:NSTextAlignmentCenter];
//        [tempfield setKeyboardType:UIKeyboardTypeNumberPad];
//        [tempfield setFont:kFont(20)];
//        [self addSubview:tempfield];
        
        tempLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.boundsWidth-fieldwidth)/2, (self.boundsHeight-fieldheight)/2, fieldwidth, fieldheight)];
        [tempLabel setTextAlignment:NSTextAlignmentCenter];
        [tempLabel setFont:kFontBold(30)];
        [tempLabel setTextColor:kDarkGray];
        //[tempLabel setBackgroundColor:[UIColor redColor]];
        [self addSubview:tempLabel];
    }
    
    {
        CGFloat lbWidth = kHeight(40);
        UILabel *minLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.boundsWidth-(2*lbWidth+kHeight(20)))/2, tempLabel.frameY+tempLabel.boundsHeight+kHeight(30), lbWidth, lbWidth)];
        [minLabel setText:@"MIN"];
        [minLabel setFont:kFont(13)];
        //[minLabel setBackgroundColor:[UIColor blueColor]];
        [minLabel setTextAlignment:NSTextAlignmentCenter];
        [minLabel setTextColor:[UIColor grayColor]];
        [self addSubview:minLabel];
        
        UILabel *maxLabel = [[UILabel alloc] initWithFrame:CGRectMake(minLabel.frameX+minLabel.boundsWidth+kHeight(20), minLabel.frameY, lbWidth, lbWidth)];
        [maxLabel setText:@"MAX"];
        [maxLabel setFont:kFont(13)];
        //[maxLabel setBackgroundColor:[UIColor blueColor]];
        [maxLabel setTextAlignment:NSTextAlignmentCenter];
        [maxLabel setTextColor:[UIColor grayColor]];
        [self addSubview:maxLabel];
    }
}

// 绘制外环背景(点击选择温度)
-(void)setChooseBgPath{
    {// 白色
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:radiusChoose startAngle:0 endAngle:2*M_PI clockwise:YES];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer new];
        shapeLayer.fillColor = [UIColor clearColor].CGColor; //填充透明颜色
        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        shapeLayer.lineWidth = lineChooseWidth;
        shapeLayer.shadowRadius=0.5;//设置阴影的宽度
        shapeLayer.shadowOffset=CGSizeMake(0,0);//设置偏移
        shapeLayer.shadowOpacity=0.9;
        shapeLayer.shadowColor = kDarkGray.CGColor;
        // 关键步骤
        shapeLayer.path = bezierPath.CGPath;
        [self.layer addSublayer:shapeLayer];
    }
    {// 灰色
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:radiusChoose startAngle:(60)*M_PI/180 endAngle:(120)*M_PI/180 clockwise:YES];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer new];
        shapeLayer.fillColor = [UIColor clearColor].CGColor; //填充透明颜色
        shapeLayer.strokeColor = kLineColor.CGColor;
        shapeLayer.lineWidth = lineChooseWidth;
        // 关键步骤
        shapeLayer.path = bezierPath.CGPath;
        [self.layer addSublayer:shapeLayer];
    }
}
// 绘制选中时外环进度环 (文字颜色，进度环颜色和位置)
-(void)setChooseStatusPath{
    // 几分熟温度环
    if((int)sliderType == 0){
        // 非自定义温度时
        if(isCustom == NO){
            // 获取当前选择的 几分熟温度
            int angle1 = [[scaleAngleArry objectAtIndex:currentChooseTempIndex] intValue];
            int startAngle1 =0;
            int endAngle1 =0;
            // 合理划分 300 度
            switch (currentChooseTempIndex) {
                case 0:
                    startAngle1 = 120;
                    endAngle1 =angle1+20;
                    break;
                case 1:
                    startAngle1 = angle1-40;
                    endAngle1 =angle1+40;
                    break;
                case 2:
                    startAngle1 = angle1-30;
                    endAngle1 =angle1+30;
                    break;
                case 3:
                    startAngle1 = angle1-20;
                    endAngle1 =angle1+20;
                    break;
                case 4:
                    startAngle1 = angle1-20;
                    endAngle1 =60;
                    break;
            }
            {// chooseShaperLayer 只添加一次，要想重复 remove 和 add 也是可以的(看具体情况)
                if(![chooseShaperLayer bd_isValue]){
                    chooseShaperLayer = [CAShapeLayer new];
                    [self.layer addSublayer:chooseShaperLayer];
                }
                UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:radiusChoose startAngle:startAngle1*M_PI/180 endAngle:endAngle1*M_PI/180 clockwise:YES];
                chooseShaperLayer.fillColor = [UIColor clearColor].CGColor; //填充透明颜色
                chooseShaperLayer.strokeColor = kMainColor.CGColor;
                chooseShaperLayer.lineWidth = lineChooseWidth;
                // 关键步骤
                chooseShaperLayer.path = bezierPath.CGPath;
            }
            {   // 刷新环形文字(选中的为白色)
                [self updateXMCircle];
            }
        }
        // 自定义温度时
        else
        {
            {// 重新绘制选中的外环
                int startAngle1 =60;
                int endAngle1 =120;
                // chooseShaperLayer 只添加一次，要想重复 remove 和 add 也是可以的(看具体情况)
                if(![chooseShaperLayer bd_isValue]){
                    chooseShaperLayer = [CAShapeLayer new];
                    [self.layer addSublayer:chooseShaperLayer];
                }
                UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:radiusChoose startAngle:startAngle1*M_PI/180 endAngle:endAngle1*M_PI/180 clockwise:YES];
                chooseShaperLayer.fillColor = [UIColor clearColor].CGColor; //填充透明颜色
                chooseShaperLayer.strokeColor = kMainColor.CGColor;
                chooseShaperLayer.lineWidth = lineChooseWidth;
                // 关键步骤
                chooseShaperLayer.path = bezierPath.CGPath;
            }
            {
                // 如果 CUSTOMIZED 已经显示就不需要刷新了（每次刷新的话，拖动手势会有"延迟"的感觉）
                if(!isCustomCircleTextShow){
                    [self updateXMCircle];
                    isCustomCircleTextShow = YES;
                }
            }
        }
    }
    // 建议温度环
    else{
        
    }
    
   
}
-(void)updateXMCircle{
    // 重新绘制圆环文字，（并改变选中的文字颜色）
    NSArray *titleArry = @[@"RARE",@"MEDIUM RARE",@"MEDIUM",@"MEDIUM WELL",@"WELL DONE",@"CUSTOMIZED"];
    // 第一次添加环形文字
    if([xmArry count]==0){
        for(int i=0;i<[titleArry count];i++){
            int scaleAngle = 0;
            if(i != [titleArry count]-1){
                // 其他 环形文字的 中心角度在数组中
                scaleAngle = [[scaleAngleArry objectAtIndex:i] intValue];
            }
            else{
                // CUSTOMIZED 字体的中心角度为 90
                scaleAngle = 90;
            }
            
            XMCircleTypeView *v = [[XMCircleTypeView alloc] initWithFrame:self.bounds];
            v.radius = radiusChoose - lineChooseWidth/4;
            v.backgroundColor = [UIColor clearColor];
            v.isCustomized = 0;
            v.text = [titleArry objectAtIndex:i];
            // 当前选中的文字设为 白色
            v.textAttributes = @{NSFontAttributeName:kFont(13),NSForegroundColorAttributeName:i==currentChooseTempIndex?[UIColor whiteColor]:kDarkGray};
            v.textAlignment = NSTextAlignmentCenter;
            v.verticalTextAlignment = XMCircleTypeVerticalAlignOutside;
            // isCustomized 属性是本人自己加的，并做了一些手脚，否则 CUSTOMIZED 是应该倒着的
            v.isCustomized = (i==[titleArry count]-1)?1:0;
            // 设置文字中心角度
            v.baseAngle = scaleAngle * M_PI / 180;
            v.characterSpacing = 0.95;
            // CUSTOMIZED 字体设置是否隐藏
            if(i == ([titleArry count]-1)){
                [v setHidden:currentChooseTempIndex==-1?NO:YES];
            }
            [self addSubview:v];
            [xmArry addObject:v];
        }
    }
    else{
        for(int i=0;i<[titleArry count];i++){
            XMCircleTypeView *v = [xmArry objectAtIndex:i];
            // 当前选中的文字设为 白色
            v.textAttributes = @{NSFontAttributeName:kFont(13),NSForegroundColorAttributeName:i==currentChooseTempIndex?[UIColor whiteColor]:kDarkGray};
            if(i == ([titleArry count]-1)){
                [v setHidden:currentChooseTempIndex==-1?NO:YES];
                v.textAttributes = @{NSFontAttributeName:kFont(13),NSForegroundColorAttributeName:currentChooseTempIndex==-1?[UIColor whiteColor]:kDarkGray};
            }
        }
    }
}
// 绘制内环(滑动/点击选择温度)
-(void)setSliderBgPath{
    {// 带豁口的圆环
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:radiusSlider startAngle:(90+30)*M_PI/180 endAngle:(90-30)*M_PI/180 clockwise:YES];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer new];
        shapeLayer.fillColor = [UIColor clearColor].CGColor; //填充透明颜色
        shapeLayer.strokeColor = kDarkGrayAlpha.CGColor;
        shapeLayer.lineWidth = lineSliderWidth;
        // 关键步骤
        shapeLayer.path = bezierPath.CGPath;
        [self.layer addSublayer:shapeLayer];
    }
    {// 底部两条线段
        int a = kHeight(7);
        CGPoint left[2];
        CGPoint right[2];
        CGPoint p1 = [self pointFromAngle: 120];
        CGPoint p2 = [self pointFromAngle: 60];
        CGPoint p3 = CGPointMake(p1.x - a/2, p1.y + a/sqrt(3)*2);
        CGPoint p4 = CGPointMake(p2.x + a/2, p2.y + a/sqrt(3)*2);
        left[0] = p1;
        left[1] = p3;
        right[0] = p2;
        right[1] = p4;
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        bezierPath.lineCapStyle = kCGLineCapRound; // 线条拐角
        bezierPath.lineJoinStyle = kCGLineCapRound;// 终点处理
        
        CAShapeLayer *shapeLayer = [CAShapeLayer new];
        shapeLayer.fillColor = [UIColor clearColor].CGColor; //填充颜色
        shapeLayer.strokeColor = kDarkGrayAlpha.CGColor;
        shapeLayer.lineWidth = lineSliderWidth;
        
        [bezierPath moveToPoint:p1];
        [bezierPath addLineToPoint:p3];
        [bezierPath closePath]; //别忘了关闭路径
        // 关键步骤
        shapeLayer.path = bezierPath.CGPath;
        [self.layer addSublayer:shapeLayer];
        
        [bezierPath moveToPoint:p2];
        [bezierPath addLineToPoint:p4];
        [bezierPath closePath]; //别忘了关闭路径
        // 关键步骤
        shapeLayer.path = bezierPath.CGPath;
        [self.layer addSublayer:shapeLayer];
    }
}
// 绘制 实心圆滑块（并设置温度）
-(void)setArcSlider{
    // 根据 角度 得到背景圆环上对应具体的点的坐标，以这个点为圆心绘制 滑块
    // -1 代表此时采用自定义温度，否则是点击选择几分熟温度
    CGPoint handleCenter =  [self pointFromAngle:currentChooseTempIndex==-1?angle:[[scaleAngleArry objectAtIndex:currentChooseTempIndex]intValue]];
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(handleCenter.x, handleCenter.y) radius:lineSliderWidth*3 startAngle:0 endAngle:2*M_PI clockwise:YES];
    // sliderShaperLayer 只添加一次，要想重复 remove 和 add 也是可以的(看个人兴趣)
    if(![sliderShaperLayer bd_isValue]){
        sliderShaperLayer = [CAShapeLayer new];
        [self.layer addSublayer:sliderShaperLayer];
    }
    sliderShaperLayer.fillColor = kLightGray.CGColor; //填充透明颜色
    sliderShaperLayer.shadowColor=[UIColor grayColor].CGColor;//设置阴影的颜色
    sliderShaperLayer.shadowRadius=5;//设置阴影的宽度
    sliderShaperLayer.shadowOffset=CGSizeMake(2,2);//设置偏移
    sliderShaperLayer.shadowOpacity=1;
    sliderShaperLayer.path = bezierPath.CGPath;
    
    // 自定义温度
    if(currentChooseTempIndex == -1){
        if(angle>=120){
            currentTemp = (int)roundf((float)(minTemp + (maxTemp - minTemp) * (angle - 120)/(360 - 60)));
            /*
            if(!isSSD){
                tempLabel.text = [NSString stringWithFormat:@"%d°F",(int)(currentTemp*1.8+32)];
            }
            else{
                tempLabel.text = [NSString stringWithFormat:@"%d°C",(int)(currentTemp)];
            }*/
            //NSString *tempUnitKey = [[NSUserDefaults standardUserDefaults] stringForKey:kTempUnit];
            NSString *tempUnitKey = @"C";
            int tempNum = currentTemp;
            [tempLabel setText:[NSString stringWithFormat:[tempUnitKey isEqualToString:@"F"]?@"%d°F":@"%d°C",tempNum]];
        }
        else{
            currentTemp = (int)roundf((float)(minTemp + (maxTemp - minTemp) * (angle + 240)/(360 - 60)));
            /*
            if(!isSSD){
                tempLabel.text = [NSString stringWithFormat:@"%d°F",(int)(currentTemp*1.8+32)];
            }
            else{
                tempLabel.text = [NSString stringWithFormat:@"%d°C",(int)(currentTemp)];
            }*/
            NSString *tempUnitKey = @"C";
            int tempNum = currentTemp;
            [tempLabel setText:[NSString stringWithFormat:[tempUnitKey isEqualToString:@"F"]?@"%d°F":@"%d°C",tempNum]];
        }
    }
    // 几分熟温度
    else
    {
        currentTemp = [[scaleTempArry objectAtIndex:currentChooseTempIndex]intValue];
        /*
        if(!isSSD){
            tempLabel.text = [NSString stringWithFormat:@"%d°F",(int)(currentTemp*1.8+32)];
           
        }
        else{
            tempLabel.text = [NSString stringWithFormat:@"%d°C",(int)(currentTemp)];
           
        }*/
        NSString *tempUnitKey = @"C";
        int tempNum = currentTemp;
        [tempLabel setText:[NSString stringWithFormat:[tempUnitKey isEqualToString:@"F"]?@"%d°F":@"%d°C",tempNum]];
    }
    // 温度描述
    switch (currentTemp) {
        case 48:
            self.tempDes = @"Rare";
            break;
        case 54:
            self.tempDes = @"Medium Rare";
            break;
        case 60:
            self.tempDes = @"Medium";
            break;
        case 65:
            self.tempDes = @"Medium Well";
            break;
        case 68:
            self.tempDes = @"Well Done";
            break;
        default:
            self.tempDes = @"Customized";
            break;
    }
    // 选择的温度(华氏度)
    //self.meatTemp = [[BDMethod bd_shareBDMethod] changeCtoF:currentTemp];
    self.meatTemp = currentTemp;
    
}
// 绘制 小绿圆
-(void)setGreenArc{
    if(sliderType == 0){
        for(int i=0;i<[scaleAngleArry count];i++){
            CGPoint handleCenter =  [self pointFromAngle:[[scaleAngleArry objectAtIndex:i]intValue]];
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(handleCenter.x, handleCenter.y) radius:kHeight(5) startAngle:0 endAngle:2*M_PI clockwise:YES];
            
            CAShapeLayer *shapeLayer = [CAShapeLayer new];
            shapeLayer.fillColor = [UIColor whiteColor].CGColor; //填充颜色
            shapeLayer.strokeColor = kMainColor.CGColor;
            shapeLayer.lineWidth = lineSliderWidth;
            
            shapeLayer.path = bezierPath.CGPath;
            [self.layer addSublayer:shapeLayer];
        }
    }
}
#pragma mark - 重写方法 (这两个方法会冒泡传递，即时self上覆盖了其它组件，self依然可以监听到事件，类似手势识别)
// 点击事件（如果点击圆环，则设置进度）
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    // 获取 触摸手势在 self 中的相对坐标
    CGPoint p = [touch locationInView:self];
    // 点击
    [self movehandle:p Type:0];
    // 发送值改变事件
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    // 之前是点击"CUSTOMIZED"才自定义温度，现改为滑动就自定义温度
    isCustom = YES;
    // 获取触摸点
    CGPoint lastPoint = [touch locationInView:self];
    // 拖动
    [self movehandle:lastPoint Type:1];
    // 发送值改变事件
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}
#pragma mark - 数学方法
//根据角度得到圆环上的坐标，设置滑块位置
-(CGPoint)pointFromAngle:(int)angleInt{
    // 中心点坐标（滑块是椭圆时）
    //CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - _circleSliderWidth/2, self.frame.size.height/2 - _circleSliderWidth/2);
    // 中心点坐标（滑块是圆形时）
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    //根据角度得到圆环上的坐标
    CGPoint result;
    result.y = round(centerPoint.y + radiusSlider * sin( ToRad(angleInt))) ;
    result.x = round(centerPoint.x + radiusSlider * cos( ToRad(angleInt)));
    
    return result;
}
// 根据坐标获取 角度
static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    result = ToDeg(radians);
    return (result >=0  ? result : result + 360.0);
    
}
-(float)distanceFromPointX:(CGPoint)start distanceToPointY:(CGPoint)end{
    float distance;
    //下面就是高中的数学，不懂我也没办法
    CGFloat xDist = (end.x - start.x);
    CGFloat yDist = (end.y - start.y);
    distance = sqrt((xDist * xDist) + (yDist * yDist));
    return distance;
}
// 触摸点变化
// type:0 点击（选择几分熟温度），进行响应区域限制
// type:1 拖拽（自定义温度），自定义温度
-(void)movehandle:(CGPoint)lastPoint Type:(int)type{
    
    //获得中心点
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2,
                                      self.frame.size.height/2);
    float distance = [self distanceFromPointX:centerPoint distanceToPointY:lastPoint];
    // 点击选择几分熟温度
    if(type == 0){
        //限制响应区域(圆环向内外扩散 kHeight(10) 区域)
        if(distance < (radiusChoose - lineChooseWidth/2-kHeight(5))){
            if(distance < tempLabel.boundsHeight/2){
                // 切换 摄氏度/华氏度
                //[self changeTempUnit];
            }
            // 记住，切换完要 return，否则会往下执行哦
            return;
        }
        if(distance > (radiusChoose + lineChooseWidth/2+kHeight(5)))return;
        //计算触摸点的角度
        float currentAngle = AngleFromNorth(centerPoint,
                                            lastPoint,
                                            NO);
        int angleInt = floor(currentAngle);
        // 点击了底部的自选温度区域
        if(angleInt > 60 && angleInt < 120){
            /*
            isCustom = YES;
            angle = 120;
            currentChooseTempIndex = -1;
            [self setChooseStatusPath];
            [self setArcSlider];*/
        }
        // 非自选温度(小绿圈温度)
        else{
            isCustom = NO;
            isCustomCircleTextShow = NO;
            // 循环遍历几分熟温度对应的角度，判断点击的角度是否在响应范围内（角度-20，角度+20）
            for(int i=0;i<[scaleAngleArry count];i++){
                int temp = [[scaleAngleArry objectAtIndex:i] intValue];
                // 直接判断
                if(temp>20 && temp<340){
                    if(angleInt>temp-20 && angleInt <temp + 20){
                        currentChooseTempIndex = i;
                        [self setChooseStatusPath];
                        [self setArcSlider];
                        break;
                    }
                }
                // 上边界会越界（出现大于360度的，我们用的方法 AngleFromNorth 获取的角度是0-360）
                else if(temp>=340 && temp<=360){
                    if(angleInt>temp-20 || angleInt <temp + 20-360){
                        currentChooseTempIndex = i;
                        [self setChooseStatusPath];
                        [self setArcSlider];
                        break;
                    }
                }
                // 下边界会越界（出现小于0度的，我们用的方法 AngleFromNorth 获取的角度是0-360）
                else{
                    if(angleInt>temp-20+360|| angleInt <temp + 20){
                        currentChooseTempIndex = i;
                        [self setChooseStatusPath];
                        [self setArcSlider];
                        break;
                    }
                }
            }
        }
    }
    // 滑动选择温度
    else{
        // 判断是否是自定义温度 isCustom=YES
        if(isCustom == YES){
            //限制响应区域（内环）
            if(distance > radiusSlider+kHeight(50))return;
            //限制响应区域（此时应该切换温度类型，故不做响应）
            //if(distance < tempLabel.boundsHeight/2)return;
            //计算触摸点的角度
            float currentAngle = AngleFromNorth(centerPoint,
                                                lastPoint,
                                                NO);
            int angleInt = floor(currentAngle);
            if(angleInt<=60 || angleInt>=120){
                //保存新角度
                angle = angleInt;
            }
            if(angleInt>60 && angleInt<=70)
            {
                angle = 60;
            }
            if(angleInt>110 && angleInt<120){
                angle = 120;
            }
            NSLog(@"角度：%d",angle);
            //重新绘制
            currentChooseTempIndex = -1;
            [self setArcSlider];
            [self setChooseStatusPath];
        }
    }
}
// 切换 摄氏度/华氏度
-(void)changeTempUnit{
    if(isSSD){
        tempLabel.text = [NSString stringWithFormat:@"%d°F",(int)(currentTemp*1.8+32)];
        isSSD = NO;
    }
    else{
        tempLabel.text = [NSString stringWithFormat:@"%d°C",(int)(currentTemp)];
        isSSD = YES;
    }
}
@end
