//
//  SliderRGBView.h
//  tryRGB
//
//  Created by mac1 on 16/5/11.
//  Copyright © 2016年 mac1. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol GetSliderColor <NSObject>
@required
-(void)getSliderColorMethod:(UIColor *)color;
@end
@interface SliderRGBView : UIView<GetSliderColor>
@property(nonatomic,strong)UIImageView * bgImg;
@property(nonatomic,strong)UIImageView * slider;//滑块
@property(nonatomic,strong)UIView * colorIndatorView;//显示颜色
@property(nonatomic,strong)UIImageView * colorIndatorImgView;//白圈那个
@property(nonatomic,retain) id <GetSliderColor> delegate;
-(SliderRGBView *)initWithFrame:(CGRect )frame;
@end
