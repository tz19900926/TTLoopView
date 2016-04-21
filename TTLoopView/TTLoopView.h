
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TitlePosition){
    TitlePositionAboveImage = 0, // 标题包含在图片内 (默认)
    TitlePositionBelowImage  = 1, //  标题在图片下面
};

@interface TTLoopView : UIView

/**
 *  使用 URL数组 创建一个图片轮播器
 *
 *  @param urls   URL字符串数组
 *  @param titles 标题数组
 *
 *  @return 图片轮播器
 */
+ (instancetype) LoopViewWithURLs:(NSArray <NSString *>*)urls titles:(NSArray <NSString *>*)titles didSelected:(void (^)(NSInteger itemIndex))SelectedBlock;

/**
 *  使用 图片数组 创建一个图片轮播器
 *
 *  @param images 图片数组
 *  @param titles 标题数组
 *
 *  @return 图片轮播器
 */
+ (instancetype) LoopViewWithImages:(NSArray <UIImage *>*)images titles:(NSArray <NSString *>*)titles didSelected:(void (^)(NSInteger itemIndex))SelectedBlock;

/** 点击图片回调block */
@property (nonatomic,copy) void (^SelectedBlock)(NSInteger itemIndex);

/** 占位图 */
@property (nonatomic,strong) UIImage *placeHolderImage;

/** 图片URL数组 */
@property (nonatomic,strong) NSArray *URLs;

/** 图片数组 */
@property (nonatomic,strong) NSArray *images;

/** 标题数组 */
@property (nonatomic, strong) NSArray *titles;

/** 时间间隔 */
@property (nonatomic,assign) NSInteger timerInterval;

/** 标题的位置 */
@property (nonatomic,assign) TitlePosition titlePosition;

/** 标题字体大小 */
@property (nonatomic,assign) CGFloat titleFont;

/** 标题字体颜色 */
@property (nonatomic,strong) UIColor *titleColor;

/** 标题背景色 */
@property (nonatomic,strong) UIColor *titleBackGroundColor;

/** 标题透明度 */
@property (nonatomic,assign) CGFloat titleAlpha;

/** 页码器普通状态颜色 */
@property (nonatomic,strong) UIColor *pageControlNorColor;

/** 页码器选中状态颜色 */
@property (nonatomic,strong) UIColor *pageControlSelColor;

@end
