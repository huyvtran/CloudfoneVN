//
//  AppDelegate.h
//  CloudfoneVN
//
//  Created by Khai Leo on 8/24/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PushKit/PushKit.h>
#import "WebServices.h"
#import "HMLocalization.h"
#import "Reachability.h"
#import "ContactObject.h"
#import "UIView+Toast.h"
#import <AddressBookUI/ABPeoplePickerNavigationController.h>
#import "AddressBook/ABPerson.h"
#import <FMDatabaseQueue.h>
#import <FMDatabase.h>
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import "CallViewController.h"
#import "DialerViewController.h"
#import "ProviderDelegate.h"
#import <AVFoundation/AVFoundation.h>

typedef enum AccountState{
    eAccountNone,
    eAccountOff,
    eAccountDis,
    eAccountOn,
}AccountState;

typedef enum eContact{
    eContactPBX,
    eContactAll,
}eContact;

typedef enum typePhoneNumber{
    ePBXPhone,
    eNormalPhone,
}typePhoneNumber;

typedef enum eTypeHistory{
    eAllCalls,
    eMissedCalls,
}eTypeHistory;

@interface AppDelegate : UIResponder <UIApplicationDelegate, WebServicesDelegate, PKPushRegistryDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) NSString *databasePath;

@property (nonatomic, strong) NSData *dataCrop;
@property (nonatomic, strong) UIImage *cropAvatar;
@property (nonatomic, assign) BOOL fromImagePicker;

@property (nonatomic, strong, getter=theNewContact) ContactObject *newContact;

@property (nonatomic, strong) WebServices *webService;
@property (nonatomic, strong) NSArray *listNumber;

@property (nonatomic, strong) NSString *logFilePath;
@property (nonatomic, assign) BOOL contactLoaded;
@property (nonatomic, assign) float hStatus;
@property (nonatomic, assign) float hNav;
@property (nonatomic, strong) NSMutableArray *listInfoPhoneNumber;
@property (nonatomic, strong) HMLocalization *localization;
@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, assign) BOOL updateTokenSuccess;

@property (nonatomic, strong) UIFont *fontLarge;
@property (nonatomic, strong) UIFont *fontNormal;
@property (nonatomic, strong) UIFont *fontDesc;

@property (nonatomic, strong) UIFont *fontLargeBold;
@property (nonatomic, strong) UIFont *fontNormalBold;
@property (nonatomic, strong) UIFont *fontDescBold;

@property (strong, nonatomic) CSToastStyle *errorStyle;
@property (strong, nonatomic) CSToastStyle *warningStyle;
@property (strong, nonatomic) CSToastStyle *successStyle;

@property (nonatomic, assign) BOOL internetActive;
@property (strong, nonatomic) Reachability *internetReachable;
@property (nonatomic, strong) NSMutableArray *pbxContacts;
@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, assign) BOOL isSyncing;

@property (nonatomic, strong) UIView *splashScreen;

+ (AppDelegate *)sharedInstance;
- (void)enableSizeForBarButtonItem: (BOOL)enable;

@property (nonatomic, assign) int numTryRegister;
@property (nonatomic, strong) CallViewController *callViewController;
@property (nonatomic, strong) DialerViewController *transferViewController;
@property (nonatomic, strong) ProviderDelegate *del;
@property (nonatomic, strong) PKPushRegistry* voipRegistry;
@property (nonatomic, assign) int current_call_id;
@property (nonatomic, assign) int pjsipConfAudioId;
@property (nonatomic, strong) NSString *remoteNumber;
@property (nonatomic, strong) AVAudioPlayer *beepPlayer;
@property (nonatomic, strong) AVAudioPlayer *ringbackPlayer;
@property (nonatomic, assign) BOOL refreshingSIP;
@property (nonatomic, assign) BOOL clearingSIP;
@property (nonatomic, strong) NSMutableArray *sipAccIDs;
- (void)playRingbackTone;
- (void)stopRingbackTone;
- (void)checkCallInfo;

- (void)refreshCurrentSIPRegistrationState;
- (BOOL)turnOfCurrentAccountDefault: (BOOL)turnOff;
- (void)tryToReRegisterToSIP;
- (void)registerSIPAccountWithInfo: (NSDictionary *)info;
- (void)checkToClearAllAccRegisteredBefore;
- (AccountState)checkSipStateOfAccount;
- (void)removeAccIDWhenRegisterFailed;
- (BOOL)deleteSIPAccountDefault;
- (void)makeCallTo: (NSString *)strCall;
- (void)transferCallToUserWithNumber: (NSString *)number;
- (int)getDurationForCurrentCall;
- (BOOL)checkCurrentCallWasHold;
- (BOOL)checkMicrophoneWasMuted;
- (BOOL)holdCurrentCall: (BOOL)hold;
- (BOOL)muteMicrophone: (BOOL)mute;
- (void)showCallViewWithDirection: (CallDirection)direction remote: (NSString *)remote displayName: (NSString *)displayName;
- (NSArray *)getContactNameOfRemoteForCall;
- (void)hangupAllCall;
- (void)answerCallWithCallID: (int)call_id;
- (BOOL)isCallWasConnected;
- (void)playBeepSound;
- (BOOL)sendDtmfWithValue: (NSString *)value;
- (void)hideCallView;
- (NSString *)getLastStatusOfCurrenCall;
- (void)refreshSIPRegistration;
- (void)showTransferCallView;
- (void)hideTransferCallView;
- (NSString *)getCallStateOfCurrentCall;
- (void)clearAndReRegisterAgainSIPAccount;

- (void)fetchAllContactsFromPhoneBook;
- (void)updateCustomerTokenIOS;

@end

