//
//  NSObject+RouteMe.m
//  Pods
//
//  Created by xujian on 15/12/5.
//
//

#import "RouteMe.h"
#import <objc/runtime.h>
#import "NSURL+Utility.h"

@implementation RouteMe
+ (instancetype)sharedRouteMe {
    static RouteMe *sharedRouteMe = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRouteMe = [[self alloc] init];
    });
    return sharedRouteMe;
}

- (void)loadConfig:(NSString*)filepath{
    NSError* error;
    NSData* data = [NSData dataWithContentsOfFile:filepath];
    _routeMap = [NSJSONSerialization
                          JSONObjectWithData:data //1
                          options:kNilOptions
                          error:&error];
}

- (UINavigationController *)navigationController{
    if (!_navigationController) {
        // @请注意，不能使用self.navigationController来操作，这个值可能为空。
        // 否则可能导致iOS 5下面出现问题。
        UIViewController *rootCtrl= (UIViewController *)[UIApplication sharedApplication].delegate.window.rootViewController;
        _navigationController = rootCtrl.navigationController;
        [_navigationController setNavigationBarHidden:NO];
    }
    
    return _navigationController;
}

- (void)routeTo:(NSURL *)targetUrl{
    [self routeTo:targetUrl withParams:nil completion:^(UIViewController *targetObj) {
        [self.navigationController pushViewController:targetObj animated:YES];
    }];
}

- (void)routeTo:(NSURL *)targetUrl withPresenter:(UIViewController*)presenter{
    [self routeTo:targetUrl withParams:nil completion:^(UIViewController *targetObj) {
        [presenter presentViewController:targetObj animated:YES completion:nil];
    }];
}

- (void)routeTo:(NSURL*)targetUrl withParams:(NSDictionary*)params completion:(RouteCompleteHandler)complete{
    NSString *scheme = targetUrl.scheme;
    if ([scheme isEqualToString:@"http"]
        || [scheme isEqualToString:@"https"]) {
        Class clazz = NSClassFromString(@"UIWebViewController");
        UIViewController *webview = [[clazz alloc]init];
        [webview setValue:targetUrl.absoluteString forKey:@"webUrl"];
        if (complete) {
            complete(webview);
        }
    } else if ([scheme isEqualToString:@"RouteMe"]) {
        NSString *path = targetUrl.path.lastPathComponent;
//        NSRange rg = [path rangeOfString:@"/" options:NSCaseInsensitiveSearch];
//        if (rg.location == 0 && rg.length>0) {
//            path = [path substringFromIndex:1];
//        }
        NSDictionary *config = self.routeMap[path];
        if (config) {
            Class objClazz = NSClassFromString(config[@"targetType"]);
            NSMutableDictionary *myparams = [NSMutableDictionary dictionaryWithDictionary:config[@"parameters"]];
            [myparams addEntriesFromDictionary:params];
            NSObject *targetObj = [[objClazz alloc] init];
            NSDictionary *queryDictionary = [targetUrl params];
            [myparams addEntriesFromDictionary:queryDictionary];
            [self easySetProperties:myparams forObject:targetObj];

            if ([targetObj isKindOfClass:[UIViewController class]]){
                if (complete) {
                    complete((UIViewController*)targetObj);
                }
            }
        }
    }else{
        //unsupported
    }
}

-(NSString*)object2Json:(id)jsonObj{
    NSError *writeError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObj options:NSJSONWritingPrettyPrinted error:&writeError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

-(id)json2Object:(NSString*)json{
    NSError *error;
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    id obj = [NSJSONSerialization
                                       JSONObjectWithData:data
                                       options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments
                                       error:&error];
    return obj;
    
}

- (void)easySetProperties:(NSDictionary *)query forObject:(id)object
{
    @try {
        
        for (NSString *key in query) {
            NSString *propertyKey = key;
            id propertyValue = query[key];
            
            if (propertyValue == nil)
            {
                continue;
            }
            
            objc_property_t attrProp = class_getProperty([object class], [key UTF8String]);
            
            if (attrProp) {
                NSString *attributesString = [NSString stringWithUTF8String:property_getAttributes(attrProp)];
                NSString *propertyType = [attributesString substringWithRange:NSMakeRange(1, 1)];
                if ([@"csiB" containsString:propertyType]) {
                    [object setValue:[NSNumber numberWithInteger:[propertyValue integerValue]] forKey:propertyKey];
                } else if ([@"lqCSILQ" containsString:propertyType]) {
                    [object setValue:[NSNumber numberWithLongLong:[propertyValue longLongValue]] forKey:propertyKey];
                } else if ([@"d" containsString:propertyType]) {
                    [object setValue:[NSNumber numberWithDouble:[propertyValue doubleValue]] forKey:propertyKey];
                } else if ([@"f" containsString:propertyType]) {
                    [object setValue:[NSNumber numberWithFloat:[propertyValue floatValue]] forKey:propertyKey];
                } else if ([attributesString containsString:@"NSString"]) {
                    [object setValue:propertyValue forKey:propertyKey];
                } else if ([attributesString containsString:@"NSMutableString"]) {
                    [object setValue:[NSMutableString stringWithString:propertyValue] forKey:propertyKey];
                } else if ([attributesString containsString:@"NSArray"]) {
                    [object setValue:[self json2Object:propertyValue] forKey:propertyKey];
                } else if ([attributesString containsString:@"NSMutableArray"]) {
                    [object setValue:[NSMutableArray arrayWithArray:[self json2Object:propertyValue]] forKey:propertyKey];
                } else if ([attributesString containsString:@"NSDictionary"]) {
                    [object setValue:[self json2Object:propertyValue] forKey:propertyKey];
                } else if ([attributesString containsString:@"NSMutableDictionary"]) {
                    [object setValue:[NSMutableDictionary dictionaryWithDictionary:[self json2Object:propertyValue]] forKey:propertyKey];
                }
            }
        }
        
    }
    @catch (NSException *exception) {
        
    }
}
@end
