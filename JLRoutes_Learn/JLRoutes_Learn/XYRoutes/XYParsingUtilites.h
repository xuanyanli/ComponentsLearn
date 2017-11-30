//
//  XYParsingUtilites.h
//  JLRoutes_Learn
//
//  Created by lixuanyan on 2017/11/30.
//  Copyright © 2017年 lixuanyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XYParsingUtilites : NSObject

+ (NSString *)variableValueFrom:(NSString *)value decodePlusSymbols:(BOOL)decodePlusSymbols;

+ (NSDictionary *)queryParams:(NSDictionary *)queryParams decodePlusSymbols:(BOOL)decodePlusSymbols;

+ (NSArray <NSString *> *)expandOptionalRoutePatternsForPattern:(NSString *)routePattern;

@end
