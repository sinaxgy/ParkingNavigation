//
//  ViewController.h
//  ParkingNavigation
//
//  Created by 徐成 on 15/7/5.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import "AFNetworking/AFNetworking.h"
#import "AFURLRequestSerialization.h"
#import "AFURLResponseSerialization.h"
#import "CustomAnnotaionView.h"
#import <AMapSearchKit/AMapSearchAPI.h>

#define kDefaultControlMargin           22
#define kDefaultLocationZoomLevel       16.1
#define kDefaultLocationZoomLevel       16.1
#define kDefaultControlMargin           22
#define kDefaultCalloutViewMargin       -8

@interface ViewController : UIViewController <MAMapViewDelegate,AMapSearchDelegate>
@property (readwrite, nonatomic, strong) NSArray *parkArray;
@property (nonatomic,strong) MAMapView *gdMapView;
@property (nonatomic,strong) UIButton *locationBtn;
@property (nonatomic,strong) UIButton *trackBtn;
@property (nonatomic,strong) MAAnnotationView *userAnnotationView;

@end

