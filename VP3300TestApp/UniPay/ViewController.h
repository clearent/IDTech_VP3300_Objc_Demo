
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AVFoundation/AVFoundation.h>

//CLEARENT: import the ClearentIdtechIOSFramework header
#import <ClearentIdtechIOSFramework/ClearentIdtechIOSFramework.h>


//CLEARENT make the view a Clearent_Public_IDTech_VP3300_Delegate
//CLEARENT make the view a ClearentManualEntryDelegate

@interface ViewController : UIViewController<UIAlertViewDelegate,Clearent_Public_IDTech_VP3300_Delegate, UIActionSheetDelegate,MFMailComposeViewControllerDelegate,ClearentManualEntryDelegate>
{
    
    IBOutlet UITextView *resultsTextView;
    IBOutlet UILabel *connectedLabel;
    IBOutlet UITextField *bluetoothFriendlyName;
    IBOutlet UISwitch *bluetoothConnectToFirstFound;
    IBOutlet UITextField *lastFiveDigitsOfDeviceSerialNumber;
    IBOutlet UITextField *txtAmount;
    IBOutlet UITextField *txtReceiptEmailAddress;
    
    IBOutlet UITextField *txtCreditCardNumber;
    IBOutlet UITextField *txtExpirationDate;
    IBOutlet UITextField *txtCsc;
    IBOutlet UISegmentedControl *connectionTypeSelect;
    IBOutlet UISegmentedControl *readerUsage;
    
    IBOutlet UILabel *bluetoothFriendlyNameLabel;
    IBOutlet UILabel *lastFiveDigitsOfDeviceSerialNumberLabel;
    IBOutlet UILabel *bluetoothConnectToFirstFoundLabel;
    
    IBOutlet UILabel *cardLabel;
    IBOutlet UILabel *expirationDateLabel;
    IBOutlet UILabel *cvvLabel;
    
    IBOutlet UIButton *bluetoothConnect;
    IBOutlet UIButton *bluetoothDisconnect;
    
    IBOutlet UIButton *useReaderButton;
    IBOutlet UIButton *cancelReaderButton;
    IBOutlet UIButton *manualEntryButton;
}

@property(nonatomic, strong) UITextView *resultsTextView;
@property(nonatomic, strong) UILabel *connectedLabel;
@property(nonatomic, strong) UITextField *bluetoothFriendlyName;
@property(nonatomic, strong) UITextField *lastFiveDigitsOfDeviceSerialNumber;
@property(nonatomic, strong) UISwitch *bluetoothConnectToFirstFound;
@property(nonatomic, strong) UIAlertView *prompt_doConnection;
@property(nonatomic, strong) UIAlertView *prompt_doConnection_Low_Volume;
@property(nonatomic, strong) UITextField *txtAmount;
@property(nonatomic, strong) UITextField *txtReceiptEmailAddress;

@property(nonatomic, strong) UITextField *txtCreditCardNumber;
@property(nonatomic, strong) UITextField *txtExpirationDate;
@property(nonatomic, strong) UITextField *txtCsc;
@property(nonatomic, strong) UISegmentedControl *connectionTypeSelect;
@property(nonatomic, strong) UISegmentedControl *readerUsage;
@property(nonatomic, strong) UILabel *bluetoothFriendlyNameLabel;
@property(nonatomic, strong) UILabel *lastFiveDigitsOfDeviceSerialNumberLabel;
@property(nonatomic, strong) UILabel *bluetoothConnectToFirstFoundLabel;

@property(nonatomic, strong) UILabel *cardLabel;
@property(nonatomic, strong) UILabel *expirationDateLabel;
@property(nonatomic, strong) UILabel *cvvLabel;

@property(nonatomic, strong) UIButton *bluetoothConnect;
@property(nonatomic, strong) UIButton *bluetoothDisconnect;

@property(nonatomic, strong) UIButton *useReaderButton;
@property(nonatomic, strong) UIButton *cancelReaderButton;
@property(nonatomic, strong) UIButton *manualEntryButton;

- (IBAction) f_cancelTrans:(id)sender;
- (IBAction) DoKeyboardOff:(id)sender;
- (IBAction) f_startAnyTransaction:(id)sender;
- (IBAction) f_manualEntry:(id)sender;
- (IBAction) connectionTypeChanged:(id)sender;
- (IBAction) readerUsageChanged:(id)sender;
@end
