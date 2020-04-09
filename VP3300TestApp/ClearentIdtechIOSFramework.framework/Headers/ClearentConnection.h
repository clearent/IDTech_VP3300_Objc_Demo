//
//  ClearentConnection.h
//  ClearentIdtechIOSFramework
//
//  Created by David Higginbotham on 3/30/20.
//  Copyright © 2020 Clearent, L.L.C. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CONNECTION_TYPE) {
    BLUETOOTH = 0,
    AUDIO_JACK = 1
};

typedef enum {
    BLUETOOTH_ADVERTISING_INTERVAL_DEFAULT = 0,
    BLUETOOTH_ADVERTISING_INTERVAL_60_MS = 1,
    BLUETOOTH_ADVERTISING_INTERVAL_152_MS = 2,
    BLUETOOTH_ADVERTISING_INTERVAL_211_MS = 3,
    BLUETOOTH_ADVERTISING_INTERVAL_318_MS = 4,
    BLUETOOTH_ADVERTISING_INTERVAL_417_MS = 5,
    BLUETOOTH_ADVERTISING_INTERVAL_546_MS = 6,
    BLUETOOTH_ADVERTISING_INTERVAL_760_MS = 7,
    BLUETOOTH_ADVERTISING_INTERVAL_1280_MS = 8
} BLUETOOTH_ADVERTISING_INTERVAL;

typedef NS_ENUM(NSUInteger, READER_INTERFACE_MODE) {
    READER_INTERFACE_3_IN_1 = 0,
    READER_INTERFACE_2_IN_1 = 1
};

@protocol ClearentConnection <NSObject>

- (int) bluetoothMaximumScanInSeconds;
- (NSString*) lastFiveDigitsOfDeviceSerialNumber;
- (NSString*) fullFriendlyName;
- (NSString*) bluetoothDeviceId;
- (BOOL) connectToFirstBluetoothFound;
- (CONNECTION_TYPE*) connectionType;
- (READER_INTERFACE_MODE*) readerInterfaceMode;
- (NSString*) createLogMessage;
- (BLUETOOTH_ADVERTISING_INTERVAL*) bluetoothAdvertisingInterval;

@end

@interface ClearentConnection: NSObject <ClearentConnection>

@property (nonatomic) int bluetoothMaximumScanInSeconds;
@property (nonatomic) NSString *lastFiveDigitsOfDeviceSerialNumber;
@property (nonatomic) NSString *fullFriendlyName;
@property (nonatomic) NSString *bluetoothDeviceId;
@property (nonatomic) BOOL connectToFirstBluetoothFound;
@property (nonatomic) CONNECTION_TYPE connectionType;
@property (nonatomic) READER_INTERFACE_MODE readerInterfaceMode;
@property (nonatomic) BLUETOOTH_ADVERTISING_INTERVAL bluetoothAdvertisingInterval;

- (NSString*) createLogMessage;
+ (instancetype) createDefaultClearentConnection;
+ (NSString*) createFullIdTechFriendlyName:(NSString*) lastFiveDigitsOfDeviceSerialNumber;

@end
