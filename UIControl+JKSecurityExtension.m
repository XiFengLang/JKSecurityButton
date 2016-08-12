//
//  UIControl+JKSecurityExtension.m
//  JKKeyboardObserver
//
//  Created by 蒋鹏 on 16/7/27.
//  Copyright © 2016年 蒋鹏. All rights reserved.
//

#import "UIControl+JKSecurityExtension.h"
#import <objc/runtime.h>


@implementation UIControl (JKSecurityExtension)

+ (void)load{
    // load方法只会调用一次
    
    SEL systemSel = @selector(sendAction:to:forEvent:);
    SEL customSel = @selector(jk_sendAction:to:forEvent:);
    Method systemMethod = class_getInstanceMethod(self, systemSel);
    Method customMethod = class_getInstanceMethod(self, customSel);
    
    // 将customMethod的实现添加到systemMethod中，如果返回YES，说明没有实现customMethod，返回NO，已经实现了该方法
    BOOL add = class_addMethod(self, systemSel, method_getImplementation(customMethod), method_getTypeEncoding(customMethod));
    if (add) {
        // 没有实现customMethod,则需要将customMethod的实现指针换回systemMethod的
        class_replaceMethod(self, customSel, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
    }else{
        // 已经实现customMethod，则对systemMethod和customMethod的实现指针IMP进行交换
        // 交换一次就行，多次交换会出现混乱
        method_exchangeImplementations(systemMethod, customMethod);
    }
}



- (void)jk_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
    
    
    if (self.quickTapEnable) {
        [self jk_sendAction:action to:target forEvent:event];
        return;
    }else if ([target isKindOfClass:NSClassFromString(@"PLImagePickerCameraView")]
              || [target isKindOfClass:NSClassFromString(@"AVFullScreenPlaybackControlsViewController")]) {
        // 系统拍照按钮/视频播放器按钮单独处理，其他需要快速点击的设置quickTapEnable = YES
        [self jk_sendAction:action to:target forEvent:event];
        return;
    }
    
    NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
    
    if ([self isKindOfClass:UIButton.class]) {
        self.maximumClickInterval = self.maximumClickInterval > 0 ? self.maximumClickInterval : kMaximumClickInterval;
        if (timeNow - self.lastClickTime < self.maximumClickInterval) {
            self.lastClickTime = timeNow;
            return;
        }
    }
    self.lastClickTime = timeNow;
    
    // 之前进行了方法IMP替换，现在相当于调用系统的sendAction:to:forEvent:,不会出现死循环
    // 这么调用，相当于在中间加入一个方法，不会拦截掉系统的事件
    [self jk_sendAction:action to:target forEvent:event];
}


- (void)setMaximumClickInterval:(NSTimeInterval)maximumClickInterval{
    objc_setAssociatedObject(self, @selector(maximumClickInterval), @(maximumClickInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    // 用OBJC_ASSOCIATION_RETAIN_NONATOMIC是因为存的是NSNumber类型
}

- (NSTimeInterval)maximumClickInterval{
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}


- (void)setLastClickTime:(NSTimeInterval)lastClickTime{
    objc_setAssociatedObject(self, @selector(lastClickTime), @(lastClickTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)lastClickTime{
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}

- (void)setQuickTapEnable:(BOOL)quickTapEnable{
    objc_setAssociatedObject(self, @selector(quickTapEnable), @(quickTapEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)quickTapEnable{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}


@end
