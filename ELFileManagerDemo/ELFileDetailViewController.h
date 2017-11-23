//
//  ELFileDetailViewController.h
//  FileManagerDemo
//
//  Created by easylink on 2017/11/17.
//  Copyright © 2017年 YuQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ELFileModel;

@interface ELFileDetailViewController : UIViewController
- (instancetype)initWithFileModel:(ELFileModel *)file;
@end
