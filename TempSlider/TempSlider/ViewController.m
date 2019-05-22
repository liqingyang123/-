//
//  ViewController.m
//  TempSlider
//
//  Created by mac on 2019/5/22.
//  Copyright © 2019 mac. All rights reserved.
//

#import "ViewController.h"
#import "CircleSliderOfScaleFood.h"     // 几分熟温度选择环
#import "BaseDefine.h"
@interface ViewController ()
{
     CircleSliderOfScaleFood *csliderScale;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat tempVwidth = kFullScreen.size.width-2*kHeight(15);
    UIImageView  *tempV = [[UIImageView alloc] initWithFrame:CGRectMake(kHeight(15), kHeight(100), tempVwidth, tempVwidth)];
    //[tempV setImage:[UIImage imageNamed:@"10"]];
    [tempV setUserInteractionEnabled:YES];
    [tempV setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:tempV];
    {
        csliderScale = [[CircleSliderOfScaleFood alloc] initWithFrame:tempV.bounds];
        [tempV addSubview:csliderScale];
    }
}


@end
