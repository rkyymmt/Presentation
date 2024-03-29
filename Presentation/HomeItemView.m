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

    _imageLayer = CALayer.layer;
    _imageLayer.frame = CGRectMake(4, 0, width - 8, height * 0.75);
    _imageLayer.contents = (__bridge id)[FileManager.fileManager thumbnailForItem:_item].CGImage;
    _imageLayer.contentsGravity = kCAGravityResizeAspect;
    [_baseLayer addSublayer:_imageLayer];

    CGFloat titleWidth = self.bounds.size.width - 20;
    CGFloat titleY = CGRectGetMaxY(_imageLayer.frame);
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, titleY, titleWidth, height - titleY - 10)];
    _titleLabel.textColor = UIColor.lightGrayColor;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = _item;
    [self addSubview:_titleLabel];
  }
  return self;
}

- (NSString *)item {
  return _item;
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
