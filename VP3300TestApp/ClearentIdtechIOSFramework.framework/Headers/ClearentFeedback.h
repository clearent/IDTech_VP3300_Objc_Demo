//
//  ClearentFeedback.h
//  ClearentIdtechIOSFramework
//
//  Created by David Higginbotham on 3/27/20.
//  Copyright © 2020 Clearent, L.L.C. All rights reserved.
//
#import <Foundation/Foundation.h>


FOUNDATION_EXPORT NSString *const CLEARENT_AUDIO_JACK_ATTACHED;
FOUNDATION_EXPORT NSString *const CLEARENT_GENERIC_CARD_READ_ERROR_RESPONSE;
FOUNDATION_EXPORT NSString *const CLEARENT_USE_CHIP_READER;
FOUNDATION_EXPORT NSString *const CLEARENT_CVM_UNSUPPORTED;
FOUNDATION_EXPORT NSString *const CLEARENT_CONTACTLESS_UNSUPPORTED;
FOUNDATION_EXPORT NSString *const CLEARENT_MSD_CONTACTLESS_UNSUPPORTED ;
FOUNDATION_EXPORT NSString *const CLEARENT_USER_ACTION_SWIPE_FAIL_TRY_INSERT_OR_SWIPE;
FOUNDATION_EXPORT NSString *const CLEARENT_BLUETOOTH_CONNECTED;
FOUNDATION_EXPORT NSString *const CLEARENT_BLUETOOTH_SEARCH;
FOUNDATION_EXPORT NSString *const CLEARENT_PLUGIN_AUDIO_JACK;
FOUNDATION_EXPORT NSString *const CLEARENT_NEW_BLUETOOTH_CONNECTION_REQUESTED;
FOUNDATION_EXPORT NSString *const CLEARENT_DISCONNECTING_BLUETOOTH_PLUGIN_AUDIO_JACK;
FOUNDATION_EXPORT NSString *const CLEARENT_UNPLUG_AUDIO_JACK_BEFORE_CONNECTING_TO_BLUETOOTH;
FOUNDATION_EXPORT NSString *const CLEARENT_USER_ACTION_PRESS_BUTTON_MESSAGE;
FOUNDATION_EXPORT NSString *const CLEARENT_USER_ACTION_3_IN_1_MESSAGE;
FOUNDATION_EXPORT NSString *const CLEARENT_USER_ACTION_2_IN_1_MESSAGE;
FOUNDATION_EXPORT NSString *const CLEARENT_USER_ACTION_USE_MAGSTRIPE_MESSAGE;
FOUNDATION_EXPORT NSString *const CLEARENT_CARD_OFFLINE_DECLINED;
FOUNDATION_EXPORT NSString *const CLEARENT_FALLBACK_TO_SWIPE_REQUEST;
FOUNDATION_EXPORT NSString *const CLEARENT_TIMEOUT_ERROR_RESPONSE;
FOUNDATION_EXPORT NSString *const CLEARENT_TIMEOUT_ERROR_RESPONSE2;
FOUNDATION_EXPORT NSString *const CLEARENT_GENERIC_TRANSACTION_TOKEN_ERROR_RESPONSE;
FOUNDATION_EXPORT NSString *const CLEARENT_GENERIC_DECLINE_RECEIPT_ERROR_RESPONSE;
FOUNDATION_EXPORT NSString *const CLEARENT_SUCCESSFUL_TOKENIZATION_MESSAGE;
FOUNDATION_EXPORT NSString *const CLEARENT_TRANSLATING_CARD_TO_TOKEN ;
FOUNDATION_EXPORT NSString *const CLEARENT_SUCCESSFUL_DECLINE_RECEIPT_MESSAGE;
FOUNDATION_EXPORT NSString *const CLEARENT_FAILED_TO_READ_CARD_ERROR_RESPONSE;
FOUNDATION_EXPORT NSString *const CLEARENT_INVALID_FIRMWARE_VERSION;
FOUNDATION_EXPORT NSString *const CLEARENT_INVALID_KERNEL_VERSION;
FOUNDATION_EXPORT NSString *const CLEARENT_READER_CONFIGURED_MESSAGE;
FOUNDATION_EXPORT NSString *const CLEARENT_DISABLE_CONFIGURATION_TO_RUN_TRANSACTION;
FOUNDATION_EXPORT NSString *const CLEARENT_READER_IS_NOT_CONFIGURED;
FOUNDATION_EXPORT NSString *const CLEARENT_DEVICE_NOT_CONNECTED;
FOUNDATION_EXPORT NSString *const CLEARENT_REQUIRED_TRANSACTION_REQUEST_RESPONSE;
FOUNDATION_EXPORT NSString *const CLEARENT_RESPONSE_TRANSACTION_STARTED;
FOUNDATION_EXPORT NSString *const CLEARENT_RESPONSE_TRANSACTION_FAILED;
FOUNDATION_EXPORT NSString *const CLEARENT_RESPONSE_INVALID_TRANSACTION;
FOUNDATION_EXPORT NSString *const CLEARENT_UNABLE_TO_GO_ONLINE;
FOUNDATION_EXPORT NSString *const CLEARENT_GENERIC_CONTACTLESS_FAILED;
FOUNDATION_EXPORT NSString *const CLEARENT_CONTACTLESS_FALLBACK_MESSAGE;
FOUNDATION_EXPORT NSString *const CLEARENT_CONTACTLESS_RETRY_MESSAGE;
FOUNDATION_EXPORT NSString *const CLEARENT_CHIP_FOUND_ON_SWIPE;
FOUNDATION_EXPORT NSString *const CLEARENT_AUDIO_JACK_ATTACHED;
FOUNDATION_EXPORT NSString *const CLEARENT_AUDIO_JACK_LOW_VOLUME;
FOUNDATION_EXPORT NSString *const CLEARENT_CONNECTING_AUDIO_JACK;
FOUNDATION_EXPORT NSString *const CLEARENT_AUDIO_JACK_REMOVED;
FOUNDATION_EXPORT NSString *const CLEARENT_PAYMENT_REQUEST_NOT_FOUND;
FOUNDATION_EXPORT NSString *const CLEARENT_PLEASE_WAIT;
FOUNDATION_EXPORT NSString *const CLEARENT_TRANSACTION_PROCESSING;
FOUNDATION_EXPORT NSString *const CLEARENT_TRANSACTION_AUTHORIZING;
FOUNDATION_EXPORT NSString *const CLEARENT_AUDIO_JACK_CONNECTED;
FOUNDATION_EXPORT NSString *const CLEARENT_BLUETOOTH_FRIENDLY_NAME_REQUIRED;
FOUNDATION_EXPORT NSString *const CLEARENT_TRANSACTION_TERMINATED;
FOUNDATION_EXPORT NSString *const CLEARENT_TRANSACTION_TERMINATE;
FOUNDATION_EXPORT NSString *const CLEARENT_USE_MAGSTRIPE;
FOUNDATION_EXPORT NSString *const CLEARENT_DEVICE_CONNECTED_WAITING_FOR_CONFIG;
FOUNDATION_EXPORT NSString *const CLEARENT_BLUETOOTH_DISCONNECTED;
FOUNDATION_EXPORT NSString *const CLEARENT_AUDIO_JACK_DISCONNECTED;
FOUNDATION_EXPORT NSString *const CLEARENT_POWERING_UP;
FOUNDATION_EXPORT NSString *const CLEARENT_TAP_PRESENT_ONE_CARD_ONLY;
FOUNDATION_EXPORT NSString *const CLEARENT_CARD_BLOCKED;
FOUNDATION_EXPORT NSString *const CLEARENT_CARD_EXPIRED;
FOUNDATION_EXPORT NSString *const CLEARENT_CARD_UNSUPPORTED;
FOUNDATION_EXPORT NSString *const CLEARENT_TAP_FAILED_INSERT_SWIPE;
FOUNDATION_EXPORT NSString *const CLEARENT_TAP_OVER_MAX_AMOUNT ;
FOUNDATION_EXPORT NSString *const CLEARENT_TAP_FAILED_INSERT_CARD_FIRST;
FOUNDATION_EXPORT NSString *const CLEARENT_CHIP_UNRECOGNIZED;
FOUNDATION_EXPORT NSString *const CLEARENT_BAD_CHIP;
FOUNDATION_EXPORT NSString *const CLEARENT_FAILED_TO_SEND_DECLINE_RECEIPT;
FOUNDATION_EXPORT NSString *const CLEARENT_PULLED_CARD_OUT_EARLY;
FOUNDATION_EXPORT NSString *const CLEARENT_CONNECTION_TYPE_REQUIRED;
FOUNDATION_EXPORT NSString *const CLEARENT_CONNECTION_PROPERTIES_REQUIRED;

typedef NS_ENUM(NSUInteger, CLEARENT_FEEDBACK_MESSAGE_TYPE) {
    CLEARENT_FEEDBACK_TYPE_UNKNOWN = 0,
    CLEARENT_FEEDBACK_USER_ACTION = 1,
    CLEARENT_FEEDBACK_INFO = 2,
    CLEARENT_FEEDBACK_BLUETOOTH = 3,
    CLEARENT_FEEDBACK_ERROR = 4
};

@protocol ClearentFeedback <NSObject>

- (NSString*) message;
- (CLEARENT_FEEDBACK_MESSAGE_TYPE*) feedBackMessageType;
- (int) returnCode;

@end

@interface ClearentFeedback: NSObject <ClearentFeedback>
@property (nonatomic) NSString *message;
@property (nonatomic) CLEARENT_FEEDBACK_MESSAGE_TYPE feedBackMessageType;
@property (nonatomic) int returnCode;

- (instancetype) initBluetooth:(NSString*) message;
- (instancetype) initUserAction:(NSString*) message;
- (instancetype) initInfo:(NSString*) message;
+ (NSDictionary*) feedbackValues;
+ (ClearentFeedback*) createFeedback:(NSString*) message;
+ (void) updateFeedbackType: (ClearentFeedback*) clearentFeedback;
@end
