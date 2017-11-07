//
//  ViewController.m
//  ELFileManagerDemo
//
//  Created by 俞琦 on 2017/10/13.
//  Copyright © 2017年 俞琦. All rights reserved.
//  http://5.fjdx1.crsky.com/software1/VC_CN-v6.0.zip

#import "ViewController.h"
#import "ELFileModel.h"
#import "ELFileManager.h"

@interface YQProgress : UIView
@property (nonatomic, assign) float progress;
@property (nonatomic, weak) UIView *blackView;
@end
@implementation YQProgress
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.progress = 0;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        
        UIView *blackView = [UIView new];
        blackView.backgroundColor = [UIColor blackColor];
        blackView.frame = CGRectMake(2, 2, self.bounds.size.width * self.progress - 4, self.bounds.size.height - 4);
        [self addSubview:blackView];
        self.blackView = blackView;
    }
    return self;
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    self.blackView.frame = CGRectMake(2, 2, self.bounds.size.width * self.progress - 4, self.bounds.size.height - 4);
    if (_progress <= 0 || _progress >= 1) {
        self.hidden = YES;
    } else {
        self.hidden = NO;
    }
}
@end

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, NSURLSessionDelegate>
@property (nonatomic, strong) NSMutableArray *files;
@property (nonatomic, strong) ELFileManager *fileManager;
@property (nonatomic, weak) UITableView *tv;
@property (nonatomic, copy) NSString *homePath;

// 下载相关
@property (nonatomic, weak) YQProgress *progress;
@end

@implementation ViewController
{
    ELFileModel *_longPressFile; // 记录长按的文件
    NSIndexPath *_longPressIndexPath; // 记录长按的indexpath
    NSString *_downloadFileName; // 下载的文件名
    NSUInteger _totolLen; // 总长度
    NSUInteger _currentLen; // 当前长度
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.fileModel == nil) { // 总目录
        self.homePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ELFileCache"];
        // 创建一个目录
        [self createHomeFilePath:self.homePath];
        self.title = @"总目录";
    } else {
        self.title = self.fileModel.name;
        self.homePath = self.fileModel.filePath;
    }
    
    // init视图
    [self initViews];

    // 获得路径下的所以文件
    [self getAllFile];
}

#pragma mark - tableView 代理数据源
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        //添加长按手势
        UILongPressGestureRecognizer * longPressGesture =[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPress:)];
        longPressGesture.minimumPressDuration = 1.0f;
        [cell addGestureRecognizer:longPressGesture];
    }
    ELFileModel *file = self.files[indexPath.row];
    cell.textLabel.text = file.name;
    if (file.fileType == ELFileTypeDirectory) { // 文件夹
        cell.detailTextLabel.text = [NSString stringWithFormat:@"文件夹： %@ %@", file.creatTime, file.fileSize];
        cell.imageView.image = [UIImage imageNamed:@"file_floder"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        switch (file.fileType) {
            case ELFileTypeImage:
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"图片： %@ %@", file.creatTime, file.fileSize];
                cell.imageView.image = [UIImage imageWithContentsOfFile:file.filePath];
            }
                break;
            case ELFileTypeTxt:
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"文档： %@ %@", file.creatTime, file.fileSize];
                cell.imageView.image = [UIImage imageNamed:@"file_txt"];
            }
                break;
            case ELFileTypeVoice:
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"音乐： %@ %@", file.creatTime, file.fileSize];
                cell.imageView.image = [UIImage imageNamed:@"file_mp3"];
            }
                break;
            case ELFileTypeAudioVidio:
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"视频： %@ %@", file.creatTime, file.fileSize];
                cell.imageView.image = [UIImage imageNamed:@"file_avi"];
            }
                break;
            case ELFileTypeApplication:
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"应用： %@ %@", file.creatTime, file.fileSize];
                cell.imageView.image = [UIImage imageNamed:@"file_ipa"];
            }
                break;
            case ELFileTypeUnknown:
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"未知文件： %@ %@", file.creatTime, file.fileSize];
                cell.imageView.image = [UIImage imageNamed:@"file_webView_error"];
            }
                break;
            case ELFileTypeWord:
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"word： %@ %@", file.creatTime, file.fileSize];
                cell.imageView.image = [UIImage imageNamed:@"file_word"];
            }
                break;
            case ELFileTypePDF:
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"pdf： %@ %@", file.creatTime, file.fileSize];
                cell.imageView.image = [UIImage imageNamed:@"file_pdf"];
            }
                break;
            case ELFileTypePPT:
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"ppt： %@ %@", file.creatTime, file.fileSize];
                cell.imageView.image = [UIImage imageNamed:@"file_ppt"];
            }
                break;
            case ELFileTypeXLS:
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"xls： %@ %@", file.creatTime, file.fileSize];
                cell.imageView.image = [UIImage imageNamed:@"file_excel"];
            }
                break;
            default:
                break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ELFileModel *file = self.files[indexPath.row];
    if (file.fileType == ELFileTypeDirectory) {
        ViewController *vc = [[ViewController alloc] init];
        vc.fileModel = file;
        vc.homePath = file.filePath;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        NSData *data = [self.fileManager readDataFromFilePath:file.filePath];
        [self.fileManager seriesWriteContent:data intoHandleFile:file.filePath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ELFileModel *file = self.files[indexPath.row];
    if ([self.fileManager deleteFileWithPath:file.filePath]) {
        [self.files removeObjectAtIndex:indexPath.row];
        [self.tv deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

#pragma mark - 对控件权限进行设置
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action == @selector(rename:) || action == @selector(moveFile) || action == @selector(copyFile))
        return YES;
    return NO;
}

#pragma mark - 下载代理

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    // 接收到数据时，创建文件
    _downloadFileName = response.suggestedFilename;
    [self.fileManager createFileToPath:self.homePath fileName:response.suggestedFilename];
    _totolLen = response.expectedContentLength;
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    
    NSString* filePath = [self.homePath stringByAppendingPathComponent:_downloadFileName];
    [self.fileManager seriesWriteContent:data intoHandleFile:filePath]; // 写入
    _currentLen += data.length;
    double progress = (double)_currentLen / _totolLen;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progress.progress = progress;
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [self getAllFile];
}

#pragma mark - 私有
- (void)initViews
{
    UITableView *tv = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tv.delegate = self;
    tv.dataSource = self;
    [self.view addSubview:tv];
    self.tv = tv;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(addAction)];
    
    YQProgress* progress = [[YQProgress alloc] initWithFrame:CGRectMake(10, self.view.bounds.size.height - 30, self.view.bounds.size.width - 20, 20)];
    progress.progress = 0;
    [self.view addSubview:progress];
    self.progress = progress;
}

- (void)getAllFile
{
    self.fileManager = [ELFileManager shareManager];
    self.files = [NSMutableArray arrayWithArray:[self.fileManager getAllFileWithPath:self.homePath]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tv reloadData];
    });
}

- (void)addAction
{
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:nil message:@"操作" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *createFolderAction = [UIAlertAction actionWithTitle:@"添加一个文件夹" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        int num = arc4random() % 100;
        NSString *name = [NSString stringWithFormat:@"新建的文件夹--%d", num];
        if ([self.fileManager createFolderToPath:self.homePath folderName:name]) {
            [self getAllFile];
        } else {
            NSLog(@"创建失败");
        }
        
    }];
    UIAlertAction *createFileAction = [UIAlertAction actionWithTitle:@"新建一个文件" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([self.fileManager createFileToPath:self.homePath fileName:@"hello.api"]) {
            [self getAllFile];
        } else {
            NSLog(@"创建失败");
        }
    }];
    UIAlertAction *addFileAction = [UIAlertAction actionWithTitle:@"添加一个文件" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        int num = arc4random() % 100;
        NSDictionary *dic = @{@"name" : @"YYQQ"};
        if ([self.fileManager addFile:dic toPath:self.homePath fileName:[NSString stringWithFormat:@"添加的字典--%d.txt", num]]) {
            [self getAllFile];
        } else {
            NSLog(@"添加失败");
        }
    }];
    UIAlertAction *downloadFileAction = [UIAlertAction actionWithTitle:@"下载一个大文件" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_02.mp4"]]];
        [dataTask resume];
    }];
    UIAlertAction *searchAction = [UIAlertAction actionWithTitle:@"搜索“的”字文件" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSArray *resFiles = [self.fileManager searchDeepFile:@"的" folderPath:self.homePath];
        for (ELFileModel *file in resFiles) {
            NSLog(@"%@", file.name);
        }
        
    }];
    
    // 添加响应方式
    [actionSheetController addAction:createFolderAction];
    [actionSheetController addAction:createFileAction];
    [actionSheetController addAction:addFileAction];
    [actionSheetController addAction:downloadFileAction];
    [actionSheetController addAction:searchAction];
    [actionSheetController addAction:cancelAction];

    // 显示
    [self presentViewController:actionSheetController animated:YES completion:nil];
}

// 创建一个目录
- (void)createHomeFilePath:(NSString *)homePath
{
    NSLog(@"%@", homePath);
    if(![[NSFileManager defaultManager] fileExistsAtPath:homePath]){ // 如果不存在这个路径 就创建
        [[NSFileManager defaultManager] createDirectoryAtPath:homePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
}

- (void)cellLongPress:(UILongPressGestureRecognizer *)longRecognizer
{
    if (longRecognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint location = [longRecognizer locationInView:self.tv];
        _longPressIndexPath = [self.tv indexPathForRowAtPoint:location];
        UITableViewCell *cell = [self.tv cellForRowAtIndexPath:_longPressIndexPath];
        _longPressFile = self.files[_longPressIndexPath.row];
        
        
        [self becomeFirstResponder];
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        //控制箭头方向
        menuController.arrowDirection = UIMenuControllerArrowDefault;
        //自定义事件
        UIMenuItem *renameItem = [[UIMenuItem alloc] initWithTitle:@"重命名" action:@selector(rename:)];
        UIMenuItem *moveItem = [[UIMenuItem alloc] initWithTitle:@"移动" action:@selector(moveFile)];
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyFile)];
        
        NSArray *menuItemArray = [NSArray arrayWithObjects:renameItem, moveItem, copyItem, nil];
        [menuController setMenuItems:menuItemArray];
        [menuController setTargetRect:cell.frame inView:self.tv];
        [menuController setMenuVisible:YES animated:YES];
        
        
        
    }
}

// 重命名
- (void)rename:(UIMenuController *)menu
{
    UIAlertController *actionAlertController = [UIAlertController alertControllerWithTitle:@"重命名" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([self.fileManager renameFileWithPath:self.homePath oldName:_longPressFile.name newName:[[[actionAlertController textFields] firstObject] text]]) { // 成功
            [self getAllFile]; // 获取数据
        } else {
            NSLog(@"失败");
        }
    }];
    
    [actionAlertController addAction:cancleAction];
    [actionAlertController addAction:defaultAction];
    
    [actionAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = _longPressFile.name;
    }];
    
    [self presentViewController:actionAlertController animated:YES completion:nil];
}

// 复制
- (void)copyFile
{
    ELFileModel *directoryFile;
    for (ELFileModel *file in self.files) {  // 获取一个临时的最前的文件夹
        if (file.fileType == ELFileTypeDirectory) {
            directoryFile = file;
        }
    }
    if ([self.fileManager copyFile:_longPressFile.filePath toNewPath:directoryFile.filePath]) {
        [self getAllFile];
        NSLog(@"复制成功");
    } else {
        NSLog(@"复制失败");
    }
}

// 移动
- (void)moveFile
{
    ELFileModel *directoryFile;
    for (ELFileModel *file in self.files) {  // 获取一个临时的最前的文件夹
        if (file.fileType == ELFileTypeDirectory) {
            directoryFile = file;
        }
    }
    if ([self.fileManager moveFile:_longPressFile.filePath toNewPath:directoryFile.filePath]) {
        [self getAllFile];
        NSLog(@"移动成功");
    } else {
        NSLog(@"移动失败");
    }
}

#pragma mark - lazy
- (NSMutableArray *)files
{
    if (!_files) {
        _files = [NSMutableArray array];
    }
    return _files;
}
@end
