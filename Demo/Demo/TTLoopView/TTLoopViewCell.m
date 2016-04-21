

#import "TTLoopViewCell.h"
#define cachePath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"cacheImageDict.data"]

@interface TTLoopViewCell ()
/** 图片View */
@property (nonatomic,strong) UIImageView *iconView;

@end

@implementation TTLoopViewCell
static NSMutableDictionary *cacheImageDict;
+ (void)initialize
{
    if (cacheImageDict == nil) {
        
        cacheImageDict = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
        if (cacheImageDict == nil) {
            cacheImageDict = [NSMutableDictionary dictionary];
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.iconView = [[UIImageView alloc] init];
        [self addSubview:self.iconView];
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.iconView.image = image;
}

- (void)setURLString:(NSString *)URLString
{
    _URLString = URLString;

    // 判断是否可以相应SDWebImage的方法
    if ([self.iconView canPerformAction:@selector(sd_setImageWithURL:placeholderImage:) withSender:nil])
    {// 可以
        NSURL *url = [NSURL URLWithString:URLString];
        [self.iconView performSelector:@selector(sd_setImageWithURL:placeholderImage:) withObject:url withObject:self.placeHolderImage];
    }else
    {// 不可以
        UIImage *image = cacheImageDict[URLString];
        
        if (image == nil) {
            // 占位图
            self.iconView.image = self.placeHolderImage;
            // 下载图片
            [self downloadImage:[NSURL URLWithString:URLString] cacheKey:URLString];
        }else
        {
            self.iconView.image = image;
        }
    }
}
// 下载并缓存到本地
- (void)downloadImage:(NSURL *)URL cacheKey:(NSString *)key
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 读取url中的内容
        NSData *data = [NSData dataWithContentsOfURL:URL];
        if (data == nil) return ;
        UIImage *image = [UIImage imageWithData:data];

        dispatch_async(dispatch_get_main_queue(), ^{
            // 缓存到本地磁盘
            cacheImageDict[key] = image;

            [NSKeyedArchiver archiveRootObject:cacheImageDict toFile:cachePath];
        });
    });
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.iconView.frame = self.bounds;
}

@end
