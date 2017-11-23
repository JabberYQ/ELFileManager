//
//  MainViewController.m
//  ELFileManagerDemo
//
//  Created by easylink on 2017/11/23.
//  Copyright © 2017年 俞琦. All rights reserved.
//

#import "MainViewController.h"
#import "ELMoreViewController.h"
#import "ELUploadFileViewController.h"
#import "ELFileModel.h"
#import "ELFileBrowseViewController.h"

@interface MainViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray * lists;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Mian";
    self.lists = @[@"上传控制器 路径：document/2333", @"文件浏览器 路径：document/2333", @"更多操作 路径：cache/ELFileCache"];
    
    UITableView *tv = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tv.delegate = self;
    tv.dataSource = self;
    [self.view addSubview:tv];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.lists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.lists[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *path = [docDir stringByAppendingPathComponent:@"2333"];
    
    if (indexPath.row == 0) {
        ELUploadFileViewController *upload = [[ELUploadFileViewController alloc] initWithPath:path maxCount:1 uploadBlock:^(NSArray *fileArray) {
            for (ELFileModel *model in fileArray) {
                NSLog(@"%@", model.name);
            }
        }];
        [self.navigationController pushViewController:upload animated:YES];
    } else if (indexPath.row == 1) {
        ELFileBrowseViewController *fileBrowse = [[ELFileBrowseViewController alloc] initWithPath:path];
        [self.navigationController pushViewController:fileBrowse animated:YES];
    } else if (indexPath.row == 2) {
        ELMoreViewController *vc = [[ELMoreViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
