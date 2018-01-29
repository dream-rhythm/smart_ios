//
//  MapViewController.m
//  SailsSDKDemo
//
//  Created by Robert.Hsueh on 2014/7/7.
//  Copyright (c) 2014年 Robert.Hsueh. All rights reserved.
//

#import "Mybaby.h"
#import "include/Sails.h"
#import "include/SailsMapCommon.h"
#import "include/LocationRegion.h"
#import "include/MarkerManager.h"
#import "include/PathRoutingManager.h"
#import "include/PinMarkerManager.h"
#import "/Users/watermoon/Desktop/most_Research/smart_ios/smart_ios/Socket/GCDAsyncSocket.h"
#import "CoreBluetooth/CoreBluetooth.h"
#import "CoreLocation/CoreLocation.h"
#import "BabyBluetooth/BabyBluetooth.h"
#import <AudioToolbox/AudioToolbox.h>
//#import "include/AudioToolbox.h"
BabyBluetooth *baby3;
typedef NS_ENUM(NSInteger, UIActionSheetMode) {
    FloorSheetMode,
    RoutingSheetMode
};

@interface Mybaby () <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource>
{
    SailsLocationMapView *sailsMapView;
    MarkerManager *sailsMarkerManager;
    PinMarkerManager *sailsPinMarkerManager;
    PathRoutingManager *sailsPathRoutingManager;
    Sails *sails;
    NSArray *floorNameList;
    UIBarButtonItem *mBarButtonPOI;
    UIBarButtonItem *mBarButtonFloor;
    UIBarButtonItem *mBarButtonSwitch;
    UIBarButtonItem *IPsetting;
    UITextField *nameField;
    UIBarButtonItem *mBarButtonRoutinMode;
    UITableView *poiTableView;
    NSDictionary *allLocationRegionOfFloors;
    UIButton *zoomInButton;
    UIButton *zoomOutButton;
    UIButton *lockCenterButton;
    UIButton *stopRoutingButton;
    UIButton *pinMarkerButton;
    UIView *naviView;
    UILabel *totalDistanceLabel;
    UILabel *currentDistanceLabel;
    UILabel *naviLabel;
    UIView *InfoView;
    UIView *RSSIView;
    UIView *PlaceView;
    UITextView *Distance,*Place;
    LocationRegion *startTest;
    LocationRegion *endTest;
    GCDAsyncSocket *clientSocket;
    NSString *str;
    NSString *Name;
    NSString *IPAddress;
    NSTimer *myTimer;
    int rssi,alert_status;
    int now,findBaby;
    int scan_counter;
    int Place_research,Place_3Global,Place_Lab,place_HM;
    int Times_research,Times_3Global,Times_Lab,Times_HM;
    enum UIActionSheetMode actionSheetMode;
}

@end

@implementation Mybaby


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的寶貝";
    str = @"";
    [self initSails];
    [self initUI];
    printf("Beacon QAQ");
    baby3 = [BabyBluetooth shareBabyBluetooth];
    //设置蓝牙委托
    [self babyDelegate];
    baby3.scanForPeripherals().begin();
    rssi=-100;
    Place_3Global=-100;
    Place_Lab=-100;
    Place_research=-100;
    place_HM=-100;
    Times_research=0;
    Times_Lab=0;
    Times_3Global=0;
    Times_HM=0;
    findBaby=0;
    scan_counter=0;
    alert_status=0;
    IPAddress=@"192.168.43.105";
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态
    myTimer=[NSTimer scheduledTimerWithTimeInterval:0.1
                                             target:self
                                           selector:@selector(doSomethingWhenTimeIsUp:)
                                           userInfo:nil
                                            repeats:NO];
    // Do any additional setup after loading the view.
    [[sailsMapView getRoutingManager] setStartMakerImage:[UIImage imageNamed:@"BabyIcon"]];
    [[sailsMapView getRoutingManager] setStartMakerFrame:48];
    
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [myTimer invalidate];
    myTimer = nil;
}
-(void)babyDelegate{
    
    
    //设置扫描到设备的委托
    [baby3 setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        Name = peripheral.name;
        rssi = [RSSI intValue];
        if(rssi>0)rssi=-100;
        if([Name isEqualToString:@"WoodBeacon3"]==true){
            //專題研究室
            Place_research=rssi;
        }
        else if([Name isEqualToString:@"WoodBeacon2"]==true){
            //三國
            Place_3Global=rssi;
        }
        else if([Name isEqualToString:@"HM-10"]==true){
            place_HM=rssi;
            NSString *formatString = NSLocalizedString(@"%.2fm", @"Format string for rssi distance.");
            if([self calcDistByRSSI:place_HM]<50){
                Distance.text = [NSString stringWithFormat:formatString,[self calcDistByRSSI:place_HM]];
            }
        }
        else if([Name isEqualToString:@"HM-11"]==true){
            place_HM=rssi;
            NSString *formatString = NSLocalizedString(@"%.2fm", @"Format string for rssi distance.");
            if([self calcDistByRSSI:place_HM]<50){
                Distance.text = [NSString stringWithFormat:formatString,[self calcDistByRSSI:place_HM]];
            }
            
            [self alert_baby];
            
            
        }
        else if([Name isEqualToString:@"corner05"]==true){
            //無線網路研究室
            Place_Lab=rssi;
        }
        printf("搜索到了设备:%s(Rssi=%s)\n",[peripheral.name UTF8String],[[RSSI stringValue] UTF8String]);
    }];
    
    //过滤器
    //设置查找设备的过滤器
    [baby3 setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        //最常用的场景是查找某一个前缀开头的设备
        //if ([peripheralName hasPrefix:@"Pxxxx"] ) {
        //    return YES;
        //}
        //return NO;
        //设置查找规则是名称大于1 ， the search rule is peripheral.name length > 1
        if (peripheralName.length >1) {
            return YES;
        }
        return NO;
    }];
}
-(void)alert_baby{
    if(alert_status==0){
        alert_status++;
        NSString *str = @"您的小孩被抱起了！！！";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警報"
                                                        message:str
                                                       delegate:self
                                              cancelButtonTitle:@"確定"
                                              otherButtonTitles:nil];
        
        // 設定樣式
        //[alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert show];
        [self sound];
        alert_status++;
    }
    else if(alert_status!=10){
        alert_status++;
    }
    else{
        alert_status=0;
    }
}
-(void)sound{
    SystemSoundID soundID;
    //NSBundle来返回音频文件路径
    NSString *soundFile = [[NSBundle mainBundle] pathForResource:@"dive2" ofType:@"wav"];
    //建立SystemSoundID对象，但是这里要传地址(加&符号)。 第一个参数需要一个CFURLRef类型的url参数，要新建一个NSString来做桥接转换(bridge)，而这个NSString的值，就是上面的音频文件路径
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundFile], &soundID);
    //播放提示音 带震动
    AudioServicesPlayAlertSound(soundID);
    //播放系统声音
    //    AudioServicesPlaySystemSound(soundID);
}

- (IBAction)onIPsettingClick:(id)sender
{
    NSString *str = @"請輸入伺服器IP";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"網路IP設定"
                                                    message:str
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles: @"確定", nil];
    
    // 設定樣式
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    //先將文字框 TextField 設定為實體物件
    nameField = [alert textFieldAtIndex:0];
    //phoneField = [alert textFieldAtIndex:1];
    
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //NSLog(@"num=%i", buttonIndex);
    //提示
    switch (buttonIndex) {
        case 0:
            printf("取消..");
            break;
        case 1:
            // Xcode5.0 之後的做法，在此進行讀取
            IPAddress=[nameField text];
            NSError * error = nil;
            [self->clientSocket disconnect];
            [self->clientSocket connectToHost:IPAddress onPort:7777 error:&error];
            //[self->clientSocket writeData:[@"{\"userPasswd\":\"T00234\",\"userName\":\"T00234\"}\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
            //[self->clientSocket readDataWithTimeout:-1 tag:0];
            break;
    }
}
- (IBAction)lockCenterButtonClicked:(UIButton *)sender
{
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(doSomethingWhenTimeIsUp:)
                                   userInfo:nil
                                    repeats:NO];
    
}
- (void) rescan:(NSTimer*)t {
    baby3.scanForPeripherals().begin();
    myTimer=[NSTimer scheduledTimerWithTimeInterval:0.1
                                             target:self
                                           selector:@selector(doSomethingWhenTimeIsUp:)
                                           userInfo:nil
                                            repeats:NO];
}
- (void) doSomethingWhenTimeIsUp:(NSTimer*)t {
    NSArray *a=[[NSArray alloc] init];
    [baby3 cancelScan];
    if(scan_counter==0){
        Place_3Global=-100;
        Place_Lab=-100;
        Place_research=-100;
        place_HM=-100;
        Times_3Global=0;
        Times_Lab=0;
        Times_research=0;
    }
    if(scan_counter!=15){
        if(Place_3Global==-100&&Place_Lab==-100&&Place_research==-100);
        else if(Place_3Global>=Place_Lab&&Place_3Global>=Place_research){
            Times_3Global++;
        }
        else if(Place_Lab>=Place_research&&Place_Lab>=Place_3Global){
            Times_Lab++;
        }
        else if(Place_research>=Place_3Global&&Place_research>=Place_Lab){
            Times_research++;
        }
        printf("rssi(%d,%d,%d,%d)\n",Place_research,Place_3Global,Place_Lab,place_HM);
        printf("times(%d,%d,%d)\n",Times_research,Times_3Global,Times_Lab);
        scan_counter++;
        myTimer=[NSTimer scheduledTimerWithTimeInterval:0.1
                                                 target:self
                                               selector:@selector(rescan:)
                                               userInfo:nil
                                                repeats:NO];
    }
    else{
        if(Times_3Global==0&&Times_Lab==0&&Times_research==0){
            
        }
        else if(Times_research>=Times_Lab&&Times_research>=Times_3Global){
            //專題研究室
            a =[sails getLocationRegionList:@"2"][76];
            now=76;
        }
        else if(Times_3Global>=Times_Lab&&Times_3Global>=Times_research){
            //三國
            a =[sails getLocationRegionList:@"2"][84];
            now=84;
        }
        else{
            //無線網路研究室
            a =[sails getLocationRegionList:@"2"][83];
            now=83;
        }
        [baby3 cancelScan];
        //[self->clientSocket writeData:[@"{\"status\":2}\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        scan_counter=0;
        myTimer=[NSTimer scheduledTimerWithTimeInterval:0.1
                                                 target:self
                                               selector:@selector(doSomethingWhenTimeIsUp2:)
                                               userInfo:nil
                                                repeats:NO];
    }
}
- (float)calcDistByRSSI:(int)rssi2
{
    int iRssi = abs(rssi2);
    float power = (iRssi-59)/(10*2.0);
    return pow(10, power);
}
- (void) doSomethingWhenTimeIsUp2:(NSTimer*)t {
    baby3.scanForPeripherals().begin();
    LocationRegion *a=[[NSArray alloc] init];
    //[self->clientSocket writeData:[@"{\"status\":2}\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    myTimer=[NSTimer scheduledTimerWithTimeInterval:0.1
                                             target:self
                                           selector:@selector(doSomethingWhenTimeIsUp:)
                                           userInfo:nil
                                            repeats:NO];
    if(place_HM!=-100){
        printf("SetBabyIcon");
        [[sailsMapView getRoutingManager] setStartMakerImage:[UIImage imageNamed:@"BabyIcon"]];
        [[sailsMapView getRoutingManager] setStartMakerFrame:48];
        a=[sails getLocationRegionList:@"2"][now];
        [self setStartPlace: a];
        Place.text=[NSString stringWithFormat:@"%@",[a label]];
        findBaby=0;
        //Distance.text = place_HM;
    }
    else{
        Distance.text=@"超出範圍";
        findBaby=1;
        [self->clientSocket writeData:[@"{\"status\":2}\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    }
    /*
    if(str.length>30&&Place_3Global==-100&&Place_Lab==-100&&Place_research==-100&&place_HM==-100
       ){
        NSString * tmp = [[str componentsSeparatedByString:@"location\":\""] objectAtIndex:1];
        tmp = [tmp substringToIndex:[tmp rangeOfString:@"\",\"user"].location];
        if([tmp isEqual:@"unknown"])tmp=@"院共同實驗室College Common Lab";
        [self setStartPlace:  [sails getLocationRegionList:@"2"][[self FindIndexByName:tmp]]];
    }+
    else{
        [sailsMarkerManager clearMarkers];
    }
     */
}


-(int)FindIndexByName:(NSString*)Label{
    NSArray*Arr=[sails getLocationRegionList:@"2"];
    NSUInteger count = [Arr count];
    for (int i = 0 ; i != count ; i++){
        id obj = [Arr objectAtIndex:i];
        NSString*l =[obj label];
        if([l isEqualToString:Label]){
            return i;
        }
        if(i<10){
            i+=70;
        }
    }
    return 83;
}
-(void)setStartPlace:(LocationRegion*)location
{
    [self->clientSocket writeData:[@"{\"status\":2}\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [sailsMarkerManager clearMarkers];
    [sailsPathRoutingManager setStartRegion:location];
    [sailsMarkerManager setLocationRegionMarker:location andImage:[UIImage imageNamed:@"BabyIcon"] andMarkerFrame:48 andIsBoundCenter:true];
    //[self->clientSocket writeData:[[NSString stringWithFormat:@"{\"status\":1,\"location\":\"%@\"}\r\n",[location  label]] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    //[sailsPathRoutingManager enableRouting];
    /*if (([sails isLocationEngineStarted] && [sailsPathRoutingManager getStartRegion] == nil) || (![sails isLocationEngineStarted] && [sailsPathRoutingManager getStartRegion] != nil)) {
     [sailsPathRoutingManager enableRouting];
     //[self animateFunctionViewHorizontal:NaviView Hidden:false];
     //sailsPinMarkerManager.hidden = true;
     }*/
    /*
    if ([sails isLocationEngineStarted]) {
        printf("Error");
        //set routing start point to current user location
        [sailsPathRoutingManager setStartRegion:nil];
        
        //set routing end point marker icon image
        [sailsPathRoutingManager setTargetMakerImage:[UIImage imageNamed:@"destination"]];
        
        //set routing end point marker icon frame
        [sailsPathRoutingManager setTargetMakerFrame:48];
        
        //set routing path's color
        Paint *routingPathPaint = [sailsPathRoutingManager getPathPaint];
        routingPathPaint.strokeColor = [UIColor colorWithRed:53.0/255.0 green:179.0/255.0 blue:229.0/255.0 alpha:255.0/255.0];
        
        stopRoutingButton.hidden = false;
        
        [self animateNaviViewLarge:true];
        
    }else {
        printf("Error2");
        //set routing end point marker icon image
        //[sailsPathRoutingManager setTargetMakerImage:[UIImage imageNamed:@"map_destination"]];
        
        //set routing end point marker icon frame
        //[sailsPathRoutingManager setTargetMakerFrame:48];
        
        //set routing path's color
        //Paint *routingPathPaint = [sailsPathRoutingManager getPathPaint];
        //routingPathPaint.strokeColor = [UIColor colorWithRed:133.0/255.0 green:176.0/255.0 blue:56.0/255.0 alpha:255.0/255.0];
        
        //if ([sailsPathRoutingManager getStartRegion] != nil) {
        //    stopRoutingButton.hidden = false;
        //}
    }
    */
}
-(void)viewDidDisappear{
    [clientSocket disconnect];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


#pragma mark - Initialization Method

//init No.1
- (void)initSails
{
    //Create map view
    sailsMapView = [[SailsLocationMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view = sailsMapView;
    
    //Create sails object
    sails = [[Sails alloc] init];
    //[sails setMode:WITH_GPS];
    //set map view to sails object
    [sails setSailsLocationMapView:sailsMapView];
    Paint *accuracyCirclePaint = [[Paint alloc] init];
    accuracyCirclePaint.strokeColor = [UIColor colorWithRed:53/255.0 green:179/255.0 blue:229/255.0 alpha:0/255.0];
    accuracyCirclePaint.fillColor = [UIColor colorWithRed:53/255.0 green:179/255.0 blue:229/255.0 alpha:0/255.0];
    accuracyCirclePaint.strokeWidth = 0;
    
    [sailsMapView setLocationMarker:[UIImage imageNamed:@"myloc_arr"] arrowImage:[UIImage imageNamed:@"myloc_arr"] accuracyCirclePaint:accuracyCirclePaint iconFrame:100];    //get marker manager
    sailsMarkerManager = [sailsMapView getMarkerManager];
    //get pin marker manager
    sailsPinMarkerManager = [sailsMapView getPinMarkerManager];
    //get path routing manager
    sailsPathRoutingManager = [sailsMapView getRoutingManager];
    
    //set floor number sort rule from descending to ascending.
    [sails setReverseFloorList:true];
    
    //load location data
    __weak SailsLocationMapView *weakSailsMapView = sailsMapView;
    __weak Mybaby *weakSelf = self;
    
    [sails loadCloudBuilding:@"11368c21cf464c1aa587b7ede79aab8b"
                  buildingID:@"5405920d1ff15731210001f3"
                     success:^(void){
                         floorNameList = [sails getFloorNameList];
                         [weakSailsMapView loadFloorMap:[floorNameList objectAtIndex:0]];
                         //weakSelf.navigationItem.title = [sails getFloorDescription:[floorNameList firstObject]];
                         //[sails setGPSFloorLayer:[floorNameList lastObject]];
                         allLocationRegionOfFloors = [weakSelf getAllLocationRegionOfFloors];
                         [weakSailsMapView startAnimationToZoom:18];
                         [poiTableView reloadData];
                         self.view.backgroundColor = [UIColor whiteColor];
                     }
                     failure:^(NSError *error) {
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SailsSDK" message:error.localizedDescription delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
                         [alertView show];
                     }];
    self->clientSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError * error = nil;
    [self->clientSocket connectToHost:@"192.168.43.105" onPort:7777 error:&error];
    
}
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port { //创建的socket单例
    [self->clientSocket writeData:[@"{\"userPasswd\":\"D0441320\",\"userName\":\"D0441320\"}\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [self->clientSocket readDataWithTimeout:-1 tag:0];
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([string containsString:@"登入成功"]) {
        [self->clientSocket writeData:[@"{\"status\":2}\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    }
    else{
        str = string;
        if(findBaby==1){
            NSString * tmp = [[str componentsSeparatedByString:@"location\":\""] objectAtIndex:1];
            tmp = [tmp substringToIndex:[tmp rangeOfString:@"\",\"user"].location];
            if([tmp isEqual:@"unknown"])tmp=@"院共同實驗室College Common Lab";
            [self setStartPlace:  [sails getLocationRegionList:@"2"][[self FindIndexByName:tmp]]];
            Place.text=tmp;
        }
    }
    [self->clientSocket readDataWithTimeout:-1 tag:0];
    
}


//init No.2
- (void)initUI
{
    //NSMutableArray *leftItems = [[NSMutableArray alloc] init];
    NSMutableArray *rightItems = [[NSMutableArray alloc] init];
    
    //init POI button
    /*mBarButtonPOI = [[UIBarButtonItem alloc] initWithTitle:@"POIs" style:UIBarButtonItemStylePlain target:self action:@selector(onNaviBarButtonPOIClick:)];
     [leftItems addObject:mBarButtonPOI];*/
    
    //init floor button
    /*mBarButtonFloor = [[UIBarButtonItem alloc] initWithTitle:@"Floor" style:UIBarButtonItemStylePlain target:self action:@selector(onNaviBarButtonFloorClick:)];
     [rightItems addObject:mBarButtonFloor];*/
    //self.navigationItem.leftBarButtonItems = leftItems;
    
    IPsetting = [[UIBarButtonItem alloc] initWithTitle:@"IP" style:UIBarButtonItemStylePlain target:self action:@selector(onIPsettingClick:)];
    [rightItems addObject:IPsetting];
    //init switch button
    mBarButtonSwitch = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStylePlain target:self action:@selector(onNaviBarButtonSwitchClick:)];
    [rightItems addObject:mBarButtonSwitch];
    
    //init routing mode button
    /*mBarButtonRoutinMode = [[UIBarButtonItem alloc] initWithTitle:@"Mode" style:UIBarButtonItemStylePlain target:self action:@selector(onNaviBarButtonRoutingModeClick:)];
     [rightItems addObject:mBarButtonRoutinMode];*/
    self.navigationItem.rightBarButtonItems = rightItems;
    
    //init UIView info for baby device info
    InfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 630, 415, 107)];
    InfoView.backgroundColor=UIColor.lightGrayColor;
    [self.view addSubview:InfoView];
    
    //init RSSIView in InfoView
    RSSIView = [[UIView alloc]initWithFrame:CGRectMake(0, 3, 206, 107)];
    RSSIView.backgroundColor=UIColor.whiteColor;
    [InfoView addSubview:RSSIView];
    UIImageView * distanceImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 80, 80)];
    distanceImg.image=[UIImage imageNamed:@"DistanceIcon.jpg"];
    [RSSIView addSubview:distanceImg];
    Distance = [[UITextView alloc]initWithFrame:CGRectMake(80,30 , 120, 60)];
    Distance.text=@"無訊號";
    Distance.font= [UIFont fontWithName:@"HelveticaNeue" size:25.0];
    [RSSIView addSubview:Distance];
    
    //init PlaceView in InfoView
    PlaceView = [[UIView alloc]initWithFrame:CGRectMake(209, 3, 206, 107)];
    PlaceView.backgroundColor=UIColor.whiteColor;
    [InfoView addSubview:PlaceView];
    UIImageView * LocationImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 80, 80)];
    LocationImg.image=[UIImage imageNamed:@"LocationIcon.jpg"];
    [PlaceView addSubview:LocationImg];
    Place =[[UITextView alloc]initWithFrame:CGRectMake(80,20 , 120, 70)];
    Place.text=@"未定位";
    Place.font= [UIFont fontWithName:@"HelveticaNeue" size:25.0];
    [PlaceView addSubview:Place];
    
    //init zoom in button
    zoomInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [zoomInButton addTarget:self action:@selector(zoomInButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [zoomInButton setImage:[UIImage imageNamed:@"zoomin"] forState: UIControlStateNormal];
    [zoomInButton setImage:[UIImage imageNamed:@"zoomin_p"] forState: UIControlStateHighlighted];
    zoomInButton.frame = CGRectMake(0, 0, 45, 45);
    zoomInButton.center = CGPointMake(360, [UIScreen mainScreen].bounds.size.height*19/24-45);
    [self.view addSubview:zoomInButton];
    
    //init zoom out button
    zoomOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [zoomOutButton addTarget:self action:@selector(zoomOutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [zoomOutButton setImage:[UIImage imageNamed:@"zoomout"] forState: UIControlStateNormal];
    [zoomOutButton setImage:[UIImage imageNamed:@"zoomout_p"] forState: UIControlStateHighlighted];
    zoomOutButton.frame = CGRectMake(0, 0, 45, 45);
    zoomOutButton.center = CGPointMake(360, [UIScreen mainScreen].bounds.size.height*19/24);
    [self.view addSubview:zoomOutButton];
    
    //init lock center button
    lockCenterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [lockCenterButton addTarget:self action:@selector(lockCenterButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [lockCenterButton setImage:[UIImage imageNamed:@"lockCenter1"] forState:UIControlStateNormal];
    lockCenterButton.frame = CGRectMake(0, 0, 45, 45);
    lockCenterButton.center = CGPointMake(30, [UIScreen mainScreen].bounds.size.height*19/24);
    lockCenterButton.tag = 1;
    [self.view addSubview:lockCenterButton];
    lockCenterButton.hidden = true;
    
    //init stop routing button
    stopRoutingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [stopRoutingButton addTarget:self action:@selector(stopRoutingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [stopRoutingButton setImage:[UIImage imageNamed:@"stop_icon"] forState:UIControlStateNormal];
    //    stopRoutingButton.frame = CGRectMake(0, 0, 36, 36);
    //    stopRoutingButton.center = CGPointMake(290, 84);
    stopRoutingButton.frame = CGRectMake(0, 0, 42, 42);
    stopRoutingButton.center = CGPointMake(30, [UIScreen mainScreen].bounds.size.height*19/24-45);
    stopRoutingButton.tag = 2;
    [self.view addSubview:stopRoutingButton];
    stopRoutingButton.hidden = true;
    
    //init place a pin marker button
    /*
     pinMarkerButton = [UIButton buttonWithType:UIButtonTypeSystem];
     [pinMarkerButton addTarget:self action:@selector(pinMarkerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
     [pinMarkerButton setTitle:@"Place a PinMarker" forState:UIControlStateNormal];
     pinMarkerButton.frame = CGRectMake(0, 0, 160, 40);
     pinMarkerButton.center = CGPointMake(80, 84);
     pinMarkerButton.tag = 3;
     [self.view addSubview:pinMarkerButton];
     */
    //init navi view
    naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
    naviView.center = CGPointMake(160, 124);//164
    naviView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    [self.view addSubview:naviView];
    
    totalDistanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
    totalDistanceLabel.center = CGPointMake(160, 15);
    totalDistanceLabel.text = @"總距離 :";
    totalDistanceLabel.textAlignment = NSTextAlignmentRight;
    totalDistanceLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:181.0/255.0 blue:229.0/255.0 alpha:255.0/255.0];
    [naviView addSubview:totalDistanceLabel];
    
    currentDistanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
    currentDistanceLabel.center = CGPointMake(160, 45);
    currentDistanceLabel.text = @"當前距離 :";
    currentDistanceLabel.textAlignment = NSTextAlignmentRight;
    currentDistanceLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:187.0/255.0 blue:51.0/255.0 alpha:255.0/255.0];
    [naviView addSubview:currentDistanceLabel];
    
    naviLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 60)];
    naviLabel.center = CGPointMake(160, 90);
    naviLabel.text = @"導航提示";
    naviLabel.numberOfLines = 2;
    naviLabel.textAlignment = NSTextAlignmentLeft;
    naviLabel.textColor = [UIColor colorWithRed:153.0/255.0 green:204.0/255.0 blue:0.0/255.0 alpha:255.0/255.0];
    [naviView addSubview:naviLabel];
    
    [self animateFunctionViewHorizontal:naviView Hidden:YES];
    [self animateNaviViewLarge:NO];
    
    //init poi table view
    CGSize frameSize = self.view.frame.size;
    const float fNaviBarMaxY = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    CGRect frameRect = CGRectMake(0, fNaviBarMaxY, frameSize.width, frameSize.height - fNaviBarMaxY);
    poiTableView = [[UITableView alloc] initWithFrame:frameRect style:UITableViewStyleGrouped];
    poiTableView.delegate = self;
    poiTableView.dataSource = self;
    [self.view addSubview:poiTableView];
    [self animateFunctionViewVertical:poiTableView Hidden:YES];
    
    __weak SailsLocationMapView *weakSailsMapView = sailsMapView;
    __weak UIButton *weakLockCenterButton = lockCenterButton;
    
    //create mode change call back block
    [sailsMapView setOnModeChangedBlock:^(void){
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if ((([weakSailsMapView getMapControlMode] & LocationCenterLockMode) == LocationCenterLockMode) && (([weakSailsMapView getMapControlMode] & FollowPhoneHeagingMode) == FollowPhoneHeagingMode)) {
                [weakLockCenterButton setImage:[UIImage imageNamed:@"lockCenter3"] forState:UIControlStateNormal];
            }else if (([weakSailsMapView getMapControlMode] & LocationCenterLockMode) == LocationCenterLockMode) {
                [weakLockCenterButton setImage:[UIImage imageNamed:@"lockCenter2"] forState:UIControlStateNormal];
            }else {
                [weakLockCenterButton setImage:[UIImage imageNamed:@"lockCenter1"] forState:UIControlStateNormal];
            }
        });
    }];
    
    __weak MarkerManager *weakSailsMarkerManager = sailsMarkerManager;
    __weak PathRoutingManager *weakRoutingManager = sailsPathRoutingManager;
    __weak Sails *weakSails = sails;
    __weak UIButton *weakStopRoutingButton = stopRoutingButton;
    __weak Mybaby *weakSelf = self;
    __weak UIView *weakNaviView = naviView;
    __weak UIButton *weakPinMarkerButton = pinMarkerButton;
    
    //create location change call back block
    [sails setOnLocationChangeEventBlock:^{
        if ([weakSailsMapView isCenterLock] && ![weakSailsMapView isInLocationFloor] && ![[weakSails getFloor] isEqualToString:@""] && [weakSails isLocationFix]) {
            [weakSailsMapView loadCurrentLocationFloorMap];
            [weakSailsMapView startAnimationToZoom:19];
        }
    }];
    
    
    
    
    
    
    //create region long click call back block
    /*[sailsMapView setOnRegionLongClickBlock:^(NSArray *locationRegions) {
     [weakSailsMarkerManager clearMarkers];
     [weakRoutingManager setStartRegion:[locationRegions firstObject]];
     [weakSailsMarkerManager setLocationRegionMarker:[locationRegions firstObject] andImage:[UIImage imageNamed:@"start_point"] andMarkerFrame:48 andIsBoundCenter:true];
     //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
     }];
     */
    //create region click call back block
    /*
    [sailsMapView setOnRegionClickBlock:^(NSArray *locationRegions) {
        
        [weakSailsMarkerManager clearMarkers];
        [weakRoutingManager setStartRegion:[locationRegions firstObject]];
        [weakSailsMarkerManager setLocationRegionMarker:[locationRegions firstObject] andImage:[UIImage imageNamed:@"start_point"] andMarkerFrame:48 andIsBoundCenter:true];
        
        [self->clientSocket writeData:[[NSString stringWithFormat:@"{\"status\":1,\"location\":\"%@\"}\r\n",[[locationRegions firstObject] getName]] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        
        //begin to routing
        if ([weakSails isLocationEngineStarted]) {
            printf("YA1");
            //set routing start point to current user location
            [weakRoutingManager setStartRegion:nil];
            
            //set routing end point marker icon image
            [weakRoutingManager setTargetMakerImage:[UIImage imageNamed:@"destination"]];
            
            //set routing end point marker icon frame
            [weakRoutingManager setTargetMakerFrame:48];
            
            //set routing path's color
            Paint *routingPathPaint = [weakRoutingManager getPathPaint];
            routingPathPaint.strokeColor = [UIColor colorWithRed:53.0/255.0 green:179.0/255.0 blue:229.0/255.0 alpha:255.0/255.0];
            
            weakStopRoutingButton.hidden = false;
            
            [weakSelf animateNaviViewLarge:true];
            
        }else {
            printf("YA2");
            //set routing end point marker icon image
            [weakRoutingManager setTargetMakerImage:[UIImage imageNamed:@"map_destination"]];
            
            //set routing end point marker icon frame
            [weakRoutingManager setTargetMakerFrame:48];
            
            //set routing path's color
            Paint *routingPathPaint = [weakRoutingManager getPathPaint];
            routingPathPaint.strokeColor = [UIColor colorWithRed:133.0/255.0 green:176.0/255.0 blue:56.0/255.0 alpha:255.0/255.0];
            
            if ([weakRoutingManager getStartRegion] != nil) {
                weakStopRoutingButton.hidden = false;
            }
        }
        
        //set routing end point location
        [self->clientSocket writeData:[@"{\"status\":2}\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        
        NSString * tmp = [[str componentsSeparatedByString:@"location\":\""] objectAtIndex:1];
        tmp = [tmp substringToIndex:[tmp rangeOfString:@"\",\"user"].location];
        if([tmp isEqual:@"unknown"])tmp=@"院共同實驗室College Common Lab";
        [weakRoutingManager setTargetRegion:[sails getLocationRegionList:@"2"][[self FindIndexByName:tmp]]];
        
        //begin to route
        if (([weakSails isLocationEngineStarted] && [weakRoutingManager getStartRegion] == nil) || (![weakSails isLocationEngineStarted] && [weakRoutingManager getStartRegion] != nil)) {
            [weakRoutingManager enableRouting];
            [weakSelf animateFunctionViewHorizontal:weakNaviView Hidden:false];
            weakPinMarkerButton.hidden = true;
        }
        
        if(Place_3Global==-100&&Place_Lab==-100&&Place_research==-100){
            //[sailsMarkerManager clearMarkers];
            [sailsPathRoutingManager setStartRegion:[sails getLocationRegionList:@"2"][[self FindIndexByName:tmp]]];
            [sailsMarkerManager setLocationRegionMarker:[sails getLocationRegionList:@"2"][[self FindIndexByName:tmp]] andImage:[UIImage imageNamed:@"start_point"] andMarkerFrame:48 andIsBoundCenter:true];
        }
        
        
    }];
    */
    //design some action in floor change call back.
    [sailsMapView setOnFloorChangedBeforeBlock:^(NSString *floorName) {
        
    }];
    
    [sailsMapView setOnFloorChangedAfterBlock:^(NSString *floorName) {
        //weakSelf.navigationItem.title = [weakSails getFloorDescription:floorName];
    }];
    
    [self configRouting];
}

- (void)configRouting
{
    [sailsPathRoutingManager setStartMakerImage:[UIImage imageNamed:@"start_point"]];
    [sailsPathRoutingManager setStartMakerFrame:48];
    [sailsPathRoutingManager setTargetMakerImage:[UIImage imageNamed:@"map_destination"]];
    [sailsPathRoutingManager setTargetMakerFrame:48];
    __weak PathRoutingManager *weakSailsPathRoutingManager = sailsPathRoutingManager;
    __weak SailsLocationMapView *weakSailsMapView = sailsMapView;
    __weak Mybaby *weakSelf = self;
    __weak MarkerManager *weakSailsMarkerManager = sailsMarkerManager;
    __weak UILabel *weakTotalDistanceLabel = totalDistanceLabel;
    __weak UILabel *weakCurrentDistanceLabel = currentDistanceLabel;
    __weak UILabel *weakNaviLabel = naviLabel;
    __weak Sails *weakSails = sails;
    __weak UIButton *weakStopRoutingButton = stopRoutingButton;
    [sailsPathRoutingManager setOnRoutingUpdateRouteSuccessBlock:^{
        NSArray *gpList = [weakSailsPathRoutingManager getCurrentFloorRoutingPathNodes];
        [weakSailsMapView autoSetMapZoomAndView:gpList];
    }];
    [sailsPathRoutingManager setOnRoutingUpdateArrivedBlock:^(LocationRegion *targetRegion) {
        [weakSelf stopRoutingButtonClicked:weakStopRoutingButton];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SailsSDK" message:[NSString stringWithFormat:@"已到達 : %@" ,[targetRegion getName]] delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
        [alertView show];
    }];
    [sailsPathRoutingManager setOnRoutingUpdateRouteFailBlock:^{
        [weakSelf stopRoutingButtonClicked:weakStopRoutingButton];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SailsSDK" message:@"Route Fail" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
        [alertView show];
    }];
    [sailsPathRoutingManager setOnRoutingUpdateTotalDistanceRefreshBlock:^(int distance) {
        weakTotalDistanceLabel.text = [NSString stringWithFormat:@"Total Routing Distance : %d (m)" ,distance];
    }];
    [sailsPathRoutingManager setOnRoutingUpdateReachNearestTransferDistanceRefreshBlock:^(int distance, PathRoutingNodeType nodeType) {
        switch (nodeType) {
            case ElevatorType:
                weakCurrentDistanceLabel.text = [NSString stringWithFormat:@"To Nearest Elevator Distance : %d (m)" ,distance];
                break;
                
            case EscalatorType:
                weakCurrentDistanceLabel.text = [NSString stringWithFormat:@"To Nearest Escalator Distance : %d (m)" ,distance];
                break;
                
            case StairType:
                weakCurrentDistanceLabel.text = [NSString stringWithFormat:@"To Nearest Stair Distance : %d (m)" ,distance];
                break;
                
            case DestinationType:
                weakCurrentDistanceLabel.text = [NSString stringWithFormat:@"To Destination Distance : %d (m)" ,distance];
                break;
        }
    }];
    [sailsPathRoutingManager setOnRoutingUpdateSwitchFloorInfoRefreshBlock:^(NSArray *infoList, int nearestIndex) {
        //set markers for every transfer location
        for (SwitchFloorInfo *mS in infoList) {
            if (mS.direction != GoTargetDirection) {
                [weakSailsMarkerManager setLocationRegionMarker:mS.fromBelongsRegion andImage:[UIImage imageNamed:@"transfer_point"] andMarkerFrame:48 andIsBoundCenter:true];
            }
        }
        //when location engine not turn,there is no current switch floor info.
        if (nearestIndex == -1) {
            return;
        }
        
        SwitchFloorInfo *sfInfo = [infoList objectAtIndex:nearestIndex];
        
        switch (sfInfo.nodeType) {
            case ElevatorType:
                if (sfInfo.direction == UpDirection) {
                    weakNaviLabel.text = [NSString stringWithFormat:@"導航提示 : \n請搭電梯上樓至%@" ,[weakSails getFloorDescription:sfInfo.toFloorName]];
                }else if (sfInfo.direction == DownDirection) {
                    weakNaviLabel.text = [NSString stringWithFormat:@"導航提示 : \n請搭電梯下樓至%@" ,[weakSails getFloorDescription:sfInfo.toFloorName]];
                }
                break;
                
            case EscalatorType:
                if (sfInfo.direction == UpDirection) {
                    weakNaviLabel.text = [NSString stringWithFormat:@"導航提示 : \n請搭手扶梯上樓至%@" ,[weakSails getFloorDescription:sfInfo.toFloorName]];
                }else if (sfInfo.direction == DownDirection) {
                    weakNaviLabel.text = [NSString stringWithFormat:@"導航提示 : \n請搭手扶梯下樓至%@" ,[weakSails getFloorDescription:sfInfo.toFloorName]];
                }
                break;
                
            case StairType:
                if (sfInfo.direction == UpDirection) {
                    weakNaviLabel.text = [NSString stringWithFormat:@"導航提示 : \n請走樓梯上樓至%@" ,[weakSails getFloorDescription:sfInfo.toFloorName]];
                }else if (sfInfo.direction == DownDirection) {
                    weakNaviLabel.text = [NSString stringWithFormat:@"導航提示 : \n請走樓梯下樓至%@" ,[weakSails getFloorDescription:sfInfo.toFloorName]];
                }
                break;
                
            case DestinationType:
                weakNaviLabel.text = [NSString stringWithFormat:@"導航提示 : \n請前往%@" ,[sfInfo.fromBelongsRegion getName]];
                break;
        }
    }];
}


#pragma mark - Button Method

- (IBAction)onNaviBarButtonPOIClick:(id)sender
{
    if ([poiTableView isHidden]) {
        [poiTableView reloadData];
        [self animateFunctionViewVertical:poiTableView Hidden:NO];
    }else {
        [self animateFunctionViewVertical:poiTableView Hidden:YES];
    }
}

- (IBAction)onNaviBarButtonFloorClick:(id)sender
{
    NSArray *floorDescList = [sails getFloorDescList];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    actionSheetMode = FloorSheetMode;
    for (NSString *floorName in floorDescList) {
        [actionSheet addButtonWithTitle:floorName];
    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet showInView:self.view];
}

- (IBAction)onNaviBarButtonRoutingModeClick:(id)sender
{
    NSArray *routingModeList = @[@"NormalRoutingMode", @"StairOnlyMode", @"EscalatorOnlyMode", @"ElevatorOnlyMode", @"ElevatorAndEscalatorMode"];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    actionSheetMode = RoutingSheetMode;
    for (NSString *routingMode in routingModeList) {
        [actionSheet addButtonWithTitle:routingMode];
    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet showInView:self.view];
}

- (IBAction)onNaviBarButtonSwitchClick:(id)sender
{
    if ([sails isLocationEngineStarted]) {
        [sails stopLocatingEngine];
        [sailsMapView setLocatorMarkerVisible:false];
        [sailsMapView setMapControlMode:GeneralMode];
        [sailsPathRoutingManager disableRouting];
        stopRoutingButton.hidden = true;
        [self animateNaviViewLarge:false];
        [self animateFunctionViewHorizontal:naviView Hidden:true];
        lockCenterButton.hidden = true;
        mBarButtonSwitch.title = @"Start";
        pinMarkerButton.hidden = false;
    }else {
        if ([sailsPathRoutingManager isRoutingEnable]) {
            [sailsPathRoutingManager disableRouting];
            stopRoutingButton.hidden = true;
            pinMarkerButton.hidden = false;
            [self animateNaviViewLarge:false];
            [self animateFunctionViewHorizontal:naviView Hidden:true];
        }
        [sails startLocatingEngine];
        [sailsMapView setLocatorMarkerVisible:true];
        [sailsMapView setMapControlMode:LocationCenterLockMode | FollowPhoneHeagingMode];
        lockCenterButton.hidden = false;
        mBarButtonSwitch.title = @"Stop";
        pinMarkerButton.hidden = true;
        [sailsPinMarkerManager clearPinMarkers];
    }
}

- (IBAction)zoomInButtonClicked:(UIButton *)sender
{
    [sailsMapView zoomIn];
}

- (IBAction)zoomOutButtonClicked:(UIButton *)sender
{
    [sailsMapView zoomOut];
}
/*
 - (IBAction)lockCenterButtonClicked:(UIButton *)sender
 {
 if ([sailsMapView isCenterLock]) {
 if (([sailsMapView getMapControlMode] & FollowPhoneHeagingMode) == FollowPhoneHeagingMode) {
 [sailsMapView setMapControlMode:([sailsMapView getMapControlMode] & ~FollowPhoneHeagingMode)];
 }else {
 [sailsMapView setMapControlMode:([sailsMapView getMapControlMode] | FollowPhoneHeagingMode)];
 }
 }else {
 [sailsMapView setMapControlMode:([sailsMapView getMapControlMode] | LocationCenterLockMode)];
 }
 }
 */
- (IBAction)stopRoutingButtonClicked:(UIButton *)sender
{
    [sailsPathRoutingManager disableRouting];
    [self animateNaviViewLarge:false];
    [self animateFunctionViewHorizontal:naviView Hidden:true];
    stopRoutingButton.hidden = true;
    if ([sails isLocationEngineStarted]) {
        pinMarkerButton.hidden = true;
    }else {
        pinMarkerButton.hidden = false;
    }
}

- (IBAction)pinMarkerButtonClicked:(UIButton *)sender
{
    [sailsPinMarkerManager setOnPinMarkerGenerateCallbackBlockWithMarkerImage:[UIImage imageNamed:@"parking_target"] markerFrame:48 isBoundCenter:NO callbackBlock:^(LocationRegionMarker *locationRegionMarker) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SailsSDK" message:@"One PinMarker Generated" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
        [alertView show];
    }];
}


#pragma mark - Operation Method

- (NSDictionary *)getAllLocationRegionOfFloors
{
    NSMutableDictionary *resultsOfFloors = [NSMutableDictionary dictionary];
    if (floorNameList != nil && [floorNameList count]) {
        for (NSString *floorName in floorNameList) {
            NSArray *tmp = [sails getLocationRegionList:floorName];
            resultsOfFloors[floorName] = tmp;
        }
    }
    return resultsOfFloors;
}

- (LocationRegion *)locationRegionAtIndexPath:(NSIndexPath *)indexPath
{
    LocationRegion *locationRegion;
    if (floorNameList != nil && allLocationRegionOfFloors != nil) {
        NSArray *result = allLocationRegionOfFloors[floorNameList[indexPath.section]];
        if (result != nil && [result count] > indexPath.row) {
            locationRegion = [result objectAtIndex:indexPath.row];
        }
    }
    return locationRegion;
}

- (void)setSailsRoutingMode:(NSString *)mode
{
    if ([mode isEqualToString:@"NormalRoutingMode"]) {
        [sailsPathRoutingManager setRoutingMode:NormalRoutingMode];
    }else if ([mode isEqualToString:@"StairOnlyMode"]) {
        [sailsPathRoutingManager setRoutingMode:StairOnlyMode];
    }else if ([mode isEqualToString:@"EscalatorOnlyMode"]) {
        [sailsPathRoutingManager setRoutingMode:EscalatorOnlyMode];
    }else if ([mode isEqualToString:@"ElevatorOnlyMode"]) {
        [sailsPathRoutingManager setRoutingMode:ElevatorOnlyMode];
    }else if ([mode isEqualToString:@"ElevatorAndEscalatorMode"]) {
        [sailsPathRoutingManager setRoutingMode:ElevatorAndEscalatorMode];
    }
}


#pragma mark - Animation Method

- (void)animateFunctionViewVertical:(UIView*)view Hidden:(BOOL)bHidden
{
    CGRect rcOutside = view.frame;
    rcOutside.origin.y = -rcOutside.size.height;
    if (bHidden) {
        if (![view isHidden]) {
            //Hide
            [UIView animateWithDuration:0.2f
                             animations:^{
                                 view.frame = rcOutside;
                             }
                             completion:^(BOOL finished) {
                                 [view setHidden:YES];
                             }];
        }
    } else {
        if ([view isHidden]) {
            //show
            [view setHidden:NO];
            [UIView animateWithDuration:0.2f
                             animations:^{
                                 CGSize frameSize = self.view.frame.size;
                                 const float fNaviBarMaxY = CGRectGetMaxY(self.navigationController.navigationBar.frame);
                                 CGRect frameRect = CGRectMake(0, fNaviBarMaxY, frameSize.width, frameSize.height - fNaviBarMaxY);
                                 view.frame = frameRect;
                             }];
        }
    }
}

- (void)animateFunctionViewHorizontal:(UIView*)view Hidden:(BOOL)bHidden
{
    CGRect rcOutside = view.frame;
    if (bHidden) {
        if (![view isHidden]) {
            //Hide
            rcOutside.origin.x = -rcOutside.size.width;
            [UIView animateWithDuration:0.2f
                             animations:^{
                                 view.frame = rcOutside;
                             }
                             completion:^(BOOL finished) {
                                 [view setHidden:YES];
                             }];
        }
    } else {
        if ([view isHidden]) {
            //show
            rcOutside.origin.x += rcOutside.size.width;
            [view setHidden:NO];
            [UIView animateWithDuration:0.2f
                             animations:^{
                                 view.frame = rcOutside;
                             }];
        }
    }
}

- (void)animateNaviViewLarge:(BOOL)large
{
    CGRect newFrame = naviView.frame;
    if (large) {
        if (naviView.frame.size.height < 40) {
            newFrame.size.height = 120.0;
            [UIView animateWithDuration:0.2f
                             animations:^{
                                 naviView.frame = newFrame;
                                 currentDistanceLabel.hidden = NO;
                                 naviLabel.hidden = NO;
                             }];
        }
    }else {
        if (naviView.frame.size.height > 40) {
            newFrame.size.height = 30.0;
            [UIView animateWithDuration:0.2f
                             animations:^{
                                 naviView.frame = newFrame;
                                 currentDistanceLabel.hidden = YES;
                                 naviLabel.hidden = YES;
                             }];
        }
    }
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheetMode == FloorSheetMode) {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        NSArray *floorDescList = [sails getFloorDescList];
        NSInteger index = [floorDescList indexOfObject:title];
        if (index != NSNotFound) {
            [sailsMapView loadFloorMap:[floorNameList objectAtIndex:index]];
            //self.navigationItem.title = title;
        }
    }else if (actionSheetMode == RoutingSheetMode) {
        [self setSailsRoutingMode:[actionSheet buttonTitleAtIndex:buttonIndex]];
    }
}


#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(allLocationRegionOfFloors != nil){
        return [allLocationRegionOfFloors count];
    }
    else return 0;
    // return (allLocationRegionOfFloors != nil)? [allLocationRegionOfFloors count] : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *result;
    if (floorNameList != nil && [floorNameList count] > section) {
        result = allLocationRegionOfFloors[floorNameList[section]];
    }
    return (result != nil) ? [result count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"poiCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"poiCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    LocationRegion *locationRegion = [self locationRegionAtIndexPath:indexPath];
    if (locationRegion != nil) {
        NSString *strName = [locationRegion getName];
        if (strName != nil && [strName length]) {
            cell.textLabel.text = strName;
        } else {
            cell.textLabel.text = locationRegion.chinese_t;
        }
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (floorNameList != nil && [floorNameList count] > 0) {
        return [sails getFloorEntireName:floorNameList[section]];
    }
    return @"";
}


#pragma mark - TableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 42.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocationRegion *locationRegion = [self locationRegionAtIndexPath:indexPath];
    if (locationRegion != nil) {
        [self animateFunctionViewVertical:poiTableView Hidden:YES];
        if (![sails isLocationEngineStarted]) {
            if (![[locationRegion getFloorName] isEqualToString:[sailsMapView getCurrentBrowseFloorName]]) {
                [sailsMapView loadFloorMap:[locationRegion getFloorName]];
            }
            if (19 > [sailsMapView getZoomLevel]) {
                [sailsMapView startAnimationToZoom:19];
            }
            GeoPoint *mapNewCenter = [[GeoPoint alloc] initWithLogitude:[locationRegion getCenterLongitude] latitude:[locationRegion getCenterLatitude]];
            [sailsMapView startMoveMapAnimationWithTarget:mapNewCenter];
            [sailsMarkerManager clearMarkers];
            [sailsMarkerManager setLocationRegionMarker:locationRegion andImage:[UIImage imageNamed:@"map_destination"] andMarkerFrame:48 andIsBoundCenter:false];
        }else {
            //set routing start point to current user location
            [sailsPathRoutingManager setStartRegion:nil];
            
            //set routing end point marker icon image
            [sailsPathRoutingManager setTargetMakerImage:[UIImage imageNamed:@"destination"]];
            
            //set routing end point marker icon frame
            [sailsPathRoutingManager setTargetMakerFrame:48];
            
            //set routing path's color
            Paint *routingPathPaint = [sailsPathRoutingManager getPathPaint];
            routingPathPaint.strokeColor = [UIColor colorWithRed:53.0/255.0 green:179.0/255.0 blue:229.0/255.0 alpha:255.0/255.0];
            
            stopRoutingButton.hidden = false;
            
            [self animateNaviViewLarge:true];
            
            //set routing end point location
            [sailsPathRoutingManager setTargetRegion:locationRegion];
            
            //begin to route
            if (([sails isLocationEngineStarted] && [sailsPathRoutingManager getStartRegion] == nil) || (![sails isLocationEngineStarted] && [sailsPathRoutingManager getStartRegion] != nil)) {
                [sailsPathRoutingManager enableRouting];
                [self animateFunctionViewHorizontal:naviView Hidden:false];
                pinMarkerButton.hidden = true;
            }
        }
    }
}

@end



