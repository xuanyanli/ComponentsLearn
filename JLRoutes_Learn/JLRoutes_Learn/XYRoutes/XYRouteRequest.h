//
//  XYRouteRequest.h
//  JLRoutes_Learn
//
//  Created by lixuanyan on 2017/11/29.
//  Copyright © 2017年 lixuanyan. All rights reserved.
//  请求

#import <Foundation/Foundation.h>

@interface XYRouteRequest : NSObject

/**
 路由的URL地址
 */
@property (nonatomic,strong,readonly) NSURL *URL;

/**
 路由的请求路径组件
 */
@property (nonatomic,strong,readonly) NSArray *pathComponents;

/**
 路由的请求参数
 */
@property (nonatomic,strong,readonly) NSDictionary *queryParams;

/**
 路由请求接口

 @param URL URL地址
 @param alwaysTreatsHostAsPathComponent 是否把主机当作路径组件
 @return self
 */
- (instancetype)initWithURL:(NSURL *)URL  alwaysTreatsHostAsPathComponent:(BOOL)alwaysTreatsHostAsPathComponent;

@end
