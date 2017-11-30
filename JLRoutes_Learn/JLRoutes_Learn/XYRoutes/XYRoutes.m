//
//  XYRoutes.m
//  JLRoutes_Learn
//
//  Created by lixuanyan on 2017/11/29.
//  Copyright © 2017年 lixuanyan. All rights reserved.
//

#import "XYRoutes.h"

#import "XYRouteDefinition.h"

#import "XYParsingUtilites.h"

#import "XYRouteResponse.h"

NSString *const XYRoutePatternKey = @"XYRoutePattern";
NSString *const XYRouteURLKey = @"XYRouteURL";
NSString *const XYRouteSchemeKey = @"XYRouteScheme";
NSString *const XYRouteWildcardComponentsKey = @"XYRouteWildcardComponents";
NSString *const XYRoutesGlobalRoutesScheme = @"XYRoutesGlobalRoutesScheme";

static NSMutableDictionary *routeControllersMap = nil;

// global options
static BOOL verboseLoggingEnabled = NO;
static BOOL shouldDecodePlusSymbols = YES;
static BOOL alwaysTreatsHostAsPathComponent = NO;

@interface XYRoutes ()

@property (nonatomic, strong) NSMutableArray *mutableRoutes;
@property (nonatomic, strong) NSString *scheme;

@end

@implementation XYRoutes

- (instancetype)init
{
    if ((self = [super init])) {
        self.mutableRoutes = [NSMutableArray array];
    }
    return self;
}

- (NSString *)description
{
    return [self.mutableRoutes description];
}

+ (NSDictionary <NSString *, NSArray <XYRouteDefinition *> *> *)allRoutes;
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    for (NSString *namespace in [routeControllersMap copy]) {
        XYRoutes *routesController = routeControllersMap[namespace];
        dictionary[namespace] = [routesController.mutableRoutes copy];
    }
    
    return [dictionary copy];
}


#pragma mark - Routing Schemes

+ (instancetype)globalRoutes
{
    return [self routesForScheme:XYRoutesGlobalRoutesScheme];
}

+ (instancetype)routesForScheme:(NSString *)scheme
{
    XYRoutes *routesController = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        routeControllersMap = [[NSMutableDictionary alloc] init];
    });
    
    if (!routeControllersMap[scheme]) {
        routesController = [[self alloc] init];
        routesController.scheme = scheme;
        routeControllersMap[scheme] = routesController;
    }
    
    routesController = routeControllersMap[scheme];
    
    return routesController;
}

+ (void)unregisterRouteScheme:(NSString *)scheme
{
    [routeControllersMap removeObjectForKey:scheme];
}

+ (void)unregisterAllRouteSchemes
{
    [routeControllersMap removeAllObjects];
}


#pragma mark - Registering Routes

- (void)addRoute:(XYRouteDefinition *)routeDefinition
{
    [self _registerRoute:routeDefinition];
}

- (void)addRoute:(NSString *)routePattern handler:(BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlock
{
    [self addRoute:routePattern priority:0 handler:handlerBlock];
}

- (void)addRoutes:(NSArray<NSString *> *)routePatterns handler:(BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlock
{
    for (NSString *routePattern in routePatterns) {
        [self addRoute:routePattern handler:handlerBlock];
    }
}

- (void)addRoute:(NSString *)routePattern priority:(NSUInteger)priority handler:(BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlock
{
    NSArray <NSString *> *optionalRoutePatterns = [XYParsingUtilites  expandOptionalRoutePatternsForPattern:routePattern];
//    XYRouteDefinition *route = [[XYRouteDefinition alloc] initWithScheme:self.scheme pattern:routePattern priority:priority handlerBlock:handlerBlock];
    
     XYRouteDefinition *route = [[XYRouteDefinition alloc] initWithScheme:self.scheme pattern:routePattern priority:priority handleBlock:handlerBlock];
    
    if (optionalRoutePatterns.count > 0) {
        // there are optional params, parse and add them
        for (NSString *pattern in optionalRoutePatterns) {
            [self _verboseLog:@"Automatically created optional route: %@,pattern:%@", route,pattern];
            XYRouteDefinition *optionalRoute = [[XYRouteDefinition alloc] initWithScheme:self.scheme pattern:routePattern priority:priority handleBlock:handlerBlock];
            [self _registerRoute:optionalRoute];
        }
        return;
    }
    
    [self _registerRoute:route];
}

- (void)removeRoute:(NSString *)routePattern
{
    if (![routePattern hasPrefix:@"/"]) {
        routePattern = [NSString stringWithFormat:@"/%@", routePattern];
    }
    
    NSInteger routeIndex = NSNotFound;
    NSInteger index = 0;
    
    for (XYRouteDefinition *route in [self.mutableRoutes copy]) {
        if ([route.pattern isEqualToString:routePattern]) {
            routeIndex = index;
            break;
        }
        index++;
    }
    
    if (routeIndex != NSNotFound) {
        [self.mutableRoutes removeObjectAtIndex:(NSUInteger)routeIndex];
    }
}

- (void)removeAllRoutes
{
    [self.mutableRoutes removeAllObjects];
}

- (void)setObject:(id)handlerBlock forKeyedSubscript:(NSString *)routePatten
{
    [self addRoute:routePatten handler:handlerBlock];
}

- (NSArray <XYRouteDefinition *> *)routes;
{
    return [self.mutableRoutes copy];
}

#pragma mark - Routing URLs

+ (BOOL)canRouteURL:(NSURL *)URL
{
    return [[self _routesControllerForURL:URL] canRouteURL:URL];
}

- (BOOL)canRouteURL:(NSURL *)URL
{
    return [self _routeURL:URL withParameters:nil executeRouteBlock:NO];
}

+ (BOOL)routeURL:(NSURL *)URL
{
    return [[self _routesControllerForURL:URL] routeURL:URL];
}

- (BOOL)routeURL:(NSURL *)URL
{
    return [self _routeURL:URL withParameters:nil executeRouteBlock:YES];
}

+ (BOOL)routeURL:(NSURL *)URL withParameters:(NSDictionary *)parameters
{
    return [[self _routesControllerForURL:URL] routeURL:URL withParameters:parameters];
}

- (BOOL)routeURL:(NSURL *)URL withParameters:(NSDictionary *)parameters
{
    return [self _routeURL:URL withParameters:parameters executeRouteBlock:YES];
}


#pragma mark - Private

+ (instancetype)_routesControllerForURL:(NSURL *)URL
{
    if (URL == nil) {
        return nil;
    }
    
    return routeControllersMap[URL.scheme] ?: [XYRoutes globalRoutes];
}

- (void)_registerRoute:(XYRouteDefinition *)route
{
    if (route.priority == 0 || self.mutableRoutes.count == 0) {
        [self.mutableRoutes addObject:route];
    } else {
        NSUInteger index = 0;
        BOOL addedRoute = NO;
        
        // search through existing routes looking for a lower priority route than this one
        for (XYRouteDefinition *existingRoute in [self.mutableRoutes copy]) {
            if (existingRoute.priority < route.priority) {
                // if found, add the route after it
                [self.mutableRoutes insertObject:route atIndex:index];
                addedRoute = YES;
                break;
            }
            index++;
        }
        
        // if we weren't able to find a lower priority route, this is the new lowest priority route (or same priority as self.routes.lastObject) and should just be added
        if (!addedRoute) {
            [self.mutableRoutes addObject:route];
        }
    }
}

- (BOOL)_routeURL:(NSURL *)URL withParameters:(NSDictionary *)parameters executeRouteBlock:(BOOL)executeRouteBlock
{
    if (!URL) {
        return NO;
    }
    
    [self _verboseLog:@"Trying to route URL %@", URL];
    
    BOOL didRoute = NO;
    XYRouteRequest *request = [[XYRouteRequest alloc] initWithURL:URL alwaysTreatsHostAsPathComponent:alwaysTreatsHostAsPathComponent];
    
    for (XYRouteDefinition *route in [self.mutableRoutes copy]) {
        // check each route for a matching response
        XYRouteResponse *response = [route routeResponseForRequest:request decodePlusSymbols:shouldDecodePlusSymbols];
        if (!response.isMatch) {
            continue;
        }
        
        [self _verboseLog:@"Successfully matched %@", route];
        
        if (!executeRouteBlock) {
            // if we shouldn't execute but it was a match, we're done now
            return YES;
        }
        
        // configure the final parameters
        NSMutableDictionary *finalParameters = [NSMutableDictionary dictionary];
        [finalParameters addEntriesFromDictionary:response.parameters];
        [finalParameters addEntriesFromDictionary:parameters];
        [self _verboseLog:@"Final parameters are %@", finalParameters];
        
        didRoute = [route callHandlerBlockWithParameters:finalParameters];
        
        if (didRoute) {
            // if it was routed successfully, we're done
            break;
        }
    }
    
    if (!didRoute) {
        [self _verboseLog:@"Could not find a matching route"];
    }
    
    // if we couldn't find a match and this routes controller specifies to fallback and its also not the global routes controller, then...
    if (!didRoute && self.shouldFallbackToGlobalRoutes && ![self _isGlobalRoutesController]) {
        [self _verboseLog:@"Falling back to global routes..."];
        didRoute = [[XYRoutes globalRoutes] _routeURL:URL withParameters:parameters executeRouteBlock:executeRouteBlock];
    }
    
    // if, after everything, we did not route anything and we have an unmatched URL handler, then call it
    if (!didRoute && executeRouteBlock && self.unmatchedURLHandler) {
        [self _verboseLog:@"Falling back to the unmatched URL handler"];
        self.unmatchedURLHandler(self, URL, parameters);
    }
    
    return didRoute;
}

- (BOOL)_isGlobalRoutesController
{
    return [self.scheme isEqualToString:XYRoutesGlobalRoutesScheme];
}

- (void)_verboseLog:(NSString *)format, ...
{
    if (!verboseLoggingEnabled || format.length == 0) {
        return;
    }
    
    va_list argsList;
    va_start(argsList, format);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
    NSString *formattedLogMessage = [[NSString alloc] initWithFormat:format arguments:argsList];
#pragma clang diagnostic pop
    
    va_end(argsList);
    NSLog(@"[JLRoutes]: %@", formattedLogMessage);
}

@end


#pragma mark - Global Options

@implementation XYRoutes (GlobalOptions)

+ (void)setVerboseLoggingEnabled:(BOOL)loggingEnabled
{
    verboseLoggingEnabled = loggingEnabled;
}

+ (BOOL)isVerboseLoggingEnabled
{
    return verboseLoggingEnabled;
}

+ (void)setShouldDecodePlusSymbols:(BOOL)shouldDecode
{
    shouldDecodePlusSymbols = shouldDecode;
}

+ (BOOL)shouldDecodePlusSymbols
{
    return shouldDecodePlusSymbols;
}

+ (void)setAlwaysTreatsHostAsPathComponent:(BOOL)treatsHostAsPathComponent
{
    alwaysTreatsHostAsPathComponent = treatsHostAsPathComponent;
}

+ (BOOL)alwaysTreatsHostAsPathComponent
{
    return alwaysTreatsHostAsPathComponent;
}

@end


#pragma mark - Deprecated

// deprecated
NSString *const kJLRoutePatternKey = @"JLRoutePattern";
NSString *const kJLRouteURLKey = @"JLRouteURL";
NSString *const kJLRouteSchemeKey = @"JLRouteScheme";
NSString *const kJLRouteWildcardComponentsKey = @"JLRouteWildcardComponents";
NSString *const kJLRoutesGlobalRoutesScheme = @"JLRoutesGlobalRoutesScheme";

NSString *const kJLRouteNamespaceKey = @"JLRouteScheme"; // deprecated
NSString *const kJLRoutesGlobalNamespaceKey = @"JLRoutesGlobalRoutesScheme"; // deprecated

@implementation XYRoutes (Deprecated)

+ (void)addRoute:(NSString *)routePattern handler:(BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlock
{
    [[self globalRoutes] addRoute:routePattern handler:handlerBlock];
}

+ (void)addRoute:(NSString *)routePattern priority:(NSUInteger)priority handler:(BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlock
{
    [[self globalRoutes] addRoute:routePattern priority:priority handler:handlerBlock];
}

+ (void)addRoutes:(NSArray<NSString *> *)routePatterns handler:(BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlock
{
    [[self globalRoutes] addRoutes:routePatterns handler:handlerBlock];
}

+ (void)removeRoute:(NSString *)routePattern
{
    [[self globalRoutes] removeRoute:routePattern];
}

+ (void)removeAllRoutes
{
    [[self globalRoutes] removeAllRoutes];
}

+ (BOOL)canRouteURL:(NSURL *)URL withParameters:(NSDictionary *)parameters
{
    return [[self globalRoutes] canRouteURL:URL];
}

- (BOOL)canRouteURL:(NSURL *)URL withParameters:(NSDictionary *)parameters
{
    return [self canRouteURL:URL];
}

@end
