#import "HomeItemView.h"
#import "FileManager.h"

@implementation HomeItemView {
  NSString *_item;
  CALayer *_baseLayer;
  CALayer *_imageLayer;
  UILabel *_titleLabel;
}

- (instancetype)initWithFrame:(CGRect)frame item:(NSString *)item {
  self = [super initWithFrame:frame];
  if (self) {
    _item = item;

    _baseLayer = CALayer.layer;
    _baseLayer.frame = self.bounds;
    [self.layer addSublayer:_baseLayer];

    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;

    // UIImage *imageLayer = [Util gestureBackImageWithColor:UIColor.whiteColor size:CGSizeMake(width, width)];
    _imageLayer = CALayer.layer;
    _imageLayer.frame = CGRectMake(4, 0, width - 8, height * 0.8);
    _imageLayer.contents = (__bridge id)[FileManager.fileManager imageWithItem:_item].CGImage;
    _imageLayer.contentsGravity = kCAGravityResizeAspect;
    [_baseLayer addSublayer:_imageLayer];

    CGFloat titleWidth = self.bounds.size.width - 20;
    CGFloat titleY = CGRectGetMaxY(_imageLayer.frame);
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, titleY, titleWidth, height - titleY - 10)];
    _titleLabel.numberOfLines = 2;
    _titleLabel.textColor = UIColor.whiteColor;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = _item;
    [self addSubview:_titleLabel];
  }
  return self;
}

- (NSString *)item {
  return _item;
}

- (void)reload {
  // _L();
  // [UIView animateWithDuration:0.4
  //         animations:^{
  //             self.alpha = 0.0;
  //           }
  //         completion:^(BOOL finished) {
  //             [self reloadData];
  //             [UIView animateWithDuration:0.4 animations:^{ self.alpha = 1.0; }];
  //           }];
}

- (void)reloadData {
  // _item = [App.app.itemController itemWithIdentifier:_itemIdentifier];
  // CRGesture *gesture = [App.app.ringController gestureWithIdentifier:_itemIdentifier];
  // UIImage *gestureImage = [CRCommon imageWithPoints:gesture.pointsString
  //                                   width:_gestureImageLayer.frame.size.width * 0.6
  //                                   lineColor:Util.lightGrayColor
  //                                   pointColor:Util.grayColor];
  // _gestureImageLayer.contents = (__bridge id)gestureImage.CGImage;
  // _titleLabel.text = _item.name;
  // _errorImageLayer.hidden = !_item.hasError;
}


- (void)startAnimating {
  if ([_baseLayer animationForKey:@"transform"]) {
    return;
  }
  CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
  animation.duration = 0.6;
  animation.repeatCount = FLT_MAX;
  animation.values = @[
      [NSValue valueWithCATransform3D:CATransform3DIdentity],
      [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI/180.0*3.0, 0, 0, 1.0)],
      [NSValue valueWithCATransform3D:CATransform3DIdentity],
      [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI/180.0*3.0, 0, 0, 1.0)],
      [NSValue valueWithCATransform3D: CATransform3DIdentity],
    ];
  [_baseLayer addAnimation:animation forKey:@"transform"];
}

- (void)endAnimating {
  [_baseLayer removeAnimationForKey:@"transform"];
}

@end
