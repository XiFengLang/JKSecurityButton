# JKSecurityButton
【iOS】`JKSecurityButton`能 防止 按钮被快速/连续点击，并且能良好的兼容iOS系统自带的某些按钮

------
用法：在相关控制器或者全局头文件 `#import "UIControl+JKSecurityExtension.h"`

默认最大点击间隔时间为0.75秒，
如需自定义则修改`static NSTimeInterval const kMaximumClickInterval = ...;`

给特定的button自定义间隔可设置`button.maximumClickInterval = ...; `

如果需要给某些按钮开启快速点击功能，设置`button.quickTapEnable = YES；` 

