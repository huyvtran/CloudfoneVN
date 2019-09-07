//
//  AppStrings.h
//  CloudfoneVN
//
//  Created by Khai Leo on 8/25/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#ifndef AppStrings_h
#define AppStrings_h

#define AES_KEY         @"OdsCloudfone@123"
#define keySyncPBX      @"CloudFonePBX"
#define PBX_SERVER      @"PBX_SERVER"
#define PBX_ID          @"PBX_ID"
#define PBX_PORT        @"PBX_PORT"
#define TURN_OFF_ACC    @"TURN_OFF_ACC"
#define PBX_ID_CONTACT  @"PBX_ID_CONTACT"

#define accSyncPBX          @"accSyncPBX"
#define nameContactSyncPBX  @"CloudFone PBX"
#define nameSyncCompany     @"Online Data Services"

#define link_introduce          @"https://cloudfone.vn/gioi-thieu-dich-vu-cloudfone/"
#define link_policy             @"http://dieukhoan.cloudfone.vn/"
#define link_appstore           @"https://itunes.apple.com/vn/app/cloudfone-vn/id1445535617?mt=8"
#define link_api                @"https://wssf.cloudfone.vn/api/SoftPhone"

#define getServerInfoFunc       @"GetServerInfo"
#define getServerContacts       @"GetServerContacts"
#define ChangeCustomerIOSToken  @"ChangeCustomerIOSToken"
#define DecryptRSA              @"DecryptRSA"
#define PushSharp               @"PushSharp"
#define GetInfoMissCall         @"GetInfoMissCall"
#define ChangeExtPass           @"ChangeExtPass"

//detect iphone5 and ipod5
#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] )
#define IS_IPOD   ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )
#define IS_IOS7   ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)

#define simulator       @"x86_64"
#define Iphone4s        @"iPhone4,1"
#define Iphone5_1       @"iPhone5,1"
#define Iphone5_2       @"iPhone5,2"
#define Iphone5c_1      @"iPhone5,3"
#define Iphone5c_2      @"iPhone5,4"
#define Iphone5s_1      @"iPhone6,1"
#define Iphone5s_2      @"iPhone6,2"
#define Iphone6         @"iPhone7,2"
#define Iphone6_Plus    @"iPhone7,1"
#define Iphone6s        @"iPhone8,1"
#define Iphone6s_Plus   @"iPhone8,2"
#define IphoneSE        @"iPhone8,4"
#define Iphone7_1       @"iPhone9,1"
#define Iphone7_2       @"iPhone9,3"
#define Iphone7_Plus1   @"iPhone9,2"
#define Iphone7_Plus2   @"iPhone9,4"
#define Iphone8_1       @"iPhone10,1"
#define Iphone8_2       @"iPhone10,4"
#define Iphone8_Plus1   @"iPhone10,2"
#define Iphone8_Plus2   @"iPhone10,5"
#define IphoneX_1       @"iPhone10,3"
#define IphoneX_2       @"iPhone10,6"
#define IphoneXR        @"iPhone11,8"
#define IphoneXS        @"iPhone11,2"
#define IphoneXS_Max1   @"iPhone11,6"
#define IphoneXS_Max2   @"iPhone11,4"

#define MYRIADPRO_REGULAR       @"MYRIADPRO-REGULAR"
#define MYRIADPRO_BOLD          @"MYRIADPRO-BOLD"
#define HelveticaNeue           @"HelveticaNeue"
#define HelveticaNeueBold       @"HelveticaNeue-Bold"
#define HelveticaNeueConBold    @"HelveticaNeue-CondensedBold"
#define HelveticaNeueItalic     @"HelveticaNeue-Italic"
#define HelveticaNeueLight      @"HelveticaNeue-Light"
#define HelveticaNeueThin       @"HelveticaNeue-Thin"

#define SFM(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define MENU_ACTIVE_COLOR   [UIColor colorWithRed:(37/255.0) green:(132/255.0) blue:(255/255.0) alpha:1.0]
#define MENU_DEFAULT_COLOR  [UIColor colorWithRed:(172/255.0) green:(185/255.0) blue:(202/255.0) alpha:1.0]
#define ORANGE_COLOR        [UIColor colorWithRed:(249/255.0) green:(157/255.0) blue:(28/255.0) alpha:1.0]
#define BLUE_COLOR          [UIColor colorWithRed:(42/255.0) green:(122/255.0) blue:(219/255.0) alpha:1.0]
#define SELECT_TAB_BG_COLOR [UIColor colorWithRed:(42/255.0) green:(172/255.0) blue:(255/255.0) alpha:1.0]

#define GRAY_200  [UIColor colorWithRed:(200/255.0) green:(200/255.0) blue:(200/255.0) alpha:1.0]
#define GRAY_215  [UIColor colorWithRed:(215/255.0) green:(215/255.0) blue:(215/255.0) alpha:1.0]
#define GRAY_220  [UIColor colorWithRed:(220/255.0) green:(220/255.0) blue:(220/255.0) alpha:1.0]
#define GRAY_225  [UIColor colorWithRed:(225/255.0) green:(225/255.0) blue:(225/255.0) alpha:1.0]
#define GRAY_230  [UIColor colorWithRed:(230/255.0) green:(230/255.0) blue:(230/255.0) alpha:1.0]
#define GRAY_235  [UIColor colorWithRed:(235/255.0) green:(235/255.0) blue:(235/255.0) alpha:1.0]
#define GRAY_240  [UIColor colorWithRed:(240/255.0) green:(240/255.0) blue:(240/255.0) alpha:1.0]
#define GRAY_245  [UIColor colorWithRed:(245/255.0) green:(245/255.0) blue:(245/255.0) alpha:1.0]
#define GRAY_250  [UIColor colorWithRed:(250/255.0) green:(250/255.0) blue:(250/255.0) alpha:1.0]

#define ProgressHUD_BG [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define logsFolderName      @"LogFiles"
#define language_key        @"language_key"
#define key_en              @"en"
#define key_vi              @"vi"

#define DATE_FROM           @"DATE_FROM"
#define UserActivity        @"UserActivity"
#define UserActivityName    @"UserActivityName"

#define type_phone_home     @"home"
#define type_phone_work     @"work"
#define type_phone_fax      @"fax"
#define type_phone_mobile   @"mobile"
#define type_phone_other    @"other"
#define type_cloudfone_id   @"cloudfoneID"

#define key_login           @"key_login"
#define key_password        @"key_password"
#define idSyncPBX           @"keySyncPBX"

#define AuthUser            @"ddb7c103eb98"
#define AuthKey             @"2b909f73069e47dba6feddb7c103eb98"
#define hotline             @"14951"


#define USERNAME ([[NSUserDefaults standardUserDefaults] objectForKey:key_login])
#define PASSWORD ([[NSUserDefaults standardUserDefaults] objectForKey:key_password])

#define missed_call                 @"Missed"
#define success_call                @"Success"
#define aborted_call                @"Aborted"
#define declined_call               @"Declined"
#define not_answer_call             @"NotAnswer"

#define incomming_call              @"Incomming"
#define outgoing_call               @"Outgoing"

#define text_hotline                @"Hotline"

#define AUDIO_CALL_TYPE             1
#define VIDEO_CALL_TYPE             2

#define TAG_STAR_BUTTON             10
#define TAG_HASH_BUTTON             11

#define CALL_INV_STATE_NULL         @"PJSIP_INV_STATE_NULL"
#define CALL_INV_STATE_CALLING      @"PJSIP_INV_STATE_CALLING"
#define CALL_INV_STATE_INCOMING     @"PJSIP_INV_STATE_INCOMING"
#define CALL_INV_STATE_EARLY        @"PJSIP_INV_STATE_EARLY"
#define CALL_INV_STATE_CONNECTING   @"PJSIP_INV_STATE_CONNECTING"
#define CALL_INV_STATE_CONFIRMED    @"PJSIP_INV_STATE_CONFIRMED"
#define CALL_INV_STATE_DISCONNECTED @"PJSIP_INV_STATE_DISCONNECTED"


#define notifRegistrationStateChange    @"notifRegistrationStateChange"
#define searchContactWithValue          @"searchContactWithValue"
#define addNewContactInContactView      @"addNewContactInContactView"
#define networkChanged                  @"networkChanged"
#define finishLoadContacts              @"finishLoadContacts"
#define finishGetPBXContacts            @"finishGetPBXContacts"
#define selectTypeForPhoneNumber        @"selectTypeForPhoneNumber"
#define notifCallStateChanged           @"notifCallStateChanged"
#define updateMissedCallBadge           @"updateMissedCallBadge"
#define reloadHistoryCall               @"reloadHistoryCall"
#define clearSIPAccountSuccessfully     @"clearSIPAccountSuccessfully"

#endif /* AppStrings_h */
