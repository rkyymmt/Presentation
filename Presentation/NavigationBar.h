#import <UIKit/UIKit.h>

@protocol NavigationBarDelegate
- (void)leftButtonPressed;
@end

@interface NavigationBar : UIView
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UILabel *titleLabel;
- (instancetype)initWithDelegate:(id<NavigationBarDelegate>)deleate;
@end
