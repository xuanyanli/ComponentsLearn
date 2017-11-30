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
        
        NSURLComponents *components = [NSURLComponents componentsWithString:[self.URL absoluteString]];
        
        if (components.host.length > 0 && (alwaysTreatsHostAsPathComponent || (![components.host isEqualToString:@"localhost"] && [components.host rangeOfString:@"."].location == NSNotFound)))
        {
             //将主机转换为“/”，以便将主机视为一个路径组件。
            NSString *host = [components.percentEncodedHost copy];
            components.host = @"/";
            components.percentEncodedPath = [host stringByAppendingPathComponent:(components.percentEncodedPath ? : @"")];
        }
        
        NSString *path = [components percentEncodedPath];
        
        //需要时处理碎片
        if (components.fragment != nil)
        {
            BOOL fragmentContainsQueryParams = NO;
            NSURLComponents *fragmentComponents = [NSURLComponents componentsWithString:components.percentEncodedFragment];
            
            if (fragmentComponents.query == nil && fragmentComponents.path != nil)
            {
                fragmentComponents.query = fragmentComponents.path;
            }
            
            if (fragmentComponents.queryItems.count > 0)
            {
                 // 如果确定该片段是唯一有效的查询参数和别的
                fragmentContainsQueryParams = fragmentComponents.queryItems.firstObject.value.length > 0;
            }
            
            if (fragmentContainsQueryParams)
            {
                //包括片段查询参数与标准的设定
                components.queryItems = [(components.queryItems ?:@[]) arrayByAddingObjectsFromArray:fragmentComponents.queryItems];
            }
            
            if (fragmentComponents.path != nil && (!fragmentContainsQueryParams || ![fragmentComponents.path isEqualToString:fragmentComponents.query]))
            {
                //将片段路径作为主路径的一部分处理片段
                path = [path stringByAppendingString:[NSString stringWithFormat:@"#%@",fragmentComponents.percentEncodedPath]];
            }
        }
        
         // 剥去前导斜杠，这样我们就不会有空的第一个路径组件。
        if (path.length > 0 && [path characterAtIndex:0] == '/')
        {
            path = [path substringFromIndex:1];
        }
        
        // 以同样的理由剥去拖尾斜杠
        if (path.length > 0 && [path characterAtIndex:path.length - 1] == '/')
        {
            path = [path substringFromIndex:path.length - 1];
        }
        
        // 拆分成路径组件
        self.pathComponents = [path componentsSeparatedByString:@"/"];
        
        //将查询项转换为字典
        NSArray <NSURLQueryItem *> *queryItems = [components queryItems] ?:@[];
        NSMutableDictionary *queryParams = [NSMutableDictionary dictionary];
        for (NSURLQueryItem *item in queryItems)
        {
            if (item.value == nil)
            {
                continue;
            }
            
            if (queryParams[item.name] == nil)
            {
                // 第一次看到这个名字的参数设置
                queryParams[item.name] = item.value;
            }else if ([queryParams[item.name] isKindOfClass:[NSArray class]])
            {
                // 已经是这些项目的一个数组，追加它
                NSArray *values = (NSArray *)(queryParams[item.name]);
                queryParams[item.name] = [values arrayByAddingObject:item.value];
            }else
            {
                //此键的现有非数组值，创建数组
                id existingValue = queryParams[item.name];
                queryParams[item.name] = @[existingValue,item.value];
            }
        }
        
        self.queryParams = [queryParams copy];
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p> - URL:%@",NSStringFromClass([self class]),self,[self.URL absoluteString]];
}

@end
