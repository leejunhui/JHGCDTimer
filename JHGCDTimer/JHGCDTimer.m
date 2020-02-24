//
//  JHGCDTimer.m
//  JHGCDTimer
//
//  Created by leejunhui on 2020/2/24.
//  Copyright © 2020 leejunhui. All rights reserved.
//

#import "JHGCDTimer.h"

@implementation JHGCDTimer

static NSMutableDictionary *timers_;
dispatch_semaphore_t semaphore_;
+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timers_ = [NSMutableDictionary dictionary];
        semaphore_ = dispatch_semaphore_create(1);
    });
}


+ (NSString *)execTask:(void(^)(void))task
                 start:(NSTimeInterval)start
              interval:(NSTimeInterval)interval
               repeats:(BOOL)repeats
                 async:(BOOL)async
{
    // 1.边界值判断
    if (!task || start < 0 || (interval <= 0 && repeats)) return nil;
    
    // 2.根据 async 判断是同步还是异步
    dispatch_queue_t queue = async ? dispatch_get_global_queue(0, 0) : dispatch_get_main_queue();
    
    // 3.创建定时器
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    // 4.设置时间
    dispatch_source_set_timer(timer,
                              dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC),
                              interval * NSEC_PER_SEC, 0);
    
    // 信号量控制存储的过程
    dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
    // 定时器的唯一标识
    NSString *name = [NSString stringWithFormat:@"%lu", (unsigned long)timers_.count];
    // 存放到字典中
    timers_[name] = timer;
    dispatch_semaphore_signal(semaphore_);
    
    // 设置回调
    dispatch_source_set_event_handler(timer, ^{
        task();
        
        if (!repeats) {
            [self cancelTask:name];
        }
    });
    
    // 启动定时器
    dispatch_resume(timer);
    
    return name;
}

+ (void)cancelTask:(NSString *)name
{
    if (name.length == 0) return;
    
    dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
    
    dispatch_source_t timer = timers_[name];
    if (timer) {
        dispatch_source_cancel(timer);
        [timers_ removeObjectForKey:name];
    }
    
    dispatch_semaphore_signal(semaphore_);
}
@end
