//
//  SHTransform.m
//  MACAPP1
//
//  Created by HaoSun on 2017/11/7.
//  Copyright © 2017年 YHKIT. All rights reserved.
//

#import "SHTransform.h"
#import "SHParmsModel.h"
#import "NSString+change.h"
@implementation SHTransform
/**
 按照固定好的excel生成需要的字符串-从而生成需要的model

 @param fullString /emptyVisit/myEmptyVisitPager    ~    userId    ~    用户id    ~    NSString    ~    GET    ;
 @return 给一个模型数组啊
 */
+ (NSArray <SHParmsModel *>*)shTransFromFullSting:(NSString *)fullString {
    NSArray *fullArray = [fullString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray *models = [NSMutableArray array];
    for (int i = 0; i < fullArray.count; i++) {
        NSArray *array2 = [fullArray[i] componentsSeparatedByString:@"\t"];
        SHParmsModel *model = [[SHParmsModel alloc] init];
        model.netUrl = [array2 objectAtIndex:0];
        NSString *strNoteName = [[array2 objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        model.netParameterName = strNoteName;
        model.netNoteName = [array2 objectAtIndex:2];
        model.netTypeName = [self netTypeNameFrom:[array2 objectAtIndex:3]];
        model.netRequest = [array2 objectAtIndex:4];
        model.requestHeaderNoteName = [array2 objectAtIndex:5];
        model.abNetUrl = [[model.netUrl componentsSeparatedByString:@"/"] lastObject];
        [models addObject:model];
    }
    return models;
}

/**在一个字符串外部加一对大括号 主要是 function最外部的大括号**/
+ (NSMutableString *)addBrackets:(NSString *)sourceString {
    NSMutableString *str = [NSMutableString string];
    [str appendString:@"{\n\n"];
    [str appendString:sourceString];
    [str appendString:@"\n}\n"];
    return str;
}


/**在一个字符串外部加一对小括号**/
+ (NSMutableString *)addParentheses:(NSString *)sourceString {
    NSMutableString *str = [NSMutableString string];
    [str appendString:@"@("];
    [str appendString:sourceString];
    [str appendString:@")"];
    return str;
}

/**
 合并数组里面的同类项

 @param parms 合并同类项
 @return 合并同类项
 */
+ (NSDictionary *)mergeParms:(NSArray <SHParmsModel *>*)parms urls:(NSArray *)urls {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (int i = 0; i < urls.count; i++) {
        [dict setObject:[NSMutableArray array] forKey:urls[i]];
    }

    for (int i = 0; i < parms.count; i++) {
        SHParmsModel * parm = parms[i];
        NSMutableArray *parmArr = dict[parm.netUrl];
        [parmArr addObject:parm];
        [dict setObject:parmArr forKey:parm.netUrl];
    }

    return dict;
}
/*只接受",@[@"NSString",@"NSInteger",@"float",@"double",@"BOOL",@"NSDate"];*/
+ (NSString *)parmType:(NSString *)type {
    NSString *tem = [type stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    NSMutableString *muStr = [NSMutableString string];
    if ([SHTransform stringIsNeedStar:tem]) {
        [muStr appendFormat:@"(%@ *)",tem];
    }else{
        if (tem.length>0) {
            [muStr appendFormat:@"(%@)",tem];
        }
    }
    return muStr;
}

/***数组去重*/
+ (NSArray *)removeRepeat:(NSArray *)reportArray {
    NSMutableArray *categoryArray = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < [reportArray count]; i++){
        if ([categoryArray containsObject:[reportArray objectAtIndex:i]] == NO){
            [categoryArray addObject:[reportArray objectAtIndex:i]];
        }
    }
    return categoryArray;
}

/**
 添加标注的body

 @return return value description
 */
+ (NSString *)addMarkBodyName:(NSString *)name markName:(NSString *)markName{
    NSMutableString *bodyString = [NSMutableString string];
    [bodyString appendString:@"@param  "];
    [bodyString appendString:name];
    [bodyString appendString:@" "];
    [bodyString appendString:markName];
    [bodyString appendString:@"\n"];
    return bodyString;
}

/**
 添加标注的头

 @return return value description
 */
+ (NSString *)addMarkHeader{
    NSMutableString *headerString = [NSMutableString string];
    [headerString appendString:@"/**\n"];
    [headerString appendString:@"<#Description"];
    [headerString appendString:@"#>\n"];
    return headerString;
}

/**
 添加标注的头

 @return return value description
 */
+ (NSString *)addMarkHeaderModel:(SHParmsModel *)model{
    NSMutableString *headerString = [NSMutableString string];
    [headerString appendString:@"/**\n"];
    [headerString appendString:model.requestHeaderNoteName];
    [headerString appendString:@"\n"];
    return headerString;
}

+ (NSString *)addMarkFooter {
    NSMutableString *footerString = [NSMutableString string];
    [footerString appendString:@"\n*/\n"];
    return footerString;
}

/**
 给URL添加备注信息

 @param urlMarkString urlMarkString description
 @return return value description
 */
+ (NSString *)addUrlMark:(NSString *)urlMarkString {
    NSMutableString *parmsString = [NSMutableString string];
    [parmsString appendString:@"/*"];
    [parmsString appendFormat:@"<#备注名称#"];
    [parmsString appendString:@">*/\n"];
    return parmsString;
}
/**
 给URL添加备注信息

 @return return value description
 */
+ (NSString *)addUrlMarkFull:(NSString *)noteNameMarkString {
    NSMutableString *parmsString = [NSMutableString string];
    [parmsString appendString:@"/*"];
    [parmsString appendString:noteNameMarkString];
    [parmsString appendString:@"*/\n"];
    return parmsString;
}

/**
 拼接 [NSString stringWithFormat:@"%@",@"report/report"] 的格式

 @param defString 拼接样式出产字符串
 @return 返回相对应的字符串
 */
+ (NSString *)addDefppendString:(NSString *)defString {
    NSString *str1 = [defString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    NSString *str = [str1 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSMutableString *muString = [NSMutableString string];
    [muString appendString:@"[NSString stringWithFormat:@"];
    [muString appendString:@"\""];
    [muString appendString:@"\%"];
    [muString appendString:@"@"];
    [muString appendString:@"\","];
    [muString appendString:@"@"];
    [muString appendString:@"\""];
    [muString appendString:str];
    [muString appendString:@"\""];
    [muString appendString:@"]"];

    return muString;
}

/**
 拼接 [NSString stringWithFormat:@"%@%@",kBase'ClassNameUrl',@"report/report"] 的格式
kBase%@Url
 @param defString 拼接样式出产字符串
 @return 返回相对应的字符串
 */
+ (NSString *)addDef2ppendString:(NSString *)defString classN:(NSString *)classN{
    NSString *str1 = [defString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    NSString *str = [str1 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *str2 = [NSString stringWithFormat:@"kBase%@Url",classN];
    NSMutableString *muString = [NSMutableString string];
    [muString appendString:@"[NSString stringWithFormat:@"];
    [muString appendString:@"\""];
    [muString appendString:@"%@%@"];
    [muString appendString:@"\","];

    [muString appendString:str2];
    [muString appendString:@","];

    [muString appendString:@"@"];
    [muString appendString:@"\""];
    [muString appendString:str];
    [muString appendString:@"\""];
    [muString appendString:@"]"];

    return muString;
}

/**
 添加备注信息

 @param marksModels marksModels description
 @return return value description
 */
+ (NSString *)addMarkModels:(NSArray <SHParmsModel *>*)marksModels {
    NSMutableString *parmsString = [NSMutableString string];
    [parmsString appendString:[SHTransform addMarkHeaderModel:[marksModels firstObject]]];
    for (int i = 0; i < marksModels.count; i++) {
        SHParmsModel *parmsModel = marksModels[i];
        [parmsString appendString:[SHTransform addMarkBodyName:parmsModel.netParameterName markName:parmsModel.netNoteName]];
    }
    [parmsString appendString:[SHTransform addMarkFooter]];
    return [parmsString sh_lowercaseString];
}
/**
  添加备注信息

 @param marks marks description
 @return return value description
 */
+ (NSString *)addMarks:(NSArray <NSString *>*)marks {
    NSMutableString *parmsString = [NSMutableString string];
    [parmsString appendString:[SHTransform addMarkHeader]];
    for (int i = 0; i < marks.count; i++) {
        [SHTransform addMark:marks[i]];
    }
    [parmsString appendString:[SHTransform addMarkFooter]];
    return parmsString;
}

/**
 添加备注 -  添加一行备注
 @param markString 需要添加的信息
 @return 备注信息
 */
+ (NSString *)addMark:(NSString *)markString {
    NSMutableString *parmsString = [NSMutableString string];
    [parmsString appendString:[SHTransform addMarkHeader]];
    [parmsString appendString:[SHTransform addMarkBodyName:markString markName:@""]];
    [parmsString appendString:[SHTransform addMarkFooter]];
    return parmsString;
}


+ (NSString *)addMarkModel:(SHParmsModel *)parmsModel {
    NSMutableString *parmsString = [NSMutableString string];
    [parmsString appendString:[SHTransform addMarkHeader]];
    [parmsString appendString:[SHTransform addMarkBodyName:parmsModel.netParameterName markName:parmsModel.netNoteName]];
    [parmsString appendString:[SHTransform addMarkFooter]];
    return parmsString;
}

+ (NSString *)urlHeaderBeginclassName:(NSString *)className {

    NSMutableString *muString = [NSMutableString string];
    [muString appendString:@"#ifndef "];
    [muString appendFormat:@"%@URL_h\n",className];
    [muString appendString:@"#define "];
    [muString appendFormat:@"%@URL_h\n",className];
    return [NSString stringWithString:muString];
}

/**
 Description

 @return <#return value description#>
 */
+ (NSString *)urlFooterEndclassName:(NSString *)className {

    NSMutableString *muString = [NSMutableString string];
    [muString appendString:@"#endif "];
    [muString appendFormat:@"/* %@URL_h */\n",className];
    return [NSString stringWithString:muString];
}

+ (BOOL)stringIsNeedStar:(NSString *)string {
    NSArray *array = @[@"NSString",@"NSArray"];
    for (int i = 0; i < array.count; i++) {
        if ([string isEqualToString:[array objectAtIndex:i]]) {
            return YES;
            break;
        }
    }
    return NO;
}

+ (NSString *)netTypeNameFrom:(NSString *)type {

    if ([[type lowercaseString] isEqualToString:@"int"]) {
        return @"NSInteger";
    }
    if ([[type lowercaseString] isEqualToString:@"integer"]) {
        return @"NSInteger";
    }
    if ([[type lowercaseString] isEqualToString:@"string"]) {
        return @"NSString";
    }
    if ([[type lowercaseString] hasPrefix:@"list"]) {
        return @"NSArray";
    }
    return type;
}

@end
