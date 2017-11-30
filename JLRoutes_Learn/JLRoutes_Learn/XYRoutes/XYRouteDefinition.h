//
//  XYRouteDefinition.h
//  JLRoutes_Learn
//
//  Created by lixuanyan on 2017/11/29.
//  Copyright © 2017年 lixuanyan. All rights reserved.
//  定义
#import <Foundation/Foundation.h>

#import "XYRouteResponse.h"

#import "XYRouteRequest.h"

@interface XYRouteDefinition : NSObject

/**
 URL方案，此路线适用，或JLRoutesGlobalRoutesScheme如果全球。
 */
@property (nonatomic,copy,readonly) NSString *scheme;

/**
 路线模式
 */
@property (nonatomic,copy,readonly) NSString *pattern;

/**
 此路由模式的优先级。
 */
@property (nonatomic,assign,readonly) NSUInteger priority;

/**
 找到匹配时调用的处理程序块。
 */
@property (nonatomic,copy,readonly) BOOL (^handleBlock)(NSDictionary *parameters);

/**
 创建一个新的路由定义。创造出来的定义可以直接添加到jlroutes实例。
 
 这是指定的初始化器。
 
 @param scheme URL方案这条航线申请，或jlroutesglobalroutesscheme如果全球。
 @param pattern 全路由模式（“/福/：酒吧”）
 @param priority “优先级的路由优先级，或0如果默认。
 @param handlerBlock 处理程序块时要调用成功找到匹配。
 */
- (instancetype)initWithScheme:(NSString *)scheme pattern:(NSString *)pattern priority:(NSInteger)priority handleBlock:(BOOL(^)(NSDictionary *parameters))handlerBlock;

/**
 创建并返回一个用于提供JLRRouteRequest JLRRouteResponse。响应指定是否存在匹配项。

 @param request 的JLRRouteRequest创建一个响应。
 @param decodePlusSymbols 全局加符号译码选项值。
 @return 一个JLRRouteResponse实例表示尝试匹配请求这个路径定义的结果。
 */
- (XYRouteResponse *)routeResponseForRequest:(XYRouteRequest *)request decodePlusSymbols:(BOOL)decodePlusSymbols;

/**
 handlerBlock与给定的参数调用

 @param parameters 参数传递给handlerblock。
 @return 通过调用handlerblock返回的值（如果它被认为是处理和没有如果没有）。
 */
- (BOOL)callHandlerBlockWithParameters:(NSDictionary *)parameters;

@end
