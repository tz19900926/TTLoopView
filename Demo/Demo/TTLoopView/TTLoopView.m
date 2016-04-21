
#import "TTLoopView.h"
#import "TTLoopViewCell.h"
#import "TTLoopViewFlowLayout.h"

@interface TTLoopView () <UICollectionViewDataSource,UICollectionViewDelegate>

/** 轮播器collectionView */
@property (nonatomic,strong) UICollectionView *collectionView;

/** 显示标题 */
@property (nonatomic,strong) UILabel *titleLabel;

/** 分页指示器 */
@property (nonatomic,strong) UIPageControl *pageControl;

/** 记录当前索引 */
@property (nonatomic,assign) NSInteger currentIndex;

/** 定时器 */
@property (nonatomic, strong) NSTimer *timer;

/** 标题页码器View */
@property (nonatomic,strong) UIView *titlePageView;

/** 图片数量 */
@property (nonatomic,assign) NSInteger imageCount;

@end

@implementation TTLoopView

#define identifier @"loopCell"
#define selfWeight self.bounds.size.width
#define selfHeight self.bounds.size.height
#pragma mark - ======== 初始化方法 ========
+ (instancetype) LoopViewWithImages:(NSArray <UIImage *>*)images titles:(NSArray <NSString *>*)titles didSelected:(void (^)(NSInteger))SelectedBlock
{
    NSAssert(images != nil, @"图片轮播器必须传入图片数组或URL数组");
    TTLoopView *loopView = [[self alloc] init];
    if (SelectedBlock) {
        loopView.SelectedBlock = SelectedBlock;
    }
    if (images) {
        loopView.images = images;
    }
    // 如果有标题，则接收数据
    if (titles) {
        loopView.titles = titles;
    }
    return loopView;
}

+ (instancetype) LoopViewWithURLs:(NSArray <NSString *>*)urls titles:(NSArray <NSString *>*)titles didSelected:(void (^)(NSInteger))SelectedBlock
{
    NSAssert(urls != nil, @"图片轮播器必须传入图片数组或URL数组");
    TTLoopView *loopView = [[self alloc] init];
    if (SelectedBlock) {
        loopView.SelectedBlock = SelectedBlock;
    }
    if (urls) {
        loopView.URLs = urls;
    }
    if (titles) {
        loopView.titles = titles;
    }
    return loopView;
}

#pragma mark - ======== 安装其他控件 ========
- (void)setup
{
    // 添加
    [self addSubview:self.collectionView];
    
    // 添加到标题页码器View
    [self.titlePageView addSubview:self.pageControl];
    
    [self addSubview:self.titlePageView];
    
    // 设置默认值
    self.timerInterval = 2;
    self.titlePosition = TitlePositionAboveImage;
}

#pragma mark - ======== 懒加载 ========
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        // 创建CollectionView
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[TTLoopViewFlowLayout alloc] init]];
        // 注册cell
        [_collectionView registerClass:[TTLoopViewCell class] forCellWithReuseIdentifier:identifier];
        // 设置代理和数据源
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
    }
    return _collectionView;
}
- (UIView *)titlePageView
{
    if (!_titlePageView) {
        _titlePageView = [[UIView alloc] init];
    }
    return _titlePageView;
}
- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
        // 如果只有一页 则隐藏分页指示器
        _pageControl.hidesForSinglePage = YES;
    }
    return _pageControl;
}

#pragma mark - ======== 布局 ========
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat titleH = self.titleFont;
    
    if (titleH == 0)
    {
        // 让标题文本自适应大小
        [self.titleLabel sizeToFit];
        
        titleH = self.titleLabel.bounds.size.height;
        
        if (titleH == 0) {
            // 设置标题的高度(默认值)
            titleH = 20;
        }
    }
    // 获取自身的大小
    CGRect frame = self.bounds;

    // 间隔值
    CGFloat marginY = 10;
    
    // 判断标题位置
    if (self.titlePosition == TitlePositionBelowImage) {
        
        frame.size.height -= titleH + marginY;
    }
    self.collectionView.frame = frame;
    
    // 页码ViewY值
    CGFloat titlePageY = selfHeight - titleH - marginY;
    
    // 设置标题页码frame
    self.titlePageView.frame = CGRectMake(0, titlePageY, selfWeight, titleH + marginY);
    
    [self.titlePageView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 页码器间距
        CGFloat marginX = 10;
        
        // 计算页码器的frame
        CGFloat pageW = self.imageCount * 15;
        CGFloat pageX = selfWeight - pageW - marginX;
        
        // 父控件的高度
        CGFloat viewHeight = CGRectGetHeight(self.titlePageView.frame);
        
        // 赋值
        self.pageControl.frame = CGRectMake(pageX, 0, pageW, viewHeight);
        
        if (self.titleLabel) {
            // 设置标题的frame
            CGFloat titleW = selfWeight - pageW - marginX;
            self.titleLabel.frame = CGRectMake(marginX, 0, titleW, viewHeight);
        }
    }];
    
    // 滚动到 URLStrs.count 位置 3
    // 主队列异步执行：在主线程空闲时才能执行block代码
    // 在执行block代码时，已经调用了collectionView数据源方法
    dispatch_async(dispatch_get_main_queue(), ^{

        if (self.imageCount > 1) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.imageCount inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
    });
}

#pragma mark - ======== 定时器方法 ========
/**
 *  创建定时器
 */
-(void)addTimer {
    if (self.timerInterval == 0) return;
    // 计时器
    self.timer = [NSTimer timerWithTimeInterval:self.timerInterval target:self selector:@selector(scrollCollectionView) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
/**
 *  移除定时器
 */
- (void)removeTimer {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - ======== 数据源方法 ========
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageCount * ((self.imageCount == 1) ? 1:1000);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TTLoopViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if (self.images) {
        cell.image = self.images[indexPath.item % self.imageCount];
    }else
    {
        if (self.placeHolderImage) {
            cell.placeHolderImage = self.placeHolderImage;
        }
        cell.URLString = self.URLs[indexPath.item % self.imageCount];
    }
    return cell;
}

#pragma mark - ======== 代理方法 ========
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.SelectedBlock) {
        self.SelectedBlock( indexPath.item % self.imageCount );
    }
}

- (void)scrollCollectionView
{
    // 获得当前显示的页号
    NSInteger page = self.collectionView.contentOffset.x / self.collectionView.bounds.size.width;
    // 计算偏移量
    CGFloat offsetX = (page + 1) * self.collectionView.bounds.size.width;
    // 设置偏移量
    [self.collectionView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 计算当前滚动的页号
    NSInteger page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    
    if (page == 0 || page == ([self.collectionView numberOfItemsInSection:0] - 1)) {
        
        page = self.imageCount - ((page == 0) ? 0: 1); // 3
        // 滚动到第URLStrs.count张
        self.collectionView.contentOffset = CGPointMake(page * scrollView.bounds.size.width, 0);
    }
    
    // 设置标题
    if (self.titles) {
        self.titleLabel.text = self.titles[page % self.titles.count];
    }
    self.pageControl.currentPage = page % self.imageCount;
}

// 当用户开始拖拽时调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removeTimer];
}

// 当用户结束拖拽时调用
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [self addTimer];
}

#pragma mark - ======== 赋值属性 ========
- (void)setURLs:(NSArray *)URLs
{
    _URLs = URLs;
    self.imageCount = URLs.count;
    self.pageControl.numberOfPages = URLs.count;
    
    [self setup];
}
- (void)setImages:(NSArray *)images
{
    _images = images;
    self.imageCount = images.count;
    self.pageControl.numberOfPages = images.count;
    
    [self setup];
}

- (void)setTitles:(NSArray *)titles
{
    _titles = titles;
    // 如果有标题数据才创建标题Label
    if (titles) {
        // 创建标题
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.text = titles[0];
        [self.titlePageView addSubview:self.titleLabel];
    }
}

- (void)setTimerInterval:(NSInteger)timerInterval
{
    _timerInterval = timerInterval;
    [self removeTimer];
    [self addTimer];
}

- (void)setTitleFont:(CGFloat)titleFont
{
    _titleFont = titleFont;
    
    self.titleLabel.font = [UIFont systemFontOfSize:titleFont];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    
    self.titleLabel.textColor = titleColor;
}

- (void)setPageControlNorColor:(UIColor *)pageControlNorColor
{
    _pageControlNorColor = pageControlNorColor;
    
    self.pageControl.pageIndicatorTintColor = pageControlNorColor;
}

- (void)setPageControlSelColor:(UIColor *)pageControlSelColor
{
    _pageControlSelColor = pageControlSelColor;
    
    self.pageControl.currentPageIndicatorTintColor = pageControlSelColor;
}

- (void)setTitleBackGroundColor:(UIColor *)titleBackGroundColor
{
    _titleBackGroundColor = titleBackGroundColor;
    
    self.titlePageView.backgroundColor = titleBackGroundColor;
}

- (void)setTitleAlpha:(CGFloat)titleAlpha
{
    _titleAlpha = titleAlpha;
    
    self.titlePageView.alpha = titleAlpha;
}

@end
