//
//  XYRoutes.h
//  JLRoutes_Learn
//
//  Created by lixuanyan on 2017/11/29.
//  Copyright © 2017年 lixuanyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XYRouteDefinition;

///匹配的路由模式，传递到处理程序参数中。
extern NSString *  _Nullable const XYRoutePatternKey;

/// 路由的原始URL在处理程序参数中传递。
extern NSString * _Nullable const XYRouteURLKey;

/// 匹配路由方案，传递到处理程序参数中。
extern NSString * _Nullable const XYRouteSchemeKey;

/// 匹配路由中的通配符组件（如果存在）传递到处理程序参数中。
extern NSString * _Nullable const XYRouteWildcardComponentsKey;

/// 全局路由名称空间。
extern NSString * _Nullable const XYRoutesGlobalRoutesScheme;


/**
 的XYRoutes类是主要的入口点进入XYRoutes框架。用于访问方案、管理路由和路由URL。
 */
@interface XYRoutes : NSObject

@property (nonatomic, assign) BOOL shouldFallbackToGlobalRoutes;

/// 所谓的任何时间routeurl回报方面shouldfallbacktoglobalroutes号。
@property (nonatomic, copy, nullable) void (^unmatchedURLHandler)(XYRoutes * _Nullable routes, NSURL *__nullable URL, NSDictionary<NSString *, id> *__nullable parameters);


///-------------------------------
/// @name Routing Schemes
///-------------------------------


/// 返回全局路由方案
+ (instancetype _Nullable )globalRoutes;

/// 返回给定方案的路由命名空间。
+ (instancetype _Nullable )routesForScheme:(NSString *_Nullable)scheme;

/// 注销和删除整个方案的命名空间
+ (void)unregisterRouteScheme:(NSString *_Nullable)scheme;

/// 注销所有路线
+ (void)unregisterAllRouteSchemes;


///-------------------------------
/// @name Managing Routes
///-------------------------------


/// 通过直接插入路由定义添加一条路由。这可能是一个类XYRouteDefinition提供定制的路由逻辑。
- (void)addRoute:(XYRouteDefinition *_Nullable)routeDefinition;

///注册一个默认的优先级routepattern（0）在接收方案中的命名空间。
- (void)addRoute:(NSString *_Nullable)routePattern handler:(BOOL (^__nullable)(NSDictionary<NSString *, id> * _Nullable parameters))handlerBlock;

/// 注册一个routepattern在全球方案命名空间与handlerblock时调用路由模式是通过URL匹配。
/// 块返回一个bool表示如果handlerblock实际上处理的路线或不。如果一块没有返回，XYRoutes将继续试图找到一个匹配的路由。
- (void)addRoute:(NSString *_Nullable)routePattern priority:(NSUInteger)priority handler:(BOOL (^__nullable)(NSDictionary<NSString *, id> * _Nullable parameters))handlerBlock;

/// 注册多个routepatterns一处理程序的默认优先级（0）在接收方案中的命名空间。
- (void)addRoutes:(NSArray<NSString *> *_Nullable)routePatterns handler:(BOOL (^__nullable)(NSDictionary<NSString *, id> * _Nullable parameters))handlerBlock;

/// 删除一个routepattern从接收方案中的命名空间。
- (void)removeRoute:(NSString *_Nullable)routePattern;

/// 从接收方案命名空间删除所有路由。
- (void)removeAllRoutes;

/// 注册一个默认的优先级routepattern（0）使用词典式操作。
- (void)setObject:(nullable id)handlerBlock forKeyedSubscript:(NSString *_Nullable)routePatten;

/// 返回接收方案名称空间中的所有已注册路由。
- (NSArray <XYRouteDefinition *> *_Nullable)routes;

/// 按计划键入的所有已注册路由
+ (NSDictionary <NSString *, NSArray <XYRouteDefinition *> *> *_Nullable)allRoutes;


/// 如果所提供的URL将成功匹配任何已注册路由，则返回“否”。
+ (BOOL)canRouteURL:(nullable NSURL *)URL;

/// 如果所提供的URL与当前方案的任何已注册路由成功匹配，则返回“否”。
- (BOOL)canRouteURL:(nullable NSURL *)URL;

/// 路线一个网址，要求匹配URL模式处理程序块直到返回YES。如果没有匹配的路由发现的unmatchedurlhandler将被称为（如果设置）。
+ (BOOL)routeURL:(nullable NSURL *)URL;

/// 在一个特定的方案中路由一个URL，为匹配URL的模式调用处理程序块，直到返回一个。如果没有匹配的路由发现的unmatchedurlhandler将被称为（如果设置）。
- (BOOL)routeURL:(nullable NSURL *)URL;

//在任何路由方案中路由URL，调用处理程序块（用于匹配URL的模式），直到返回yes。+ (BOOL)routeURL:(nullable NSURL *)URL withParameters:(nullable NSDictionary<NSString *, id> *)parameters;

/// Routes a URL in a specific scheme, calling handler blocks (for patterns that match URL) until one returns YES.
/// Additional parameters get passed through to the matched route block.
- (BOOL)routeURL:(nullable NSURL *)URL withParameters:(nullable NSDictionary<NSString *, id> *)parameters;

@end


// Global settings to use for parsing and routing.

@interface XYRoutes (GlobalOptions)

///----------------------------------
/// @name Configuring Global Options
///----------------------------------

/// Configures verbose logging. Defaults to NO.
+ (void)setVerboseLoggingEnabled:(BOOL)loggingEnabled;

/// Returns current verbose logging enabled state. Defaults to NO.
+ (BOOL)isVerboseLoggingEnabled;

/// Configures if '+' should be replaced with spaces in parsed values. Defaults to YES.
+ (void)setShouldDecodePlusSymbols:(BOOL)shouldDecode;

/// Returns if '+' should be replaced with spaces in parsed values. Defaults to YES.
+ (BOOL)shouldDecodePlusSymbols;

/// Configures if URL host is always considered to be a path component. Defaults to NO.
+ (void)setAlwaysTreatsHostAsPathComponent:(BOOL)treatsHostAsPathComponent;

/// Returns if URL host is always considered to be a path component. Defaults to NO.
+ (BOOL)alwaysTreatsHostAsPathComponent;


@end
