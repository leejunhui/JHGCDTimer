//
//  ViewController.m
//  JHGCDTimer
//
//  Created by leejunhui on 2020/2/24.
//  Copyright © 2020 leejunhui. All rights reserved.
//

#import "ViewController.h"
#import "JHProxy.h"
#import "JHGCDTimer.h"
@interface ViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
//@property (nonatomic, strong) NSTimer *timer;
//@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) dispatch_source_t timer;
@property (copy, nonatomic) NSString *task;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 打印当前 RunLoop 的 mode
    NSLog(@"当前 RunLoop 的 mode 为：%@", [[NSRunLoop currentRunLoop] currentMode]);
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
    //    [self.timer invalidate];
    //    [self.displayLink invalidate];
    
    [JHGCDTimer cancelTask:self.task];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 三种类型的 Timer
    
    // 1.NSTimer
    //    [self NSTimerDemo];
    
    // 2.CADisplayLink
    //    [self CADisplayLinkDemo];
    
    // 3.dispatch_source_timer
    //    [self DispatchSourceTimerDemo];
    
    // 4.自定义 GCD Timer
    [self customGCDTimer];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    NSLog(@"scrollViewDidScroll - 滑动时 RunLoop 的 mode 为：%@", [[NSRunLoop currentRunLoop] currentMode]);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //    NSLog(@"scrollViewDidEndDecelerating - 减速结束时 RunLoop 的 mode 为：%@", [[NSRunLoop currentRunLoop] currentMode]);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //    NSLog(@"scrollViewDidEndDragging - 拖动结束时 RunLoop 的 mode 为：%@", [[NSRunLoop currentRunLoop] currentMode]);
}

#pragma mark - NSTimer
- (void)NSTimerDemo
{
    // 因为 NSTimer 在底层是依靠 RunLoop 来驱动的，而在 RunLoop 的生命周期里面如果没有 NSTimer 对象被添加到 mode 中，NSTimer 对象就无法执行定时任务
    
    // 1.timerWithTimeInterval:invocation:repeats: 方法需要手动调用一次 fire 方法
    // 并且这种方式创建的 NSTimer 对象默认是不会启动的，需要手动将 NSTimer 对象添加到 RunLoop 中，并
    // 指定对应的是哪个 mode,这里可以选择 NSDefaultRunLoopMode，但是如果要兼容界面中有滚动视图的情况，则
    // 需要指定 mode 为 NSRunLoopCommonModes，因为界面发生滚动时，RunLoop 的 mode 为 UITrackingRunLoopMode，而如果只指定mode为
    // NSDefaultRunLoopMode 的话，在界面发生滚动的时候，timer就会停止工作。
    //    NSMethodSignature *methodSignature = [ViewController instanceMethodSignatureForSelector:@selector(NSTimerTask)];
    //    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    //    invocation.target = self;
    //    invocation.selector = @selector(NSTimerTask);
    //    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0f invocation:invocation repeats:YES];
    //    [timer fire];
    
    
    // 2.scheduledTimerWithTimeInterval:invocation:repeats: 方法就不需要手动调用 fire 方法了
    // 这个方法默认会把 timer 添加到 RunLoop 的NSDefaultRunLoopMode,所以如果需要兼容滚动时定时器也能正常工作的话，则需要
    // 指定 NSRunLoopCommonModes
    //    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 invocation:invocation repeats:YES];
    
    // 3.timerWithTimeInterval:target:selector:userInfo:repeats: 方法需要手动调用 fire 方法，也需要加入到 RunLoop 中
    /**
     The selector should have the following signature: timerFireMethod: (including a colon to indicate that the method takes an argument). The timer passes itself as the argument, thus the method would adopt the following pattern:
     - (void)timerFireMethod:(NSTimer *)timer
     根据官方文档的说明，timer 执行的任务的方法签名可以增加一个冒号来接收 timer 对象，以及对应的 userInfo 字典
     */
    //    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(timerFireMethod:) userInfo:@{@"param":@"666"} repeats:YES];
    //    [timer fire];
    
    // 4.scheduledTimerWithTimeInterval:target:selector:userInfo:repeats: 相比上面第三种方式，不需要手动调用 fire 方法
    // 这个方法默认会把 timer 添加到 RunLoop 的NSDefaultRunLoopMode,所以如果需要兼容滚动时定时器也能正常工作的话，则需要
    // 指定 NSRunLoopCommonModes
    //    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerFireMethod:) userInfo:@{@"param":@"666"} repeats:YES];
    
    // 5.timerWithTimeInterval:repeats:block: 方法接收一个 block 作为定时执行的任务，但是此时 timer 并不会执行，需要手动调用 fire 方法
    // 并且还需要加入到 RunLoop 中，否则只会执行一次任务，同样的，如果要支持滑动视图 timer 仍然可以工作，需要指定 mode 为 NSRunLoopCommonModes
    //    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
    //        NSLog(@"block形式的timer 正在执行任务");
    //    }];
    //    [timer fire];
    
    // 6.scheduledTimerWithTimeInterval:repeats:block: 相比上面第五种方式，不需要手动调用 fire 方法
    // 这个方法默认会把 timer 添加到 RunLoop 的NSDefaultRunLoopMode,所以如果需要兼容滚动时定时器也能正常工作的话，则需要
    // 指定 NSRunLoopCommonModes
    //    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
    //        NSLog(@"block形式的timer 正在执行任务");
    //    }];
    
    // 7.initWithFireDate:interval:target:selector:userInfo:repeats: 方法作为初始化构造器方法，也需要调用 fire 方法才能启动，但只会执行一次，
    // 如果要执行多次，则需要加入到 RunLoop 中，如果需要兼容滚动时定时器也能正常工作的话，则需要指定 NSRunLoopCommonModes
    //    NSTimer *timer = [[NSTimer alloc] initWithFireDate:[NSDate now] interval:1.0f target:self selector:@selector(timerFireMethod:) userInfo:@{@"param":@"777"} repeats:YES];
    //    [timer fire];
    
    // 8.initWithFireDate:interval:repeats:block: 方法与第六种相比，需要调用 fire 方法手动启动，但只会执行一次，
    // 如果要执行多次，则需要加入到 RunLoop 中，如果需要兼容滚动时定时器也能正常工作的话，则需要指定 NSRunLoopCommonModes
    //    NSTimer *timer = [[NSTimer alloc] initWithFireDate:[NSDate now] interval:1.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
    //        NSLog(@"block形式的timer 正在执行任务");
    //    }];
    //    [timer fire];
    
    //    self.timer = timer;
    //    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    //    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    // 使用 NSTimer 的时候需要注意避免循环引用，主要是参数中带 self 的时候
    // 所以在 iOS 10 之后，系统提供了两个带 block 的 timer 初始化方法来避免循环引用
    // 我们还可以通过 代理对象 来作为中间者
    // 代理对象需要重写 forwardingTargetForSelector 方法来实现方法转发
    // 然后持有对 target 的弱引用
    //    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:[JHProxy proxyWithTarget:self] selector:@selector(NSTimerTask) userInfo:nil repeats:YES];
}

- (void)NSTimerTask
{
    NSLog(@"NSTimer 启动了 ~~~");
}

- (void)timerFireMethod:(NSTimer *)timer
{
    NSLog(@"%s", __func__);
    NSDictionary *userInfo = timer.userInfo;
    NSLog(@"userInfo: %@", userInfo);
}

#pragma mark - CADisplayLinkDemo
- (void)CADisplayLinkDemo
{
    // CADisplayLink 使用起来比较简单，但是不能指定时间间隔，因为 CADisplayLink 是以 60FPS 的屏幕刷新率来工作的
    // 使用 CADisplayLink 也需要注意循环引用的问题，和 NSTimer 一样，我们可以使用代理者对象来解决这个问题
    // 使用 CADisplayLink 必须要加入 RunLoop 才能正常工作
    //    self.displayLink = [CADisplayLink displayLinkWithTarget:[JHProxy proxyWithTarget:self] selector:@selector(displayLinkTask)];
    //    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    //    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)displayLinkTask
{
    NSLog(@"CADisplayLink 启动了 ~~~");
}

#pragma mark - DispatchSourceTimerDemo
- (void)DispatchSourceTimerDemo
{
    // NSTimer依赖于RunLoop，如果RunLoop的任务过于繁重，可能会导致NSTimer不准时
    // 而 GCD 的定时器更准时，使用 GCD 定时器需要声明一个强应用属性，否则会没有效果
    // 并且当视图滚动时，GCD 定时器仍能工作，可见并没有受 RunLoop 影响
    dispatch_queue_t queue = dispatch_queue_create("timer", DISPATCH_QUEUE_SERIAL);
    //    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer,
                              dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC),
                              1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"dispatch_source_t timer ");
    });
    dispatch_resume(timer);
    
    self.timer = timer;
}

#pragma mark - 自定义 GCD Timer
- (void)customGCDTimer
{
    self.task = [JHGCDTimer execTask:^{
        NSLog(@"自定义 GCD Timer - %@", [NSThread currentThread]);
    } start:0.0 interval:1.0 repeats:YES async:NO];
}

- (void)customGCDTimerTask
{
    NSLog(@"自定义 GCD Timer - %@", [NSThread currentThread]);
}

@end
