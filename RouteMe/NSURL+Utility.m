

#import "NSURL+Utility.h"
#import <objc/runtime.h>

@implementation NSURL (Utility)

@dynamic isGB18030;

- (BOOL)isGB18030Encoded {
    NSNumber *n = objc_getAssociatedObject(self, @selector(isGB18030));
    if (n == nil) {
        return NO;
    }
    return [n boolValue];
}

- (void)setIsGB18030Encoded:(BOOL) isGB18030{
    if (isGB18030) {
        objc_setAssociatedObject(self, @selector(isGB18030), [NSNumber numberWithInt:1], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        objc_setAssociatedObject(self, @selector(isGB18030), [NSNumber numberWithInt:0], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
- (NSDictionary *)params {
    if(!self.query) {
        return nil;
    }
    
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    NSArray *keyValuePairs = [self.query componentsSeparatedByString:@"&"];
    for(id kv in keyValuePairs) {
        NSArray *kvPair = [kv componentsSeparatedByString:@"="];
        if(kvPair.count > 1)
        {
            NSString *key = [kvPair objectAtIndex:0];
            NSString *value = [kvPair objectAtIndex:1];
            CFStringRef s1, s2;
            s1 = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                    (CFStringRef)(value),
                                                                    CFSTR(""),
                                                                    kCFStringEncodingUTF8);
            if (!s1) {
                s2 = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                    (CFStringRef)(value),
                                                                    CFSTR(""),
                                                                    kCFStringEncodingGB_18030_2000);
                
            }
 
            if (!s1 && !s2) {
                continue;
            }
 
            if (s1) {
                [ret setValue:(__bridge NSString*)(s1) forKey:key];
                CFRelease(s1);
            } else {
                [self setIsGB18030Encoded:YES];
                [ret setValue:(__bridge NSString*)(s2) forKey:key];
                CFRelease(s2);
            }
        }
    }
    
    return ret;
}

@end
