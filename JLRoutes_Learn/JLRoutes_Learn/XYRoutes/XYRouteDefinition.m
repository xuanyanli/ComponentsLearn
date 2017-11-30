//
//  XYRouteDefinition.m
//  JLRoutes_Learn
//
//  Created by lixuanyan on 2017/11/29.
//  Copyright © 2017年 lixuanyan. All rights reserved.
// 定义

#import "XYRouteDefinition.h"

#import "XYParsingUtilites.h"

#import "XYRoutes.h"

/**
 代表注册路由模型对象，包括URL方案，路由模式，并优先。
 这个类可以继承的压倒一切的routeresponseforrequest自定义路径解析行为：decodeplussymbols：。
 - callhandlerblockwithparameters也可以修改自定义的参数传递给handlerblock。
 */

@interface XYRouteDefinition()

@property (nonatomic, copy) NSString *pattern;
@property (nonatomic, copy) NSString *scheme;
@property (nonatomic, assign) NSUInteger priority;
@property (nonatomic, copy) BOOL (^handlerBlock)(NSDictionary *parameters);

@property (nonatomic, strong) NSArray *patternComponents;

@end

@implementation XYRouteDefinition

#pragma mark-  创建一个新的路由定义。创造出来的定义可以直接添加到jlroutes实例。
- (instancetype)initWithScheme:(NSString *)scheme pattern:(NSString *)pattern priority:(NSInteger)priority handleBlock:(BOOL(^)(NSDictionary *parameters))handlerBlock
{
    self = [super init];
    if (self)
    {
        self.scheme = scheme;
        self.pattern = pattern;
        self.priority = priority;
        self.handlerBlock = handlerBlock;
        
        if ([pattern characterAtIndex:0] == '/')
        {
            pattern = [pattern substringFromIndex:1];
        }
        
        self.patternComponents = [pattern componentsSeparatedByString:@"/"];
    }
    
    return self;
}

#pragma mark-  创建并返回一个用于提供JLRRouteRequest JLRRouteResponse。响应指定是否存在匹配项。
- (XYRouteResponse *)routeResponseForRequest:(XYRouteRequest *)request decodePlusSymbols:(BOOL)decodePlusSymbols
{
    BOOL patternContainsWildcard = [self.patternComponents containsObject:@"*"];
    
    if (request.pathComponents.count != self.patternComponents.count && !patternContainsWildcard)
    {  // definitely not a match, nothing left to do
        return [XYRouteResponse invalidMatchResponse];
    }
    
    XYRouteResponse *response = [XYRouteResponse invalidMatchResponse];
    NSMutableDictionary *routeParams = [NSMutableDictionary dictionary];
    BOOL isMatch = YES;
    NSUInteger index = 0;
    
    for (NSString *patternComponent in self.patternComponents)
    {
        NSString *URLComponent = nil;
        
        if (index < request.pathComponents.count)
        {
            URLComponent  = request.pathComponents[index];
        }else if ([patternComponent isEqualToString:@"*"])
        {
            URLComponent = [request.pathComponents lastObject];
        }
        
        if ([patternComponent hasPrefix:@":"])
        {
            NSString *variableName = [self variableNameForValue:patternComponent];
            NSString *variableValue = [self variableNameForValue:URLComponent];
             routeParams[variableName] = variableValue;
        }else if ([patternComponent isEqualToString:@"*"]) {
            // match wildcards
            NSUInteger minRequiredParams = index;
            if (request.pathComponents.count >= minRequiredParams) {
                // match: /a/b/c/* has to be matched by at least /a/b/c
                routeParams[XYRouteWildcardComponentsKey] = [request.pathComponents subarrayWithRange:NSMakeRange(index, request.pathComponents.count - index)];
                isMatch = YES;
            } else {
                // not a match: /a/b/c/* cannot be matched by URL /a/b/
                isMatch = NO;
            }
            break;
        } else if (![patternComponent isEqualToString:URLComponent]) {
            // break if this is a static component and it isn't a match
            isMatch = NO;
            break;
        }
        index++;
    }
    
    if (isMatch) {
        // if it's a match, set up the param dictionary and create a valid match response
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params addEntriesFromDictionary:[XYParsingUtilites queryParams:request.queryParams decodePlusSymbols:decodePlusSymbols]];
        [params addEntriesFromDictionary:routeParams];
        [params addEntriesFromDictionary:[self baseMatchParametersForRequest:request]];
        response = [XYRouteResponse validMatchResponseWithParameters:[params copy]];
    }
    
    return response;
}

- (NSString *)variableNameForValue:(NSString *)value
{
    NSString *name = [value substringFromIndex:1];
    if (name.length > 1 && [name characterAtIndex:name.length - 1] == '#')
    {
        name = [name substringFromIndex:name.length - 1];
    }
    
    return name;
}

- (NSString *)variableValueForValue:(NSString *)value decodePlusSymbols:(BOOL)decodePlusSymbols
{
    NSString *var = [value stringByRemovingPercentEncoding];
    if (var.length > 1 && [var characterAtIndex:var.length - 1] == '#')
    {
        var = [var substringFromIndex:var.length - 1];
    }
    
    var = [XYParsingUtilites variableValueFrom:var decodePlusSymbols:decodePlusSymbols];
    
    return var;
}

- (NSDictionary *)baseMatchParametersForRequest:(XYRouteRequest *)request
{
    return @{XYRoutePatternKey: self.pattern ?: [NSNull null], XYRouteURLKey: request.URL ?: [NSNull null], XYRouteSchemeKey: self.scheme ?: [NSNull null]};
}

#pragma mark-  handlerBlock与给定的参数调用
- (BOOL)callHandlerBlockWithParameters:(NSDictionary *)parameters
{
    if (self.handlerBlock == nil) {
        return YES;
    }
    
    return self.handlerBlock(parameters);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p> - %@ (priority: %@)", NSStringFromClass([self class]), self, self.pattern, @(self.priority)];
}

@end
