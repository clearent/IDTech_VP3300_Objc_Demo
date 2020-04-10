
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
    

}

//only for iPhone
@property (strong, nonatomic) IBOutlet UIScrollView *sView;
@property (strong, nonatomic) IBOutlet UIView *view1;
@property (strong, nonatomic) IBOutlet UIView *view2;
@property (strong, nonatomic) IBOutlet UIView *view4;
@property (strong, nonatomic) IBOutlet UIView *view5;
@property (strong, nonatomic) IBOutlet UIView *view6;
@property (strong, nonatomic) IBOutlet UIView *view7;
@property (strong, nonatomic) IBOutlet UIPageControl *pcControlPanes;

//for all
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

- (IBAction) f_cancelTrans:(id)sender;
- (IBAction) DoKeyboardOff:(id)sender;
- (IBAction) f_startAnyTransaction:(id)sender;

@end
