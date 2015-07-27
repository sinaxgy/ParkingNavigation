//
//  CustomAnnotaionView.h
//  ParkingNavigation
//
//  Created by 徐成 on 15/7/25.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "CustomCalloutView.h"

#define kCalloutWidth       280.0
#define kCalloutHeight      70.0

@interface CustomAnnotationView : MAAnnotationView

@property (nonatomic, readonly) CustomCalloutView *calloutView;

@end
