#import "NavigationBar.h"

@implementation NavigationBar {
  __weak id<NavigationBarDelegate> _delegate;
}

- (instancetype)initWithDelegate:(id<NavigationBarDelegate>)deleate {
  self = [super initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 64)];
  if (self) {
    _delegate = deleate;
    self.backgroundColor = UIColor.blackColor;

    _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = UIColor.lightGrayColor;
    [self addSubview:_titleLabel];

    _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftButton.frame = CGRectMake(8, self.bounds.size.height / 2 - 22, 44, 44);
    [_leftButton setImage:[UIImage imageNamed:@"navigation_close"] forState:UIControlStateNormal];
    [_leftButton addTarget:self action:@selector(leftButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_leftButton];
  }
  return self;
}

- (void)leftButtonPressed:(UIButton *)leftButton {
  [_delegate leftButtonPressed];
}

@end
