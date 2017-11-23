//
//  ELUploadFileViewController.h
//  FileManagerDemo
//
//  Created by easylink on 2017/11/16.
//  Copyright © 2017年 YuQi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UploadFileBlock)(NSArray *fileArray);

@interface ELUploadFileViewController : UIViewController
- (instancetype)initWithPath:(NSString *)path maxCount:(NSInteger)maxCount uploadBlock:(UploadFileBlock)uploadBlock;
@end

