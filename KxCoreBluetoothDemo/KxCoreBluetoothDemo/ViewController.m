//
//  ViewController.m
//  KxCoreBluetoothDemo
//
//  Created by FD on 2018/11/1.
//  Copyright © 2018 FD. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "KxControlViewController.h"
@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate,UITableViewDelegate,UITableViewDataSource,KxControlViewControllerDelegate>

///中心设备
@property (nonatomic, strong) CBCentralManager *centeralManager;

///外设
@property (nonatomic, strong) CBPeripheral *peripheral;

@property (nonatomic, strong) NSMutableArray *peripheralArray;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) KxControlViewController *control;

@property (nonatomic, strong) NSMutableArray *serviceArray;

@property (nonatomic, strong) CBCharacteristic *positionCharacteristic;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self addRefreshButton];
    [self configCenteral];
    [self searchPeripheral];
    [self initControlVc];
}

//刷新搜索外设
- (void)addRefreshButton {
    UIButton *button = ({
        CGFloat w = [UIScreen mainScreen].bounds.size.width;
        CGFloat h = [UIScreen mainScreen].bounds.size.height;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(w - 80, h - 80, 80, 80)];
        btn.layer.cornerRadius = 40;
        [btn addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchDown];
        btn.backgroundColor = [UIColor blueColor];
        [btn setTitle:@"refresh" forState:UIControlStateNormal];
        btn;
    });
    [self.view addSubview:button];
}

- (void)initControlVc {
    KxControlViewController *control = [[KxControlViewController alloc] init];
    control.delegate = self;
    self.control = control;
}

- (void)refresh {
    [self.peripheralArray removeAllObjects];
    [self searchPeripheral];
}

/**
 配置中心设备
 */
- (void)configCenteral {
    self.centeralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}

/**
 搜索外设
 */
- (void)searchPeripheral {
    if (@available(iOS 10.0, *)) {
        if (self.centeralManager.state != CBManagerStatePoweredOn) {
            return;
        }
    } else {
    }
    [self.centeralManager stopScan];
    [self.centeralManager scanForPeripheralsWithServices:nil options:nil];
}

#pragma mark - Operation

- (void)sleep {
    if (!self.peripheral) {
        return;
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"sleep" forKey:@"status"];
    NSString *str = [self convertToJsonData:dict];
    NSData *data =[str dataUsingEncoding:NSUTF8StringEncoding];

    [self.peripheral writeValue:data forCharacteristic:self.positionCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)wakeUp {
    if (!self.peripheral) {
        return;
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"wake" forKey:@"status"];
    NSString *str = [self convertToJsonData:[dict copy]];
    NSData *data =[str dataUsingEncoding:NSUTF8StringEncoding];
    [self.peripheral writeValue:data forCharacteristic:self.positionCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)back {
    [self.centeralManager cancelPeripheralConnection:self.peripheral];
    [self refresh];
}

#pragma mark - Delegates
///状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStateUnknown:
            NSLog(@"未知状态");
            break;
        case CBManagerStatePoweredOn:
            NSLog(@"可用状态");
            [self searchPeripheral];
            break;
        case CBManagerStateResetting:
            NSLog(@"重设状态");
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"关闭状态");
            break;
        case CBManagerStateUnsupported:
            NSLog(@"不可用状态");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"未授权状态");
            break;
        default:
            break;
    }
}

///发现设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (![self isExistPeriperhal:peripheral]) {
        [self.peripheralArray addObject:peripheral];
        [self.tableView reloadData];
        NSString *peripheralName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
        NSLog(@"%@",peripheralName);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
        NSLog(@"外设的服务：%@",service);
    }
    CBService *service = peripheral.services.lastObject;
    // 根据UUID寻找服务中的特征
    if (service) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"EA0D"]] forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSArray *characteristics = [service characteristics];
    if (peripheral != self.peripheral) {
        NSLog(@"Wrong Peripheral.\n");
        return ;
    }
    if (error != nil) {
        NSLog(@"error: %@\n", error);
        return ;
    }
    for (CBCharacteristic *characteristic in characteristics) {
        if ([[[characteristic UUID] UUIDString] isEqualToString:@"EA0D"]) {
            self.positionCharacteristic = characteristic;
        }
    }
}


///连接上设备
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"connect success");
    [self.peripheral discoverServices:@[[CBUUID UUIDWithString:@"84941CC5-EA0D-4CAE-BB06-1F849CCF8495"]]];
    [self presentViewController:self.control animated:YES completion:nil];
}

///连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"connect failed");
}

///断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"disconnect");
}


#pragma mark - tableViewDelegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.peripheral = self.peripheralArray[indexPath.row];
    self.peripheral.delegate = self;
    [self.centeralManager cancelPeripheralConnection:self.peripheral];
    [self.centeralManager connectPeripheral:self.peripheral options:nil];
}

#pragma mark - tableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripheralArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bluetooth"];
    if (!cell) {
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"bluetooth"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CBPeripheral *peripheral = self.peripheralArray[indexPath.row];
    NSString *name = peripheral.name;
    if (!name) {
        name = @"Unnamed";
    }
    cell.textLabel.text = name;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}


#pragma mark - Lazy Load

- (NSMutableArray *)peripheralArray {
    if (!_peripheralArray) {
        _peripheralArray = [[NSMutableArray alloc] init];
    }
    return _peripheralArray;
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}


-(NSString *)convertToJsonData:(NSDictionary *)dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
}

- (BOOL)isExistPeriperhal:(CBPeripheral *)peripheral {
    if (!peripheral.name) {
        return YES;
    }
    for (CBPeripheral *per in self.peripheralArray) {
        if ([per.name isEqualToString:peripheral.name]) {
            return YES;
            break;
        }
    }
    return NO;
}



@end
