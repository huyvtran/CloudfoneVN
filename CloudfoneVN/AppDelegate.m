//
//  AppDelegate.m
//  CloudfoneVN
//
//  Created by Khai Leo on 8/24/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import "AppDelegate.h"
#import "AppTabbarViewController.h"
#import "PBXContact.h"
#import "PhoneObject.h"
#import "ContactDetailObj.h"
#import <Intents/Intents.h>
#include <Intents/INInteraction.h>

//  FOR PJSIP
#include "pjsip_sources/pjlib/include/pjlib.h"
#include "pjsip_sources/pjsip/include/pjsua.h"
#include "pjsip_sources/pjsua/pjsua_app.h"
#include "pjsip_sources/pjsua/pjsua_app_config.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AppDelegate (){
    Reachability* hostReachable;
}

@end

@implementation AppDelegate
@synthesize logFilePath, contactLoaded, listInfoPhoneNumber, localization, hStatus, hNav, internetActive, internetReachable, deviceToken, updateTokenSuccess;
@synthesize databasePath;
@synthesize fontDesc, fontNormal, fontLarge, fontDescBold, fontLargeBold, fontNormalBold;
@synthesize errorStyle, warningStyle, successStyle;
@synthesize pbxContacts, contacts, isSyncing;
@synthesize current_call_id, pjsipConfAudioId, remoteNumber, del, voipRegistry, callViewController, transferViewController, beepPlayer, ringbackPlayer, refreshingSIP, clearingSIP, sipAccIDs, numTryRegister;
@synthesize webService, listNumber;
@synthesize cropAvatar, dataCrop, fromImagePicker, splashScreen;

AppDelegate      *app;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //  SET FABRIC
    [Fabric with:@[[Crashlytics class]]];
    
    NSString *subDirectory = [NSString stringWithFormat:@"%@/.%@.txt", logsFolderName, [AppUtil getCurrentDate]];
    logFilePath = [WriteLogsUtils makeFilePathWithFileName: subDirectory];
    
    [WriteLogsUtils startWriteLogsUtil];
    [AppUtil startAppUtil];
    [ContactsUtil startContactsUtil];
    [SipUtil startSipUtil];
    
    webService = [[WebServices alloc] init];
    webService.delegate = self;
    
    listNumber = [[NSArray alloc] initWithObjects: @"+", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    sipAccIDs = [[NSMutableArray alloc] init];
    
    NSString *version = [AppUtil getAppVersionWithBuildVersion: YES];
    if (IS_IPHONE || IS_IPOD) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@">>>>>>>>>>>>>>>>>>>> START APPLICATION ON IPHONE with APP VERSION: %@ <<<<<<<<<<<<<<<<<<<<", version]];
    }else{
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@">>>>>>>>>>>>>>>>>>>> START APPLICATION ON IPAD with APP VERSION: %@ <<<<<<<<<<<<<<<<<<<<", version]];
    }
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")){
        UNUserNotificationCenter *notifiCenter = [UNUserNotificationCenter currentNotificationCenter];
        notifiCenter.delegate = self;
        [notifiCenter requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }
        }];
    }
    
    //  Enable all notification type. VoIP Notifications don't present a UI but we will use this to show local nofications later
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert| UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    
    //register the notification settings
    [application registerUserNotificationSettings:notificationSettings];
    
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact
                contactLoaded = NO;
                [self fetchAllContactsFromPhoneBook];
            } else {
                NSLog(@"User denied access");
            }
        });
    }else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined){
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact
                contactLoaded = NO;
                [self fetchAllContactsFromPhoneBook];
            } else {
                NSLog(@"User denied access");
            }
        });
    }
    
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostName:@"www.apple.com"];
    [hostReachable startNotifier];
    
    [self setupFontForApp];
    [self setupMessageStyleForApp];
    
    [self enableSizeForBarButtonItem: FALSE];
    
    UINavigationBar.appearance.barTintColor = MENU_ACTIVE_COLOR;
    UINavigationBar.appearance.tintColor = UIColor.whiteColor;
    UINavigationBar.appearance.translucent = NO;
    
    UINavigationBar.appearance.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:fontLarge, NSFontAttributeName, UIColor.whiteColor, NSForegroundColorAttributeName, nil];
    
    hStatus = application.statusBarFrame.size.height;
    isSyncing = FALSE;
    
    //  Set default language for app if haven't setted yet
    [self setLanguageForApp];
    
    // Copy database and connect
    [self copyFileDataToDocument:@"cloudfonevn.sqlite"];
    [DatabaseUtil startDatabaseUtil];
    [DatabaseUtil connectToDatabase];
    
    
    AppTabbarViewController *tabbarVC = [[AppTabbarViewController alloc] init];
    [self.window setRootViewController: tabbarVC];
    [self.window makeKeyAndVisible];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
        self.del = [[ProviderDelegate alloc] init];
        [self.del config];
    }
    [self registerForNotifications:[UIApplication sharedApplication]];
    
    app = self;
    [self startPjsuaForApp];
    current_call_id = -1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:)
                                                 name:kReachabilityChangedNotification object:nil];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    int num_call = pjsua_call_get_count();
    if (num_call == 0) {
        [self deleteSIPAccountDefault];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //  Kiểm tra thử đang có cuộc gọi hay không? Để kiểm tra trường hợp bấm gọi từ call history của thiết bị
    int num_call = pjsua_call_get_count();
    if (num_call == 0) {
        numTryRegister = 0;
        
        int numAccount = pjsua_acc_get_count();
        if (numAccount == 0) {
            [self tryToReRegisterToSIP];
        }
        
        AccountState accState = [self checkSipStateOfAccount];
        //  kiếm tra có phải từ phone call history mở lên không
        NSString *phoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:UserActivity];
        if (![AppUtil isNullOrEmpty: phoneNumber])
        {
            if (accState == eAccountNone) {
                //  Nếu chưa đăng nhập, mà có thông tin đăng nhập thì đăng nhập rồi gọi
                NSString *domain = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
                NSString *port = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PORT];
                
                if (![AppUtil isNullOrEmpty: domain] && ![AppUtil isNullOrEmpty: port] && ![AppUtil isNullOrEmpty: USERNAME] && ![AppUtil isNullOrEmpty: port])
                {
                    
                }else{
                    //  reset value
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserActivity];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserActivityName];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [self.window makeToast:[localization localizedStringForKey:@"You have not signed your account yet"] duration:3.0 position:CSToastPositionCenter];
                }
            }
            else if (accState == eAccountOn) {
                NSString *displayName = [[NSUserDefaults standardUserDefaults] objectForKey:UserActivityName];
                //  Nếu SIP registration đang sẵn sàng thì gọi
                [SipUtil makeCallToPhoneNumber: phoneNumber displayName: displayName];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserActivity];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserActivityName];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            }
            else{
                //  Chờ đăng ký SIP xong sẽ gọi
            }
            
            
            
//            switch (accState) {
//                case eAccountNone:
//                {
//
//
//                    [self performSelector:@selector(hideSplashScreen) withObject:nil afterDelay:3.0];
//
//                    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"Call with UserActivity phone number = %@, but have not signed with any account", phoneNumber] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
//
//                    break;
//                }
//                case eAccountOff:
//                {
//                    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"Call with UserActivity phone number = %@, but current account was off", phoneNumber] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
//
//                    UIAlertView *alertAcc = [[UIAlertView alloc] initWithTitle:nil message:[localization localizedStringForKey:@"Your account was turned off. Do you want to enable and call?"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"No"] otherButtonTitles: [localization localizedStringForKey:@"Yes"], nil];
//                    alertAcc.delegate = self;
//                    alertAcc.tag = 100;
//                    [alertAcc show];
//
//                    break;
//                }
//                default:
//                    break;
//            }
//            if (accState == eAccountNone || accState == eAccountOff) {
//
//            }else{
//                //  Check registration state
//                LinphoneRegistrationState state = [SipUtils getRegistrationStateOfDefaultProxyConfig];
//                if (state == LinphoneRegistrationOk) {
//                    [waitingHud dismissAnimated: TRUE];
//
//                    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"Call with UserActivity phone number = %@", phoneNumber] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
//
//                    splashScreen.hidden = YES;
//
//                }else {
//                    if (waitingHud == nil) {
//                        waitingHud = [[YBHud alloc] initWithHudType:DGActivityIndicatorAnimationTypeLineScale andText:@""];
//                        waitingHud.tintColor = [UIColor whiteColor];
//                        waitingHud.dimAmount = 0.5;
//                    }
//                    [waitingHud showInView:self.window animated:TRUE];
//
//                    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"Call with UserActivity phone number = %@, but waiting for register to SIP", phoneNumber] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
//                }
//            }
        }
    }else{
        
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
{
    //  when user click facetime video
    if ([userActivity.activityType isEqualToString:@"INStartVideoCallIntent"]) {
        return TRUE;
    }
    
    INInteraction *interaction = userActivity.interaction;
    if (interaction != nil) {
        INStartAudioCallIntent *startAudioCallIntent = (INStartAudioCallIntent *)interaction.intent;
        if (startAudioCallIntent != nil && startAudioCallIntent.contacts.count > 0) {
            INPerson *contact = startAudioCallIntent.contacts[0];
            if (contact != nil) {
                INPersonHandle *personHandle = contact.personHandle;
                NSString *content = personHandle.value;
                if (![AppUtil isNullOrEmpty: content])
                {
                    NSArray *arr = [content componentsSeparatedByString:@"|||"];
                    NSString *callerName = @"";
                    NSString *phoneNumber = @"";
                    
                    if (arr.count == 2) {
                        callerName = [arr objectAtIndex: 0];
                        phoneNumber = [arr objectAtIndex: 1];
                        
                    }else if (arr.count == 1) {
                        phoneNumber = [arr objectAtIndex: 0];
                    }
                    
                    if (![AppUtil isNullOrEmpty: phoneNumber]) {
                        if (callerName == nil) {
                            callerName = @"";
                        }
                        
                        [[NSUserDefaults standardUserDefaults] setObject:phoneNumber forKey:UserActivity];
                        [[NSUserDefaults standardUserDefaults] setObject:callerName forKey:UserActivityName];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }
            }
        }
    }
    return YES;
}

- (void)clearAndReRegisterAgainSIPAccount {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTextForConnectingSIPAccount" object:nil];
    
    numTryRegister++;
    [self deleteSIPAccountDefault];
    [self performSelector:@selector(tryToReRegisterToSIP) withObject:nil afterDelay:1.0];
}

+ (AppDelegate *)sharedInstance{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (void)registerForNotifications:(UIApplication *)app {
    self.voipRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    self.voipRegistry.delegate = self;
    
    // Initiate registration.
    self.voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
        // Call category
        UNNotificationAction *act_ans =
        [UNNotificationAction actionWithIdentifier:@"Answer"
                                             title:NSLocalizedString(@"Answer", nil)
                                           options:UNNotificationActionOptionForeground];
        UNNotificationAction *act_dec = [UNNotificationAction actionWithIdentifier:@"Decline"
                                                                             title:NSLocalizedString(@"Decline", nil)
                                                                           options:UNNotificationActionOptionNone];
        UNNotificationCategory *cat_call =
        [UNNotificationCategory categoryWithIdentifier:@"call_cat"
                                               actions:[NSArray arrayWithObjects:act_ans, act_dec, nil]
                                     intentIdentifiers:[[NSMutableArray alloc] init]
                                               options:UNNotificationCategoryOptionCustomDismissAction];
        
        // Msg category
        UNTextInputNotificationAction *act_reply =
        [UNTextInputNotificationAction actionWithIdentifier:@"Reply"
                                                      title:NSLocalizedString(@"Reply", nil)
                                                    options:UNNotificationActionOptionNone];
        UNNotificationAction *act_seen =
        [UNNotificationAction actionWithIdentifier:@"Seen"
                                             title:NSLocalizedString(@"Mark as seen", nil)
                                           options:UNNotificationActionOptionNone];
        UNNotificationCategory *cat_msg =
        [UNNotificationCategory categoryWithIdentifier:@"msg_cat"
                                               actions:[NSArray arrayWithObjects:act_reply, act_seen, nil]
                                     intentIdentifiers:[[NSMutableArray alloc] init]
                                               options:UNNotificationCategoryOptionCustomDismissAction];
        
        // Video Request Category
        UNNotificationAction *act_accept =
        [UNNotificationAction actionWithIdentifier:@"Accept"
                                             title:NSLocalizedString(@"Accept", nil)
                                           options:UNNotificationActionOptionForeground];
        
        UNNotificationAction *act_refuse = [UNNotificationAction actionWithIdentifier:@"Cancel"
                                                                                title:NSLocalizedString(@"Cancel", nil)
                                                                              options:UNNotificationActionOptionNone];
        UNNotificationCategory *video_call =
        [UNNotificationCategory categoryWithIdentifier:@"video_request"
                                               actions:[NSArray arrayWithObjects:act_accept, act_refuse, nil]
                                     intentIdentifiers:[[NSMutableArray alloc] init]
                                               options:UNNotificationCategoryOptionCustomDismissAction];
        
        // ZRTP verification category
        UNNotificationAction *act_confirm = [UNNotificationAction actionWithIdentifier:@"Confirm"
                                                                                 title:NSLocalizedString(@"Accept", nil)
                                                                               options:UNNotificationActionOptionNone];
        
        UNNotificationAction *act_deny = [UNNotificationAction actionWithIdentifier:@"Deny"
                                                                              title:NSLocalizedString(@"Deny", nil)
                                                                            options:UNNotificationActionOptionNone];
        UNNotificationCategory *cat_zrtp =
        [UNNotificationCategory categoryWithIdentifier:@"zrtp_request"
                                               actions:[NSArray arrayWithObjects:act_confirm, act_deny, nil]
                                     intentIdentifiers:[[NSMutableArray alloc] init]
                                               options:UNNotificationCategoryOptionCustomDismissAction];
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        [[UNUserNotificationCenter currentNotificationCenter]
         requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound |
                                          UNAuthorizationOptionBadge)
         completionHandler:^(BOOL granted, NSError *_Nullable error) {
             // Enable or disable features based on authorization.
             if (error) {
                 NSLog(@"%@", error.description);
             }
         }];
        NSSet *categories = [NSSet setWithObjects:cat_call, cat_msg, video_call, cat_zrtp, nil];
        [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:categories];
    }
}

- (void)fetchAllContactsFromPhoneBook {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (contacts == nil) {
            contacts = [[NSMutableArray alloc] init];
        }
        [contacts removeAllObjects];
        
        if (listInfoPhoneNumber == nil) {
            listInfoPhoneNumber = [[NSMutableArray alloc] init];
        }
        [listInfoPhoneNumber removeAllObjects];
        
        ABAddressBookRef addressListBook = ABAddressBookCreate();
        NSArray *arrayOfAllPeople = (__bridge  NSArray *) ABAddressBookCopyArrayOfAllPeople(addressListBook);
        if (arrayOfAllPeople != nil) {
            [contacts addObjectsFromArray: arrayOfAllPeople];
        }
        
        [self getAllIDContactInPhoneBook];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            contactLoaded = TRUE;
            [[NSNotificationCenter defaultCenter] postNotificationName:finishLoadContacts object:nil];
        });
    });
}

- (void)setLanguageForApp {
    NSString *curLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:language_key];
    if ([AppUtil isNullOrEmpty: curLanguage]) {
        curLanguage = key_vi;
        [[NSUserDefaults standardUserDefaults] setObject:curLanguage forKey:language_key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    localization = [HMLocalization sharedInstance];
    [localization setLanguage: curLanguage];
}

- (void)getAllIDContactInPhoneBook
{
    if (pbxContacts == nil) {
        pbxContacts = [[NSMutableArray alloc] init];
    }
    [pbxContacts removeAllObjects];
    
    ABAddressBookRef addressListBook = ABAddressBookCreate();
    NSArray *arrayOfAllPeople = (__bridge  NSArray *) ABAddressBookCopyArrayOfAllPeople(addressListBook);
    NSUInteger peopleCounter = 0;
    
    for (peopleCounter = 0; peopleCounter < [arrayOfAllPeople count]; peopleCounter++)
    {
        ABRecordRef aPerson = (__bridge ABRecordRef)[arrayOfAllPeople objectAtIndex:peopleCounter];
        int contactId = ABRecordGetRecordID(aPerson);
        
        //  Kiem tra co phai la contact pbx hay ko?
        NSString *sipNumber = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonFirstNamePhoneticProperty);
        if (sipNumber != nil && [sipNumber isEqualToString: keySyncPBX])
        {
            NSString *pbxServer = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
            ABMultiValueRef phones = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
            if (ABMultiValueGetCount(phones) > 0)
            {
                NSMutableArray *listPBX = [[NSMutableArray alloc] init];
                
                for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
                {
                    CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
                    CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phones, j);
                    
                    NSString *phoneStr = (__bridge NSString *)phoneNumberRef;
                    phoneStr = [[phoneStr componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                    
                    NSString *nameStr = (__bridge NSString *)locLabel;
                    
                    if (phoneStr != nil && nameStr != nil) {
                        PBXContact *pbxContact = [[PBXContact alloc] init];
                        pbxContact._name = nameStr;
                        pbxContact._number = phoneStr;
                        
                        NSString *convertName = [AppUtil convertUTF8CharacterToCharacter: nameStr];
                        NSString *nameForSearch = [AppUtil getNameForSearchOfConvertName: convertName];
                        pbxContact._nameForSearch = nameForSearch;
                        [listPBX addObject: pbxContact];
                        
                        //  get avatar
                        NSString *avatarStr = @"";
                        if (![AppUtil isNullOrEmpty: pbxServer]) {
                            NSString *avatarName = SFM(@"%@_%@.png", pbxServer, phoneStr);
                            NSString *localFile = SFM(@"/avatars/%@", avatarName);
                            NSData *avatarData = [AppUtil getFileDataFromDirectoryWithFileName:localFile];
                            if (avatarData != nil) {
                                avatarStr = [avatarData base64EncodedStringWithOptions: 0];
                            }
                        }
                        //  [Khai le - 02/11/2018]
                        PhoneObject *phone = [[PhoneObject alloc] init];
                        phone.number = phoneStr;
                        phone.name = nameStr;
                        phone.nameForSearch = nameForSearch;
                        phone.avatar = avatarStr;
                        phone.contactId = contactId;
                        phone.phoneType = ePBXPhone;
                        
                        [listInfoPhoneNumber addObject: phone];
                    }
                }
                [pbxContacts removeAllObjects];
                [pbxContacts addObjectsFromArray: listPBX];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:contactId] forKey:PBX_ID_CONTACT];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:finishGetPBXContacts object:nil];
            });
            
            continue;
        }
        NSString *fullname = [AppUtil getNameOfContact: aPerson];
        if (![AppUtil isNullOrEmpty: fullname])
        {
            NSMutableArray *listPhone = [self getListPhoneOfContactPerson: aPerson withName: fullname];
            if (listPhone != nil && listPhone.count > 0) {
                NSString *convertName = [AppUtil convertUTF8CharacterToCharacter: fullname];
                NSString *nameForSearch = [AppUtil getNameForSearchOfConvertName: convertName];
                
                for (int i=0; i<listPhone.count; i++) {
                    ContactDetailObj *phoneItem = [listPhone objectAtIndex: i];
                    
                    PhoneObject *phone = [[PhoneObject alloc] init];
                    phone.number = phoneItem._valueStr;
                    phone.name = fullname;
                    phone.nameForSearch = nameForSearch;
                    phone.avatar = [ContactsUtil getBase64AvatarFromContact: aPerson];
                    phone.contactId = contactId;
                    phone.phoneType = eNormalPhone;
                    
                    [listInfoPhoneNumber addObject: phone];
                }
            }else{
                NSLog(@"This contact don't have any phone number!!!");
            }
        }
    }
}

- (NSMutableArray *)getListPhoneOfContactPerson: (ABRecordRef)aPerson withName: (NSString *)contactName
{
    NSMutableArray *result = nil;
    ABMultiValueRef phones = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
    NSString *strPhone = [[NSMutableString alloc] init];
    if (ABMultiValueGetCount(phones) > 0)
    {
        result = [[NSMutableArray alloc] init];
        
        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
        {
            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
            CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phones, j);
            
            NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;
            phoneNumber = [self removeAllSpecialInString: phoneNumber];
            
            strPhone = @"";
            if (locLabel == nil) {
                ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                anItem._iconStr = @"btn_contacts_home.png";
                anItem._titleStr = [localization localizedStringForKey:@"Home"];
                anItem._valueStr = phoneNumber;
                anItem._buttonStr = @"contact_detail_icon_call.png";
                anItem._typePhone = type_phone_home;
                [result addObject: anItem];
            }else{
                if (CFStringCompare(locLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_home.png";
                    anItem._titleStr = [localization localizedStringForKey:@"Home"];
                    anItem._valueStr = phoneNumber;
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_home;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABWorkLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_work.png";
                    anItem._titleStr = [localization localizedStringForKey:@"Work"];
                    anItem._valueStr = phoneNumber;
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_work;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_mobile.png";
                    anItem._titleStr = [localization localizedStringForKey:@"Mobile"];
                    anItem._valueStr = phoneNumber;
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_mobile;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABPersonPhoneHomeFAXLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_fax.png";
                    anItem._titleStr = [localization localizedStringForKey:@"Fax"];
                    anItem._valueStr = phoneNumber;
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_fax;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABOtherLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_fax.png";
                    anItem._titleStr = [localization localizedStringForKey:@"Other"];
                    anItem._valueStr = phoneNumber;
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_other;
                    [result addObject: anItem];
                }else{
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_mobile.png";
                    anItem._titleStr = [localization localizedStringForKey:@"Mobile"];
                    anItem._valueStr = phoneNumber;
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_mobile;
                    [result addObject: anItem];
                }
            }
        }
    }
    return result;
}

- (NSString *)removeAllSpecialInString: (NSString *)phoneString {
    NSString *resultStr = @"";
    for (int strCount=0; strCount<phoneString.length; strCount++) {
        char characterChar = [phoneString characterAtIndex: strCount];
        NSString *characterStr = SFM(@"%c", characterChar);
        if ([listNumber containsObject: characterStr]) {
            resultStr = SFM(@"%@%@", resultStr, characterStr);
        }
    }
    return resultStr;
}

- (void)checkNetworkStatus:(NSNotification *)notice
{
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable: {
            internetActive = FALSE;
            [[NSNotificationCenter defaultCenter] postNotificationName:networkChanged object:nil];
            break;
        }
        case ReachableViaWiFi: {
            internetActive = TRUE;
            [[NSNotificationCenter defaultCenter] postNotificationName:networkChanged object:nil];
            break;
        }
        case ReachableViaWWAN: {
            internetActive = TRUE;
            [[NSNotificationCenter defaultCenter] postNotificationName:networkChanged object:nil];
            break;
        }
    }
}

- (void)setupFontForApp {
    if (IS_IPHONE || IS_IPOD) {
        NSString *deviceMode = [DeviceUtil getModelsOfCurrentDevice];
        if ([deviceMode isEqualToString: Iphone5_1] || [deviceMode isEqualToString: Iphone5_2] || [deviceMode isEqualToString: Iphone5c_1] || [deviceMode isEqualToString: Iphone5c_2] || [deviceMode isEqualToString: Iphone5s_1] || [deviceMode isEqualToString: Iphone5s_2] || [deviceMode isEqualToString: IphoneSE])
        {
            fontLarge = [UIFont fontWithName:MYRIADPRO_REGULAR size:19.0];
            fontNormal = [UIFont fontWithName:MYRIADPRO_REGULAR size:17.0];
            fontDesc = [UIFont fontWithName:MYRIADPRO_REGULAR size:15.0];
            
            fontLargeBold = [UIFont fontWithName:MYRIADPRO_BOLD size:18.0];
            fontNormalBold = [UIFont fontWithName:MYRIADPRO_BOLD size:16.0];
            fontDescBold = [UIFont fontWithName:MYRIADPRO_BOLD size:14.0];
            
        }else if ([deviceMode isEqualToString: Iphone6] || [deviceMode isEqualToString: Iphone6s] || [deviceMode isEqualToString: Iphone7_1] || [deviceMode isEqualToString: Iphone7_2] || [deviceMode isEqualToString: Iphone8_1] || [deviceMode isEqualToString: Iphone8_2])
        {
            fontLarge = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
            fontNormal = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
            fontDesc = [UIFont fontWithName:MYRIADPRO_REGULAR size:14.0];
            
            fontLargeBold = [UIFont fontWithName:MYRIADPRO_BOLD size:18.0];
            fontNormalBold = [UIFont fontWithName:MYRIADPRO_BOLD size:16.0];
            fontDescBold = [UIFont fontWithName:MYRIADPRO_BOLD size:14.0];
            
        }else if ([deviceMode isEqualToString: Iphone6_Plus] || [deviceMode isEqualToString: Iphone6s_Plus] || [deviceMode isEqualToString: Iphone7_Plus1] || [deviceMode isEqualToString: Iphone7_Plus2] || [deviceMode isEqualToString: Iphone8_Plus1] || [deviceMode isEqualToString: Iphone8_Plus2])
        {
            fontNormal = [UIFont fontWithName:MYRIADPRO_REGULAR size:15.0];
            fontDesc = [UIFont fontWithName:MYRIADPRO_REGULAR size:14.0];
            
            fontLargeBold = [UIFont fontWithName:MYRIADPRO_BOLD size:18.0];
            fontNormalBold = [UIFont fontWithName:MYRIADPRO_BOLD size:16.0];
            fontDescBold = [UIFont fontWithName:MYRIADPRO_BOLD size:14.0];
            
        }else if ([deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS]){
            //  Screen width: 375.000000 - Screen height: 812.000000
            fontNormal = [UIFont fontWithName:MYRIADPRO_REGULAR size:15.0];
            fontDesc = [UIFont fontWithName:MYRIADPRO_REGULAR size:14.0];
            
            fontLargeBold = [UIFont fontWithName:MYRIADPRO_BOLD size:18.0];
            fontNormalBold = [UIFont fontWithName:MYRIADPRO_BOLD size:16.0];
            fontDescBold = [UIFont fontWithName:MYRIADPRO_BOLD size:14.0];
            
        }else if ([deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2]){
            //  Screen width: 375.000000 - Screen height: 812.000000
            fontNormal = [UIFont fontWithName:MYRIADPRO_REGULAR size:15.0];
            fontDesc = [UIFont fontWithName:MYRIADPRO_REGULAR size:14.0];
            
            fontLargeBold = [UIFont fontWithName:MYRIADPRO_BOLD size:18.0];
            fontNormalBold = [UIFont fontWithName:MYRIADPRO_BOLD size:16.0];
            fontDescBold = [UIFont fontWithName:MYRIADPRO_BOLD size:14.0];
        }else{
            fontNormal = [UIFont fontWithName:MYRIADPRO_REGULAR size:15.0];
            fontDesc = [UIFont fontWithName:MYRIADPRO_REGULAR size:14.0];
            
            fontLargeBold = [UIFont fontWithName:MYRIADPRO_BOLD size:18.0];
            fontNormalBold = [UIFont fontWithName:MYRIADPRO_BOLD size:16.0];
            fontDescBold = [UIFont fontWithName:MYRIADPRO_BOLD size:14.0];
        }
    }else{
        fontNormal = [UIFont fontWithName:MYRIADPRO_REGULAR size:15.0];
        fontDesc = [UIFont fontWithName:MYRIADPRO_REGULAR size:14.0];
    }
}

- (void)setupMessageStyleForApp {
    //  setup message style
    warningStyle = [[CSToastStyle alloc] initWithDefaultStyle];
    warningStyle.backgroundColor = ORANGE_COLOR;
    warningStyle.messageColor = UIColor.whiteColor;
    warningStyle.messageFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    warningStyle.cornerRadius = 20.0;
    warningStyle.messageAlignment = NSTextAlignmentCenter;
    warningStyle.messageNumberOfLines = 5;
    warningStyle.shadowColor = UIColor.blackColor;
    warningStyle.shadowOpacity = 1.0;
    warningStyle.shadowOffset = CGSizeMake(-5, -5);
    
    errorStyle = [[CSToastStyle alloc] initWithDefaultStyle];
    errorStyle.backgroundColor = [UIColor colorWithRed:(211/255.0) green:(55/255.0) blue:(55/255.0) alpha:1.0];
    errorStyle.messageColor = UIColor.whiteColor;
    errorStyle.messageFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    errorStyle.cornerRadius = 20.0;
    errorStyle.messageAlignment = NSTextAlignmentCenter;
    errorStyle.messageNumberOfLines = 5;
    errorStyle.shadowColor = UIColor.blackColor;
    errorStyle.shadowOpacity = 1.0;
    errorStyle.shadowOffset = CGSizeMake(-5, -5);
    
    successStyle = [[CSToastStyle alloc] initWithDefaultStyle];
    successStyle.backgroundColor = BLUE_COLOR;
    successStyle.messageColor = UIColor.whiteColor;
    successStyle.messageFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    successStyle.cornerRadius = 20.0;
    successStyle.messageAlignment = NSTextAlignmentCenter;
    successStyle.messageNumberOfLines = 5;
    successStyle.shadowColor = UIColor.blackColor;
    successStyle.shadowOpacity = 1.0;
    successStyle.shadowOffset = CGSizeMake(-5, -5);
}

- (void)enableSizeForBarButtonItem: (BOOL)enable {
    float fontSize = 0.1;
    if (enable) {
        fontSize = 18.0;
    }
    NSDictionary *titleInfo = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO_REGULAR size:fontSize], NSFontAttributeName, UIColor.whiteColor, NSForegroundColorAttributeName, nil];
    [UIBarButtonItem.appearance setTitleTextAttributes:titleInfo forState:UIControlStateNormal];
    [UIBarButtonItem.appearance setTitleTextAttributes:titleInfo forState:UIControlStateHighlighted];
}

// copy database
- (void)copyFileDataToDocument : (NSString *)filename {
    NSArray *arrPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arrPath objectAtIndex:0];
    NSString *pathString = [documentPath stringByAppendingPathComponent:filename];
    databasePath = [[NSString alloc] initWithString: pathString];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    [fileManager setAttributes:[NSDictionary dictionaryWithObject:NSFileProtectionNone forKey:NSFileProtectionKey] ofItemAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents"] error:NULL];
    
    if (![fileManager fileExistsAtPath:pathString]) {
        NSError *error;
        @try {
            NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
            [fileManager copyItemAtPath:bundlePath toPath:pathString error:&error];
            if (error != nil ) {
            }
        }
        @catch (NSException *exception) {
        }
    }
}

- (void)checkToCallPhoneNumberFromPhoneCallHistory {
    NSString *phoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey: UserActivity];
    if (![AppUtil isNullOrEmpty: phoneNumber]) {
        NSString *displayName = [[NSUserDefaults standardUserDefaults] objectForKey: UserActivityName];
        
        [SipUtil makeCallToPhoneNumber: phoneNumber displayName: displayName];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserActivity];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserActivityName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


#pragma mark - PJSIP
- (void)startPjsuaForApp {
    pjsua_create();
    
    pjsua_config ua_cfg;
    pjsua_logging_config log_cfg;
    pjsua_media_config media_cfg;
    
    pjsua_config_default(&ua_cfg);
    pjsua_logging_config_default(&log_cfg);
    pjsua_media_config_default(&media_cfg);
    
    ua_cfg.cb.on_incoming_call = &on_incoming_call;
    ua_cfg.cb.on_call_media_state = &on_call_media_state;
    ua_cfg.cb.on_call_state = &on_call_state;
    ua_cfg.cb.on_reg_state = &on_reg_state;
    ua_cfg.cb.on_reg_started = &on_reg_started;
    ua_cfg.cb.on_call_transfer_status = &on_call_transfer_status;
    
    pjsua_init(&ua_cfg, &log_cfg, &media_cfg);
    
    pjsua_transport_config transportConfig;
    
    pjsua_transport_config_default(&transportConfig);
    
    transportConfig.port = 51000;
    
    pjsua_transport_create(PJSIP_TRANSPORT_UDP, &transportConfig, NULL);
    //  pjsua_transport_create(PJSIP_TRANSPORT_TCP, &transportConfig, NULL);
    
    pjsua_start();
}

//  Callback called by the library upon receiving incoming call
static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id, pjsip_rx_data *rdata)
{
    pjsua_call_info ci;
    PJ_UNUSED_ARG(acc_id);
    PJ_UNUSED_ARG(rdata);

    pjsua_call_get_info(call_id, &ci);

    NSUUID *uuid = [NSUUID UUID];
    NSString *callId = [NSString stringWithFormat:@"%d", call_id];

    [app.del.calls setObject:callId forKey:uuid];
    [app.del.uuids setObject:uuid forKey:callId];

    NSString *caller = [app.localization localizedStringForKey:@"Unknown"];
    NSArray *info = [app getContactNameForCallWithCallInfo: ci];
    if (info != nil && info.count == 2) {
        caller = [info firstObject];
        app.remoteNumber = [info lastObject];
        
        //  lưu tên cho số điện thoại để hiển thị khi cần thiết
        NSString *key = SFM(@"name_for_%@", [info lastObject]);
        [[NSUserDefaults standardUserDefaults] setObject:caller forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [app.del reportIncomingCallwithUUID:uuid handle:app.remoteNumber caller_name:caller video:FALSE];
    
    //  PJ_LOG(3,(THIS_FILE, "Incoming call from %.*s!!", (int)ci.remote_info.slen,ci.remote_info.ptr));
    //  Automatically answer incoming calls with 200/OK
    //  pjsua_call_answer(call_id, 200, NULL, NULL);
}

//  Callback called by the library when call's media state has changed
static void on_call_media_state(pjsua_call_id call_id)
{
    pjsua_call_info ci;
    
    pjsua_call_get_info(call_id, &ci);
    
    if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        // When media is active, connect call to sound device.
        pjsua_conf_connect(ci.conf_slot, 0);
        pjsua_conf_connect(0, ci.conf_slot);
    }
}

// Callback called by the library when call's state has changed
static void on_call_state(pjsua_call_id call_id, pjsip_event *e)
{
    //  store call_id to get duration
    app.current_call_id = call_id;

    pjsua_call_info ci;

    PJ_UNUSED_ARG(e);

    pjsua_call_get_info(call_id, &ci);
    //  PJ_LOG(3,(THIS_FILE, "Call %d state=%.*s", call_id, (int)ci.state_text.slen, ci.state_text.ptr));
    
    //  get remote number
    NSString *remoteNumber = @"";
    NSArray *contactInfo = [app getContactNameForCallWithCallInfo: ci];
    if (contactInfo.count >= 2) {
        remoteNumber = [contactInfo objectAtIndex: 1];
    }
    
    NSString *state = [app getContentOfCallStateWithStateValue: ci.state];
    NSString *last_status = [NSString stringWithFormat:@"%d", ci.last_status];
    app.pjsipConfAudioId = ci.conf_slot;

    NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithObjectsAndKeys:state, @"state", last_status, @"last_status", nil];
    if (ci.state == PJSIP_INV_STATE_DISCONNECTED) {
        app.current_call_id = -1;
        [info setObject:[NSNumber numberWithLong:ci.connect_duration.sec] forKey:@"call_duration"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notifCallStateChanged object:info];

    if (ci.state == PJSIP_INV_STATE_DISCONNECTED) {
        //  reset remoteNumber
        app.remoteNumber = @"";
        dispatch_async(dispatch_get_main_queue(), ^{
            /** Initial call role (UAC == caller) */
            //  TRƯỜNG HỢP CHỈ DÀNH CHO MÌNH LÀ CALEE VÀ CUỘC GỌI CHƯA ĐƯỢC KẾT NỐI THÀNH CÔNG
            if (ci.role != PJSIP_ROLE_UAC && ci.role != PJSIP_UAC_ROLE && ci.last_status != PJSIP_SC_OK) {
                //  Nếu là nhận cuộc gọi vào last_status khác 200: Nghĩa là màn hình call chưa đc show lên, nên sẽ add history ở đây
                NSString *callID = [AppUtil randomStringWithLength: 12];
                NSString *date = [AppUtil getCurrentDate];
                NSString *time = [AppUtil getCurrentTimeStamp];
            
                NSString *callStatus;
                if (ci.last_status == PJSIP_SC_REQUEST_TERMINATED) {
                    //  caller đã hủy cuộc gọi: do đó trạng thái sẽ là gọi nhỡ
                    callStatus = missed_call;
                }else if (ci.last_status == PJSIP_SC_DECLINE) {
                    //  mình huỷ cuộc gọi
                    callStatus = missed_call;
                }else{
                    callStatus = success_call;
                }
                
                NSString *strAddress = remoteNumber;
                NSString *domain = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
                NSString *port = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PORT];
                if (![AppUtil isNullOrEmpty: domain] && ![AppUtil isNullOrEmpty: port]) {
                    strAddress = SFM(@"sip:%@@%@:%@", remoteNumber, domain, port);
                }
                
                int timeInt = [[NSDate date] timeIntervalSince1970];
                [DatabaseUtil InsertHistory:callID status:callStatus phoneNumber:remoteNumber callDirection:incomming_call recordFiles:@"" duration:0 date:date time:time time_int:timeInt callType:AUDIO_CALL_TYPE sipURI:strAddress MySip:USERNAME kCallId:@"" andFlag:1 andUnread:1];
                
                //  Update lại cuộc số gọi nhỡ ở
                [[NSNotificationCenter defaultCenter] postNotificationName:updateMissedCallBadge object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:reloadHistoryCall object:nil];
            }
            
            NSString *callId = [NSString stringWithFormat:@"%d", call_id];
            NSUUID *uuid = (NSUUID *)[app.del.uuids objectForKey: callId];
            if (uuid) {
                [app.del.uuids removeObjectForKey: callId];
                [app.del.calls removeObjectForKey: uuid];

                CXEndCallAction *act = [[CXEndCallAction alloc] initWithCallUUID:uuid];
                CXTransaction *tr = [[CXTransaction alloc] initWithAction:act];
                [app.del.controller requestTransaction:tr completion:^(NSError * _Nullable error) {
                    NSLog(@"error = %@", error);
                }];
            }
        });
    }
}


static void on_reg_started(pjsua_acc_id acc_id, pj_bool_t renew) {
    if (renew == 0 && app.clearingSIP) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:clearSIPAccountSuccessfully object:nil];
        });
    }
}

- (BOOL)turnOfCurrentAccountDefault: (BOOL)turnOff {
    int numAccount = pjsua_acc_get_count();
    if (numAccount > 0) {
        pjsua_acc_id acc_id = pjsua_acc_get_default();
        if (pjsua_acc_is_valid(acc_id)) {
            if (turnOff) {
                pj_status_t status = pjsua_acc_set_registration(acc_id, 0);
                if (status == PJ_SUCCESS) {
                    return TRUE;
                }
            }else{
                pj_status_t status = pjsua_acc_set_registration(acc_id, 1);
                if (status == PJ_SUCCESS) {
                    return TRUE;
                }
            }
        }
    }
    return FALSE;
}

- (void)tryToReRegisterToSIP {
    NSString *account = USERNAME;
    NSString *password = PASSWORD;
    NSString *domain = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
    NSString *port = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PORT];
    
    if (![AppUtil isNullOrEmpty: account] && ![AppUtil isNullOrEmpty: password] && ![AppUtil isNullOrEmpty:domain] && ![AppUtil isNullOrEmpty: port])
    {
        NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:account, @"account", password, @"password", domain, @"domain", port, @"port", nil];
        [self registerSIPAccountWithInfo: info];
    }
}

static void on_reg_state(pjsua_acc_id acc_id)
{
    //  pjsip_status_code   PJSIP_SC_OK
    pjsua_acc_info info;
    pjsua_acc_get_info(acc_id, &info);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"registration state: %d", info.status);
        if (info.status == PJSIP_SC_OK) {
            //  Lưu acc_id khi register thành công (vì bây giờ chưa tìm được cách lấy ds account từ PJSIP)
            if (![app.sipAccIDs containsObject:[NSNumber numberWithInt:acc_id]]) {
                [app.sipAccIDs addObject:[NSNumber numberWithInt:acc_id]];
            }
            
            //  get missed callfrom server
            [app getMissedCallFromServer];
            [app checkToCallPhoneNumberFromPhoneCallHistory];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:notifRegistrationStateChange object:[NSNumber numberWithInt: info.status]];
        }else{
            if (app.numTryRegister <= 5) {
                [app clearAndReRegisterAgainSIPAccount];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:notifRegistrationStateChange object:[NSNumber numberWithInt: info.status]];
        }
    });
    PJ_UNUSED_ARG(acc_id);
    
    // Log already written.
}

static void on_call_transfer_status(pjsua_call_id call_id,
                                    int status_code,
                                    const pj_str_t *status_text,
                                    pj_bool_t final,
                                    pj_bool_t *p_cont)
{
    NSLog(@"Call %d: transfer status=%d (%.*s) %s", call_id, status_code, (int)status_text->slen, status_text->ptr, (final ? "[final]" : ""));
    if (status_code/100 == 2) {
        NSLog(@"Call %d: call transferred successfully, disconnecting call", call_id);
        pjsua_call_hangup(call_id, PJSIP_SC_GONE, NULL, NULL);
        *p_cont = PJ_FALSE;
    }
}

- (NSString *)getContentOfCallStateWithStateValue: (pjsip_inv_state)state {
    switch (state) {
        case PJSIP_INV_STATE_NULL:{
            return CALL_INV_STATE_NULL;
        }
        case PJSIP_INV_STATE_CALLING:{
            return CALL_INV_STATE_CALLING;
        }
        case PJSIP_INV_STATE_INCOMING:{
            return CALL_INV_STATE_INCOMING;
        }
        case PJSIP_INV_STATE_EARLY:{
            return CALL_INV_STATE_EARLY;
        }
        case PJSIP_INV_STATE_CONNECTING:{
            return CALL_INV_STATE_CONNECTING;
        }
        case PJSIP_INV_STATE_CONFIRMED:{
            return CALL_INV_STATE_CONFIRMED;
        }
        case PJSIP_INV_STATE_DISCONNECTED:{
            return CALL_INV_STATE_DISCONNECTED;
        }
    }
    return @"";
}

- (NSArray *)getContactNameForCallWithCallInfo: (pjsua_call_info)ci {
    NSString *contactName = [NSString stringWithUTF8String: ci.remote_info.ptr];
    if (![AppUtil isNullOrEmpty: contactName]) {
        NSString *name = @"";
        NSString *subname = @"";
        
        //  get name
        NSRange range = [contactName rangeOfString:@" <"];
        if (range.location != NSNotFound) {
            name = [contactName substringToIndex: range.location];
        }else {
            range = [contactName rangeOfString:@"<"];
            if (range.location != NSNotFound) {
                name = [contactName substringToIndex: range.location];
            }
        }
        if ([name hasPrefix:@"\""]) {
            name = [name substringFromIndex:1];
        }
        if ([name hasSuffix:@"\""]) {
            name = [name substringToIndex:name.length - 1];
        }
        
        //  get subname
        range = [contactName rangeOfString:@"<sip:"];
        if (range.location != NSNotFound) {
            NSRange subrange = [contactName rangeOfString:@"@"];
            if (subrange.location != NSNotFound && range.location < subrange.location) {
                subname = [contactName substringWithRange:NSMakeRange(range.location+range.length, subrange.location - (range.location+range.length))];
            }
        }
        return @[name, subname];
    }
    return nil;
}


- (void)registerSIPAccountWithInfo: (NSDictionary *)info {
    NSString *account = [info objectForKey:@"account"];
    NSString *domain = [info objectForKey:@"domain"];
    NSString *port = [info objectForKey:@"port"];
    NSString *password = [info objectForKey:@"password"];
    
//    account = @"nhcla150";
//    domain = @"nhanhoa1.vfone.vn";
//    port = @"51000";
//    password = @"cloudcall123";
    
    if (![AppUtil isNullOrEmpty: account] && ![AppUtil isNullOrEmpty: domain] && ![AppUtil isNullOrEmpty: port] && ![AppUtil isNullOrEmpty: password])
    {
        pj_status_t status;
        
        // Register the account on local sip server
        pjsua_acc_id acc_id;
        pjsua_acc_config cfg;
        pjsua_acc_config_default(&cfg);
        
        NSString *strCall = SFM(@"sip:%@@%@:%@", account, domain, port);
        NSString *regUri = SFM(@"sip:%@:%@", domain, port);
        
        cfg.id = pj_str((char *)[strCall UTF8String]);
        cfg.reg_uri = pj_str((char *)[regUri UTF8String]);
        cfg.cred_count = 1;
        cfg.cred_info[0].realm = pj_str("*");
        cfg.cred_info[0].scheme = pj_str("digest");
        cfg.cred_info[0].username = pj_str((char *)[account UTF8String]);
        cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
        cfg.cred_info[0].data = pj_str((char *)[password UTF8String]);
        cfg.ice_cfg_use=PJSUA_ICE_CONFIG_USE_DEFAULT;
        //  disable IPV6
        cfg.ipv6_media_use = PJSUA_IPV6_DISABLED;
        cfg.reg_timeout = 20;
        //  cfg.reg_retry_interval = 0; //  0 to disable re-retry register
        
//        cfg.sip_stun_use = PJSUA_STUN_USE_DISABLED;
//        cfg.media_stun_use = PJSUA_STUN_USE_DISABLED;
        
        NSString *email = account;
        pjsip_generic_string_hdr CustomHeader;
        pj_str_t name = pj_str("Call-ID");
        pj_str_t value = pj_str((char *)[email UTF8String]);
        pjsip_generic_string_hdr_init2(&CustomHeader, &name, &value);
        pj_list_push_back(&cfg.reg_hdr_list, &CustomHeader);
        
        pjsip_endpoint* endpoint = pjsua_get_pjsip_endpt();
        pj_dns_resolver* resolver;
        
        struct pj_str_t servers[] = {pj_str((char *)[domain UTF8String]) };
        pjsip_endpt_create_resolver(endpoint, &resolver);
        pj_dns_resolver_set_ns(resolver, 1, servers, NULL);
        
        // Init transport config structure
        pjsua_transport_config trans_cfg;
        pjsua_transport_config_default(&trans_cfg);
        //  trans_cfg.port = [port intValue];
        
        // Add UDP transport.
        status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &trans_cfg, NULL);
        if (status != PJ_SUCCESS){
            NSLog(@"Error creating UDP transport");
        }
//
//        status = pjsua_transport_create(PJSIP_TRANSPORT_TCP, &trans_cfg, NULL);
//        if (status != PJ_SUCCESS){
//            NSLog(@"Error creating TCP transport");
//        }
        
        status = pjsua_acc_add(&cfg, PJ_TRUE, &acc_id);
        if (status != PJ_SUCCESS){
            NSLog(@"Error adding account");
        }
    }else{
        [self.window makeToast:[localization localizedStringForKey:@"Please check your informations"] duration:3.0 position:CSToastPositionCenter style:self.errorStyle];
    }
}

- (void)refreshSIPRegistration
{
    int numAccount = pjsua_acc_get_count();
    if (numAccount > 0) {
        pjsua_acc_id acc_id = pjsua_acc_get_default();
        if (pjsua_acc_is_valid(acc_id)) {
            pjsua_acc_set_registration(acc_id, 1);
        }
    }else{
        [self tryToReRegisterToSIP];
    }
}

- (void)startPJThread {
    
}

- (void)makeCallTo: (NSString *)strCall {
    char *destUri = (char *)[strCall UTF8String];
    
    pjsua_acc_id acc_id = 0;
    pj_status_t status;
    pj_str_t pj_uri = pj_str(destUri);
    
    //current register id _acc_id
    
    
//    pjsua_msg_data msg_data;
//    pjsua_msg_data_init(&msg_data);
//    pj_caching_pool cp;
//    pj_pool_t *pool;
//    pj_caching_pool_init(&cp, &pj_pool_factory_default_policy, 0);
//    pool= pj_pool_create(&cp.factory, "header", 1000, 1000, NULL);
//
//    NSString *callID = [AppUtil randomStringWithLength: 10];
//    pj_str_t hname = pj_str((char *)[@"Call-ID" UTF8String]);
//    pj_str_t hvalue = pj_str((char *)[callID UTF8String]);
//    pjsip_generic_string_hdr* add_hdr = pjsip_generic_string_hdr_create(pool, &hname, &hvalue);
//    pj_list_push_back(&msg_data.hdr_list, add_hdr);
//    status = pjsua_call_make_call(acc_id, &pj_uri, 0, NULL, &msg_data, NULL);
    
    status = pjsua_call_make_call(acc_id, &pj_uri, 0, NULL, NULL, NULL);
    if (status != PJ_SUCCESS){
        NSLog(@"Error making call");
    }
    /*
    pj_pool_release(pool);
    */
}

- (void)transferCallToUserWithNumber: (NSString *)number {
    if (current_call_id != -1) {
        pjsua_call_info ci;
        pjsua_call_get_info(current_call_id, &ci);
        
        if (ci.state == PJSIP_INV_STATE_CONFIRMED) {
            NSString *domain = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
            NSString *port = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PORT];
            if (![AppUtil isNullOrEmpty: domain] && ![AppUtil isNullOrEmpty: port]) {
                NSString *stringDest = SFM(@"sip:%@@%@:%@", number, domain, port);
                pj_str_t dest = pj_str((char *)[stringDest UTF8String]);
                pjsua_call_xfer(current_call_id, &dest, nil);
            }
        }
    }
}

- (void)checkCallInfo {
    if (current_call_id != -1) {
        pjsua_call_info ci;
        pjsua_call_get_info(current_call_id, &ci);
        int duration = (int)ci.connect_duration.sec;
        NSLog(@"%d", duration);
    }
}


- (int)getDurationForCurrentCall {
    if (current_call_id != -1) {
        pjsua_call_info ci;
        pjsua_call_get_info(current_call_id, &ci);
        //  NSLog(@"%ld - %ld", ci.total_duration.sec, ci.connect_duration.sec);
        return (int)ci.connect_duration.sec;
    }
    return 0;
}

- (void)hangupAllCall {
    pjsua_call_hangup_all();
}

- (void)answerCallWithCallID: (int)call_id {
    pjsua_call_answer(call_id, 200, NULL, NULL);
    //  show call screen
    [self showCallViewWithDirection: IncomingCall remote: self.remoteNumber displayName:@""];
}

- (BOOL)isCallWasConnected {
    if (current_call_id != -1) {
        pjsua_call_info ci;
        pjsua_call_get_info(current_call_id, &ci);
        
        if (ci.state == PJSIP_INV_STATE_CONFIRMED) {
            return TRUE;
        }
    }
    return FALSE;
}

- (NSString *)getCallStateOfCurrentCall {
    if (current_call_id != -1) {
        pjsua_call_info ci;
        pjsua_call_get_info(current_call_id, &ci);
        
        NSString *state = [app getContentOfCallStateWithStateValue: ci.state];
        return state;
    }
    return @"";
}

- (NSString *)getLastStatusOfCurrenCall {
    if (current_call_id != -1) {
        pjsua_call_info ci;
        pjsua_call_get_info(current_call_id, &ci);
        NSString *last_status = [NSString stringWithFormat:@"%d", ci.last_status];
        return last_status;
    }
    return @"0";
}

- (BOOL)checkCurrentCallWasHold {
    if (current_call_id != -1) {
        pjsua_call_info ci;
        pjsua_call_get_info(current_call_id, &ci);
        if (ci.media_status == PJSUA_CALL_MEDIA_LOCAL_HOLD) {
            return TRUE;
        }
    }
    return FALSE;
}

- (BOOL)holdCurrentCall: (BOOL)hold {
    if (hold) {
        pj_status_t status = pjsua_call_set_hold(current_call_id, nil);
        if (status != PJ_SUCCESS){
            return FALSE;
        }
        return TRUE;
    }else{
        pj_status_t status = pjsua_call_reinvite(current_call_id, PJSUA_CALL_UNHOLD, nil);
        //  pj_status_t status = pjsua_call_update(current_call_id, PJSUA_CALL_UNHOLD, nil);
        if (status != PJ_SUCCESS){
            return FALSE;
        }
        return TRUE;
    }
}

- (BOOL)checkMicrophoneWasMuted {
    if (pjsipConfAudioId >= 0) {
        unsigned int tx_level;
        unsigned int rx_level;
        pjsua_conf_get_signal_level(pjsipConfAudioId, &tx_level, &rx_level);
        if (tx_level == 0) {
            return TRUE;
        }else{
            return FALSE;
        }
    }
    return FALSE;
}

- (BOOL)muteMicrophone: (BOOL)mute {
    if (mute) {
        @try {
            if( pjsipConfAudioId != 0 ) {
                NSLog(@"WC_SIPServer microphone disconnected from call");
                pjsua_conf_disconnect(0, pjsipConfAudioId);
                return TRUE;
            }
            return FALSE;
        }
        @catch (NSException *exception) {
            return FALSE;
        }
    }else{
        @try {
            if( pjsipConfAudioId != 0 ) {
                NSLog(@"WC_SIPServer microphone reconnected to call");
                pjsua_conf_connect(0,pjsipConfAudioId);
                return TRUE;
            }
            return FALSE;
        }
        @catch (NSException *exception) {
            return FALSE;
        }
    }
}

- (BOOL)sendDtmfWithValue: (NSString *)value {
    pjsua_call_send_dtmf_param param;
    param.method = PJSUA_DTMF_METHOD_RFC2833;
    param.duration = PJSUA_CALL_SEND_DTMF_DURATION_DEFAULT;
    param.digits = pj_str((char *)[value UTF8String]);
    
    pj_status_t status = pjsua_call_send_dtmf(current_call_id, &param);
    if (status != PJ_SUCCESS){
        return FALSE;
    }
    return TRUE;
}

- (void)playBeepSound {
    if (beepPlayer == nil) {
        /* Use this code to play an audio file */
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        
        beepPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        [beepPlayer prepareToPlay];
    }
    
    if (beepPlayer.isPlaying) {
        [beepPlayer stop];
        [beepPlayer prepareToPlay];
    }
    [beepPlayer play];
}

- (void)playRingbackTone {
    if (ringbackPlayer == nil) {
        /* Use this code to play an audio file */
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"ringbacktone"  ofType:@"mp3"];
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        
        ringbackPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        ringbackPlayer.numberOfLoops = -1; //Infinite
        [ringbackPlayer prepareToPlay];
    }
    
    if (ringbackPlayer.isPlaying) {
        return;
    }
    [ringbackPlayer play];
}

- (void)stopRingbackTone {
    if (ringbackPlayer != nil) {
        [ringbackPlayer stop];
    }
    ringbackPlayer = nil;
}

- (void)showCallViewWithDirection: (CallDirection)direction remote: (NSString *)remote displayName: (NSString *)displayName {
    if (callViewController == nil) {
        callViewController = [[CallViewController alloc] initWithNibName:@"CallViewController" bundle:nil];
    }
    callViewController.callDirection = direction;
    callViewController.remoteNumber = remote;
    callViewController.displayName = displayName;
    
    callViewController.view.clipsToBounds = TRUE;
    //  callViewController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0);
    [self.window addSubview: callViewController.view];
    [callViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.window);
        make.height.mas_equalTo(0);
    }];
    [self performSelector:@selector(startToShowCallView) withObject:nil afterDelay:0.02];
}

- (void)showTransferCallView {
    if (transferViewController == nil) {
        transferViewController = [[DialerViewController alloc] initWithNibName:@"DialerViewController" bundle:nil];
    }
    transferViewController.tfAddress.text = @"";
    transferViewController.isTransferCall = TRUE;
    transferViewController.view.clipsToBounds = TRUE;
    transferViewController.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0);
    [self.window addSubview: transferViewController.view];
    
    [self performSelector:@selector(startToShowTransferCallView) withObject:nil afterDelay:0.1];
}

- (void)startToShowCallView {
    [callViewController.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.window);
    }];
    
//    [callViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.bottom.right.equalTo(self.window);
//    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.window layoutIfNeeded];
    }];
}

- (void)hideCallView {
    [callViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.window);
        make.height.mas_equalTo(0.0);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.window layoutIfNeeded];
    }completion:^(BOOL finished) {
        [callViewController.view removeFromSuperview];
        callViewController = nil;
    }];
}

- (void)startToShowTransferCallView {
    [transferViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.window);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.window layoutIfNeeded];
    }];
}

- (void)hideTransferCallView {
    [transferViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.window);
        make.height.mas_equalTo(0.0);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.window layoutIfNeeded];
    }completion:^(BOOL finished) {
        [transferViewController.view removeFromSuperview];
        transferViewController = nil;
    }];
}

#pragma mark - FOR ACCOUNT
- (void)checkToClearAllAccRegisteredBefore {
    int numAccount = pjsua_acc_get_count();
    if (numAccount > 0) {
        pjsua_acc_id acc_id = pjsua_acc_get_default();
        if (pjsua_acc_is_valid(acc_id)) {
            for (int index=0; index<sipAccIDs.count; index++) {
                pjsua_acc_id remove_acc_id = [[sipAccIDs objectAtIndex: index] intValue];
                if ([sipAccIDs containsObject:[NSNumber numberWithInt: remove_acc_id]] && acc_id != remove_acc_id) {
                    [sipAccIDs removeObject:[NSNumber numberWithInt: remove_acc_id]];
                    if (pjsua_acc_is_valid(remove_acc_id)) {
                        pjsua_acc_del(remove_acc_id);
                    }
                }
            }
        }
    }else{
        [sipAccIDs removeAllObjects];
    }
}
- (AccountState)checkSipStateOfAccount {
    int numAccount = pjsua_acc_get_count();
    if (numAccount > 0) {
        pjsua_acc_id acc_id = pjsua_acc_get_default();
        if (pjsua_acc_is_valid(acc_id)) {
            pjsua_acc_info info;
            pjsua_acc_get_info(acc_id, &info);
            
            
            pj_caching_pool cp;
            pj_pool_t *pool;
            
            pjsua_msg_data msg_data;
            pjsua_msg_data_init(&msg_data);
            
            pj_caching_pool_init(&cp, &pj_pool_factory_default_policy, 0);
            pool= pj_pool_create(&cp.factory, "header", 1000, 1000, NULL);
            
            pjsua_acc_config config;
            pjsua_acc_get_config(acc_id, pool, &config);
            pj_pool_release(pool);
            
            if (info.status == PJSIP_SC_OK) {
                return eAccountOn;
            }
        }
        return eAccountOff;
    }else{
        NSString *turnOff = [[NSUserDefaults standardUserDefaults] objectForKey:TURN_OFF_ACC];
        if (![AppUtil isNullOrEmpty: turnOff] && [turnOff isEqualToString:@"1"]) {
            return eAccountDis;
        }
        return eAccountNone;
    }
}

- (void)removeAccIDWhenRegisterFailed {
    int numAccount = pjsua_acc_get_count();
    if (numAccount > 0) {
        pjsua_acc_id acc_id = pjsua_acc_get_default();
        pjsua_acc_info info;
        pjsua_acc_get_info(acc_id, &info);
        if (info.status != PJSIP_SC_OK) {
            pj_status_t status = pjsua_acc_del(acc_id);
            if (status == PJ_SUCCESS) {
                if ([sipAccIDs containsObject:[NSNumber numberWithInt: acc_id]]) {
                    [sipAccIDs removeObject:[NSNumber numberWithInt: acc_id]];
                }
            }
        }
    }
}

- (BOOL)deleteSIPAccountDefault {
    int numAccount = pjsua_acc_get_count();
    if (numAccount > 0) {
        pjsua_acc_id accId = pjsua_acc_get_default();
        if (pjsua_acc_is_valid(accId)) {
            pj_status_t status = pjsua_acc_del(accId);
            if (status == PJ_SUCCESS) {
                if ([sipAccIDs containsObject:[NSNumber numberWithInt: accId]]) {
                    [sipAccIDs removeObject:[NSNumber numberWithInt: accId]];
                }
                return TRUE;
            }else{
                return FALSE;
            }
        }
    }
    return TRUE;
}

- (NSArray *)getContactNameOfRemoteForCall {
    if (current_call_id != -1) {
        pjsua_call_info ci;
        pjsua_call_get_info(current_call_id, &ci);
        NSString *contactName = [NSString stringWithUTF8String: ci.remote_info.ptr];
        if (![AppUtil isNullOrEmpty: contactName]) {
            NSString *name;
            NSString *subname;
            
            //  get name
            NSRange range = [contactName rangeOfString:@" <"];
            if (range.location != NSNotFound) {
                name = [contactName substringToIndex: range.location];
            }else {
                range = [contactName rangeOfString:@"<"];
                if (range.location != NSNotFound) {
                    name = [contactName substringToIndex: range.location];
                }
            }
            if ([name hasPrefix:@"\""]) {
                name = [name substringFromIndex:1];
            }
            if ([name hasSuffix:@"\""]) {
                name = [name substringToIndex:name.length - 1];
            }
            
            //  get subname
            range = [contactName rangeOfString:@"<sip:"];
            if (range.location != NSNotFound) {
                NSRange subrange = [contactName rangeOfString:@"@"];
                if (subrange.location != NSNotFound && range.location < subrange.location) {
                    subname = [contactName substringWithRange:NSMakeRange(range.location+range.length, subrange.location - (range.location+range.length))];
                }
            }
            return @[name, subname];
        }
    }
    return nil;
}

-(NSDate *) toLocalTime {
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: [NSDate date]];
    return [NSDate dateWithTimeInterval: seconds sinceDate: [NSDate date]];
}

#pragma mark - Web services delegate
- (void)getMissedCallFromServer
{
    NSString *pbxIp = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
    NSString *ExtUser = USERNAME;
    
    NSString *dateFrom = [[NSUserDefaults standardUserDefaults] objectForKey:DATE_FROM];
    
    NSDate *localDate = [self toLocalTime];
    NSString *dateTo = [NSString stringWithFormat:@"%ld", (long)[localDate timeIntervalSince1970]];
    //  NSString *dateTo = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    
    //    NSDate *globalDate = [self toGlobalTime];
    //    NSLog(@"%ld", (long)[localDate timeIntervalSince1970]);
    //    NSLog(@"%ld", (long)[globalDate timeIntervalSince1970]);
    
    if (![AppUtil isNullOrEmpty: dateFrom] && ![AppUtil isNullOrEmpty: pbxIp] && ![AppUtil isNullOrEmpty: ExtUser]) {
        if (webService == nil) {
            webService = [[WebServices alloc] init];
            webService.delegate = self;
        }
        NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
        [jsonDict setObject:AuthUser forKey:@"AuthUser"];
        [jsonDict setObject:AuthKey forKey:@"AuthKey"];
        [jsonDict setObject:pbxIp forKey:@"IP"];
        [jsonDict setObject:ExtUser forKey:@"PhoneNumberReceive"];
        [jsonDict setObject:dateFrom forKey:@"DateFrom"];
        [jsonDict setObject:dateTo forKey:@"DateTo"];
        
        [webService callWebServiceWithLink:GetInfoMissCall withParams:jsonDict inBackgroundMode:YES];
    }
    [[NSUserDefaults standardUserDefaults] setObject:dateTo forKey:DATE_FROM];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateCustomerTokenIOS {
    NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
    if (USERNAME != nil && ![AppUtil isNullOrEmpty: server]) {
        NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
        [jsonDict setObject:AuthUser forKey:@"AuthUser"];
        [jsonDict setObject:AuthKey forKey:@"AuthKey"];
        [jsonDict setObject:@"" forKey:@"UserName"];
        [jsonDict setObject:deviceToken forKey:@"IOSToken"];
        [jsonDict setObject:server forKey:@"PBXID"];
        [jsonDict setObject:USERNAME forKey:@"PBXExt"];
        
        [webService callWebServiceWithLink:ChangeCustomerIOSToken withParams:jsonDict];
    }
}

- (void)insertMissedCallToDatabase: (id)data
{
    if (data != nil && [data isKindOfClass:[NSArray class]]) {
        for (int i=0; i<[(NSArray *)data count]; i++) {
            NSDictionary *callInfo = [data objectAtIndex: i];
            id createDate = [callInfo objectForKey:@"createDate"];
            NSString *phoneNumberCall = [callInfo objectForKey:@"phoneNumberCall"];
            if (createDate != nil && phoneNumberCall != nil) {
                NSString *callId = [AppUtil randomStringWithLength: 10];
                NSString *date = [AppUtil getDateFromInterval:[createDate doubleValue]];
                NSString *time = [AppUtil getFullTimeStringFromTimeInterval:[createDate doubleValue]];
                
                BOOL exists = [DatabaseUtil checkMissedCallExistsFromUser: phoneNumberCall withAccount: USERNAME atTime: (int)[createDate intValue]];
                if (!exists) {
                    [DatabaseUtil InsertHistory:callId status:missed_call phoneNumber:phoneNumberCall callDirection:incomming_call recordFiles:@"" duration:0 date:date time:time time_int:[createDate doubleValue] callType:AUDIO_CALL_TYPE sipURI:phoneNumberCall MySip:USERNAME kCallId:@"" andFlag:1 andUnread:1];
                }
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:updateMissedCallBadge object:nil];
    }
}

//  https://www.oipapio.com/question-1278506


#pragma mark - PushKit Functions

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(NSString *)type {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"PushKit Token invalidated");
    });
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type
{
    NSLog(@"PushKit : incoming voip notfication: %@", payload.dictionaryPayload);
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) { // Call category
        UNNotificationAction *act_ans =
        [UNNotificationAction actionWithIdentifier:@"Answer"
                                             title:NSLocalizedString(@"Answer", nil)
                                           options:UNNotificationActionOptionForeground];
        UNNotificationAction *act_dec = [UNNotificationAction actionWithIdentifier:@"Decline"
                                                                             title:NSLocalizedString(@"Decline", nil)
                                                                           options:UNNotificationActionOptionNone];
        UNNotificationCategory *cat_call =
        [UNNotificationCategory categoryWithIdentifier:@"call_cat"
                                               actions:[NSArray arrayWithObjects:act_ans, act_dec, nil]
                                     intentIdentifiers:[[NSMutableArray alloc] init]
                                               options:UNNotificationCategoryOptionCustomDismissAction];
        // Msg category
        UNTextInputNotificationAction *act_reply =
        [UNTextInputNotificationAction actionWithIdentifier:@"Reply"
                                                      title:NSLocalizedString(@"Reply", nil)
                                                    options:UNNotificationActionOptionNone];
        UNNotificationAction *act_seen =
        [UNNotificationAction actionWithIdentifier:@"Seen"
                                             title:NSLocalizedString(@"Mark as seen", nil)
                                           options:UNNotificationActionOptionNone];
        UNNotificationCategory *cat_msg =
        [UNNotificationCategory categoryWithIdentifier:@"msg_cat"
                                               actions:[NSArray arrayWithObjects:act_reply, act_seen, nil]
                                     intentIdentifiers:[[NSMutableArray alloc] init]
                                               options:UNNotificationCategoryOptionCustomDismissAction];
        
        // Video Request Category
        UNNotificationAction *act_accept =
        [UNNotificationAction actionWithIdentifier:@"Accept"
                                             title:NSLocalizedString(@"Accept", nil)
                                           options:UNNotificationActionOptionForeground];
        
        UNNotificationAction *act_refuse = [UNNotificationAction actionWithIdentifier:@"Cancel"
                                                                                title:NSLocalizedString(@"Cancel", nil)
                                                                              options:UNNotificationActionOptionNone];
        UNNotificationCategory *video_call =
        [UNNotificationCategory categoryWithIdentifier:@"video_request"
                                               actions:[NSArray arrayWithObjects:act_accept, act_refuse, nil]
                                     intentIdentifiers:[[NSMutableArray alloc] init]
                                               options:UNNotificationCategoryOptionCustomDismissAction];
        
        // ZRTP verification category
        UNNotificationAction *act_confirm = [UNNotificationAction actionWithIdentifier:@"Confirm"
                                                                                 title:NSLocalizedString(@"Accept", nil)
                                                                               options:UNNotificationActionOptionNone];
        
        UNNotificationAction *act_deny = [UNNotificationAction actionWithIdentifier:@"Deny"
                                                                              title:NSLocalizedString(@"Deny", nil)
                                                                            options:UNNotificationActionOptionNone];
        UNNotificationCategory *cat_zrtp =
        [UNNotificationCategory categoryWithIdentifier:@"zrtp_request"
                                               actions:[NSArray arrayWithObjects:act_confirm, act_deny, nil]
                                     intentIdentifiers:[[NSMutableArray alloc] init]
                                               options:UNNotificationCategoryOptionCustomDismissAction];
        
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        [[UNUserNotificationCenter currentNotificationCenter]
         requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound |
                                          UNAuthorizationOptionBadge)
         completionHandler:^(BOOL granted, NSError *_Nullable error) {
             // Enable or disable features based on authorization.
             if (error) {
                 NSLog(@"%@", error.description);
             }
         }];
        NSSet *categories = [NSSet setWithObjects:cat_call, cat_msg, video_call, cat_zrtp, nil];
        [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:categories];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self processRemoteNotification:payload.dictionaryPayload];
    });
}

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(PKPushType)type
{
    NSLog(@"PushKit credentials updated");
    NSLog(@"voip token: %@", (credentials.token));
    dispatch_async(dispatch_get_main_queue(), ^{
        deviceToken = credentials.token.description;
        deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
        deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
        deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
        
        //  Cap nhat token cho phan chat
        if (USERNAME != nil && ![USERNAME isEqualToString: @""]) {
            [self updateCustomerTokenIOS];
        }else{
            updateTokenSuccess = FALSE;
        }
    });
}

- (void)processRemoteNotification:(NSDictionary *)userInfo {
    /*  Push content
     alert =     {
     "call-id" = 14953;
     "loc-key" = "Incoming call from 14953";
     };
     badge = 1;
     "call-id" = 14953;
     "content-available" = 1;
     "loc-key" = "Incoming call from 14953";
     sound = default;
     title = Cloudfone;
     */
    
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    if (aps != nil)
    {
        NSDictionary *alert = [aps objectForKey:@"alert"];
        [self tryToReRegisterToSIP];
        
        NSString *loc_key = [aps objectForKey:@"loc-key"];
        NSString *callId = [aps objectForKey:@"call-id"];
        
        NSString *caller = callId;
//        PhoneObject *contact = [ContactsUtil getContactPhoneObjectWithNumber: callId];
//        if (![AppUtil isNullOrEmpty: contact.name]) {
//            caller = contact.name;
//        }
        
        NSString *content = [NSString stringWithFormat:[localization localizedStringForKey:@"You have a call from %@"], caller];
        
        UILocalNotification *messageNotif = [[UILocalNotification alloc] init];
        messageNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow: 0.1];
        messageNotif.timeZone = [NSTimeZone defaultTimeZone];
        messageNotif.timeZone = [NSTimeZone defaultTimeZone];
        messageNotif.alertBody = content;
        messageNotif.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification: messageNotif];
        
        
        //            NSString *loc_key = [aps objectForKey:@"loc-key"];
        //            NSString *callId = [aps objectForKey:@"call-id"];
        if (alert != nil) {
            loc_key = [alert objectForKey:@"loc-key"];
            //  if we receive a remote notification, it is probably because our TCP background socket was no more working. As a result, break it and refresh registers in order to make sure to receive incoming INVITE or MESSAGE
            
            //linphone_core_set_network_reachable(LC, FALSE);
            if (![DeviceUtil checkNetworkAvailable]) {
                if (localization == nil) {
                    [self setLanguageForApp];
                }
                [self.window makeToast:[localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter style:errorStyle];
                return;
            }
            if (loc_key != nil) {
                //  callId = [userInfo objectForKey:@"call-id"];
                if (callId != nil) {
                    if ([callId isEqualToString:@""]){
                        //Present apn pusher notifications for info
                        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
                            UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
                            content.title = @"APN Pusher";
                            content.body = @"Push notification received !";
                            
                            UNNotificationRequest *req = [UNNotificationRequest requestWithIdentifier:@"call_request" content:content trigger:NULL];
                            [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:req withCompletionHandler:^(NSError * _Nullable error) {
                                // Enable or disable features based on authorization.
                                if (error) {
                                    NSLog(@"Error while adding notification request :%@", error.description);
                                }
                            }];
                        } else {
                            UILocalNotification *notification = [[UILocalNotification alloc] init];
                            notification.repeatInterval = 0;
                            notification.alertBody = @"Push notification received !";
                            notification.alertTitle = @"APN Pusher";
                            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                        }
                    } else {
                        NSLog(@"addPushCallId");
                        //  [LinphoneManager.instance addPushCallId:callId];
                    }
                } else  if ([callId  isEqual: @""]) {
                    NSLog(@"PushNotification: does not have call-id yet, fix it !");
                }
            }else{
                [self.window makeToast:@"Not loc_key" duration:1.0 position:CSToastPositionCenter style:self.errorStyle];
            }
        }
    }
}

#pragma mark - Webservice Delegate
- (void)failedToCallWebService:(NSString *)link andError:(NSString *)error
{
    if ([link isEqualToString:ChangeCustomerIOSToken]) {
        updateTokenSuccess = FALSE;
    }
}

- (void)successfulToCallWebService:(NSString *)link withData:(NSDictionary *)data {
    if ([link isEqualToString:ChangeCustomerIOSToken]) {
        updateTokenSuccess = TRUE;
        
    }else if ([link isEqualToString: GetInfoMissCall]){
        [self insertMissedCallToDatabase: data];
    }
}

-(void)receivedResponeCode:(NSString *)link withCode:(int)responeCode {
    
}

@end
