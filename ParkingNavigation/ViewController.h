//
//  ViewController.h
//  ParkingNavigation
//
//  Created by 徐成 on 15/7/5.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwiftClass-swift.h"
#import <MAMapKit/MAMapKit.h>
#import "AFNetworking/AFNetworking.h"
#import "AFURLRequestSerialization.h"
#import "AFURLResponseSerialization.h"
#import "SwiftyJSON.h"

#define kDefaultControlMargin           22
#define kDefaultLocationZoomLevel       16.1

@interface ViewController : UIViewController <MAMapViewDelegate>

@property (nonatomic,strong) MAMapView *mapView;
@property (nonatomic,strong) UIButton *locationBtn;

@end

