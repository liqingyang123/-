//
//  CircleChooseSlider.h
//  OutdoorChef
//
//  Created by 李青阳 on 2019/1/28.
//  Copyright © 2019年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
// 可选择 Food几分熟温度 的圆环滑杆
@interface CircleSliderOfScaleFood : UIControl

@property(nonatomic,assign)int meatTemp;
@property(nonatomic,strong)NSString *tempDes;

@end

NS_ASSUME_NONNULL_END
