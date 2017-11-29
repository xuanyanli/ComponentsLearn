//
//  XYRouteRequest.m
//  JLRoutes_Learn
//
//  Created by lixuanyan on 2017/11/29.
//  Copyright © 2017年 lixuanyan. All rights reserved.
//  请求

/*
 *  https://johony:p4ssword@www.example.com:443/script.ext;param=value?query=value#ref
 *
 *  scheme:             https
 *  user:               johony
 *  password:           p4ssword
 *  host:               www.example.com
 *  port:               443
 *  path:               script
 *  pathExtension:      .ext
 *  parameterString:    param=value
 *  query:              query=value
 *  fragment:           ref
 */

#import "XYRouteRequest.h"

@interface XYRouteRequest()

/**
 路由的URL地址
 */
@property (nonatomic,strong) NSURL *URL;

/**
 路由的请求路径组件
 */
@property (nonatomic,strong) NSArray *pathComponents;

/**
 路由的请求参数
 */
@property (nonatomic,strong) NSDictionary *queryParams;

@end

@implementation XYRouteRequest

/**
 路由请求接口
 
 @param URL URL地址
 @param alwaysTreatsHostAsPathComponent 是否把主机当作路径组件
 @return self
 */
- (instancetype)initWithURL:(NSURL *)URL  alwaysTreatsHostAsPathComponent:(BOOL)alwaysTreatsHostAsPathComponent
{
    self = [super init];
    if (self)
    {
        self.URL = URL;
        
        
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p> - URL:%@",NSStringFromClass([self class]),self,[self.URL absoluteString]];
}

@end
