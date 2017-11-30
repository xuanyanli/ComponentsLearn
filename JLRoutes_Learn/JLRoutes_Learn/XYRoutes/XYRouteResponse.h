//
//  XYRouteResponse.h
//  JLRoutes_Learn
//
//  Created by lixuanyan on 2017/11/29.
//  Copyright © 2017年 lixuanyan. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 JLRRouteResponse试图从路径jlrrouterequest响应。
 */
@interface XYRouteResponse : NSObject

/**
 指示响应是匹配还是不匹配。
 */
@property (nonatomic,assign,readonly,getter=isMatch) BOOL match;

/**
匹配参数（或无效响应的零）。
 */
@property (nonatomic,strong,readonly,nullable) NSDictionary *parameters;

/**
 创建无效匹配响应
 */
+ (instancetype _Nullable ) invalidMatchResponse;

/**
 用给定的参数创建有效的匹配响应。
 */
+ (instancetype _Nullable )validMatchResponseWithParameters:(NSDictionary *_Nullable)parameters;

@end
