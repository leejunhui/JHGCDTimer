//
//  JHProxy.m
//  JHGCDTimer
//
//  Created by leejunhui on 2020/2/24.
//  Copyright © 2020 leejunhui. All rights reserved.
//

#import "JHProxy.h"

@implementation JHProxy
+ (instancetype)proxyWithTarget:(id)target
{
    JHProxy *proxy = [[JHProxy alloc] init];
    proxy.target = target;
    return proxy;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return self.target;
}
@end
