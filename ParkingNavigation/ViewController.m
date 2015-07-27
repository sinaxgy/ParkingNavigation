//
//  ViewController.m
//  ParkingNavigation
//
//  Created by 徐成 on 15/7/5.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

#import "ViewController.h"

#define key c6a010e9d1e147319198817afd4de5d2
#define ip  @"10.104.7.110:8080"
//#define ip  @"123.57.254.235"

@interface ViewController ()

@end

@implementation ViewController
@synthesize gdMapView;

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self fetch:nil];
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
    [gdMapView addSubview:_locationBtn];
    
    _trackBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    _trackBtn.frame = CGRectMake(60, self.view.bounds.size.height - 50, 25, 25);
    _trackBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [_trackBtn setImage:[UIImage imageNamed:@"parking"] forState:UIControlStateNormal];
    [_trackBtn setImage:[UIImage imageNamed:@"noparking"] forState:UIControlStateSelected];
    [_trackBtn addTarget:self action:@selector(trackParkAction:) forControlEvents:UIControlEventTouchUpInside];
    [gdMapView addSubview:_trackBtn];
}

- (void) initMapView
{
    self.view.backgroundColor = [UIColor grayColor];
    gdMapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    gdMapView.compassOrigin = CGPointMake(gdMapView.compassOrigin.x, kDefaultControlMargin);
    gdMapView.scaleOrigin = CGPointMake(gdMapView.scaleOrigin.x, kDefaultControlMargin);
    self.gdMapView.delegate = self;
    [self.view addSubview:self.gdMapView];
    gdMapView.showsUserLocation = YES;
    gdMapView.headingFilter = 10;
    gdMapView.desiredAccuracy = kCLLocationAccuracyKilometer;
    gdMapView.distanceFilter = 10;
}

- (void) locationAction
{
    if (gdMapView.userTrackingMode != MAUserTrackingModeFollow) {
        gdMapView.userTrackingMode = MAUserTrackingModeFollow;
        [gdMapView setZoomLevel:kDefaultLocationZoomLevel animated:YES];
        [_locationBtn setImage:[UIImage imageNamed:@"location_yes"] forState:UIControlStateNormal];
    }else {
        gdMapView.userTrackingMode = MAUserTrackingModeNone;
        [_locationBtn setImage:[UIImage imageNamed:@"location_no"] forState:UIControlStateNormal];
    }
}

- (void) trackParkAction:(UIButton*)sender {
    sender.selected = !sender.selected;
}

- (void)setParkArray:(NSArray *)parkArray{
    if (self.parkArray) {
        [self.gdMapView removeAnnotations:self.parkArray];
    }
    NSLog(@"%@>>>>>>%@",self.parkArray,parkArray);
    //self.parkArray = parkArray;
    [self.gdMapView addAnnotations:parkArray];
}

#pragma mark MAMapViewDelegete
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (updatingLocation) {
        if (!_trackBtn.selected) {
            [self fetch:userLocation];
        }
    }
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[MAUserLocation class]])
    {
        //[self reGeoAction];
    }
    
    if ([view isKindOfClass:[CustomAnnotationView class]]) {
        CustomAnnotationView *cusView = (CustomAnnotationView *)view;
        CGRect frame = [cusView convertRect:cusView.calloutView.frame toView:self.gdMapView];
        
        frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(kDefaultCalloutViewMargin, kDefaultCalloutViewMargin, kDefaultCalloutViewMargin, kDefaultCalloutViewMargin));
        
        if (!CGRectContainsRect(self.gdMapView.frame, frame))
        {
            CGSize offset = [self offsetToContainRect:frame inRect:self.gdMapView.frame];
            
            CGPoint theCenter = self.gdMapView.center;
            theCenter = CGPointMake(theCenter.x - offset.width, theCenter.y - offset.height);
            
            CLLocationCoordinate2D coordinate = [self.gdMapView convertPoint:theCenter toCoordinateFromView:self.gdMapView];
            
            [self.gdMapView setCenterCoordinate:coordinate animated:YES];
        }
        
    }
}

- (MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        static NSString *reuseIndetifier = @"userReuseIndentifier";
        MAAnnotationView *annotationView = (MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
            annotationView.image = [UIImage imageNamed:@"location_lo"];
            annotationView.layer.backgroundColor = (__bridge CGColorRef)([UIColor redColor]);
            annotationView.opaque = YES;
        }
        return annotationView;
    }
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        CustomAnnotationView *annotationView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
        }
        annotationView.image = [UIImage imageNamed:@"point"];
        annotationView.canShowCallout = NO;
        // 设置中心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -18);
        return annotationView;
    }
    return nil;
}

#pragma MARK :---- 不同于Swift,OC中的json的key值不能为中文
- (void) fetch:(MAUserLocation *)userLocation {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 10.0f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSString *url = [self fourPointStringWithUserLocation:userLocation];
    if (!userLocation) {
        url = [NSString stringWithFormat:@"http://%@/YLQ/searchPoints.action?en=1,300&es=1,2&wn=4,2&ws=3,2",ip];
    }
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSLog(@"objects:%@----array:%@",responseObject,self.parkArray);
            self.parkArray = [self annotationsWithObjects:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Error: %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"读取信息失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }];
}

- (void) postParameters:(NSDictionary*)parameters responseJSON:(void (^)(NSDictionary *dic))block {
    NSString *url = @"";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];     //申明返回的结果是json类型
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if (block) {
            block((NSDictionary*)responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (block) {
            block(nil);
        }
    }];
}

- (NSString*)fourPointStringWithUserLocation:(MAUserLocation *)userLocation {
    CGFloat latitudeSouth = userLocation.location.coordinate.latitude - 3*0.008983f;
    CGFloat latitudeNorth = userLocation.location.coordinate.latitude + 3*0.008983f;
    CGFloat longitudeEast = userLocation.location.coordinate.longitude + 3*0.008984f;
    CGFloat longitudeWest = userLocation.location.coordinate.longitude - 3*0.008984f;
    NSString * url = [NSString stringWithFormat:@"http://%@/YLQ/searchPoints.action?en=%f,%f&es=%f,%f&wn=%f,%f&ws=%f,%f",ip,longitudeEast,latitudeNorth,longitudeEast,latitudeSouth,longitudeWest,latitudeNorth,longitudeWest,latitudeSouth];
    NSLog(@"%@",url);
    return url;
}

- (NSArray*)annotationsWithObjects:(NSArray*)objects {
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (NSDictionary*dic in objects) {
        [array addObject:[self annotationWithxyDic:dic]];
    }
    return array;
}

- (MAPointAnnotation*) annotationWithxyDic:(NSDictionary*)dic {
    MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
    NSString *x = [dic objectForKey:@"x"];
    NSString *y = [dic objectForKey:@"y"];
    NSString *name = [dic objectForKey:@"name"];
    NSString *address = [dic objectForKey:@"address"];
    NSString *dynum = [dic objectForKey:@"dynum"];
    NSString *spaceNum = [dic objectForKey:@"spaceNum"];
    annotation.coordinate = CLLocationCoordinate2DMake(y.floatValue, x.floatValue);
    annotation.title = [NSString stringWithFormat:@"%@:占用%d/%d",name,dynum.intValue,spaceNum.intValue];
    annotation.subtitle = address;
    return annotation;
}

- (CGSize)offsetToContainRect:(CGRect)innerRect inRect:(CGRect)outerRect
{
    CGFloat nudgeRight = fmaxf(0, CGRectGetMinX(outerRect) - (CGRectGetMinX(innerRect)));
    CGFloat nudgeLeft = fminf(0, CGRectGetMaxX(outerRect) - (CGRectGetMaxX(innerRect)));
    CGFloat nudgeTop = fmaxf(0, CGRectGetMinY(outerRect) - (CGRectGetMinY(innerRect)));
    CGFloat nudgeBottom = fminf(0, CGRectGetMaxY(outerRect) - (CGRectGetMaxY(innerRect)));
    return CGSizeMake(nudgeLeft ?: nudgeRight, nudgeTop ?: nudgeBottom);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
