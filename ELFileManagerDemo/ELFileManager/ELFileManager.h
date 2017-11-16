//
//  ELFileManager.h
//  ELFileManager
//
//  Created by 俞琦 on 2017/10/12.
//  Copyright © 2017年 俞琦. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ELFileModel;

@interface ELFileManager : NSObject

/**
 初始化单例
 
 @return 自身对象
 */
+ (instancetype)shareManager;

/**
 获得一个文件
 
 @param path 文件路径
 @return ELFileModel 对象
 */
- (ELFileModel *)getFileWithPath:(NSString *)path;


/**
 获取到当前路径下的所有文件（包括文件夹）
 
 @param path 文件夹路径
 @return 返回 ELFileModel 对象数组
 */
- (NSArray *)getAllFileWithPath:(NSString *)path;


/**
 文件是否存在
 
 @param path 文件路径
 @return 是否存在
 */
- (BOOL)fileExistsAtPath:(NSString *)path;

/**
 新建一个文件夹-1
 
 @param path 文件所在的文件夹路径
 @param name 文件夹名称
 @return 返回 成功与否
 */
- (BOOL)createFolderToPath:(NSString *)path folderName:(NSString *)name;


/**
 新建一个文件夹-2
 
 @param fullPath 文件夹的全路径
 @return 成功与否
 */
- (BOOL)createFolderToFullPath:(NSString *)fullPath;

/**
 新建一个文件到指定目录-1
 
 @param path 文件所在的文件夹路径
 @param name 文件名称
 @return 返回 成功与否
 */
- (BOOL)createFileToPath:(NSString *)path fileName:(NSString *)name;


/**
 新建一个文件到指定目录-2
 
 @param fullPath 文件的全路径
 @return 成功与否
 */
- (BOOL)createFileToFullPath:(NSString *)fullPath;

/**
 添加文件到指定目录
 
 @param file 需要写入的文件
 @param path 文件所在的文件夹路径
 @param name 文件名称
 @return 返回 成功与否
 */
- (BOOL)addFile:(id)file toPath:(NSString *)path fileName:(NSString *)name;

/**
 删除文件
 
 @param path 文件路径（全路径）
 @return 返回 成功与否
 */
- (BOOL)deleteFileWithPath:(NSString *)path;


/**
 移动文件
 
 @param oldPath 原本的文件全路径
 @param newPath 新的文件所在的文件夹路径
 @return 成功与否
 */
- (BOOL)moveFile:(NSString *)oldPath toNewPath:(NSString *)newPath;

/**
 复制文件
 
 @param oldPath 原本的文件全路径
 @param newPath 新的文件所在的文件夹路径
 @return 成功与否
 */
- (BOOL)copyFile:(NSString *)oldPath toNewPath:(NSString *)newPath;

/**
 重命名
 
 @param path 文件所在的文件夹路径
 @param oldName 老名字
 @param newName 新名字
 @return 返回 成功与否
 */
- (BOOL)renameFileWithPath:(NSString *)path oldName:(NSString *)oldName newName:(NSString *)newName;



/**
 搜索表面的文件（不会搜索当前文件夹里的文件夹内文件。。）
 
 @param searchText 搜索的文字
 @param folderPath 搜索的文件夹路径
 @return 返回 ELFileModel 对象数组
 */
- (NSArray *)searchSurfaceFile:(NSString *)searchText folderPath:(NSString *)folderPath;



/**
 搜索深度的文件 (会把当前文件夹里的所有文件都查一遍 包括文件夹里的文件夹)
 
 @param searchText 搜索的文字
 @param folderPath 搜索的文件夹路径
 @return 返回 ELFileModel 对象数组
 */
- (NSArray *)searchDeepFile:(NSString *)searchText folderPath:(NSString *)folderPath;

/**
 读取文件的内容
 
 @param filePath 文件的路径
 @return 返回 NSData类型对象
 */
- (NSData *)readDataFromFilePath:(NSString *)filePath;


/**
 往文件里追加内容
 
 @param contentData 追加的内容
 @param filePath 文件路径
 */
- (void)seriesWriteContent:(NSData *)contentData intoHandleFile:(NSString *)filePath;
@end


