//
//  ViewController.h
//  BasicSimbleeApp
//
//  Created by Robert Rehrig on 5/31/17.
//  Copyright © 2017 Rob Rehr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomColors.h"
@import CoreBluetooth;
@import QuartzCore;

#define SCAN_ALL 0 // 0: scan/connect only for SIMBLEE_UUID, 1: general BLE scan

#define SIMBLEE_UUID        @"1234"
#define READABLE_CHAR_UUID  @"2D30C082-F39F-4CE6-923F-3484EA480596"
#define WRITEABLE_CHAR_UUID @"2D30C083-F39F-4CE6-923F-3484EA480596"

@interface ViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong)   CBCentralManager    *centralManager;
@property (nonatomic, strong)   CBPeripheral        *simbleePeripheral;
@property (nonatomic, strong)   CBCharacteristic    *writeableChar;

@property (nonatomic, strong)   NSTimer             *connectTimer;
@property (nonatomic, strong)   NSTimer             *updateRSSITimer;

@property (nonatomic, strong)   IBOutlet UILabel    *BLEStatus;
@property (nonatomic, strong)   IBOutlet UILabel    *SimbleeButtonLabel;
@property (nonatomic, strong)   IBOutlet UILabel    *SimbleeButtonStateLabel;
@property (nonatomic, strong)   IBOutlet UILabel    *SimbleeRSSILabel;
@property (nonatomic, strong)   IBOutlet UILabel    *SimbleeUUIDLabel;
@property (nonatomic, strong)   IBOutlet UILabel    *SimbleeNameLabel;
@property (nonatomic, strong)   IBOutlet UIButton   *connectButton;
@property (nonatomic, strong)   IBOutlet UIButton   *toggleButton;

// properties to hold data characteristics for the peripheral device
@property (nonatomic) BOOL bBLEState;  // 0: not connectable, 1: connectable
@property (nonatomic) BOOL bConnected; // 0: disconnected, 1: connected
@property (nonatomic) BOOL bToggleValue;

- (IBAction)connectToPeripherals:(id)sender;
- (IBAction)disconnectFromPeripherals:(id)sender;
- (IBAction)buttonPressed:(UIButton*)sender;

- (void) updateRSSI;
- (void) stopScan;

@end

