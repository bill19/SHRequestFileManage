//
//  MTFileManager.m
//  MACAPP1
//
//  Created by HaoSun on 2017/11/8.
//  Copyright © 2017年 YHKIT. All rights reserved.
//

#import "MTFileManager.h"
#import "MutiModelAttribute.h"
#import "SHTransform.h"
#import "SHParmsModel.h"
#import "SHFileHeader.h"
#import <Cocoa/Cocoa.h>
#import "NSString+change.h"
@interface MTFileManager()

@property (nonatomic, strong) NSMutableArray *mutiModelArray;

@property (nonatomic, strong) NSMutableArray *allModelArray;

@property (nonatomic, strong) NSMutableString *atString;

@property (nonatomic, strong) NSArray *urls;

@end

@implementation MTFileManager

- (BOOL)createModelWithUrlurlString:(NSString *)urlstring {
    [self createModelWithUrlurlArray:[SHTransform shTransFromFullSting:urlstring]];
    [self creatRequestFileWithArray:[SHTransform shTransFromFullSting:urlstring]];

    return YES;
}
/**
 * 创建出url文件
 * @param urlArray json数据
 */
- (BOOL)createModelWithUrlurlArray:(NSArray <SHParmsModel *>*)urlArray
{
    NSMutableString *headerString = [NSMutableString string];
    [headerString appendString:[self creatFileHeaderClassName:self.className projectName:self.projectName developerName:self.developerName abString:self.abString isHeader:YES]];
    [headerString appendFormat:@"#define kBase%@Url @\"\" \n",self.className];
    [headerString appendString:[SHTransform urlHeaderBeginclassName:self.className]];
    NSMutableArray *urlTempArr = [NSMutableArray array];
    NSMutableArray *marksTemp = [NSMutableArray array];
    for (NSUInteger index = 0; index < urlArray.count; index++) {
        SHParmsModel *parmsModel = [urlArray objectAtIndex:index];
        [urlTempArr addObject:parmsModel.netUrl];
        [marksTemp addObject:parmsModel.requestHeaderNoteName];
    }
    NSArray *urls = [SHTransform removeRepeat:urlTempArr];
    NSArray *marksurls = [SHTransform removeRepeat:marksTemp];
    self.urls = urls;
    for (int i = 0; i < urls.count; i++) {
        //去除空格
        NSString *urlStr1 = [[urls objectAtIndex:i] stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *urlStr = [urlStr1 stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        //创建 #define URL_NH_REPORT  的格式
        [headerString appendString:[SHTransform addUrlMarkFull:marksurls[i]]];
        NSString *temStr = [[urls[i] componentsSeparatedByString:@"/"] lastObject];
        [headerString appendFormat:@"#define URL_%@_%@ ",[self.abString uppercaseStringWithLocale:[NSLocale currentLocale]],[temStr uppercaseStringWithLocale:[NSLocale currentLocale]]];
        [headerString appendString:[SHTransform addDef2ppendString:urlStr classN:self.className]];
        [headerString appendString:@"\n\n\n"];
    }

    [headerString appendString:[SHTransform urlFooterEndclassName:self.className]];
    return [self generateFileAllowForHeader:@"URL" needSource:NO headerStr:headerString sourceStr:[NSMutableString string]];
}

- (BOOL)creatRequestFileWithArray:(NSArray <SHParmsModel *>*)modelArray {

    NSMutableString *headerString  = [NSMutableString string];
    [headerString appendString:[self creatFileHeaderClassName:self.className projectName:self.projectName developerName:self.developerName abString:self.abString isHeader:YES]];
    //拼接上面的block回调
    [headerString appendString:k_Block_Success];
    [headerString appendString:k_Block_Failure];
    [headerString appendString:k_Block_Error];
    NSMutableString *headerSocString = [NSMutableString string];
    [headerSocString appendString:k_block_judgeHeader];
    NSDictionary *dict = [SHTransform mergeParms:modelArray urls:self.urls];
    [headerSocString appendString:[self sourceStringFromUrls:self.urls dict:dict isNeedRequestType:NO]];
    NSString *str1 = [NSString stringWithFormat:@"%@Request",_className];
    [headerString appendFormat:k_CLASS,str1,headerSocString];


    NSMutableString *muSourceStr = [NSMutableString stringWithFormat:@"%@",[self creatRequestFileSourceWithArray:modelArray]];
    return  [self generateFileAllowForHeader:@"Request" needSource:YES headerStr:headerString sourceStr:muSourceStr];
}

/**
 通过存储的字典和url集合 返回对应的参数备注集合和头部信息

 @param urls <#urls description#>
 @param dict <#dict description#>
 @return <#return value description#>
 */
- (NSString *)sourceStringFromUrls:(NSArray *)urls dict:(NSDictionary *)dict isNeedRequestType:(BOOL)needRequestType{
    NSMutableString *sourceStr = [NSMutableString string];//要返回的字符串
    for (NSString *url in urls) {
        /**插入方法信息*/
        NSMutableString *tempSourceString = [NSMutableString string];//注释信息
        NSMutableString *parmsString = [NSMutableString string];//参数数组拼接字符串
        NSMutableString *parmInPutString = [NSMutableString string];//内部的参数字典拼接
        NSString *requestStr = [NSString string];//获取请求方式 post or get
        NSArray *models = dict[url];
        for (int i = 0; i < models.count; i++) {
            SHParmsModel *parmModel = [models objectAtIndex:i];
            [parmsString appendString:[parmModel.netParameterName sh_lowercaseString]];
            if (parmModel.netParameterName.length>0) {
                [parmsString appendString:@":"];
            }
            [parmsString appendString:[SHTransform parmType:parmModel.netTypeName]];
            if ([parmModel.netParameterName isEqualToString:@"id"]) {
                [parmsString appendString:@"ID"];
            }else{
                [parmsString appendString:parmModel.netParameterName];
            }

            if (parmModel.netParameterName.length>0) {
                [parmsString appendString:@" "];
            }
            requestStr = parmModel.netRequest;
            NSMutableString *tempNetType =[NSMutableString string];
            if ([SHTransform stringIsNeedStar:parmModel.netTypeName] ) {
                [tempNetType appendString:parmModel.netParameterName];
            }else{
                [tempNetType appendString:[SHTransform addParentheses:parmModel.netParameterName]];
            }
            if (parmModel.netParameterName.length>0) {
                if ([tempNetType isEqualToString:@"id"]) {
                    [parmInPutString appendFormat:@"    [self addParmWith:params mtobject:%@ mtkey:@\"%@\"];\n",@"ID",parmModel.netParameterName];
                }else{
                    [parmInPutString appendFormat:@"    [self addParmWith:params mtobject:%@ mtkey:@\"%@\"];\n",tempNetType,parmModel.netParameterName];
                }
            }
        }
        NSString *url_Str = [NSString stringWithFormat:@"URL_%@_%@ ",[self.abString uppercaseStringWithLocale:[NSLocale currentLocale]],[[[url componentsSeparatedByString:@"/"] lastObject] uppercaseStringWithLocale:[NSLocale currentLocale]]];//获取URL 例如 URL_XX_XX字符串
        [tempSourceString appendString:[SHTransform addMarkModels:models]];//备注信息拼接
        [tempSourceString appendString:k_function_header([_abString uppercaseString],[[url componentsSeparatedByString:@"/"] lastObject],parmsString,k_function_footer,needRequestType?@"\n":@";\n")];
        [sourceStr appendString:tempSourceString];

        if (needRequestType == YES) {//内部写入参数信息 拼接接收到的参数字典

            [parmInPutString insertString:@"    [self addParametersForDict:params];\n" atIndex:0];
            [parmInPutString insertString:@"    NSMutableDictionary *params = [NSMutableDictionary dictionary];\n" atIndex:0];
            [parmInPutString appendString:k_function_requestBody(requestStr,url_Str)];
            NSString *barcketsString = [SHTransform addBrackets:parmInPutString];
            [sourceStr appendString:barcketsString];
        }
    }
    return sourceStr;
}

- (NSString *)creatRequestFileSourceWithArray:(NSArray <SHParmsModel *>*)modelArray {

    NSMutableString *sourceStr = [NSMutableString string];
    [sourceStr appendString:[self creatFileHeaderClassName:self.className projectName:self.projectName developerName:self.developerName abString:self.abString isHeader:NO]];
    NSMutableString *sourceString = [NSMutableString string];
    [sourceString appendString:k_block_judgeSource];
    /**创建唯一调用方法*/
    NSDictionary *dict = [SHTransform mergeParms:modelArray urls:self.urls];
    [sourceString appendString:[self sourceStringFromUrls:self.urls dict:dict isNeedRequestType:YES]];
    [sourceString appendString:k_function_addParm];
    [sourceString appendString:k_function_addParmWithDict];
    NSString *str1 = [NSString stringWithFormat:@"%@Request",_className];
    [sourceStr appendFormat:k_CLASS_M,str1,sourceString];
    return sourceStr;
}

/**
 创建文件的头信息
 */
- (NSString *)creatFileHeaderClassName:(NSString *)className projectName:(NSString *)projectName developerName:(NSString *)developerName abString:(NSString *)abString isHeader:(BOOL)isHeader{

    NSString *dateFull = [NSDate stringWithFormat:@"yyyy/MM/dd"];
    NSString *dateYear = [NSDate stringWithFormat:@"yyyy"];
    if (isHeader) {
       return  [NSString stringWithFormat:k_HEADINFO('h'),className,projectName,developerName,dateFull,dateYear,developerName];
    }else{
        NSString *classNameStr = [NSString stringWithFormat:@"%@Request",className];
        NSMutableString *tempStr = [NSMutableString stringWithFormat:k_HEADINFO('m'),classNameStr,projectName,_developerName,dateFull,dateYear,developerName,classNameStr];
        [tempStr appendFormat:@"#import \"%@URL.h\"",_className];
        [tempStr appendString:@"\n\n"];
      return  tempStr;
    }
}


/**
 * 生成文件并存放到指定的目录下
 * @return 成功为YES 失败为NO
 * deprecated 目前弃用
 */
- (BOOL)generateFileAllowForHeader:(NSString *)name needSource:(BOOL)needSource headerStr:(NSMutableString *)headerStr sourceStr:(NSMutableString *)sourceStr{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *dirPath = [paths[0] stringByAppendingPathComponent:name];

    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:dirPath error:nil];
    BOOL dir = NO;
    BOOL exis = [fm fileExistsAtPath:dirPath isDirectory:&dir];
    if (!exis && !dir)
    {
        [fm createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil error:nil];
    }

    BOOL headFileFlag = NO;
    BOOL sourceFileFlag = NO;
    NSString *rpath = [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.h",_className,name]];
    headFileFlag = [headerStr writeToFile:rpath atomically:NO encoding:NSUTF8StringEncoding error:nil];
    if (needSource) {
        NSString *sourceFilePath = [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.m",_className,name]];
        sourceFileFlag =  [sourceStr writeToFile:sourceFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
        [fm createDirectoryAtPath:sourceFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    if (needSource) {
        return headFileFlag;
    }else{
        return (headFileFlag&&sourceFileFlag);
    }
}


+ (void)openFloder
{
    //    NSString *dateStr = [NSDate stringWithFormat:@"yyyy-MM-dd"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    //    NSString *dirPath = [paths[0] stringByAppendingPathComponent:dateStr];
    [[NSWorkspace sharedWorkspace]selectFile:nil inFileViewerRootedAtPath:paths[0]];
}
@end
