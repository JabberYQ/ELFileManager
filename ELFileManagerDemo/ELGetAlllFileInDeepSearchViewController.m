//
//  ELGetAlllFileInDeepSearchViewController.m
//  ELFileManagerDemo
//
//  Created by easylink on 2017/11/24.
//  Copyright © 2017年 俞琦. All rights reserved.
//

#import "ELGetAlllFileInDeepSearchViewController.h"
#import "ELFileManager.h"
#import "ELFileModel.h"
#import "ELFileDetailViewController.h"

@interface ELGetAlllFileInDeepSearchViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) ELFileManager * fileManager;
@property (nonatomic, weak) UITableView * tableView;
@property (nonatomic, copy) NSString * homePath;
@property (nonatomic, strong) NSMutableArray *files;
@end

@implementation ELGetAlllFileInDeepSearchViewController

- (instancetype)initWithPath:(NSString *)path
{
    if (self = [super init]) {
        self.homePath = path;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![self.fileManager fileExistsAtPath:self.homePath]) {
        [self.fileManager createFolderToFullPath:self.homePath];
    }
    
    [self initViews];
}

- (void)initViews
{
    UITableView *tv = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tv.delegate = self;
    tv.dataSource = self;
    [self.view addSubview:tv];
    self.tableView = tv;
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UIImage *cellImage;
    if (file.fileType == ELFileTypeDirectory) { // 文件夹
        cell.detailTextLabel.text = [NSString stringWithFormat:@"文件夹： %@ %@", file.creatTime, file.fileSize];
        cellImage = [UIImage imageNamed:@"file_floder"];
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

    ELFileDetailViewController *fileDetail = [[ELFileDetailViewController alloc] initWithFileModel:file];
    [self.navigationController pushViewController:fileDetail animated:YES];
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
        _files = [NSMutableArray arrayWithArray:[self.fileManager getAllFileInPathWithDeepSearch:self.homePath]];
    }
    return _files;
}

@end
