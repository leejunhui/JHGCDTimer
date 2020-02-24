//
//  JHProxy.h
//  JHGCDTimer
//
//  Created by leejunhui on 2020/2/24.
//  Copyright © 2020 leejunhui. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JHProxy : NSObject
+ (instancetype)proxyWithTarget:(id)target;
@property (nonatomic, weak) id target;
@end

NS_ASSUME_NONNULL_END
