//
//  UIView+Responder.h
//  Pods
//
//  Created by xujian on 15/12/5.
//
//

#import <UIKit/UIKit.h>

@interface UIView (FindResponder)
- (UIViewController *) firstAvailableUIViewController;
- (id)traverseResponderChainForUIViewController;
@end
