
#import <UIKit/UIKit.h>

@interface TTLoopViewCell : UICollectionViewCell

/** 图片 */
@property (nonatomic,weak) UIImage  *image;

/** 图片URL */
@property (nonatomic,copy) NSString *URLString;

/** 占位图 */
@property (nonatomic,weak) UIImage *placeHolderImage;
@end
