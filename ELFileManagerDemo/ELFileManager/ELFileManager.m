//
//  ELFileManager.m
//  ELFileManager
//
//  Created by 俞琦 on 2017/10/12.
//  Copyright © 2017年 俞琦. All rights reserved.
//

#import "ELFileManager.h"
#import "ELFileModel.h"

@interface ELFileManager()
@property (nonatomic, strong) NSFileManager *fileManager;
@end

@implementation ELFileManager
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

- (NSArray *)getAllFileWithPath:(NSString *)path
{
    NSMutableArray *files = [NSMutableArray array];
    NSArray<NSString *> *subPathsArray = [self.fileManager contentsOfDirectoryAtPath:path error: NULL];
    for(NSString *str in subPathsArray){
        ELFileModel *file = [[ELFileModel alloc] initWithFilePath: [NSString stringWithFormat:@"%@/%@",path, str]];
        [files addObject:file];
    }
    return files;
}

- (BOOL)createFolderToPath:(NSString *)path folderName:(NSString *)name
{
    path = [NSString stringWithFormat:@"%@/%@", path, name];
    return [self.fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

- (BOOL)createFileToPath:(NSString *)path fileName:(NSString *)name
{
    path = [NSString stringWithFormat:@"%@/%@", path, name];
    return [self.fileManager createFileAtPath:path contents:[@"ss" dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

- (BOOL)addFile:(id)file toPath:(NSString *)path fileName:(NSString *)name
{
    path = [NSString stringWithFormat:@"%@/%@", path, name];
    return [file writeToFile:path atomically:YES];
}

- (BOOL)deleteFileWithPath:(NSString *)path
{
    return [self.fileManager removeItemAtPath:path error:nil];
}

- (BOOL)moveFile:(NSString *)oldPath toNewPath:(NSString *)newPath
{
    newPath = [NSString stringWithFormat:@"%@/%@", newPath, [oldPath lastPathComponent]];
    return [self.fileManager moveItemAtPath:oldPath toPath:newPath error:nil];
}

- (BOOL)copyFile:(NSString *)oldPath toNewPath:(NSString *)newPath
{
    NSError *error;
    newPath = [NSString stringWithFormat:@"%@/%@", newPath, [oldPath lastPathComponent]];
    BOOL succeed = [self.fileManager copyItemAtPath:oldPath toPath:newPath error:&error];
    return succeed;
}

- (BOOL)renameFileWithPath:(NSString *)path oldName:(NSString *)oldName newName:(NSString *)newName
{
    NSString *oldPath = [NSString stringWithFormat:@"%@/%@", path, oldName];
    NSString *newPath = [NSString stringWithFormat:@"%@/%@", path, newName];
    return [self.fileManager moveItemAtPath:oldPath toPath:newPath error:nil];
}

- (NSArray *)searchSurfaceFile:(NSString *)searchText folderPath:(NSString *)folderPath
{
    NSArray *files = [self getAllFileWithPath:folderPath];
    
    NSMutableArray *returnArr = [NSMutableArray array];
    for (ELFileModel *file in files) {
        if ([file.name rangeOfString:searchText].location != NSNotFound) {
            [returnArr addObject:file];
        }
    }
    return returnArr;
}

- (NSArray *)searchDeepFile:(NSString *)searchText folderPath:(NSString *)folderPath
{
    NSArray *files = [self getAllFileWithPath:folderPath];
    
    NSMutableArray *returnArr = [NSMutableArray array];
    for (ELFileModel *file in files) {
        if ([file.name rangeOfString:searchText].location != NSNotFound) { // 找到文件
            if (file.fileType == ELFileTypeDirectory) { // 文件夹
                [returnArr addObjectsFromArray:[self searchDeepFile:searchText folderPath:file.filePath]]; // 递归去找
            }
            [returnArr addObject:file];
        }
    }
    return returnArr;
}

- (NSData *)readDataFromFilePath:(NSString *)filePath
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    NSData *data = [fileHandle readDataToEndOfFile];
    [fileHandle closeFile];
    return data;
}

- (void)seriesWriteContent:(NSData *)contentData intoHandleFile:(NSString *)filePath
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:contentData];
    [fileHandle closeFile];
}

#pragma mark - lazy
- (NSFileManager *)fileManager
{
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}

@end
