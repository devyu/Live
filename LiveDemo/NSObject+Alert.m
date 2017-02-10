//
//  NSObject+Alert.m
//  LiveDemo
//
//  Created by mac on 2017/2/9.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "NSObject+Alert.h"
#import <UIKit/UIKit.h>

@implementation NSObject (Alert)

- (void)showAlert:(NSString *)message {
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([self isKindOfClass:[UIViewController class]] ||
        [self isKindOfClass:[UIView class]]) {
      [[[UIAlertView alloc] initWithTitle:@"提醒"
                                  message:message
                                 delegate:nil
                        cancelButtonTitle:@"好的"
                        otherButtonTitles:nil, nil] show];
    }
  });
}

@end
