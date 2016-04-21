# TTLoopView

2016-4-21 上传项目

+ (instancetype) LoopViewWithURLs: 使用网络图片创建轮播器
+ (instancetype) LoopViewWithImages: 使用本地图片创建轮播器

可以手动创建 也可以使用xib创建

如果项目中包含 SDWebImage 框架，使用网络图片时会自动使用 sd_setImageWithURL:placeholderImage: 如果不包换，有自己内部的缓存策略