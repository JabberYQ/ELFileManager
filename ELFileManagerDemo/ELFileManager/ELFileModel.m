//
//  ELFileModel.m
//  ELFileManager
//
//  Created by 俞琦 on 2017/10/12.
//  Copyright © 2017年 俞琦. All rights reserved.
//

#import "ELFileModel.h"

static const UInt8 IMAGES_TYPES_COUNT = 8;
static const UInt8 TEXT_TYPES_COUNT = 2;
static const UInt8 VIOCEVIDIO_COUNT = 14;
static const UInt8 Application_count = 4;
static const UInt8 AV_COUNT = 14;
static const UInt8 DOC_TYPES_COUNT = 4;
static const UInt8 XLS_TYPES_COUNT = 4;
static const UInt8 PPT_TYPES_COUNT = 2;
static const UInt8 PDF_TYPES_COUNT = 2;

static const NSString *IMAGES_TYPES[IMAGES_TYPES_COUNT] = {@"png", @"PNG", @"jpg",@",JPG", @"jpeg", @"JPEG" ,@"gif", @"GIF"};
static const NSString *TEXT_TYPES[TEXT_TYPES_COUNT] = {@"txt", @"TXT"};
static const NSString *VIOCEVIDIO_TYPES[VIOCEVIDIO_COUNT] = {@"mp3",@"MP3",@"wav",@"WAV",@"CD",@"cd",@"ogg",@"OGG",@"midi",@"MIDE",@"vqf",@"VQF",@"amr",@"AMR"};
static const NSString *AV_TYPES[AV_COUNT] = {@"asf",@"ASF",@"wma",@"WMA",@"rm",@"RM",@"rmvb",@"RMVB",@"avi",@"AVI",@"mkv",@"MKV",@"mp4",@"MP4"};
static const NSString *Application_types[Application_count] = {@"apk",@"APK",@"ipa",@"IPA"};
static const NSString *DOC_TYPES[DOC_TYPES_COUNT] = {@"doc",@"DOC",@"docx",@"DOCX"};
static const NSString *XLS_TYPES[XLS_TYPES_COUNT] = {@"xls",@"XLS", @"xlsx",@"XLSX"};
static const NSString *PPT_TYPES[PPT_TYPES_COUNT] = {@"ppt",@"PPT"};
static const NSString *PDF_TYPES[PDF_TYPES_COUNT] = {@"pdf",@"PDF"};

//@interface ELFileModel()
//@end

@implementation ELFileModel
{
    NSFileManager *fileMgr;
}

- (instancetype)init
{
    if(self = [super init]) {
        fileMgr = [NSFileManager defaultManager];
    }
    return self;
}

- (instancetype)initWithFilePath:(NSString *)filePath
{
    if(self = [self init]){
        self.filePath = filePath;
    }
    return self;
}


- (void)setFilePath:(NSString *)filePath
{
    _filePath = filePath;
    self.name = [filePath lastPathComponent];
    self.fileType = ELFileTypeUnknown; // 暂时先设置为未知
    
    BOOL isDirectory = true;
    [fileMgr fileExistsAtPath:filePath isDirectory:&isDirectory];
    if (isDirectory) { // 存在文件夹,说明这个文件是文件夹
        self.fileType = ELFileTypeDirectory;
    } else {
        self.fileType = [self judgeType:[filePath pathExtension]];  // 设置类型
    }
    
    NSError *error = nil;
    NSDictionary *fileAttributes = [fileMgr attributesOfItemAtPath:filePath error:&error];
    if (fileAttributes != nil) {
        
        self.attributes = fileAttributes;
        
        // 下面把一些常用的获取到
        NSDate *fileModDate = [fileAttributes objectForKey:NSFileModificationDate];
        if (fileModDate) { // 修改时间
            //用于格式化NSDate对象
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //设置格式：zzz表示时区
            [dateFormatter setDateFormat:@"MM-dd HH:mm:ss"];
            //NSDate转NSString
            self.modTime = [dateFormatter stringFromDate:fileModDate];
        }
        
        NSDate *fileCreateDate = [fileAttributes objectForKey:NSFileCreationDate];
        if (fileCreateDate) { // 创建时间
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //设置格式：zzz表示时区
            [dateFormatter setDateFormat:@"MM-dd HH:mm:ss"];
            //NSDate转NSString
            self.creatTime = [dateFormatter stringFromDate:fileCreateDate];
        }
        
        // 获得大小
        self.fileSizefloat = [self calculateSize];
        
        // 大小的字符
        if (self.fileSizefloat) {
            NSNumber *fileSize = [NSNumber numberWithUnsignedLongLong:self.fileSizefloat];
            NSString *sizestr = [NSString stringWithFormat:@"%qi",[fileSize unsignedLongLongValue]];
            if (sizestr.length <=3) {
                self.fileSize = [NSString stringWithFormat:@"%.1f B",self.fileSizefloat];
            } else if(sizestr.length>3 && sizestr.length<7){
                self.fileSize = [NSString stringWithFormat:@"%.1f KB",self.fileSizefloat/1000.0];
            }else{
                self.fileSize = [NSString stringWithFormat:@"%.1f M",self.fileSizefloat/(1000.0 * 1000)];
            }
        } else {
            self.fileSize = @"0 B";
        }
    }
}



#pragma mark - 私有
// 计算大小
- (float)calculateSize
{
    if (self.fileType != ELFileTypeDirectory) { // 文件
        NSNumber *fileSize = [self.attributes objectForKey:NSFileSize];
        return [fileSize unsignedLongLongValue];
    } else { // 文件夹
        //遍历文件夹中的所有内容
        NSArray *subpaths = [fileMgr subpathsAtPath:_filePath];
        //计算文件夹大小
        float totalByteSize = 0;
        for (NSString *subpath in subpaths){
            //拼接全路径
            NSString *fullSubPath = [_filePath stringByAppendingPathComponent:subpath];
            //判断是否为文件
            BOOL dir = NO;
            [fileMgr fileExistsAtPath:fullSubPath isDirectory:&dir];
            if (dir == NO){//是文件
                NSDictionary *attr = [fileMgr attributesOfItemAtPath:fullSubPath error:nil];
                totalByteSize += [attr[NSFileSize] integerValue];
            }
        }
        return totalByteSize;
    }
}

// 通过后缀获得类型
- (ELFileType)judgeType:(NSString *)pathExtension
{
    NSArray *imageTypesArray = [NSArray arrayWithObjects: IMAGES_TYPES count: IMAGES_TYPES_COUNT];
    if ([imageTypesArray containsObject:pathExtension]) {
        return ELFileTypeImage;
    }
    
    NSArray *textTypesArray = [NSArray arrayWithObjects: TEXT_TYPES count: TEXT_TYPES_COUNT];
    if ([textTypesArray containsObject:pathExtension]) {
        return ELFileTypeTxt;
    }
    
    NSArray *viceViodeArray = [NSArray arrayWithObjects: VIOCEVIDIO_TYPES count: VIOCEVIDIO_COUNT];
    if ([viceViodeArray containsObject:pathExtension]) {
        return ELFileTypeVoice;
    }
    
    NSArray *appViodeArray = [NSArray arrayWithObjects: Application_types count: Application_count];
    if ([appViodeArray containsObject:pathExtension]) {
        return ELFileTypeApplication;
    }
    
    NSArray *AVArray = [NSArray arrayWithObjects: AV_TYPES count: AV_COUNT];
    if ([AVArray containsObject:pathExtension]) {
        return ELFileTypeAudioVidio;
    }
    
    NSArray *DOCArray = [NSArray arrayWithObjects: DOC_TYPES count: DOC_TYPES_COUNT];
    if ([DOCArray containsObject:pathExtension]) {
        return ELFileTypeWord;
    }
    
    NSArray *XLSArray = [NSArray arrayWithObjects: XLS_TYPES count: XLS_TYPES_COUNT];
    if ([XLSArray containsObject:pathExtension]) {
        return ELFileTypeXLS;
    }
    
    NSArray *PDFArray = [NSArray arrayWithObjects: PDF_TYPES count: PDF_TYPES_COUNT];
    if ([PDFArray containsObject:pathExtension]) {
        return ELFileTypePDF;
    }
    
    NSArray *PPTArray = [NSArray arrayWithObjects: PPT_TYPES count: PPT_TYPES_COUNT];
    if ([PPTArray containsObject:pathExtension]) {
        return ELFileTypePPT;
    }
    
    return ELFileTypeUnknown;
}
@end
