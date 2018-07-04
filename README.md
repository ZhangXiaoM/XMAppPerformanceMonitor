# XMAppPerformanceMonitor

### 关于本项目

一个采用后台线程的 app 性能检测工具，检测 APP CPU、内存、FPS、异常等性能信息。

所有信息的收集和计算都由子线程完成，不会影响 APP 性能和阻塞主线程。

本地信息仅供调试使用，建议有统计需求的，将收集的信息上送到服务器统计。

### 用法

```objc
#import "XMCrashMonitor.h"
#import "XMCPUMonitor.h"
#import "XMMemoryMonitor.h"
#import "XMFPSMonitor.h"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[XMCrashMonitor sharedMonitor] startMonitor];
    
    [[XMFPSMonitor sharedMonitor] startMonitor];
    [[XMCPUMonitor sharedMonitor] startMonitor];
    [[XMMemoryMonitor sharedMonitor] startMonitor];
    
    return YES;
}
```

