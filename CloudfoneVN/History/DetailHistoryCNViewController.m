//
//  DetailHistoryCNViewController.m
//  linphone
//
//  Created by user on 18/3/14.
//
//

#import "DetailHistoryCNViewController.h"
#import "NewContactViewController.h"
#import "UIHistoryDetailCell.h"
#import "NewHistoryDetailCell.h"
#import "CallHistoryObject.h"
#import "NSData+Base64.h"

@interface DetailHistoryCNViewController () {
    AppDelegate *appDelegate;
    NSMutableArray *listHistoryCalls;
    NSString *displayName;
}
@end

@implementation DetailHistoryCNViewController

@synthesize _viewHeader, bgHeader, _iconBack, _lbHeader, _imgAvatar, _lbName, icDelete;
@synthesize btnCall, _tbHistory;
@synthesize phoneNumber, onDate, onlyMissedCall;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // MY CODE HERE
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setupUIForView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self displayInformationForView];
    
    //  reset missed call
    [DatabaseUtil resetMissedCallOfRemote:phoneNumber onDate:onDate ofAccount:USERNAME];
    [[NSNotificationCenter defaultCenter] postNotificationName:updateMissedCallBadge object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayInformationForView)
                                                 name:reloadHistoryCall object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)btnCallPressed:(UIButton *)sender {
    if (![AppUtil isNullOrEmpty: phoneNumber]) {
        [SipUtil makeCallToPhoneNumber: phoneNumber displayName: displayName];
    }else{
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"The phone number can not empty"] duration:2.0 position:CSToastPositionCenter];
    }
}

- (void)displayInformationForView
{
    if ([phoneNumber isEqualToString: hotline]) {
        displayName = text_hotline;
        _imgAvatar.image = [UIImage imageNamed:@"hotline_avatar.png"];
    }else{
        PhoneObject *contact = [ContactsUtil getContactPhoneObjectWithNumber: phoneNumber];
        if (![AppUtil isNullOrEmpty:contact.name]) {
            displayName = contact.name;
        }else{
            displayName = [AppUtil getNameWasStoredFromUserInfo: phoneNumber];
        }
        
        if (![AppUtil isNullOrEmpty: contact.avatar]) {
            _imgAvatar.image = [UIImage imageWithData: [NSData base64DataFromString: contact.avatar]];
        }else{
            _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
        }
    }
    _lbHeader.text = displayName;
    _lbName.text = phoneNumber;
    
    if (listHistoryCalls == nil) {
        listHistoryCalls = [[NSMutableArray alloc] init];
    }
    [listHistoryCalls removeAllObjects];
    [_tbHistory reloadData];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([AppUtil isNullOrEmpty: onDate]) {
            [listHistoryCalls addObjectsFromArray: [DatabaseUtil getAllListCallOfMe:USERNAME withPhoneNumber:phoneNumber]];
        }else{
            [listHistoryCalls addObjectsFromArray: [DatabaseUtil getAllCallOfMe:USERNAME withPhone:phoneNumber onDate:onDate onlyMissedCall: onlyMissedCall]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tbHistory reloadData];
        });
    });
}

#pragma mark - my functions

- (void)setupUIForView
{
    self.view.backgroundColor = UIColor.whiteColor;
    
    float wAvatar = 100.0;
    float wIconCall = 70.0;
    float hHeader = appDelegate.hStatus + appDelegate.hNav + wAvatar + 30.0 + wIconCall/2;
    
    //  header
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(hHeader);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_viewHeader);
    }];
    
    _lbHeader.font = appDelegate.fontLarge;
    [_lbHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader).offset(appDelegate.hStatus);
        make.centerX.equalTo(_viewHeader.mas_centerX);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(appDelegate.hNav);
    }];
    
    _iconBack.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    [_iconBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader);
        make.centerY.equalTo(_lbHeader.mas_centerY);
        make.width.height.mas_equalTo(40.0);
    }];
    
    icDelete.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    [icDelete mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_viewHeader);
        make.top.bottom.equalTo(_iconBack);
        make.width.equalTo(_iconBack.mas_width);
    }];
    
    _imgAvatar.layer.cornerRadius = wAvatar/2;
    _imgAvatar.layer.borderWidth = 2.0;
    _imgAvatar.layer.borderColor = UIColor.whiteColor.CGColor;
    _imgAvatar.clipsToBounds = TRUE;
    [_imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbHeader.mas_bottom);
        make.centerX.equalTo(_viewHeader.mas_centerX);
        make.width.height.mas_equalTo(wAvatar);
    }];
    
    _lbName.font = appDelegate.fontNormal;
    _lbName.textColor = UIColor.whiteColor;
    [_lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imgAvatar.mas_bottom);
        make.left.equalTo(_viewHeader).offset(5.0);
        make.right.equalTo(_viewHeader).offset(-5.0);
        make.height.mas_equalTo(30.0);
    }];
    
    //  button call
    btnCall.layer.cornerRadius = wIconCall/2;
    btnCall.clipsToBounds = TRUE;
    btnCall.layer.borderWidth = 2.0;
    btnCall.layer.borderColor = UIColor.whiteColor.CGColor;
    [btnCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(_viewHeader.mas_bottom);
        make.width.height.mas_equalTo(wIconCall);
    }];
    
    //  content
    [_tbHistory registerNib:[UINib nibWithNibName:@"NewHistoryDetailCell" bundle:nil] forCellReuseIdentifier:@"NewHistoryDetailCell"];
    _tbHistory.delegate = self;
    _tbHistory.dataSource = self;
    _tbHistory.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tbHistory.showsVerticalScrollIndicator = FALSE;
    [_tbHistory mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, wIconCall/2);
    headerView.backgroundColor = UIColor.clearColor;
    _tbHistory.tableHeaderView = headerView;
}

#pragma mark - tableview delegate

- (NSString *)convertIntToTime : (int) time{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *startData = [NSDate dateWithTimeIntervalSince1970:time];
    dateFormatter.dateFormat = @"HH:mm";
    NSString *str_time = [dateFormatter stringFromDate:startData];
    return str_time;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listHistoryCalls.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewHistoryDetailCell *cell = (NewHistoryDetailCell *)[tableView dequeueReusableCellWithIdentifier: @"NewHistoryDetailCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CallHistoryObject *aCall = [listHistoryCalls objectAtIndex: indexPath.row];
    
    //  cell.lbTime.text = [AppUtils getTimeStringFromTimeInterval: aCall._timeInt];
    cell.lbTime.text = aCall._time;
    
    if (aCall._duration == 0) {
        cell.lbDuration.text = @"";
    }else{
        NSString *duration = [AppUtil convertDurtationToString: aCall._duration];
        cell.lbDuration.text = duration;
    }
    
    if ([aCall._status isEqualToString: aborted_call] || [aCall._status isEqualToString: declined_call]) {
        cell.lbState.text = [appDelegate.localization localizedStringForKey:@"Aborted call"];
    }else if ([aCall._status isEqualToString: missed_call]){
        cell.lbState.text = [appDelegate.localization localizedStringForKey:@"Missed call"];
    }else{
        cell.lbState.text = @"";
    }
    
    if ([aCall._callDirection isEqualToString: incomming_call]) {
        if ([aCall._status isEqualToString: missed_call]) {
            cell.imgStatus.image = [UIImage imageNamed:@"ic_call_missed.png"];
        }else{
            cell.imgStatus.image = [UIImage imageNamed:@"ic_call_incoming.png"];
        }
    }else{
        cell.imgStatus.image = [UIImage imageNamed:@"ic_call_outgoing.png"];
    }
    
    NSString *dateStr = [AppUtil checkTodayForHistoryCall: onDate];
    
    if (![dateStr isEqualToString:@"Today"]) {
        dateStr = [AppUtil checkYesterdayForHistoryCall: aCall._date];
        if ([dateStr isEqualToString:@"Yesterday"]) {
            dateStr = [appDelegate.localization localizedStringForKey:@"Yesterday"];
        }
    }else{
        dateStr = [appDelegate.localization localizedStringForKey:@"Today"];
    }
    cell.lbDate.text = dateStr;
    
    return cell;
}

- (IBAction)_iconBackClicked:(UIButton *)sender {
    appDelegate.newContact = nil;
    [self.navigationController popViewControllerAnimated: TRUE];
}

- (IBAction)icDeleteClick:(UIButton *)sender
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:[appDelegate.localization localizedStringForKey:@"Do you want to delete this history call?"]];
    [attrTitle addAttribute:NSFontAttributeName value:[AppDelegate sharedInstance].fontNormal range:NSMakeRange(0, attrTitle.string.length)];
    [alertVC setValue:attrTitle forKey:@"attributedTitle"];
    
    UIAlertAction *btnNo = [UIAlertAction actionWithTitle:[[AppDelegate sharedInstance].localization localizedStringForKey:@"No"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
    //  [btnClose setValue:UIColor.redColor forKey:@"titleTextColor"];
    
    UIAlertAction *btnDelete = [UIAlertAction actionWithTitle:[[AppDelegate sharedInstance].localization localizedStringForKey:@"Delete"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                {
                                    [DatabaseUtil deleteCallHistoryOfRemote:phoneNumber onDate:onDate ofAccount:USERNAME];
                                    appDelegate.newContact = nil;
                                    
                                    [self.navigationController popViewControllerAnimated: TRUE];
                                }];
    [btnDelete setValue:UIColor.redColor forKey:@"titleTextColor"];
    [alertVC addAction:btnNo];
    [alertVC addAction:btnDelete];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (NSString *)getEventTimeFromDuration:(NSTimeInterval)duration
{
    NSDateComponentsFormatter *cFormatter = [[NSDateComponentsFormatter alloc] init];
    cFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
    cFormatter.includesApproximationPhrase = NO;
    cFormatter.includesTimeRemainingPhrase = NO;
    cFormatter.allowedUnits = NSCalendarUnitHour |NSCalendarUnitMinute | NSCalendarUnitSecond;
    cFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorDropAll;
    
    return [cFormatter stringFromTimeInterval:duration];
}

@end

