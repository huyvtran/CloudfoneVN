//
//  SendLogsViewController.m
//  linphone
//
//  Created by lam quang quan on 11/27/18.
//

#import "SendLogsViewController.h"
#import "SendLogFileCell.h"
#import "AESCrypt.h"

@interface SendLogsViewController (){
    NSMutableArray *listFiles;
    NSMutableArray *listSelect;
    
    UIButton *btnSend;
}

@end

@implementation SendLogsViewController
@synthesize tbLogs;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    self.navigationController.navigationBarHidden = FALSE;
    self.title = [[AppDelegate sharedInstance].localization localizedStringForKey:@"Send logs"];
    
    [self addRightBarButtonForNavigationBar];
    
    //  remove other files if it is not log file
    [DeviceUtil cleanLogFolder];
    
    if (listSelect == nil) {
        listSelect = [[NSMutableArray alloc] init];
    }
    [listSelect removeAllObjects];
    
    if (listFiles == nil) {
        listFiles = [[NSMutableArray alloc] init];
    }
    [listFiles removeAllObjects];
    [listFiles addObjectsFromArray:[WriteLogsUtils getAllFilesInDirectory:logsFolderName]];
    [tbLogs reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startSendLogsFiles {
    /*
    NSString *totalEmail = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", @"lekhai0212@gmail.com", @"Send logs file", messageSend];
    NSString *url = [totalEmail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication]  openURL: [NSURL URLWithString: url]];
    */
    
    if ([MFMailComposeViewController canSendMail]) {
        BOOL networkReady = [DeviceUtil checkNetworkAvailable];
        if (!networkReady) {
            [self.view makeToast:[[AppDelegate sharedInstance].localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
            return;
        }
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        
        NSString *emailTitle =  @"Send logs files";
        NSString *messageBody = @"";
        NSArray *toRecipents = [NSArray arrayWithObject:@"lekhai0212@gmail.com"];
        
        for (int i=0; i<listSelect.count; i++)
        {
            NSIndexPath *curIndex = [listSelect objectAtIndex: i];
            NSString *fileName = [listFiles objectAtIndex: curIndex.row];
            NSString *path = [DeviceUtil getPathOfFileWithSubDir:SFM(@"%@/%@", logsFolderName, fileName)];
            
            NSString* content = [NSString stringWithContentsOfFile:path
                                                          encoding:NSUTF8StringEncoding
                                                             error:NULL];
            NSString *encryptStr = [AESCrypt encrypt:content password:AES_KEY];
            NSData *logFileData = [encryptStr dataUsingEncoding:NSUTF8StringEncoding];
            NSString *nameForSend = [DeviceUtil convertLogFileName: fileName];
            [mc addAttachmentData:logFileData mimeType:@"text/plain" fileName:nameForSend];
        }
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        
        [self presentViewController:mc animated:YES completion:NULL];
    }else{
        [self.view makeToast:[[AppDelegate sharedInstance].localization localizedStringForKey:@"Can not send email. Please check your email account again!"] duration:3.0 position:CSToastPositionCenter];
    }
}

- (void)addRightBarButtonForNavigationBar {
    UIView *viewSend = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    viewSend.backgroundColor = UIColor.clearColor;
    
    btnSend =  [UIButton buttonWithType:UIButtonTypeCustom];
    btnSend.imageEdgeInsets = UIEdgeInsetsMake(9, 9, 9, 9);
    btnSend.frame = CGRectMake(15, 0, 40, 40);
    btnSend.backgroundColor = UIColor.clearColor;
    [btnSend setImage:[UIImage imageNamed:@"sent-mail"] forState:UIControlStateNormal];
    [btnSend setImage:[UIImage imageNamed:@"sent-mail-dis"] forState:UIControlStateDisabled];
    [btnSend addTarget:self action:@selector(startSendLogsFiles) forControlEvents:UIControlEventTouchUpInside];
    [viewSend addSubview: btnSend];
    
    UIBarButtonItem *btnSendBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: viewSend];
    self.navigationItem.rightBarButtonItem =  btnSendBarButtonItem;
}

//  setup ui trong view
- (void)setupUIForView
{
//    [icSend setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
//    [icSend setTitleColor:UIColor.grayColor forState:UIControlStateDisabled];
//    [icSend mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(viewHeader).offset(-5.0);
//        make.centerY.equalTo(lbHeader.mas_centerY);
//        make.width.mas_equalTo(80.0);
//        make.height.mas_equalTo(HEADER_ICON_WIDTH);
//    }];
    
    tbLogs.backgroundColor = UIColor.clearColor;
    [tbLogs mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.view);
    }];
    tbLogs.delegate = self;
    tbLogs.dataSource = self;
    tbLogs.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - uitableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"SendLogFileCell";
    SendLogFileCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SendLogFileCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *fileName = [listFiles objectAtIndex: indexPath.row];
    fileName = [DeviceUtil convertLogFileName: fileName];
    cell.lbName.text = fileName;
    
    if (![listSelect containsObject: indexPath]) {
        cell.imgSelect.image = [UIImage imageNamed:@"ic_not_check.png"];
    }else{
        cell.imgSelect.image = [UIImage imageNamed:@"ic_checked.png"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![listSelect containsObject: indexPath]) {
        [listSelect addObject: indexPath];
    }else{
        [listSelect removeObject: indexPath];
    }
    [tbLogs reloadData];
    if (listSelect.count > 0) {
        btnSend.enabled = TRUE;
    }else{
        btnSend.enabled = FALSE;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

#pragma mark - Email
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultSent) {
        [self.view makeToast:[[AppDelegate sharedInstance].localization localizedStringForKey:@"Your email was sent. Thank you!"] duration:4.0 position:CSToastPositionCenter];
        
    }else if (result == MFMailComposeResultSaved) {
        [self.view makeToast:[[AppDelegate sharedInstance].localization localizedStringForKey:@"Your email was saved. Thank you!"] duration:4.0 position:CSToastPositionCenter];
        
    }else if (result == MFMailComposeResultFailed) {
        [self.view makeToast:[[AppDelegate sharedInstance].localization localizedStringForKey:@"Failed to send email. Please check again!"] duration:4.0 position:CSToastPositionCenter];
    }
    [self performSelector:@selector(goBack) withObject:nil afterDelay:2.0];
}

- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
