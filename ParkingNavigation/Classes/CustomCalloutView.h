//
//  CustomCalloutView.h
//  ParkingNavigation
//
//  Created by 徐成 on 15/7/25.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kArrorHeight        10

#define kPortraitMargin     5
#define kPortraitWidth      50
#define kPortraitHeight     50

#define kTitleWidth         220
#define kTitleHeight        20

@interface CustomCalloutView : UIView

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end
