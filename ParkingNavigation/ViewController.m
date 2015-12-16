//
//  ViewController.m
//  ParkingNavigation
//
//  Created by 徐成 on 15/7/5.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

#import "ViewController.h"
#import <AMapSearchKit/AMapSearchAPI.h>

#define key @"c6a010e9d1e147319198817afd4de5d2"
//#define ip  @"10.104.7.110:8080"
#define ip  @"123.57.254.235"

@interface ViewController ()
{
    MAPointAnnotation *destinationPoint;
    MAPointAnnotation *targetPoint;
    AMapSearchAPI *search;
    CLLocation *user_Location;
    NSArray *pathPolylines;
}
@end

@implementation ViewController
@synthesize gdMapView;

- (void)viewDidLoad {
    [super viewDidLoad];
    search = [[AMapSearchAPI alloc] initWithSearchKey:key Delegate:self];
    [self initMapView];
    [self initControllers];
    [self locationAction];
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
    
    
    UIButton *pathButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    pathButton.frame = CGRectMake(100, CGRectGetHeight(self.view.bounds) - 50, 25, 25);
    pathButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    pathButton.backgroundColor = [UIColor whiteColor];
    [pathButton setImage:[UIImage imageNamed:@"path"] forState:UIControlStateNormal];
    pathButton.backgroundColor = [UIColor clearColor];
    [pathButton addTarget:self action:@selector(pathAction) forControlEvents:UIControlEventTouchUpInside];
    
    [gdMapView addSubview:pathButton];
}

- (void) initMapView
{
    self.view.backgroundColor = [UIColor grayColor];
    gdMapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    gdMapView.compassOrigin = CGPointMake(gdMapView.compassOrigin.x, kDefaultControlMargin);
    gdMapView.scaleOrigin = CGPointMake(gdMapView.scaleOrigin.x, kDefaultControlMargin);
    self.gdMapView.delegate = self;
    [self.view addSubview:self.gdMapView];
    gdMapView.showsUserLocation = YES;
    gdMapView.headingFilter = 100;
    gdMapView.desiredAccuracy = kCLLocationAccuracyKilometer;
    gdMapView.distanceFilter = 10;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [gdMapView addGestureRecognizer:longPress];
}

#pragma mark aciton

- (void) longPress:(UILongPressGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CLLocationCoordinate2D coordinate = [gdMapView convertPoint:[recognizer locationInView:gdMapView] toCoordinateFromView:gdMapView];
        if (targetPoint) {
            [gdMapView removeAnnotation:targetPoint];
            targetPoint = nil;
        }
        targetPoint = [[MAPointAnnotation alloc]init];
        targetPoint.coordinate = coordinate;
        targetPoint.title = @"目的地";
        [gdMapView addAnnotation:targetPoint];
        
        [self fetch:coordinate];
    }
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

- (void) pathAction {
    if (!destinationPoint || !user_Location || !search) {
        return;
    }
    AMapNavigationSearchRequest *request = [[AMapNavigationSearchRequest alloc] init];
    request.searchType = AMapSearchType_NaviDrive;
    request.origin = [AMapGeoPoint locationWithLatitude:user_Location.coordinate.latitude longitude:user_Location.coordinate.longitude];
    request.destination = [AMapGeoPoint locationWithLatitude:destinationPoint.coordinate.latitude longitude:destinationPoint.coordinate.longitude];
    [search AMapNavigationSearch:request];
}

- (NSArray *)polylinesForPath:(AMapPath*)path {
    if (!path || path.steps.count == 0) {
        return nil;
    }
    NSMutableArray *polylines = [NSMutableArray array];
    NSLog(@"距离:%ld,\n耗时:%ld,\n导航策略:%@\n费用tolls:%f,\n收费路段长度tollDistance%ld",(long)[path distance],path.duration,path.strategy,path.tolls,(long)path.tollDistance);
//    for (NSString *value in path.steps) {
//        NSLog(@"steps:%@",value);
//    }
    [path.steps enumerateObjectsUsingBlock:^(AMapStep *step, NSUInteger idx, BOOL *stop) {
        NSUInteger count = 0;
        CLLocationCoordinate2D *coordinates = [self coordinatesForString:step.polyline
                                                         coordinateCount:&count
                                                              parseToken:@";"];
        
        MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coordinates count:count];
        [polylines addObject:polyline];
        
        free(coordinates), coordinates = NULL;
    }];
    return polylines;
}

- (CLLocationCoordinate2D *)coordinatesForString:(NSString *)string
                                 coordinateCount:(NSUInteger *)coordinateCount
                                      parseToken:(NSString *)token
{
    if (string == nil)
    {
        return NULL;
    }
    
    if (token == nil)
    {
        token = @",";
    }
    
    NSString *str = @"";
    if (![token isEqualToString:@","])
    {
        str = [string stringByReplacingOccurrencesOfString:token withString:@","];
    }
    
    else
    {
        str = [NSString stringWithString:string];
    }
    
    NSArray *components = [str componentsSeparatedByString:@","];
    NSUInteger count = [components count] / 2;
    if (coordinateCount != NULL)
    {
        *coordinateCount = count;
    }
    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D*)malloc(count * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < count; i++)
    {
        coordinates[i].longitude = [[components objectAtIndex:2 * i]     doubleValue];
        coordinates[i].latitude  = [[components objectAtIndex:2 * i + 1] doubleValue];
    }
    
    return coordinates;
}

- (void) trackParkAction:(UIButton*)sender {
    sender.selected = !sender.selected;
}

- (void)setParkArray:(NSArray *)parkArray{
    if (_parkArray) {
        [self.gdMapView removeAnnotations:_parkArray];
    }
    _parkArray = parkArray;
    [self.gdMapView addAnnotations:parkArray];
}

#pragma mark - AMapSearchDelegate
- (void) searchRequest:(id)request didFailWithError:(NSError *)error {
    NSLog(@"request:%@,error:%@",request,error);
}

- (void)onNavigationSearchDone:(AMapNavigationSearchRequest *)request response:(AMapNavigationSearchResponse *)response {
    if (response.count > 0) {
        if (pathPolylines) {
            [gdMapView removeOverlays:pathPolylines];
            pathPolylines = @[];
        }
        NSLog(@"request paths num:%lu",(unsigned long)response.route.paths.count);
        [response.route.paths enumerateObjectsUsingBlock:^(AMapPath* path, NSUInteger idx, BOOL *stop) {
            NSLog(@"%lu",(unsigned long)idx);
            pathPolylines = [self polylinesForPath:path];
            [gdMapView addOverlays:pathPolylines];
            [gdMapView showAnnotations:@[destinationPoint,gdMapView.userLocation] animated:YES];
        }];
    }
}


#pragma mark MAMapViewDelegete
- (MAOverlayView*)mapView:(MAMapView *)mapView viewForOverlay:(id<MAOverlay>)overlay {
    if ([overlay isKindOfClass:[MAPolyline class]]) {
        MAPolylineView *polylineView = [[MAPolylineView alloc] initWithPolyline:overlay];
        polylineView.lineWidth = 4;
        polylineView.strokeColor = [UIColor blueColor];
        return polylineView;
    }
    return nil;
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (self.userAnnotationView) {
        self.userAnnotationView.transform = CGAffineTransformMakeRotation(userLocation.heading.trueHeading * 6.28 /360);
    }
    if (!_trackBtn.selected) {
        [self fetch:userLocation.location.coordinate];
    }
    user_Location = userLocation.location;
}

- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated
{
    // 修改定位按钮状态
    if (mode == MAUserTrackingModeNone)
    {
        [_locationBtn setImage:[UIImage imageNamed:@"location_no"] forState:UIControlStateNormal];
    }
    else
    {
        [_locationBtn setImage:[UIImage imageNamed:@"location_yes"] forState:UIControlStateNormal];
    }
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    if ([view isKindOfClass:[CustomAnnotationView class]]) {
        CustomAnnotationView *cusView = (CustomAnnotationView *)view;
        CGRect frame = [cusView convertRect:cusView.calloutView.frame toView:self.gdMapView];
        
        frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(kDefaultCalloutViewMargin, kDefaultCalloutViewMargin, kDefaultCalloutViewMargin, kDefaultCalloutViewMargin));
        
        if ([cusView.annotation isKindOfClass:[MAPointAnnotation class]]) {
            destinationPoint = cusView.annotation;
        }
        
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
        self.userAnnotationView = [[MAAnnotationView alloc] init];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
            annotationView.image = [UIImage imageNamed:@"location_lo"];
            annotationView.layer.backgroundColor = (__bridge CGColorRef)([UIColor redColor]);
            annotationView.opaque = YES;
        }
        self.userAnnotationView = annotationView;
        return annotationView;
    }
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        if ([[annotation title] isEqualToString:@"目的地"]) {
            MAAnnotationView *annotaionView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"targetView"];
            if (!annotaionView) {
                annotaionView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"targetView"];
            }
            annotaionView.image = [UIImage imageNamed:@"target"];
            annotaionView.canShowCallout = YES;
            return annotaionView;
        }
        CustomAnnotationView *annotationView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
        }
        annotationView.image = [UIImage imageNamed:@"point1"];
        annotationView.canShowCallout = NO;
        // 设置中心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -18);
        return annotationView;
    }
    return nil;
}

#pragma MARK :---- 不同于Swift,OC中的json的key值不能为中文
- (void) fetch:(CLLocationCoordinate2D )coordinate {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 10.0f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSString *url = [self fourPointStringWithCoordinate:coordinate];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            self.parkArray = [self annotationsWithObjects:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) postParameters:(NSDictionary*)parameters responseJSON:(void (^)(NSDictionary *dic))block {
    NSString *url = @"";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];     //申明返回的结果是json类型
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
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

- (NSString*)fourPointStringWithCoordinate:(CLLocationCoordinate2D )coordinate {
    CGFloat latitudeSouth = coordinate.latitude - 3*0.008983f;
    CGFloat latitudeNorth = coordinate.latitude + 3*0.008983f;
    CGFloat longitudeEast = coordinate.longitude + 3*0.008984f;
    CGFloat longitudeWest = coordinate.longitude - 3*0.008984f;
    NSString * url = [NSString stringWithFormat:@"http://%@/YLQ/searchPoints.action?en=%f,%f&es=%f,%f&wn=%f,%f&ws=%f,%f",ip,longitudeEast,latitudeNorth,longitudeEast,latitudeSouth,longitudeWest,latitudeNorth,longitudeWest,latitudeSouth];
    //NSLog(@"%@",url);
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
