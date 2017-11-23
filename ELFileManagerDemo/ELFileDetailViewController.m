//
//  ELFileDetailViewController.m
//  FileManagerDemo
//
//  Created by easylink on 2017/11/17.
//  Copyright © 2017年 YuQi. All rights reserved.
//

#import "ELFileDetailViewController.h"
#import "ELFileModel.h"
#import <QuickLook/QuickLook.h>

@interface ELFileDetailViewController () <UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong) ELFileModel * file;
@property (nonatomic, strong) UIDocumentInteractionController * documentInteraction;
@property (nonatomic, weak) UIWebView * webView;
@end

@implementation ELFileDetailViewController

- (instancetype)initWithFileModel:(ELFileModel *)file
{
    if (self = [super init]) {
        self.file = file;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"文件详情";
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *urlStr = self.file.filePath;
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    
    UIDocumentInteractionController *documentVc = [UIDocumentInteractionController interactionControllerWithURL:url];
    documentVc.delegate = self;
    
    UIView *remindView = [[UIView alloc] initWithFrame:self.view.bounds];
    remindView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    remindView.hidden = YES;
    [self.view addSubview:remindView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height * 0.4, self.view.bounds.size.width, 60)];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:18];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"文件暂不支持本地打开\n请用其他应用打开";
    label.textColor = [UIColor colorWithRed:47/255.0 green:47/255.0 blue:47/255.0 alpha:1.0];
    [remindView addSubview:label];
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"用其他应用打开" forState:UIControlStateNormal];
    btn.frame = CGRectMake((self.view.bounds.size.width-200)/2, self.view.bounds.size.height * 0.55, 200, 45);
    btn.titleLabel.font = [UIFont systemFontOfSize:18];
    btn.layer.cornerRadius = 5;
    btn.backgroundColor = [UIColor colorWithRed:43/255.0 green:173/255.0 blue:158/255.0 alpha:1.0];
    [btn addTarget:self action:@selector(openInOtherApp) forControlEvents:UIControlEventTouchUpInside];
    [remindView addSubview:btn];
    
    
    BOOL canOpen = [documentVc presentPreviewAnimated:YES];
    if (!canOpen) {
        remindView.hidden = NO;
    }
}

- (void)openInOtherApp
{
    NSString *urlStr = self.file.filePath;
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    //创建实例
    UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:url];
    
    //设置代理
    documentController.delegate = self;
    BOOL canOpen = [documentController presentOpenInMenuFromRect:CGRectZero
                                                          inView:self.view
                                                        animated:YES];
    if (!canOpen) {
    
    }
}

#pragma mark - UIDocumentInteractionController 代理方法
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
    return self.view.bounds;
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
