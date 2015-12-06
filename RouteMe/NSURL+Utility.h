//
//  NSURL+Utility.h

#import <Foundation/Foundation.h>

#define addScheme(oUrl)  [oUrl URLByAddingScheme]

@interface NSURL (Utility)

@property (nonatomic, strong) NSNumber* isGB18030;
- (BOOL)isGB18030Encoded;
- (void)setIsGB18030:(NSNumber *)isGB18030;
- (NSDictionary *)params;

@end
