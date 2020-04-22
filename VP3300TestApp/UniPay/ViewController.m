#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

NSString *baseUrl = @"https://gateway-sb.clearent.net";
NSString *publicKey = @"307a301406072a8648ce3d020106092b240303020801010c036200042b0cfb3a1faaca8fb779081717a0bafb03e0cb061a1ef297f75dc5b951aaf163b0c2021e9bb73071bf89c711070e96ab1b63c674be13041d9eb68a456eb6ae63a97a9345c120cd8bff1d5998b2ebbafc198c5c5b26c687bfbeb68b312feb43bf";

@synthesize resultsTextView;
@synthesize connectedLabel;
@synthesize searchBluetoothLabel;
@synthesize searchBluetooth;
@synthesize bluetoothSearchResultsLabel;
@synthesize bluetoothFriendlyName;
@synthesize bluetoothConnectToFirstFound;
@synthesize lastFiveDigitsOfDeviceSerialNumber;
@synthesize txtAmount;
@synthesize txtReceiptEmailAddress;
@synthesize alertImage;
@synthesize readerInterfaceMode;
@synthesize readerInterfaceModeSelect;
@synthesize txtCreditCardNumber;
@synthesize txtExpirationDate;
@synthesize txtCsc;
@synthesize bluetoothDevicePicker;
@synthesize connectionTypeSelect;
@synthesize readerUsage;
@synthesize prompt_doConnection;
@synthesize prompt_doConnection_Low_Volume;
@synthesize bluetoothFriendlyNameLabel;
@synthesize lastFiveDigitsOfDeviceSerialNumberLabel;
@synthesize bluetoothConnectToFirstFoundLabel;
@synthesize bluetoothConnect;
@synthesize bluetoothDisconnect;

@synthesize cardLabel;
@synthesize expirationDateLabel;
@synthesize cvvLabel;
   
@synthesize useReaderButton;
@synthesize cancelReaderButton;
@synthesize manualEntryButton;

@synthesize loopTest;
@synthesize cancelLoopTest;

@synthesize batteryLevelLabel;
@synthesize loopCountLabel;

//CLEARENT: This is the object you will interact with.
Clearent_VP3300 *clearentVP3300;

ClearentVP3300Config *clearentVP3300Config;

//CLEARENT: This object will be used to create transaction tokens for manually entered cards.
ClearentManualEntry *clearentManualEntry;

ClearentConnection *clearentConnection;

NSMutableArray *bluetoothDevicePickerData;

NSArray<ClearentBluetoothDevice> *bluetoothDevicesFound;

static bool runSampleAsRefund = NO;

static bool runningTransaction = false;

static bool startLoop = false;

NSString *loopStartTime;
NSString *loopEndTime;
int loopCount = 0;
NSTimer *loopTimer;
NSString *batteryLevelTime;

UIImage *creditCardImage;
UIImage *insertImage;
UIImage *checkmarkImage;

NSString *chimeFilePath;
NSURL *chimeFileURL;
NSString *popFilePath;
NSURL *popFileURL;

extern int g_IOS_Type;

-(void) appendMessageToResults:(NSString*) message{
    [self performSelectorOnMainThread:@selector(_appendMessageToResults:) withObject:message waitUntilDone:false];

}
-(void) _appendMessageToResults:(id)object{
    [self.resultsTextView setText:[NSString stringWithFormat:@"%@\n%@\n", self.resultsTextView.text,(NSString*)object]];
    [self.resultsTextView scrollRangeToVisible:NSMakeRange([self.resultsTextView.text length], 0)];
    
}

- (IBAction) DoClearLog:(id)sender{
    
    [self clearLog];
    
}

- (void) clearLog {
    
    [self.resultsTextView setText: @""];
    
    [self.resultsTextView scrollRangeToVisible:NSMakeRange([self.resultsTextView.text length], 0)];
    
}

//for return IDTResult type function
-(void) displayUpRet2:(NSString*) operation returnValue: (RETURN_CODE)rt
{
    
    NSString * str = [NSString stringWithFormat:
                      @"%@ ERROR: ID-\"%i\", message: %@.",
                      operation, rt, [clearentVP3300 device_getResponseCodeString:rt]];
    [self appendMessageToResults:str];
    
}

- (IBAction) DoKeyboardOff: (id) sender {
    
    [sender resignFirstResponder];
    
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if (alertView == prompt_doConnection || alertView == prompt_doConnection_Low_Volume)
    {
        //selected option to start the connection task at the reader attachment prompt
        if (1 == buttonIndex) {
            //[self appendMessageToResults: @"Start Connect Task..."];
            [clearentVP3300 device_connectToAudioReader];
            
        }
    }
    
}

#pragma mark - VP3300 Delegate methods
static int _lcdDisplayMode = 0;

- (void) lcdDisplay:(int)mode  lines:(NSArray*)lines{
//deprecated
}

- (void) dataInOutMonitor:(NSData*)data  incoming:(BOOL)isIncoming{
    NSLog([NSString stringWithFormat:@"DATA INOUT %@: %@",isIncoming?@"IN":@"OUT",data.description]);
}

- (void) plugStatusChange:(BOOL)deviceInserted{
    if (deviceInserted) {
        //[self appendMessageToResults: @"device Attached."];
        
        if ([[AVAudioSession sharedInstance] outputVolume] < 1.0) {
            [prompt_doConnection_Low_Volume show];
        } else{
            [prompt_doConnection show];
        }
        
    }
    else{
       // [self appendMessageToResults: @"device removed."];
        [self dismissAllAlertViews];
    }
}

-(void)isReady{
    //connectedLabel.text = @"READY";
    //connectedLabel.backgroundColor = UIColor.systemGreenColor;
}

-(void) beepbeep {
    NSData* response;
    RETURN_CODE sendCommandRt = [clearentVP3300 device_sendIDGCommand:0x01 subCommand:0x02 data:[IDTUtility hexToData:@"ff04ff00"] response:&response];
    if(RETURN_CODE_DO_SUCCESS != sendCommandRt) {
        NSLog(@"it worked");
    } else {
        NSLog(@"it did not work");
    }
}

//Check every time to contribute to drain.
- (void) getLowBatteryLevelTime {
    
    bool islow = false;
    
    if([clearentVP3300 isConnected]) {
        
        @try {
            NSData* sendCommandResponse;
            
            RETURN_CODE sendCommandRt = [[IDT_VP3300 sharedController] device_sendIDGCommand:0xF0 subCommand:0x02 data:nil response:&sendCommandResponse];
            
            if(RETURN_CODE_DO_SUCCESS == sendCommandRt) {
                islow = true;
            } else {
                islow = false;
            }
        } @catch (NSException *exception) {
            NSLog(@"catch");
        } @finally {
            NSLog(@"finally");
        }
        
    }
    
    if(islow && batteryLevelTime == nil) {
        batteryLevelTime = [self getTime];
    }
}

-(void) deviceConnected {
    connectedLabel.text = @"Connected";
    connectedLabel.backgroundColor = UIColor.systemGreenColor;
    
   // [self getLowBatteryLevelTime];
    
}

-(void) deviceDisconnected {
    NSLog(@"DisConnt --");
    connectedLabel.text = @"Disconnected";
    connectedLabel.backgroundColor = UIColor.lightGrayColor;
    batteryLevelLabel.text = @"";
    
    [self disableCardImage];
}

-(void) eventFunctionICC: (Byte) nICC_Attached{
    NSLog(@"VP3300_EventFunctionICC Return Status Code %2X ",  nICC_Attached);
    [self appendMessageToResults:[NSString stringWithFormat:@"\nVP3300_EventFunctionICC Return Status Code %2X ",  nICC_Attached]];
    
}

-(void) dismissAllAlertViews {
    [prompt_doConnection dismissWithClickedButtonIndex:-1 animated:FALSE];
    [prompt_doConnection_Low_Volume dismissWithClickedButtonIndex:-1 animated:FALSE];
}

//deprecated..
- (void) deviceMessage:(NSString*) message {
    
    NSLog([NSString stringWithFormat:@"DEVICEMESSAGE %@", message ]);
    
}

- (void) feedback:(ClearentFeedback *)clearentFeedback {
    
    if(clearentFeedback.returnCode > 0) {
        runningTransaction = false;
        [self appendMessageToResults:[NSString stringWithFormat:@"Cancel transaction %@", clearentFeedback.message ]];
    }
    
    if([clearentFeedback.message containsString:@"PLEASE SWIPE, TAP, OR INSERT"]) {
        [self transitionCardImageToInsertImage];
    }
    
    if(clearentFeedback.feedBackMessageType == CLEARENT_FEEDBACK_USER_ACTION ){
        [self playPop];
        [self appendMessageToResults:[NSString stringWithFormat:@"🟢 %@", clearentFeedback.message ]];
    } else if(clearentFeedback.feedBackMessageType == CLEARENT_FEEDBACK_INFO ){
        [self appendMessageToResults:[NSString stringWithFormat:@" %@", clearentFeedback.message ]];
    } else if(clearentFeedback.feedBackMessageType == CLEARENT_FEEDBACK_ERROR ){
           [self disableCardImage];
           [self appendMessageToResults:[NSString stringWithFormat:@"👎 %@", clearentFeedback.message ]];
    } else if(clearentFeedback.feedBackMessageType == CLEARENT_FEEDBACK_BLUETOOTH ){
           [self appendMessageToResults:[NSString stringWithFormat:@" %@", clearentFeedback.message ]];
    } else if(clearentFeedback.feedBackMessageType == CLEARENT_FEEDBACK_TYPE_UNKNOWN ){
           [self appendMessageToResults:[NSString stringWithFormat:@"UNKNOWN: %@", clearentFeedback.message ]];
    }

}

//When you set up the ClearentConnection object you can choose to disable the flag that will connect to the first one found.
//if you also do not provide a specific bluetooth friendly name, last 5 digits of device serial number, or a deviceID,  the bluetooth scan will
//search for all bluetooth devices that start with 'IDTECH' and send them back.
//A ClearentBluetoothDevice gives you the bluetooth friendly name and the device UUID. You can present the friednly names to your user
//so they can select the one to use. When they do so you can then pass this deviceId in the ClearentConnection object on your subsequent request.

- (void) bluetoothDevices:(NSArray<ClearentBluetoothDevice> *)bluetoothDevices {
    
    bluetoothDevicesFound = bluetoothDevices;
    
    if(bluetoothDevices != nil && [bluetoothDevices count] > 0) {
        
        [bluetoothDevicePickerData removeAllObjects];
        
        for (ClearentBluetoothDevice* clearentBluetoothDevice in bluetoothDevices) {
            
            if(clearentBluetoothDevice.connected) {
                connectedLabel.text = clearentBluetoothDevice.friendlyName;
            }
            
            [bluetoothDevicePickerData addObject:clearentBluetoothDevice.friendlyName];
            
        }
        
        if(bluetoothDevicePickerData.count > 0) {
            
            [bluetoothDevicePicker reloadAllComponents];
            
        }
    }
    
}

- (void) handleManualEntryError: (NSString*) message {
    
    [self appendMessageToResults:message];
    
}

- (void) showAlertView: (NSString*) msg {
    
    [self dismissAllAlertViews];
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"VP3300"
                              message:msg
                              delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil];
    [alertView show];
    
    alertView = nil;
}

#pragma mark - View methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    prompt_doConnection = [[UIAlertView alloc]
                           initWithTitle:@"VP3300"
                           message:@"Device detected in headphone jack. Try connecting it?"
                           delegate:self
                           cancelButtonTitle:@"Cancel"
                           otherButtonTitles:@"OK",nil];
    prompt_doConnection_Low_Volume = [[UIAlertView alloc]
                           initWithTitle:@"VP3300"
                           message:@"Device detected in headphone jack. Try connecting it? WARNING: Low volume detected. Please increase headphone volume to MAXIMUM before proceeding with connection attempt."
                           delegate:self
                           cancelButtonTitle:@"Cancel"
                           otherButtonTitles:@"OK",nil];    
    
#ifndef __i386__
    
    [self initClearent];
    
#endif
    [self initSettings];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

- (NSInteger) numberOfComponentsInPickerView: (UIPickerView *) pickerView {
    
   return 1;
    
}

- (NSInteger) pickerView: (UIPickerView *) pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return bluetoothDevicePickerData.count;
    
}

 - (NSString*) pickerView: (UIPickerView *) pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
     
     return bluetoothDevicePickerData[row];
     
}

- (void) pickerView: (UIPickerView *) pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSString *pickedFriendlyName = bluetoothDevicePickerData[row];
    
    if(bluetoothDevicesFound != nil && bluetoothDevicesFound.count > 0) {
        
        for (ClearentBluetoothDevice* clearentBluetoothDevice in bluetoothDevicesFound) {
            if(pickedFriendlyName != nil && ![pickedFriendlyName isEqualToString:clearentBluetoothDevice.friendlyName]) {
                bluetoothFriendlyName.text = pickedFriendlyName;
            }
        }
        
    }
}

- (UIView * ) pickerView: (UIPickerView * ) pickerView viewForRow: (NSInteger) row forComponent: (NSInteger) component reusingView: (UIView * ) view {
    
    UILabel * label = [
        [UILabel alloc] initWithFrame: CGRectMake(0, 0, 300, 37)];
    label.text = [bluetoothDevicePickerData objectAtIndex: row];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blueColor];

    return label;

}

- (CGFloat) pickerView: (UIPickerView *) pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;

    return sectionWidth;
}


- (void) initClearent {
    
    [self initClearentVP3300Config];
       
    clearentVP3300 = [[Clearent_VP3300 alloc] initWithConnectionHandling:self clearentVP3300Configuration:clearentVP3300Config];
       
    clearentManualEntry = [[ClearentManualEntry alloc] init:self clearentBaseUrl:baseUrl publicKey:publicKey];
}

- (void) initClearentVP3300Config {
    
    clearentVP3300Config = [[ClearentVP3300Config alloc] init];
    
    clearentVP3300Config.clearentBaseUrl = baseUrl;
    clearentVP3300Config.publicKey = publicKey;
    clearentVP3300Config.contactAutoConfiguration = false;
    clearentVP3300Config.contactlessAutoConfiguration = false;
    clearentVP3300Config.contactless = true;
    clearentVP3300Config.disableRemoteLogging = false;
    
}

- (void) initSettings {
    
    runSampleAsRefund = NO;
    txtExpirationDate.hidden = YES;
    txtCsc.hidden = YES;
    txtCreditCardNumber.hidden = YES;
    expirationDateLabel.hidden = YES;
    cardLabel.hidden = YES;
    cvvLabel.hidden = YES;
    manualEntryButton.hidden = YES;
    useReaderButton.hidden = NO;
    cancelReaderButton.hidden = NO;
    bluetoothDevicePickerData = [NSMutableArray new];
    [bluetoothDevicePickerData addObject:@""];
       
    self.bluetoothDevicePicker.dataSource = self;
    self.bluetoothDevicePicker.delegate = self;
    self.bluetoothDevicePicker.showsSelectionIndicator = YES;
       
    self.searchBluetooth.on = false;
    self.bluetoothConnectToFirstFound.on = false;
    
    creditCardImage = [UIImage imageNamed:@"credit-card-icon-png-1"];
    
    checkmarkImage = [UIImage imageNamed:@"checkmark"];
    insertImage = [UIImage imageNamed:@"insertcard"];
   
    [alertImage setContentMode:UIViewContentModeScaleAspectFit];

    NSArray * imageArray  = [[NSArray alloc] initWithObjects:
    creditCardImage,
    insertImage,
    checkmarkImage,
    nil];
    
   // alertImage.animationImages = imageArray;
    
    [self disableCardImage];
    
    chimeFilePath = [[NSBundle mainBundle] pathForResource:@"chime" ofType:@"mp3"];
    chimeFileURL = [NSURL fileURLWithPath:chimeFilePath];
    
    NSError *error;
    
    self.chimeAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:chimeFileURL error:&error];
    
    popFilePath = [[NSBundle mainBundle] pathForResource:@"pop" ofType:@"m4a"];
    popFileURL = [NSURL fileURLWithPath:popFilePath];
       
    NSError *popError;
       
    self.popAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:popFileURL error:&popError];
    
}

- (void) playChime {
    [self.chimeAudioPlayer play];
}

- (void) playPop {
    [self.popAudioPlayer play];
}


- (void) startCardImage {
    
    if ([NSThread isMainThread])
    {
        [self showCardImage];
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            //Update UI in UI thread here
            [self showCardImage];
        });
    }
    
}

- (void) showCardImage {
    [UIView transitionWithView:alertImage
      duration:0.5f
       options:UIViewAnimationOptionTransitionCrossDissolve
    animations:^{
        self.alertImage.image = creditCardImage;
    } completion:nil];
}

- (void) disableCardImage {
    
    if ([NSThread isMainThread])
    {
        [self transitionCardImageToDisappear];
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            //Update UI in UI thread here
            [self transitionCardImageToDisappear];
        });
    }
    
}

- (void) transitionCardImageToDisappear {
    
    [UIView transitionWithView:alertImage
      duration:0.75f
       options:UIViewAnimationOptionTransitionCrossDissolve
    animations:^{
        self.alertImage.image = nil;
    } completion:nil];
}

- (void) cardImageToInsertImage {
    
    if ([NSThread isMainThread])
    {
        [self transitionCardImageToInsertImage];
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            //Update UI in UI thread here
            [self transitionCardImageToDisappear];
        });
    }
    
}

- (void) transitionCardImageToInsertImage {
    
    [UIView transitionWithView:alertImage
      duration:0.75f
       options:UIViewAnimationOptionTransitionCrossDissolve
    animations:^{
        self.alertImage.image = insertImage;
    } completion:nil];
}


- (void) cardImageToCheckmark {
    
     if ([NSThread isMainThread])
       {
           [self transitionCardImageToCheckMark];
       }
       else
       {
           dispatch_sync(dispatch_get_main_queue(), ^{
               //Update UI in UI thread here
               [self transitionCardImageToCheckMark];
           });
       }
}

- (void) transitionCardImageToCheckMark {
    
    [UIView transitionWithView:alertImage
            duration:0.75f
             options:UIViewAnimationOptionTransitionCrossDissolve
          animations:^{
        self.alertImage.image = checkmarkImage;
          } completion:nil];
    [self playChime];
}

-(void) exampleManualEntry {
    
    ClearentCard *clearentCard = [self createManualCardEntryRequest];
    
    [clearentManualEntry createTransactionToken:clearentCard];
    
}

- (ClearentCard*) createManualCardEntryRequest {
    ClearentCard *clearentCard = [[ClearentCard alloc] init];
    clearentCard.card = [txtCreditCardNumber text];
    clearentCard.expirationDateMMYY = [txtExpirationDate text];
    clearentCard.csc= [txtCsc text];
    clearentCard.softwareType = @"Clearent Objc IDTech Demo";
    clearentCard.softwareTypeVersion = @"V2.0";
    return clearentCard;
}
 
-(void) successfulTransactionToken:(NSString*) jsonString {
    //deprecated
    NSLog(@"%@", jsonString);
    
}

- (void) successTransactionToken:(ClearentTransactionToken*) clearentTransactionToken {
    [self appendMessageToResults:@"A Clearent Transaction Token (JWT) has been created. Running sample transaction..."];
    NSLog(@"%@",clearentTransactionToken.jwt);
    NSLog(@"%@",clearentTransactionToken.cvm);
    NSLog(@"%@",clearentTransactionToken.lastFour);
    NSLog(@"%@",clearentTransactionToken.trackDataHash);
    NSLog(@"%@",clearentTransactionToken.cardType);
    
    [self exampleUseJwtToRunPaymentTransaction:clearentTransactionToken.jwt];
}


- (void) exampleUseJwtToRunPaymentTransaction:(NSString*)jwt {
    NSLog(@"%@Run the transaction...",jwt);
    //Construct the url
    NSString *targetUrl;
    if(runSampleAsRefund) {
      targetUrl = [NSString stringWithFormat:@"%@/rest/v2/mobile/transactions/refund", baseUrl];
    } else {
      targetUrl = [NSString stringWithFormat:@"%@/rest/v2/mobile/transactions/sale", baseUrl];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //Create a sample json request.
    NSData *postData;
    if(runSampleAsRefund) {
        postData = [self exampleRefundAsJson];
    } else {
        postData = [self exampleClearentTransactionRequestAsJson];
    }
    //Build a url request. It's a POST.
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    //Use json
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    //add a test apikey as a header
    [request setValue:@"24425c33043244778a188bd19846e860" forHTTPHeaderField:@"api-key"];
    
    //add the JWT as a header.
    [request setValue:jwt forHTTPHeaderField:@"mobilejwt"];
    [request setURL:[NSURL URLWithString:targetUrl]];
    [request setTimeoutInterval:20];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {
          //Clearent returns an object that is defined the same for both successful and unsuccessful calls with one exception. The 'payload' can be different.
          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
          NSLog(@"Clearent Transaction Response status code: %ld", (long)[httpResponse statusCode]);
          if(error != nil) {
              [self appendMessageToResults:error.description];
              runningTransaction = false;
          } else if(data != nil && [httpResponse statusCode] == 200) {
              NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
              NSDictionary *successfulResponseDictionary = [self jsonAsDictionary:responseStr];
              NSDictionary *payload = [successfulResponseDictionary objectForKey:@"payload"];
              NSDictionary *transaction = [payload objectForKey:@"transaction"];
              NSString *transactionId = [transaction objectForKey:@"id"];
              NSString *displayMessage = [transaction objectForKey:@"display-message"];
              NSString *amount = [transaction objectForKey:@"amount"];
              NSString *result = [transaction objectForKey:@"result"];
              NSString *transactionResult;
              if(runSampleAsRefund) {
                transactionResult = [NSString stringWithFormat:@"Refund completed. Amount: %@ Result: %@ Transaction Id: %@ Display Message: %@", amount, result, transactionId, displayMessage];
              } else {
                transactionResult = [NSString stringWithFormat:@"Payment completed. Final Amount: %@ Result: %@ Transaction Id: %@ Display Message: %@", amount, result, transactionId, displayMessage];
              }
             
              [self appendMessageToResults:transactionResult];
              if(self.txtReceiptEmailAddress.text != nil) {
                  [self exampleRequestReceipt:transactionId];
              } else {
                  runningTransaction = false;
                  [self cardImageToCheckmark];
              }
          } else {
              NSString *errorResult;
              NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             
              NSDictionary *errorResponseDictionary = [self jsonAsDictionary:responseStr];
              if ([errorResponseDictionary objectForKey:@"payload"]) {
                  NSDictionary *payload = [errorResponseDictionary objectForKey:@"payload"];
                  if ([payload objectForKey:@"transaction"]) {
                      NSDictionary *transaction = [payload objectForKey:@"transaction"];
                      NSString *transactionId = [transaction objectForKey:@"id"];
                      NSString *errorMessage = [transaction objectForKey:@"display-message"];
                      if(runSampleAsRefund) {
                          errorResult = [NSString stringWithFormat:@"Refund transaction failed.Result: %@ Transaction Id: %@",errorMessage, transactionId];
                      } else {
                          errorResult = [NSString stringWithFormat:@"Payment transaction failed.Result: %@ Transaction Id: %@",errorMessage, transactionId];
                      }
                      [self appendMessageToResults:errorResult];
                      [self exampleRequestReceipt:transactionId];
                  } else if ([payload objectForKey:@"error"]) {
                      NSDictionary *error = [payload objectForKey:@"error"];
                      NSString *errorMessage = [error objectForKey:@"error-message"];
                      if(runSampleAsRefund) {
                          errorResult = [NSString stringWithFormat:@"Refund transaction failed.Result: %@",errorMessage];
                      } else {
                          errorResult = [NSString stringWithFormat:@"Payment transaction failed.Result: %@",errorMessage];
                      }
                      
                      [self appendMessageToResults:errorResult];
                  }
              } else {
                      NSLog(@"Response not handled : %s", responseStr);
                      [self appendMessageToResults:@"Failed to handle response"];
                  }
              }
              runningTransaction = false;
        [self cardImageToCheckmark];
        
      } ] resume];
}

- (NSData*) exampleClearentTransactionRequestAsJson  {
    
    NSString *usedAmount = @"1.00";
    
    if(txtAmount.text != nil) {
        usedAmount = txtAmount.text;
    }
    
    NSDictionary* dict = @{@"amount":usedAmount,@"type":@"SALE",  @"software-type": @"ios Idtech Demo App",
                           @"software-type-version":@"1"};
    
    return [NSJSONSerialization dataWithJSONObject:dict
                                           options:NSJSONWritingPrettyPrinted error:nil];
    
}

- (NSData*) exampleRefundAsJson  {
    
    NSString *usedAmount = @"1.00";
    
    if(txtAmount.text != nil) {
        usedAmount = txtAmount.text;
    }
    
    NSDictionary* dict = @{@"amount":usedAmount,@"type":@"REFUND",  @"software-type": @"ios Idtech Demo App",
                           @"software-type-version":@"1"};
    
    return [NSJSONSerialization dataWithJSONObject:dict
                                           options:NSJSONWritingPrettyPrinted error:nil];
    
}

- (NSDictionary *)jsonAsDictionary:(NSString *)stringJson {
    NSData *data = [stringJson dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:0
                                                                     error:&error];
    if (error) {
        NSLog(@"Error json: %@", [error description]);
    }
    
    return jsonDictionary;
}

- (void) exampleRequestReceipt:(NSString*)transactionId {
    
    if(transactionId == nil) {
        return;
    }
    
    NSString *targetUrl = [NSString stringWithFormat:@"%@/rest/v2/receipts", baseUrl];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSDictionary* dict;
    
    dict = @{@"id":transactionId,@"email-address":txtReceiptEmailAddress.text};
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dict
                                           options:NSJSONWritingPrettyPrinted error:nil];
    
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    //add a test apikey as a header. Do not hard code api keys in your app !
    [request setValue:@"24425c33043244778a188bd19846e860" forHTTPHeaderField:@"api-key"];

    [request setURL:[NSURL URLWithString:targetUrl]];
    [request setTimeoutInterval:20];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {
        
          //Clearent returns an object that is defined the same for both successful and unsuccessful calls with one exception. The 'payload' can be different.
          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
          NSLog(@"Clearent Transaction Response status code: %ld", (long)[httpResponse statusCode]);
        
          if(error != nil) {
              
              [self appendMessageToResults:error.description];
              
          } else if(data != nil) {
              
              NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
              NSDictionary *successfulResponseDictionary = [self jsonAsDictionary:responseStr];
              NSDictionary *payload = [successfulResponseDictionary objectForKey:@"payload"];
              NSDictionary *receipt = [payload objectForKey:@"receipt-response"];
              NSString *emailAddress = [receipt objectForKey:@"email-address"];
              
              if(emailAddress != nil) {
                  NSString *receiptResult = [NSString stringWithFormat:@"Receipt emailed to %@", emailAddress];
                  [self appendMessageToResults:receiptResult];
              }

          }
          runningTransaction = false;
        
      }] resume];
}

- (void)viewDidUnload
{
     [super viewDidUnload];
}

- (IBAction) f_searchForBLE: (id) sender {
        
    clearentConnection = [self createClearentConnection];
    
    [clearentVP3300 startConnection:clearentConnection];
    
}

- (IBAction) connectionTypeChanged: (id) sender {
    
    switch (connectionTypeSelect.selectedSegmentIndex) {
    case 0:
        bluetoothConnectToFirstFound.hidden = NO;
        lastFiveDigitsOfDeviceSerialNumber.hidden = NO;
        bluetoothFriendlyName.hidden = NO;
        bluetoothConnectToFirstFoundLabel.hidden = NO;
        lastFiveDigitsOfDeviceSerialNumberLabel.hidden = NO;
        bluetoothFriendlyNameLabel.hidden = NO;
        bluetoothConnect.hidden = NO;
        bluetoothDisconnect.hidden = NO;
        bluetoothSearchResultsLabel.hidden = NO;
        bluetoothDevicePicker.hidden = NO;
        searchBluetooth.hidden = NO;
        searchBluetoothLabel.hidden = NO;
        break;
    case 1:
        bluetoothConnectToFirstFound.hidden = YES;
        lastFiveDigitsOfDeviceSerialNumber.hidden = YES;
        bluetoothFriendlyName.hidden = YES;
        bluetoothConnectToFirstFoundLabel.hidden = YES;
        lastFiveDigitsOfDeviceSerialNumberLabel.hidden = YES;
        bluetoothFriendlyNameLabel.hidden = YES;
        bluetoothConnect.hidden = YES;
        bluetoothDisconnect.hidden = YES;
        bluetoothSearchResultsLabel.hidden = YES;
        bluetoothDevicePicker.hidden = YES;
        searchBluetooth.hidden = YES;
        searchBluetoothLabel.hidden = YES;
        break;
    default:
        break;
    }
}

- (IBAction) readerInterfaceModeChanged: (id) sender {
    
    switch (readerInterfaceModeSelect.selectedSegmentIndex) {
    case 0:
        //TODO
        break;
    case 1:
       //TODO
        break;
    default:
        break;
    }
}

- (IBAction) readerUsageChanged: (id) sender {
    
    switch (readerUsage.selectedSegmentIndex) {
    case 0:
        txtExpirationDate.hidden = YES;
        txtCsc.hidden = YES;
        txtCreditCardNumber.hidden = YES;
        expirationDateLabel.hidden = YES;
        cardLabel.hidden = YES;
        cvvLabel.hidden = YES;
        manualEntryButton.hidden = YES;
        useReaderButton.hidden = NO;
        cancelReaderButton.hidden = NO;
        break;
    case 1:
        txtExpirationDate.hidden = NO;
        txtCsc.hidden = NO;
        txtCreditCardNumber.hidden = NO;
        expirationDateLabel.hidden = NO;
        cardLabel.hidden = NO;
        cvvLabel.hidden = NO;
        manualEntryButton.hidden = NO;
        useReaderButton.hidden = YES;
        cancelReaderButton.hidden = YES;
        break;
    default:
        break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    BOOL b = [clearentVP3300 isConnected];
    
    if(b==YES) {
        [self deviceConnected];
    } else {
        [self deviceDisconnected];
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
    
}


#pragma mark - spec methods

- (IBAction) f_manualEntry:(id)sender{
   // [self startCardImage];
    [self exampleManualEntry];
    
}

- (IBAction) f_disconnectBluetooth: (id) sender {
    
    [clearentVP3300 device_disconnectBLE];
    
}

- (IBAction) f_cancelTrans: (id) sender {
    
    [self disableCardImage];
    
    RETURN_CODE rt = [clearentVP3300  device_cancelTransaction];
    
    [self clearLog];
    
}

- (IBAction) f_loopTest:(id)sender {
        
    startLoop = true;
    loopCount = 0;
    loopCountLabel.text = @"";
    batteryLevelLabel.text = @"";
    batteryLevelTime = nil;
    loopStartTime = [self getTime];
    
    [self startTransactionInLoop:nil];
    loopTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(startTransactionInLoop:) userInfo:nil repeats:true];
    
}

- (void) startTransactionInLoop:(id) sender {
    
    resultsTextView.text = @"";
    
    if(!runningTransaction) {

        [clearentVP3300  device_cancelTransaction];
        //[clearentVP3300 device_disconnectBLE];
        
        runningTransaction = true;
        loopCount = loopCount + 1;
        loopCountLabel.text = [NSString stringWithFormat:@"%i",loopCount];
        ClearentPayment *clearentPayment = [self createClearentPayment];
        clearentConnection = [self createClearentConnection];
        ClearentResponse *clearentResponse = [clearentVP3300 startTransaction:clearentPayment clearentConnection:clearentConnection];

        if(clearentResponse.responseType != RESPONSE_SUCCESS) {
            NSString * str = [NSString stringWithFormat:
                            @"ERROR: ID-\"%i\", message: %@.",
                              clearentResponse.idtechReturnCode, clearentResponse.response];
            [self appendMessageToResults:str];
            [clearentVP3300  device_cancelTransaction];
        }
    }
}

- (IBAction) f_cancelLoopTest:(id)sender {
    
    if (loopTimer != nil) {
        [loopTimer invalidate];
        loopTimer = nil;
        startLoop = false;
    }
    
    loopCountLabel.text = [NSString stringWithFormat:@"%i",loopCount];
    
    if(batteryLevelTime != nil) {
        batteryLevelLabel.text = [NSString stringWithFormat:@"Low at %@", batteryLevelTime];
    } else {
        batteryLevelLabel.text = @"No Battery Info";
    }
    
    if(loopStartTime != nil) {
        loopEndTime = [self getTime];
        NSString *timeRange = [NSString stringWithFormat:@"Loop Time  %@ to %@ , transaction count: %i",loopStartTime, loopEndTime, loopCount];
        [self appendMessageToResults:timeRange];
    }
    
}


- (IBAction) f_startAnyTransaction:(id)sender{

    resultsTextView.text = @"";
    
    //The Clearent framework has been designed to expose all the capabilities of the IDTech framework. We've added a few methods to help consolidate some of those
    //based on the most common use case we have. Read the card and tokenize it.
    
    //The startTransaction method takes 2 arguments. The ClearentPayment which defines the payment request and the ClearentConnection which instructs the
    //framework how to connect to the reader.
    
    //When the transaction has been started, the framework will send back messages using the feedback callback. Messages marked as User Actions should be shown to the
    //user.
    
    //Once the card is read the data is sent to our servers. We send back a transaction token (jwt) using the successTransationToken callback.
    //The jwt in the ClearentTransactionToken object can then be used to present a payment to the Clearent mobile gateway endpoint.
    
    ClearentPayment *clearentPayment = [self createClearentPayment];
    
    clearentConnection = [self createClearentConnection];
    
    [self startCardImage];
    
    ClearentResponse *clearentResponse = [clearentVP3300 startTransaction:clearentPayment clearentConnection:clearentConnection];

    //If an error is returned here it means the transaction should be retried. The feedback callback should get all types of feedback, user actions, informational,
    //processing errors, and card read errors.
    //You can choose to filter out some of these messages but at a mimimum it is recommended you show the ones marked as FEEDBACK_USER_ACTION. Otherwise the User will
    //not know what to do when the reader wants them to perform an action related to the interation with the reader. Example, you swiped a card with a chip, or you
    //inserted the card wrong.
    
    if(clearentResponse.responseType != RESPONSE_SUCCESS) {
        
        NSString * str = [NSString stringWithFormat:
                        @"ERROR: ID-\"%i\", message: %@.",
                          clearentResponse.idtechReturnCode, clearentResponse.response];
        
        [self appendMessageToResults:str];
        
    }
}

- (ClearentPayment*) createClearentPayment {
    
    ClearentPayment *clearentPayment = [[ClearentPayment alloc] initSale];
    
    //Provide the amount when working with the 3 in 1 solution. The amount is required for contactless and since you don't know how they will interact with the reader
    //it's best to just provide the amount every time. If you are not using contactless and are using the 2 in 1 reader interface option with the ClearentConnection
    //you can pass a zero. This is only for creating the transation token (jwt). When you run the payment through the mobile gateway endpoint you will need to provide an
    //amount.
    [clearentPayment setAmount:[self getAmount]];
    
    //The email address is an optional field because credit card certification states you are suppose to print a receipt for the customer if there is an offline
    //decline. In this case we will email them a recent.
    clearentPayment.emailAddress = txtReceiptEmailAddress.text;
   
    return clearentPayment;
}

- (ClearentConnection*) createClearentConnection {
    
    //The create method contains defaults that optimize your first experience with connecting to IDTech readers. It defaults the connection
    //to bluetooth readers and when scanning will connect to the first IDTech reader found. When a bluetooth device is found the
    //framework will remember the device UUID that Apple generates so future connections are faster.
    
    //The bluetooth solution also uses the service UUID of 1820 as a filter since all IDTech readers are configured to use it.
    
    ClearentConnection *clearentConnection;
    if(connectionTypeSelect.selectedSegmentIndex == 0) {
        clearentConnection =  [[ClearentConnection alloc] initBluetoothFirstConnect];
    } else {
        clearentConnection =  [[ClearentConnection alloc] initAudioJack];
    }
    
    if(readerInterfaceModeSelect.selectedSegmentIndex == 0) {
        clearentConnection.readerInterfaceMode = CLEARENT_READER_INTERFACE_3_IN_1;
    } else {
        clearentConnection.readerInterfaceMode = CLEARENT_READER_INTERFACE_2_IN_1;
    }
    
    if(bluetoothConnectToFirstFound.on) {
        clearentConnection.connectToFirstBluetoothFound = true;
    } else {
        clearentConnection.connectToFirstBluetoothFound = false;
    }
    
    if(searchBluetooth.on) {
        clearentConnection.searchBluetooth = true;
    } else {
        clearentConnection.searchBluetooth = false;
    }
    
    NSString *enteredBluetoothFriendlyName = [bluetoothFriendlyName text];
    
    if(enteredBluetoothFriendlyName != nil && bluetoothDevicesFound != nil && bluetoothDevicesFound.count > 0) {
        
        for (ClearentBluetoothDevice* clearentBluetoothDevice in bluetoothDevicesFound) {
            if([enteredBluetoothFriendlyName isEqualToString:clearentBluetoothDevice.friendlyName]) {
                clearentConnection.bluetoothDeviceId = clearentBluetoothDevice.deviceId;
                clearentConnection.fullFriendlyName = nil;
            }
        }
    }
    
    //clearentConnection.bluetoothAdvertisingInterval = CLEARENT_BLUETOOTH_ADVERTISING_INTERVAL_60_MS;
    
    //clearentConnection.bluetoothMaximumScanInSeconds = 60;
    
    //Most of the time you will never use this. But you do have the ability to change the friendly name of the device and if you do you will need to provide
    //the full friendly name, especially if it does not conform to IDTECH's default naming standard - IDTECH-VP3300-nnnnn (where nnnnn is last 5 of device serial
    //number.
    
    if(clearentConnection.bluetoothDeviceId == nil && enteredBluetoothFriendlyName != nil) {
        clearentConnection.fullFriendlyName = enteredBluetoothFriendlyName;
    }
    
    //if you have a reader in hand, and can provide the last 5 digits of the device serial number, the framework will add the IdTech friendly name prefix for you
    //(IDTECH-VP3300-)
    
    clearentConnection.lastFiveDigitsOfDeviceSerialNumber = [lastFiveDigitsOfDeviceSerialNumber text];

    return clearentConnection;
}

- (double) getAmount {
    
    double amount;
    
    if(txtAmount.text != nil && ![txtAmount.text isEqualToString:@""]) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        formatter.maximumFractionDigits = 2;
        formatter.roundingMode = NSNumberFormatterRoundHalfUp;
        NSNumber *nsNumber = [formatter numberFromString:txtAmount.text];
        amount = nsNumber.doubleValue;
    } else {
        amount = 1.00;
        txtAmount.text = @"1.00";
    }
    
    return amount;
}


- (NSString*) getTime {
    
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    NSString *newDateString = [outputFormatter stringFromDate:now];
    NSLog(@"date %@", newDateString);
    return newDateString;
    
}


@end

