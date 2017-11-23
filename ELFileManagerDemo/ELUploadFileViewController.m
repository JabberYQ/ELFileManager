//
//  ELFileChooserViewController.m
//  ELMoblieProject
//
//  Created by easylink on 2017/11/16.
//  Copyright © 2017年 俞琦. All rights reserved.
//

#import "ELUploadFileViewController.h"
#import "ELFileManager.h"
#import "ELFileModel.h"
#import "ELFileDetailViewController.h"

@interface ELSelectedFileManager : NSObject
@property (nonatomic, strong) NSMutableArray * selectedFileArray;
@property (nonatomic, assign) NSInteger maxCount;
@property (nonatomic, assign) NSInteger selectedFileCount;
@end

@implementation ELSelectedFileManager
static id instance = nil;
+ (instancetype)shareManager
{
    @synchronized(self) {
        if (!instance) {
            instance = [[self alloc] init];
        }
        return instance;
    }
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self) {
        if (!instance) {
            instance = [super allocWithZone:zone];
        }
        return instance;
    }
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    return self;
}

// 添加文件 成功返回YES
- (BOOL)addFile:(ELFileModel *)file
{
    if ([self isFileContain:file]) { //
        return NO;
    } else {
        [self.selectedFileArray addObject:file];
        return YES;
    }
}

- (BOOL)removeFile:(ELFileModel *)file
{
    BOOL isRemove = NO;
    for (int i = 0; i < self.selectedFileArray.count; i ++) {
        ELFileModel *aFile = self.selectedFileArray[i];
        if ([aFile.filePath isEqualToString:file.filePath]) { // 存在
            [self.selectedFileArray removeObject:aFile];
            isRemove = YES;
            break;
        }
    }
    return isRemove;
}

- (BOOL)isFileContain:(ELFileModel *)file
{
    BOOL isExists = NO;
    for (int i = 0; i < self.selectedFileArray.count; i ++) {
        ELFileModel *aFile = self.selectedFileArray[i];
        if ([aFile.filePath isEqualToString:file.filePath]) { // 存在
            isExists = YES;
            break;
        }
    }
    return isExists;
}

- (BOOL)isFull
{
    if (self.selectedFileArray.count >= self.maxCount) {
        return YES;
    } else {
        return NO;
    }
}

- (NSInteger)selectedFileCount
{
    return self.selectedFileArray.count;
}

- (NSMutableArray *)selectedFileArray
{
    if (!_selectedFileArray) {
        _selectedFileArray = [NSMutableArray array];
    }
    return _selectedFileArray;
}

- (void)emptySelectedArray
{
    [self.selectedFileArray removeAllObjects];
}
@end



@interface ELUploadFileViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, copy) UploadFileBlock uploadBlock;
@property (nonatomic, assign) NSInteger maxCount;

@property (nonatomic, strong) ELFileManager * fileManager;
@property (nonatomic, weak) UITableView * tableView;
@property (nonatomic, copy) NSString * homePath;
@property (nonatomic, strong) NSMutableArray *files;
@property (nonatomic, weak) UIButton *uploadBtn;
@end

@implementation ELUploadFileViewController
- (instancetype)initWithPath:(NSString *)path maxCount:(NSInteger)maxCount uploadBlock:(UploadFileBlock)uploadBlock
{
    if (self = [super init]) {
        self.homePath = path;
        if ([ELSelectedFileManager shareManager].maxCount == 0) {
            [ELSelectedFileManager shareManager].maxCount = maxCount;
        }
        self.maxCount = maxCount;
        self.uploadBlock = uploadBlock;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![self.fileManager fileExistsAtPath:self.homePath]) {
        [self.fileManager createFolderToFullPath:self.homePath];
    }
    ELFileModel *floder = [self.fileManager getFileWithPath:self.homePath];
    self.title = floder.name;
    
    [self initViews];
}

#pragma mark - 私有方法
- (void)initViews
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    
    UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 50) style:UITableViewStyleGrouped];
    tv.delegate = self;
    tv.dataSource = self;
    [self.view addSubview:tv];
    self.tableView = tv;
    
    // 添加上传按钮
    UIButton *uploadBtn = [[UIButton alloc] init];
    uploadBtn.frame = CGRectMake(0, self.view.bounds.size.height - 50, self.view.bounds.size.width, 50);
    uploadBtn.backgroundColor = [UIColor colorWithRed:43/255.0 green:173/255.0 blue:158/255.0 alpha:1.0];
    [uploadBtn setTitle:@"上  传" forState:UIControlStateNormal];
    [uploadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    uploadBtn.titleLabel.font = [UIFont boldSystemFontOfSize:19];
    [uploadBtn addTarget:self action:@selector(uploadBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:uploadBtn];
    self.uploadBtn = uploadBtn;
    
    [self reloadUploadBtnStr];
}

- (void)alertWithString:(NSString *)str
{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertC addAction:action];
    [self presentViewController:alertC animated:YES completion:nil];
}

- (void)uploadBtnDidClick:(UIButton *)sender
{
    NSArray *selectedFileArray = [ELSelectedFileManager shareManager].selectedFileArray;
    if (self.uploadBlock) {
        self.uploadBlock(selectedFileArray);
    }
    [[ELSelectedFileManager shareManager] emptySelectedArray];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)reloadUploadBtnStr
{
    NSString *uploadBtnStr;
    if ([ELSelectedFileManager shareManager].selectedFileCount == 0) {
        uploadBtnStr = @"上传";
        self.uploadBtn.backgroundColor = [UIColor grayColor];
        self.uploadBtn.enabled = NO;
    } else {
        uploadBtnStr = [NSString stringWithFormat:@"上传(%ld)", [ELSelectedFileManager shareManager].selectedFileCount];
        self.uploadBtn.backgroundColor = [UIColor colorWithRed:43/255.0 green:173/255.0 blue:158/255.0 alpha:1.0];
        self.uploadBtn.enabled = YES;
    }
    [self.uploadBtn setTitle:uploadBtnStr forState:UIControlStateNormal];
}

- (void)seleteBtnDidClick:(UIButton *)sender
{
    int index = sender.tag%1000;
    ELFileModel *file = self.files[index];
    if (sender.selected == YES) { // 已经选中
        [[ELSelectedFileManager shareManager] removeFile:file];
    } else {
        if ([[ELSelectedFileManager shareManager] isFull]) {
            [self alertWithString:[NSString stringWithFormat:@"最多只能选择%ld个文件", [ELSelectedFileManager shareManager].maxCount]];
            return;
        }
        [[ELSelectedFileManager shareManager] addFile:file];
    }
    
    [self reloadUploadBtnStr];
    
    sender.selected = !sender.selected;
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    ELFileModel *file = self.files[indexPath.row];
    cell.textLabel.text = file.name;
    UIImage *cellImage;
    if (file.fileType == ELFileTypeDirectory) { // 文件夹
        cell.detailTextLabel.text = [NSString stringWithFormat:@"文件夹： %@ %@", file.creatTime, file.fileSize];
        cellImage = [UIImage imageNamed:@"file_floder"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = nil;
    } else {
        
        switch (file.fileType) {
            case ELFileTypeImage:
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"图片： %@ %@", file.creatTime, file.fileSize];
                cellImage = [UIImage imageWithContentsOfFile:file.filePath];
            }
                break;
            case ELFileTypeTxt:
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"文档： %@ %@", file.creatTime, file.fileSize];
                cellImage = [UIImage imageNamed:@"file_txt"];
            }
                break;
            case ELFileTypeVoice:
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"音乐： %@ %@", file.creatTime, file.fileSize];
                cellImage = [UIImage imageNamed:@"file_mp3"];
            }
                break;
            case ELFileTypeAudioVidio:
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"视频： %@ %@", file.creatTime, file.fileSize];
                cellImage = [UIImage imageNamed:@"file_avi"];
            }
                break;
            case ELFileTypeApplication:
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"应用： %@ %@", file.creatTime, file.fileSize];
                cellImage = [UIImage imageNamed:@"file_ipa"];
            }
                break;
            case ELFileTypeUnknown:
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"未知文件： %@ %@", file.creatTime, file.fileSize];
                cellImage = [UIImage imageNamed:@"file_webView_error"];
            }
                break;
            case ELFileTypeWord:
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"word： %@ %@", file.creatTime, file.fileSize];
                cellImage = [UIImage imageNamed:@"file_word"];
            }
                break;
            case ELFileTypePDF:
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"pdf： %@ %@", file.creatTime, file.fileSize];
                cellImage = [UIImage imageNamed:@"file_pdf"];
            }
                break;
            case ELFileTypePPT:
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"ppt： %@ %@", file.creatTime, file.fileSize];
                cellImage = [UIImage imageNamed:@"file_ppt"];
            }
                break;
            case ELFileTypeXLS:
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"xls： %@ %@", file.creatTime, file.fileSize];
                cellImage = [UIImage imageNamed:@"file_excel"];
            }
                break;
            default:
                break;
        }
        
        // 除了文件夹，其他设置选择按钮
        UIButton *seleteBtn = [[UIButton alloc] init];
        seleteBtn.tag = [NSString stringWithFormat:@"1000%ld", indexPath.row].intValue;
        [seleteBtn setImage:[UIImage imageNamed:@"filemanager_cell_unselected"] forState:UIControlStateNormal];
        [seleteBtn setImage:[UIImage imageNamed:@"filemanager_cell_selected"] forState:UIControlStateSelected];
        seleteBtn.frame = CGRectMake(0, 0, 40, 40);
        [seleteBtn addTarget:self action:@selector(seleteBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = seleteBtn;
        
        if ([[ELSelectedFileManager shareManager] isFileContain:file]) {
            seleteBtn.selected = YES;
        } else {
            seleteBtn.selected = NO;
        }
        
    }
    
    // 设置cell图片大小
    CGSize imageSize = CGSizeMake(40, 40);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
    [cellImage drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ELFileModel *file = self.files[indexPath.row];
    if (file.fileType == ELFileTypeDirectory) { // 文件夹
        ELUploadFileViewController *vc = [[ELUploadFileViewController alloc] initWithPath:file.filePath maxCount:[ELSelectedFileManager shareManager].maxCount - [ELSelectedFileManager shareManager].selectedFileCount uploadBlock:self.uploadBlock];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        ELFileDetailViewController *fileDetail = [[ELFileDetailViewController alloc] initWithFileModel:file];
        [self.navigationController pushViewController:fileDetail animated:YES];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

#pragma mark - lazy
- (ELFileManager *)fileManager
{
    if (!_fileManager) {
        _fileManager = [ELFileManager shareManager];
    }
    return _fileManager;
}

- (NSMutableArray *)files
{
    if (!_files) {
        _files = [NSMutableArray arrayWithArray:[self.fileManager getAllFileWithPath:self.homePath]];
    }
    return _files;
}

@end

