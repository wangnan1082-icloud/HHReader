//
//  IPTool.h
//  WifiUploadFile
//
//  Created by 王楠 on 2018/5/23.
//  Copyright © 2018年 王楠. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPTool : NSObject

/// 获取ip地址
+ (NSString *)deviceIPAdress;

/// 获取设备当前网络IP地址
+ (NSString *)getIPAddress:(BOOL)preferIPv4;
@end
