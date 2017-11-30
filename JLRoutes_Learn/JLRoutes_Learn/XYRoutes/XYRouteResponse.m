//
//  XYRouteResponse.m
//  JLRoutes_Learn
//
//  Created by lixuanyan on 2017/11/29.
//  Copyright © 2017年 lixuanyan. All rights reserved.
//  响应

#import "XYRouteResponse.h"

@interface XYRouteResponse()

@property (nonatomic,assign) BOOL match;
@property (nonatomic,strong) NSDictionary *parameters;

@end

@implementation XYRouteResponse

/**
 创建无效匹配响应
 */
+ (instancetype) invalidMatchResponse
{
    XYRouteResponse *response = [[[self class]alloc]init];
    response.match = NO;
    
    return response;
}

/**
 用给定的参数创建有效的匹配响应。
 */
+ (instancetype)validMatchResponseWithParameters:(NSDictionary *)parameters
{
    XYRouteResponse *response = [[[self class]alloc]init];
    response.match = YES;
    response.parameters = parameters;
    
    return response;
}

- (NSString *)description
{
      return [NSString stringWithFormat:@"<%@ %p> - match: %@, params: %@", NSStringFromClass([self class]), self, (self.match ? @"YES" : @"NO"), self.parameters];
}

@end
