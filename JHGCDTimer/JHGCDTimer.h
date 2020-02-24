//
//  JHGCDTimer.h
//  JHGCDTimer
//
//  Created by leejunhui on 2020/2/24.
//  Copyright © 2020 leejunhui. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JHGCDTimer : NSObject
+ (NSString *)execTask:(void(^)(void))task
                 start:(NSTimeInterval)start
              interval:(NSTimeInterval)interval
               repeats:(BOOL)repeats
                 async:(BOOL)async;

+ (void)cancelTask:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
