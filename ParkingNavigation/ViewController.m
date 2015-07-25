//
//  ViewController.m
//  ParkingNavigation
//
//  Created by 徐成 on 15/7/5.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

#import "ViewController.h"

#define key c6a010e9d1e147319198817afd4de5d2

@interface ViewController ()

@end

@implementation ViewController
@synthesize mapView;

- (void)viewDidLoad {
    [super viewDidLoad];
    //NSDictionary *dic = [SwiftAlamofireJSON JSONWithGET];
    // Do any additional setup after loading the view, typically from a nib.
    [self fetch];
    [self initMapView];
    [self initControllers];
}

#pragma mark initialization
- (void) initControllers
{
    _locationBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    _locationBtn.frame = CGRectMake(20, self.view.bounds.size.height - 50, 25, 25);
    _locationBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin;
    [_locationBtn setImage:[UIImage imageNamed:@"location_no"] forState:UIControlStateNormal];
    [_locationBtn addTarget:self action:@selector(locationAction) forControlEvents:UIControlEventTouchUpInside];
    [mapView addSubview:_locationBtn];
}

- (void) initMapView
{
    self.view.backgroundColor = [UIColor grayColor];
    mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    mapView.compassOrigin = CGPointMake(mapView.compassOrigin.x, kDefaultControlMargin);
    mapView.scaleOrigin = CGPointMake(mapView.scaleOrigin.x, kDefaultControlMargin);
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    mapView.showsUserLocation = YES;
    mapView.headingFilter = 10;
    mapView.desiredAccuracy = kCLLocationAccuracyKilometer;
    mapView.distanceFilter = 10;
}

- (void) locationAction
{
    if (mapView.userTrackingMode != MAUserTrackingModeFollow) {
        mapView.userTrackingMode = MAUserTrackingModeFollow;
        [mapView setZoomLevel:kDefaultLocationZoomLevel animated:YES];
        [_locationBtn setImage:[UIImage imageNamed:@"location_yes"] forState:UIControlStateNormal];
    }else {
        mapView.userTrackingMode = MAUserTrackingModeNone;
        [_locationBtn setImage:[UIImage imageNamed:@"location_no"] forState:UIControlStateNormal];
    }
}

#pragma mark MAMapViewDelegete
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    NSLog(@"%@",userLocation);
}
#pragma MARK :---- OC中的json的key值不能为中文
- (void) fetch {
    //NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@""]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString * url = @"http://10.104.4.202/web/index.php/app/service";
    //NSString * chineseUrl = @"http://10.104.4.202/web/index.php/app/picture?pro_id=5";
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"responseObject:%@",responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"dic");
        }
        NSLog(@"%lu",(unsigned long)[dict count]);
        NSArray *keys  = [[NSArray alloc] init];
        keys = [dict allKeys];
        NSLog(@"keys:%@",keys);
        for (NSString* key in keys) {
            NSLog(@"value:%@",[dict objectForKey:key]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (NSString*)fourPointStringWithUserLocation:(MAUserLocation *)userLocation {
    CGFloat latitudeSouth = userLocation.location.coordinate.latitude - 0.008983f;
    CGFloat latitudeNorth = userLocation.location.coordinate.latitude + 0.008983f;
    CGFloat longitudeEast = userLocation.location.coordinate.longitude + 0.008984f;
    CGFloat longitudeWest = userLocation.location.coordinate.longitude - 0.008984f;
    
    NSString *str = [NSString stringWithFormat:@"en:%f,%f,es:%f,%f,wn:%f,%f,ws:%f,%f",longitudeEast,latitudeNorth,longitudeEast,latitudeSouth,longitudeWest,latitudeNorth,longitudeWest,latitudeSouth];
    return str;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
