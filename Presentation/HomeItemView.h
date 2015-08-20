#import <UIKit/UIKit.h>

@interface HomeItemView : UIView
- (instancetype)initWithFrame:(CGRect)frame item:(NSString *)item;
- (NSString *)item;
- (void)startAnimating;
- (void)endAnimating;
@end
