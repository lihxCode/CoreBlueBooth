//
//  ViewController.m
//  KxBlueBooth
//
//  Created by FD on 2018/11/1.
//  Copyright © 2018 FD. All rights reserved.
//


#define kCharacteristicUUID @"EA0D"
#define kServiceUUID @"84941CC5-EA0D-4CAE-BB06-1F849CCF8495"
#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreServices/CoreServices.h>

@interface ViewController()<CBPeripheralManagerDelegate>
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableCharacteristic *characteristic;
@property (nonatomic, strong) CBMutableService *service;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self confiPeripheral];
    
}

- (void)confiPeripheral {
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (void)configCharacteristicAndService {
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
    CBMutableService *service = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
    CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyWrite|CBCharacteristicPropertyNotify|CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsWriteable|CBAttributePermissionsReadable];
    service.characteristics = @[characteristic];
    self.characteristic = characteristic;
    self.service = service;
    [self.peripheralManager removeAllServices];
    [self.peripheralManager addService:service];
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service
                    error:(NSError *)error {
    if (error) {
        NSLog(@"error service: %@", [error localizedDescription]);
    }else{
        [self startService];
    }
}



- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBManagerStatePoweredOn:
        {
            NSLog(@"正常状态");
            [self configCharacteristicAndService];
            break;
        }
        case CBManagerStatePoweredOff:
        case CBManagerStateUnknown:
        case CBManagerStateResetting:
        case CBManagerStateUnsupported:
        case CBManagerStateUnauthorized:
            NSLog(@"非正常状态");
            break;
        default:
            break;
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    if (error) {
        NSLog(@"failed");
    }else {
        NSLog(@"success");
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    CBATTRequest *request = requests[0];
    if ([request.characteristic.UUID isEqual:self.characteristic.UUID]) {
        self.characteristic.value = request.value;
        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
        NSData *data = request.value;
        NSString *cmdStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *dict = [self dictionaryWithJsonString:cmdStr];
        if ([[dict objectForKey:@"status"] isEqualToString:@"sleep"]) {
            [self sleep];
        }else if ([[dict objectForKey:@"status"] isEqualToString:@"wake"]){
            [self wakeUp];
        }
        NSLog(@"获取的数据%@",cmdStr);
    }
}

- (void)startService {
    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey:@[self.service.UUID], CBAdvertisementDataLocalNameKey:@"FD" }];
}

- (void)stopService {
    [self.peripheralManager stopAdvertising];
}

#pragma mark - SysOperation

- (void)sleep {
    io_registry_entry_t registerEntry = IORegistryEntryFromPath(kIOMasterPortDefault, "IOService:/IOResources/IODisplayWrangler");
    if (registerEntry) {
        IORegistryEntrySetCFProperty(registerEntry, CFSTR("IORequestIdle"), kCFBooleanTrue);
        IOObjectRelease(registerEntry);
    }
}

- (void)wakeUp {
    io_registry_entry_t registerEntry = IORegistryEntryFromPath(kIOMasterPortDefault, "IOService:/IOResources/IODisplayWrangler");
    if (registerEntry) {
        IORegistryEntrySetCFProperty(registerEntry, CFSTR("IORequestIdle"), kCFBooleanFalse);
        IOObjectRelease(registerEntry);
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}


- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (void)registerScreenStatusNotify {
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(receiveSleepNotification:) name:NSWorkspaceScreensDidSleepNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(receiveWakeNotification:) name:NSWorkspaceScreensDidWakeNotification object:nil];
}

- (void)receiveSleepNotification:(NSNotification *)info {
    
}

- (void)receiveWakeNotification:(NSNotification *)info {
    
}

- (OSStatus)sendAppleEventToSysProcess:(AEEventID)eventId {
    AEAddressDesc targetDsec;
    static const ProcessSerialNumber kPSNOfSystemProcess = {0,kSystemProcess};
    AppleEvent eventReply = {typeNull,NULL};
    AppleEvent eventToSend = {typeNull, NULL};
    OSStatus status = AECreateDesc(typeProcessSerialNumber, &kPSNOfSystemProcess, sizeof(kPSNOfSystemProcess), &targetDsec);
    if (status != noErr) {
        return status;
    }
    status = AECreateAppleEvent(kCoreEventClass, eventId, &targetDsec, kAutoGenerateReturnID, kAnyTransactionID, &eventToSend);
    AEDisposeDesc(&targetDsec);
    if (status != noErr) {
        return status;
    }
    status = AESendMessage(&eventToSend, &eventReply, kAENormalPriority, kAEDefaultTimeout);
    AEDisposeDesc(&eventToSend);
    if (status != noErr) {
        return status;
    }
    AEDisposeDesc(&eventReply);
    return status;
}
@end
