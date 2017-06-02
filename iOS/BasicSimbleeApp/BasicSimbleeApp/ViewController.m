//
//  ViewController.m
//  BasicSimbleeApp
//
//  Created by Robert Rehrig on 5/31/17.
//  Copyright © 2017 Rob Rehr. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.bBLEState      = false; // assume not connectable until we check with central manager
    self.bConnected     = false; // not connected
    self.bToggleValue   = false;
    
    // create central manager for BLE communication
    CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.centralManager = centralManager;
}


- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CBCentralManagerDelegate

// method called whenever you have successfully connected to a BLE peripheral
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connected to %@", peripheral);
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    self.bConnected = true;
    [self.connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    [self.connectButton removeTarget:nil
                              action:NULL
                    forControlEvents:UIControlEventAllEvents];
    [self.connectButton addTarget:self
                           action:@selector(disconnectFromPeripherals:)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.toggleButton setEnabled:true];
    [self.toggleButton setBackgroundColor:[UIColor appleBlueColor]];
    [self.SimbleeButtonLabel setTextColor:[UIColor blackColor]];
    [self.SimbleeButtonStateLabel setTextColor:[UIColor blackColor]];
    [self.SimbleeRSSILabel setTextColor:[UIColor blackColor]];
    [self.SimbleeUUIDLabel setTextColor:[UIColor blackColor]];
    [self.SimbleeNameLabel setTextColor:[UIColor blackColor]];
    [self updateRSSI];
    // set a timer to update RSSI value every 2 seconds
    self.updateRSSITimer = [NSTimer scheduledTimerWithTimeInterval: 2.0 target: self
                                                       selector: @selector(updateRSSI) userInfo: nil repeats: YES];
    [self.SimbleeUUIDLabel setText:[NSString stringWithFormat:@"UUID: %@", [[peripheral identifier] UUIDString]]];
    [self.SimbleeNameLabel setText:[NSString stringWithFormat:@"Name: %@", [peripheral name]]];
    [self.BLEStatus setText:[NSString stringWithFormat:@"Connected"]];
}

// method called whenever you have failed to connect to a BLE peripheral
- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Error connecting: %@", error);
}

// method called whenever you have successfully disconnected from a BLE peripheral
- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Disconnected from %@", peripheral);
    self.bConnected = false;
    self.simbleePeripheral = nil; // remove reference to Simblee device
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [self.connectButton removeTarget:nil
                              action:NULL
                    forControlEvents:UIControlEventAllEvents];
    [self.connectButton addTarget:self
                           action:@selector(connectToPeripherals:)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.toggleButton setEnabled:false];
    [self.toggleButton setBackgroundColor:[UIColor lightGrayColor]];
    [self.SimbleeButtonLabel setTextColor:[UIColor lightGrayColor]];
    [self.SimbleeButtonStateLabel setTextColor:[UIColor lightGrayColor]];
    // check if timer is running, stop it
    if ( [self.updateRSSITimer isValid] ) {
        [self.updateRSSITimer invalidate];
        self.updateRSSITimer=nil;
    }
    [self.SimbleeRSSILabel setTextColor:[UIColor lightGrayColor]];
    [self.SimbleeUUIDLabel setTextColor:[UIColor lightGrayColor]];
    [self.SimbleeNameLabel setTextColor:[UIColor lightGrayColor]];
    [self.SimbleeRSSILabel setText:@"RSSI: "];
    [self.SimbleeUUIDLabel setText:@"UUID: "];
    [self.SimbleeNameLabel setText:@"Name: "];
    [self.BLEStatus setText:[NSString stringWithFormat:@"Disonnected"]];
}

// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter.
// This contains most of the information there is to know about a BLE peripheral.
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    
    if ([localName length] > 0) {
#if SCAN_ALL
        // just show discovered BLE devices
        NSLog(@"Found a BLE device: %@, RSSI: %ld", localName, [RSSI longValue]);
        
#else
        // connect to Simblee device
        NSLog(@"Found a Simblee device: %@, RSSI: %ld", localName, [RSSI longValue]);
        // stop scanning and timer
        if ( [self.connectTimer isValid] ) {
            [self.connectTimer invalidate];
            self.connectTimer=nil;
        }
        [self.centralManager stopScan];
        
        // connect and save reference to peripheral
        self.simbleePeripheral = peripheral;
        peripheral.delegate = self;
        [self.centralManager connectPeripheral:peripheral options:nil];
#endif
    }
}

// method called whever the device state changes
- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    // determine the state of the peripheral
    if ([central state] == CBManagerStatePoweredOff) {
        NSLog(@"CoreBluetooth BLE hardware is powered off");
        self.bBLEState = false;
        [self.BLEStatus setText:@"BLE Powered Off"];
        [self.connectButton setBackgroundColor:[UIColor lightGrayColor]];
        [self.connectButton setEnabled:false];
    } else if ([central state] == CBManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
        self.bBLEState = true;
        [self.BLEStatus setText:@"Disconnected"];
        [self.connectButton setBackgroundColor:[UIColor appleBlueColor]];
        [self.connectButton setEnabled:true];
#if SCAN_ALL
        // scan for any BLE devices
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
#else
        // scan for only specified BLE devices
        NSArray *services = @[[CBUUID UUIDWithString:SIMBLEE_UUID]];
        [self.centralManager scanForPeripheralsWithServices:services options:nil];
#endif
        NSLog(@"BLE scan started");
        // check if timer is already running
        if ( [self.connectTimer isValid] ) {
            [self.connectTimer invalidate];
            self.connectTimer=nil;
        }
        // set a timer to stop scanning for BLE peripherals in 5 seconds
        self.connectTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0 target: self
                                                       selector: @selector(stopScan) userInfo: nil repeats: NO];
    } else if ([central state] == CBManagerStateUnauthorized) {
        NSLog(@"CoreBluetooth BLE state is unauthorized");
        self.bBLEState = false;
        [self.BLEStatus setText:@"BLE Unauthorized"];
        [self.connectButton setBackgroundColor:[UIColor lightGrayColor]];
        [self.connectButton setEnabled:false];
    } else if ([central state] == CBManagerStateUnknown) {
        NSLog(@"CoreBluetooth BLE state is unknown");
        self.bBLEState = false;
        [self.BLEStatus setText:@"BLE Status Uknown"];
        [self.connectButton setBackgroundColor:[UIColor lightGrayColor]];
        [self.connectButton setEnabled:false];
    } else if ([central state] == CBManagerStateUnsupported) {
        NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
        self.bBLEState = false;
        [self.BLEStatus setText:@"BLE Unsupported"];
        [self.connectButton setBackgroundColor:[UIColor lightGrayColor]];
        [self.connectButton setEnabled:false];
    }
}

- (void) updateRSSI {
    [self.simbleePeripheral readRSSI];
}

- (void) peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    [self.SimbleeRSSILabel setText:[NSString stringWithFormat:@"RSSI: %d", [RSSI intValue]]];
}

// button to start scanning for BLE peripherals
- (IBAction)connectToPeripherals:(id)sender {
    if (self.bBLEState) {
#if SCAN_ALL
        // scan for any BLE devices
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
#else
        // scan for only specified BLE devices
        NSArray *services = @[[CBUUID UUIDWithString:SIMBLEE_UUID]];
        [self.centralManager scanForPeripheralsWithServices:services options:nil];
#endif
        NSLog(@"BLE scan started");
        // check if timer is already running
        if ( [self.connectTimer isValid] ) {
            [self.connectTimer invalidate];
            self.connectTimer=nil;
        }
        // set a timer to stop scanning for BLE peripherals in 5 seconds
        self.connectTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0 target: self
                                                       selector: @selector(stopScan) userInfo: nil repeats: NO];
    }
}

- (IBAction)disconnectFromPeripherals:(id)sender {
    if (self.bConnected) {
        [self.centralManager cancelPeripheralConnection:self.simbleePeripheral];
    }
}

// stop scanning for BLE peripherals
- (void) stopScan {
    NSLog(@"BLE scan stopped");
    [self.centralManager stopScan];
}

#pragma mark - CBPeripheralDelegate

// CBPeripheralDelegate - Invoked when you discover the peripheral's available services
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service: %@", service.UUID);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

// Invoked when you discover the characteristics of a specified service
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *aChar in service.characteristics) {
        NSLog(@"Found Characteristic: %@", aChar.UUID);
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:WRITEABLE_CHAR_UUID]]) {
            self.writeableChar = aChar;
        } else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:READABLE_CHAR_UUID]]) {
            [self.simbleePeripheral setNotifyValue:YES forCharacteristic:aChar];
        }
    }
}

// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed
- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSData *data = [characteristic value];
    int value = CFSwapInt32LittleToHost(*(int*)([data bytes]));
    
    if (value == 1) {
        [self.SimbleeButtonStateLabel setText:@"Pressed"];
    } else if (value == 0) {
        [self.SimbleeButtonStateLabel setText:@"Released"];
    }
}

#pragma mark - CBCharacteristic helpers

- (IBAction)buttonPressed:(UIButton*)sender {
    if (self.bConnected) {
        self.bToggleValue = !self.bToggleValue;
        int toSend = 0;
        if (self.bToggleValue) {
            toSend = 1;
        }
        
        const unsigned char bytes[] = {toSend};
        [self.simbleePeripheral writeValue:[NSData dataWithBytes:bytes length:sizeof(bytes)] forCharacteristic:self.writeableChar type:CBCharacteristicWriteWithoutResponse];
    }
}


@end
