//
//  NewContactViewController.m
//  linphone
//
//  Created by Ei Captain on 3/17/17.
//
//

#import "NewContactViewController.h"
#import "NewPhoneCell.h"
#import "TypePhoneObject.h"
#import "NSData+Base64.h"
#import "ContactDetailObj.h"
#import "InfoForNewContactTableCell.h"
#import "PECropViewController.h"
#import "TypePhonePopupView.h"
#import "PhoneObject.h"

#define ROW_CONTACT_NAME    0
#define ROW_CONTACT_EMAIL   1
#define ROW_CONTACT_COMPANY 2
#define NUMBER_ROW_BEFORE   3

@interface NewContactViewController ()<PECropViewControllerDelegate>{
    AppDelegate *appDelegate;
    UITapGestureRecognizer *tapOnScreen;
    
    PECropViewController *PECropController;
    
    UIView *viewFooter;
    UIButton *btnCancel;
    UIButton *btnSave;
    TypePhonePopupView *popupTypePhone;
}

@end

@implementation NewContactViewController
@synthesize _viewHeader, bgHeader, _iconBack, _lbHeader, _imgAvatar, _imgChangePicture, _btnAvatar;
@synthesize currentPhoneNumber, currentName;

#pragma mark - my controller
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //  my code here
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.newContact == nil) {
        appDelegate.newContact = [[ContactObject alloc] init];
        appDelegate.newContact._listPhone = [[NSMutableArray alloc] init];
    }
    
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.navigationController.navigationBarHidden = TRUE;
    
    [self showContentWithCurrentLanguage];
    
    if (appDelegate.newContact == nil) {
        appDelegate.newContact = [[ContactObject alloc] init];
        appDelegate.newContact._listPhone = [[NSMutableArray alloc] init];
    }
    
    if (currentName != nil && ![currentName isEqualToString:@""]) {
        appDelegate.newContact._fullName = currentName;
        appDelegate.newContact._firstName = currentName;
    }
    //  For case add contact from keypad screen
    if (currentPhoneNumber != nil && ![currentPhoneNumber isEqualToString:@""] && ![self checkCurrentPhone: currentPhoneNumber inList: appDelegate.newContact._listPhone])
    {
        ContactDetailObj *aPhone = [[ContactDetailObj alloc] init];
        aPhone._iconStr = @"btn_contacts_mobile.png";
        aPhone._titleStr = [appDelegate.localization localizedStringForKey:type_phone_mobile];
        aPhone._valueStr = currentPhoneNumber;
        aPhone._buttonStr = @"contact_detail_icon_call.png";
        aPhone._typePhone = type_phone_mobile;
        [appDelegate.newContact._listPhone addObject: aPhone];
    }
    
    if (appDelegate.dataCrop != nil) {
        _imgAvatar.image = [UIImage imageWithData: appDelegate.dataCrop];
    }else{
        _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    }
    
    [_tbContents reloadData];
    
    if ([appDelegate.newContact._fullName isEqualToString:@""] || appDelegate.newContact._fullName == nil) {
        [self enableForSaveButton: NO];
    }else{
        [self enableForSaveButton: YES];
    }
    //  notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenSelectTypeForPhone:)
                                                 name:selectTypeForPhoneNumber object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_iconBackClicked:(UIButton *)sender {
    currentPhoneNumber = @"";
    appDelegate.dataCrop = nil;
    appDelegate.cropAvatar = nil;
    
    [self.navigationController popViewControllerAnimated: TRUE];
}

- (IBAction)_btnAvatarPressed:(UIButton *)sender {
    [self.view endEditing: YES];
    if (appDelegate.dataCrop != nil) {
        UIActionSheet *popupAddContact = [[UIActionSheet alloc] initWithTitle:[appDelegate.localization localizedStringForKey:@"Options"] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:@"Cancel"] destructiveButtonTitle:nil otherButtonTitles:
                                          [appDelegate.localization localizedStringForKey:@"Gallery"],
                                          [appDelegate.localization localizedStringForKey:@"Camera"],
                                          [appDelegate.localization localizedStringForKey:@"Remove Avatar"],
                                          nil];
        popupAddContact.tag = 100;
        [popupAddContact showInView:self.view];
    }else{
        UIActionSheet *popupAddContact = [[UIActionSheet alloc] initWithTitle:[appDelegate.localization localizedStringForKey:@"Options"] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:@"Cancel"] destructiveButtonTitle:nil otherButtonTitles:
                                          [appDelegate.localization localizedStringForKey:@"Gallery"],
                                          [appDelegate.localization localizedStringForKey:@"Camera"],
                                          nil];
        popupAddContact.tag = 101;
        [popupAddContact showInView:self.view];
    }
}

#pragma mark - my functions

- (void)showContentWithCurrentLanguage {
    _lbHeader.text = [appDelegate.localization localizedStringForKey: @"Add contact"];
    [btnCancel setTitle:[appDelegate.localization localizedStringForKey:@"Cancel"]
               forState:UIControlStateNormal];
    [btnSave setTitle:[appDelegate.localization localizedStringForKey:@"Save"]
             forState:UIControlStateNormal];
}

- (void)afterAddAndReloadContactDone {
    appDelegate.newContact = nil;
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Successful"]
                duration:1.0 position:CSToastPositionCenter];
    
    [self performSelector:@selector(backToView) withObject:nil afterDelay:2.0];
}

- (void)backToView{
    [ProgressHUD dismiss];
    
    appDelegate.dataCrop = nil;
    appDelegate.newContact = nil;
    
    [self.navigationController popViewControllerAnimated: TRUE];
}

- (void)setupUIForView {
    _lbHeader.font = appDelegate.fontNormal;
    
    tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnMainScreen)];
    tapOnScreen.delegate = self;
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer: tapOnScreen];
    
    float wAvatar = 110.0;
    
    float hHeader = appDelegate.hStatus + appDelegate.hNav + wAvatar/2;
    //  view header
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(hHeader);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_viewHeader);
    }];
    
    [_lbHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader).offset(appDelegate.hStatus);
        make.centerX.equalTo(_viewHeader.mas_centerX);
        make.width.mas_equalTo(200.0);
        make.height.mas_equalTo(appDelegate.hNav);
    }];
    
    _iconBack.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    [_iconBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader);
        make.centerY.equalTo(_lbHeader.mas_centerY);
        make.width.height.mas_equalTo(40.0);
    }];
    
    _imgAvatar.layer.borderColor = UIColor.whiteColor.CGColor;
    _imgAvatar.layer.borderWidth = 2.0;
    _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    _imgAvatar.layer.cornerRadius = wAvatar/2;
    _imgAvatar.clipsToBounds = YES;
    [_imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(_viewHeader.mas_bottom);
        make.width.height.mas_equalTo(wAvatar);
    }];
    
    [_btnAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_imgAvatar);
    }];
    
    [_imgChangePicture mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_imgAvatar.mas_centerX);
        make.bottom.equalTo(_imgAvatar.mas_bottom).offset(-10.0);
        make.width.height.mas_equalTo(20.0);
    }];
    
    [_tbContents registerNib:[UINib nibWithNibName:@"InfoForNewContactTableCell" bundle:nil] forCellReuseIdentifier:@"InfoForNewContactTableCell"];
    [_tbContents registerNib:[UINib nibWithNibName:@"NewPhoneCell" bundle:nil] forCellReuseIdentifier:@"NewPhoneCell"];
    _tbContents.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tbContents.delegate = self;
    _tbContents.dataSource = self;
    [_tbContents mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    
    UIView *viewHeader = [[UIView alloc] init];
    viewHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, wAvatar/2);
    viewHeader.backgroundColor = UIColor.clearColor;
    _tbContents.tableHeaderView = viewHeader;
    
    
    //  Footer view
    viewFooter = [[UIView alloc] init];
    viewFooter.frame = CGRectMake(0, 0, SCREEN_WIDTH, 100);
    
    btnCancel = [[UIButton alloc] init];
    [btnCancel setTitle:[appDelegate.localization localizedStringForKey:@"Cancel"]
               forState:UIControlStateNormal];
    
    btnCancel.backgroundColor = [UIColor colorWithRed:(210/255.0) green:(51/255.0)
                                                 blue:(92/255.0) alpha:1.0];
    [btnCancel setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnCancel.clipsToBounds = YES;
    btnCancel.layer.cornerRadius = 40.0/2;
    [viewFooter addSubview: btnCancel];
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(viewFooter.mas_centerX).offset(-10);
        make.centerY.equalTo(viewFooter.mas_centerY);
        make.width.mas_equalTo(140.0);
        make.height.mas_equalTo(40.0);
    }];
    
    btnSave = [[UIButton alloc] init];
    [btnSave setTitle:[appDelegate.localization localizedStringForKey:@"Save"]
             forState:UIControlStateNormal];
    btnSave.backgroundColor = [UIColor colorWithRed:(20/255.0) green:(129/255.0)
                                               blue:(211/255.0) alpha:1.0];
    [btnSave setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnSave.clipsToBounds = YES;
    btnSave.layer.cornerRadius = 40.0/2;
    [viewFooter addSubview: btnSave];
    [btnSave mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewFooter.mas_centerX).offset(10);
        make.centerY.equalTo(viewFooter.mas_centerY);
        make.width.equalTo(btnCancel.mas_width);
        make.height.equalTo(btnCancel.mas_height);
    }];
    [btnSave addTarget:self
                action:@selector(saveContactPressed:)
      forControlEvents:UIControlEventTouchUpInside];
    
    _tbContents.tableFooterView = viewFooter;
}

//  Hiển thị bàn phím
- (void)keyboardWillShow:(NSNotification *)notif {
    CGSize keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [_tbContents mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-keyboardSize.height);
    }];
}

//  Ẩn bàn phím
- (void)keyboardDidHide: (NSNotification *) notif{
    [_tbContents mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
    }];
}

//  Tap vào màn hình chính để đóng bàn phím
- (void)whenTapOnMainScreen {
    [self.view endEditing: true];
}

//  Thêm hoặc xoá số phone
- (void)btnAddPhonePressed: (UIButton *)sender {
    int tag = (int)[sender tag];
    if (tag - NUMBER_ROW_BEFORE >= 0) {
        if ([sender.currentTitle isEqualToString:@"Add"])
        {
            NewPhoneCell *cell = [_tbContents cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];
            if (cell != nil && ![cell._tfPhone.text isEqualToString:@""]) {
                ContactDetailObj *aPhone = [[ContactDetailObj alloc] init];
                aPhone._valueStr = cell._tfPhone.text;
                aPhone._buttonStr = @"contact_detail_icon_call.png";
                
                NSString *type = cell._iconTypePhone.currentTitle;
                if ([type isEqualToString:type_phone_work])
                {
                    aPhone._typePhone = type_phone_work;
                    aPhone._iconStr = @"btn_contacts_work.png";
                    aPhone._titleStr = [appDelegate.localization localizedStringForKey:type_phone_work];
                    
                }else if ([type isEqualToString:type_phone_fax]){
                    aPhone._typePhone = type_phone_fax;
                    aPhone._iconStr = @"btn_contacts_fax.png";
                    aPhone._titleStr = [appDelegate.localization localizedStringForKey:type_phone_fax];
                    
                }else if ([type isEqualToString:type_phone_home]){
                    aPhone._typePhone = type_phone_home;
                    aPhone._iconStr = @"btn_contacts_home.png";
                    aPhone._titleStr = [appDelegate.localization localizedStringForKey:type_phone_home];
                    
                }else{
                    aPhone._typePhone = type_phone_mobile;
                    aPhone._iconStr = @"btn_contacts_mobile.png";
                    aPhone._titleStr = [appDelegate.localization localizedStringForKey:type_phone_mobile];
                }
                [appDelegate.newContact._listPhone addObject: aPhone];
            }else{
                [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please input phone number"]
                            duration:2.0 position:CSToastPositionCenter];
            }
        }else if ([sender.currentTitle isEqualToString:@"Remove"]){
            if (tag-NUMBER_ROW_BEFORE < appDelegate.newContact._listPhone.count) {
                [appDelegate.newContact._listPhone removeObjectAtIndex: tag-NUMBER_ROW_BEFORE];
            }
        }
    }
    
    //  Khi thêm mới hoặc xoá thì chỉ có dòng cuối cùng là new
    [_tbContents reloadData];
}

- (void)whenTextfieldPhoneDidChanged: (UITextField *)textfield {
    int row = (int)[textfield tag];
    if (row-NUMBER_ROW_BEFORE >= 0 && row-NUMBER_ROW_BEFORE < appDelegate.newContact._listPhone.count)
    {
        ContactDetailObj *curPhone = [appDelegate.newContact._listPhone objectAtIndex: row];
        curPhone._valueStr = textfield.text;
    }
}

#pragma mark - UITableview Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return NUMBER_ROW_BEFORE + [appDelegate.newContact._listPhone count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == ROW_CONTACT_NAME || indexPath.row == ROW_CONTACT_EMAIL || indexPath.row == ROW_CONTACT_COMPANY)
    {
        InfoForNewContactTableCell *cell = [tableView dequeueReusableCellWithIdentifier: @"InfoForNewContactTableCell"];
        switch (indexPath.row) {
            case ROW_CONTACT_NAME:{
                cell.lbTitle.text = [appDelegate.localization localizedStringForKey:@"Fullname"];
                cell.tfContent.text = [ContactsUtil getFullnameOfContactIfExists];
                [cell.tfContent addTarget:self
                                   action:@selector(whenTextfieldFullnameChanged:)
                         forControlEvents:UIControlEventEditingChanged];
                break;
            }
            case ROW_CONTACT_EMAIL:{
                cell.lbTitle.text = [appDelegate.localization localizedStringForKey:@"Email"];
                cell.tfContent.tag = 100;
                cell.tfContent.keyboardType = UIKeyboardTypeEmailAddress;
                [cell.tfContent addTarget:self
                                   action:@selector(whenTextfieldChanged:)
                         forControlEvents:UIControlEventEditingChanged];
                
                if (![appDelegate.newContact._email isEqualToString: @""] && appDelegate.newContact._email != nil) {
                    cell.tfContent.text = appDelegate.newContact._email;
                }else{
                    cell.tfContent.text = @"";
                }
                
                break;
            }
            case ROW_CONTACT_COMPANY:{
                cell.lbTitle.text = [appDelegate.localization localizedStringForKey:@"Company"];
                cell.tfContent.tag = 101;
                [cell.tfContent addTarget:self
                                   action:@selector(whenTextfieldChanged:)
                         forControlEvents:UIControlEventEditingChanged];
                
                if (![appDelegate.newContact._company isEqualToString: @""] && appDelegate.newContact._company != nil) {
                    cell.tfContent.text = appDelegate.newContact._company;
                }else{
                    cell.tfContent.text = @"";
                }
                break;
            }
        }
        return cell;
    }else{
        NewPhoneCell *cell = [tableView dequeueReusableCellWithIdentifier: @"NewPhoneCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row == appDelegate.newContact._listPhone.count + NUMBER_ROW_BEFORE) {
            cell._tfPhone.text = @"";
            
            [cell._iconNewPhone setTitle:@"Add" forState:UIControlStateNormal];
            [cell._iconNewPhone setBackgroundImage:[UIImage imageNamed:@"ic_add_phone.png"]
                                          forState:UIControlStateNormal];
            
            [cell._iconTypePhone setTitle:@"Mobile" forState:UIControlStateNormal];
            [cell._iconTypePhone setBackgroundImage:[UIImage imageNamed:@"btn_contacts_mobile"]
                                           forState:UIControlStateNormal];
        }else{
            if ((indexPath.row - NUMBER_ROW_BEFORE) >= 0 && (indexPath.row - NUMBER_ROW_BEFORE) < appDelegate.newContact._listPhone.count) {
                ContactDetailObj *aPhone = [appDelegate.newContact._listPhone objectAtIndex: (indexPath.row - NUMBER_ROW_BEFORE)];
                cell._tfPhone.text = aPhone._valueStr;
                
                [cell._iconNewPhone setTitle:@"Remove" forState:UIControlStateNormal];
                [cell._iconNewPhone setBackgroundImage:[UIImage imageNamed:@"ic_delete_phone.png"]
                                              forState:UIControlStateNormal];
                [cell._iconTypePhone setTitle:aPhone._typePhone forState:UIControlStateNormal];
                [cell._iconTypePhone setBackgroundImage:[UIImage imageNamed:aPhone._iconStr]
                                               forState:UIControlStateNormal];
            }
        }
        cell._tfPhone.tag = indexPath.row;
        [cell._tfPhone addTarget:self
                          action:@selector(whenTextfieldPhoneDidChanged:)
                forControlEvents:UIControlEventEditingChanged];
        
        cell._iconNewPhone.tag = indexPath.row;
        [cell._iconNewPhone addTarget:self
                               action:@selector(btnAddPhonePressed:)
                     forControlEvents:UIControlEventTouchUpInside];
        
        cell._iconTypePhone.tag = indexPath.row;
        [cell._iconTypePhone addTarget:self
                                action:@selector(btnTypePhonePressed:)
                      forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == ROW_CONTACT_NAME || indexPath.row == ROW_CONTACT_EMAIL || indexPath.row == ROW_CONTACT_COMPANY) {
        return 83.0;
    }
    return 50.0;
}

#pragma mark - ContactDetailsImagePickerDelegate Functions

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    appDelegate.cropAvatar = image;
    [appDelegate enableSizeForBarButtonItem: FALSE];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (void)openEditor {
    PECropController = [[PECropViewController alloc] init];
    PECropController.delegate = self;
    PECropController.image = appDelegate.cropAvatar;
    
    UIImage *image = appDelegate.cropAvatar;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    PECropController.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length, length);
    PECropController.keepingCropAspectRatio = true;
    [self.navigationController pushViewController:PECropController animated:TRUE];
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect
{
    [appDelegate enableSizeForBarButtonItem: FALSE];
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
    appDelegate.dataCrop = UIImagePNGRepresentation(croppedImage);
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [appDelegate enableSizeForBarButtonItem: FALSE];
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - ActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 100) {
        switch (buttonIndex) {
            case 0:{
                [self pressOnGallery];
                break;
            }
            case 1:{
                [self pressOnCamera];
                break;
            }
            case 2:{
                [self removeAvatar];
                break;
            }
            case 3:{
                NSLog(@"Cancel");
                break;
            }
        }
    }else if (actionSheet.tag == 101){
        switch (buttonIndex) {
            case 0:{
                [self pressOnGallery];
                break;
            }
            case 1:{
                [self pressOnCamera];
                break;
            }
        }
    }
}

- (void)pressOnCamera {
    appDelegate.fromImagePicker = YES;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker setDelegate: self];
    [picker setSourceType: UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)pressOnGallery {
    appDelegate.fromImagePicker = YES;
    [appDelegate enableSizeForBarButtonItem: TRUE];
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)removeAvatar {
    appDelegate.newContact._avatar = @"";
    _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    appDelegate.dataCrop = nil;
}

- (void)saveContactPressed: (UIButton *)sender {
    [self.view endEditing: TRUE];
    
    if ((appDelegate.newContact._firstName == nil || [appDelegate.newContact._firstName isEqualToString:@""]) && (appDelegate.newContact._lastName == nil || [appDelegate.newContact._lastName isEqualToString:@""]))
    {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Contact name can not empty!"]
                    duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    [ProgressHUD backgroundColor: ProgressHUD_BG];
    [ProgressHUD show:[appDelegate.localization localizedStringForKey:@"Please wait..."] Interaction:NO];
    
    //  Remove all phone number with value is empty
    for (int iCount=0; iCount<appDelegate.newContact._listPhone.count; iCount++) {
        ContactDetailObj *aPhone = [appDelegate.newContact._listPhone objectAtIndex: iCount];
        if ([aPhone._valueStr isEqualToString: @""]) {
            [appDelegate.newContact._listPhone removeObject: aPhone];
            iCount--;
        }
    }
    
    ABRecordRef contact = [ContactsUtil addNewContacts];
    //  Thêm thông tin contact vào danh sách
    [self updatePhonebookInfoWithNewContact: contact];
    [appDelegate fetchAllContactsFromPhoneBook];
    [self afterAddAndReloadContactDone];
}

- (void)updatePhonebookInfoWithNewContact: (ABRecordRef)aPerson
{
    ABMultiValueRef phones = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phones) > 0)
    {
        int contactId = ABRecordGetRecordID(aPerson);
        
        NSString *fullname = [ContactsUtil getFullNameFromContact: aPerson];
        NSString *convertName = [AppUtil convertUTF8CharacterToCharacter: fullname];
        NSString *nameForSearch = [AppUtil getNameForSearchOfConvertName: convertName];
        NSString *avatar = [ContactsUtil getBase64AvatarFromContact: aPerson];
        
        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
        {
            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
            NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;
            phoneNumber = [AppUtil removeAllSpecialInString: phoneNumber];
            
            PhoneObject *phone = [[PhoneObject alloc] init];
            phone.number = phoneNumber;
            phone.name = fullname;
            phone.nameForSearch = nameForSearch;
            phone.avatar = avatar;
            phone.contactId = contactId;
            phone.phoneType = eNormalPhone;
            if (![appDelegate.listInfoPhoneNumber containsObject: phone]) {
                [appDelegate.listInfoPhoneNumber addObject: phone];
            }
        }
    }
}

- (void)whenTextfieldFullnameChanged: (UITextField *)textfield {
    //  Save fullname into first name
    appDelegate.newContact._firstName = textfield.text;
    appDelegate.newContact._fullName = textfield.text;
    appDelegate.newContact._lastName = @"";
    
    if (![textfield.text isEqualToString:@""]) {
        [self enableForSaveButton: YES];
    }else{
        [self enableForSaveButton: NO];
    }
}

- (void)whenTextfieldChanged: (UITextField *)textfield {
    if (textfield.tag == 100) {
        appDelegate.newContact._email = textfield.text;
    }else if (textfield.tag == 101){
        appDelegate.newContact._company = textfield.text;
    }
}

- (void)enableForSaveButton: (BOOL)enable {
    btnSave.enabled = enable;
    if (enable) {
        btnSave.backgroundColor = [UIColor colorWithRed:(20/255.0) green:(129/255.0)
                                                   blue:(211/255.0) alpha:1.0];
    }else{
        btnSave.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                   blue:(200/255.0) alpha:1.0];
    }
}

//  Chọn loại phone cho điện thoại
- (void)btnTypePhonePressed: (UIButton *)sender {
    [self.view endEditing: true];
    
    float hPopup;
    if (SCREEN_WIDTH > 320) {
        hPopup = 4*50 + 6;
    }else{
        hPopup = 4*40 + 6;
    }
    
    popupTypePhone = [[TypePhonePopupView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-236)/2, (SCREEN_HEIGHT-hPopup)/2, 236, hPopup)];
    [popupTypePhone setTag: sender.tag];
    [popupTypePhone showInView:appDelegate.window animated:YES];
}

//  Chọn loại phone
- (void)whenSelectTypeForPhone: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[TypePhoneObject class]]) {
        int curIndex = (int)[popupTypePhone tag];
        
        //  Choose phone type for row: Add new phone
        NewPhoneCell *cell = [_tbContents cellForRowAtIndexPath:[NSIndexPath indexPathForRow:curIndex inSection:0]];
        if ([cell isKindOfClass:[NewPhoneCell class]]) {
            NSString *imgName = [AppUtil getTypeOfPhone: [(TypePhoneObject *)object _strType]];
            [cell._iconTypePhone setBackgroundImage:[UIImage imageNamed:imgName]
                                           forState:UIControlStateNormal];
            [cell._iconTypePhone setTitle:[(TypePhoneObject *)object _strType] forState:UIControlStateNormal];
        }
        if (curIndex - NUMBER_ROW_BEFORE >= 0 && (curIndex - NUMBER_ROW_BEFORE) < appDelegate.newContact._listPhone.count)
        {
            ContactDetailObj *curPhone = [appDelegate.newContact._listPhone objectAtIndex: (curIndex - NUMBER_ROW_BEFORE)];
            curPhone._typePhone = [(TypePhoneObject *)object _strType];
            curPhone._iconStr = [AppUtil getTypeOfPhone: curPhone._typePhone];
            [_tbContents reloadData];
        }
    }
}

- (BOOL)checkCurrentPhone: (NSString *)phone inList: (NSArray *)listPhone {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_valueStr = %@", phone];
    NSArray *filter = [listPhone filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        return YES;
    }
    return NO;
}

@end
