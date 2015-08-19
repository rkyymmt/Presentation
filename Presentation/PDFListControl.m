#import "PDFListControl.h"
#import <CoreRing/CoreRing.h>
#import "Common.h"

@implementation PDFListControl {
  id<PDFListControlDelegate> _delegate;
}

- (instancetype)initWithDelegate:(id<PDFListControlDelegate>)delegate {
  self = [super initWithFrame:CGRectMake(0,
                                         UIScreen.mainScreen.bounds.size.height * 0.6,
                                         UIScreen.mainScreen.bounds.size.width,
                                         UIScreen.mainScreen.bounds.size.height * 0.4)];
  if (self) {
    _delegate = delegate;

    NSArray *points = @[CR_POINTS_ONE, CR_POINTS_TWO, CR_POINTS_THREE, CR_POINTS_FOUR];

    for (int i = 0; i < points.count; i++) {
      UIImage *image = [CRCommon imageWithPoints:points[i]
                                 width:48
                                 lineColor:UIColor.lightGrayColor
                                 pointColor:UIColor.whiteColor];

      UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
      button.tag = i;
      button.frame = CGRectMake(self.bounds.size.width / (points.count * 2) * (2 * i + 1) - 32,
                                0,
                                64,
                                64);
      [button setImage:image forState:UIControlStateNormal];
      [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
      [self addSubview:button];
    }

    NSArray *arrowPoints = @[CR_POINTS_LEFT, CR_POINTS_RIGHT];
    for (int i = 0; i < arrowPoints.count; i++) {
      UIImage *image = [CRCommon imageWithPoints:arrowPoints[i]
                                 width:48
                                 lineColor:UIColor.lightGrayColor
                                 pointColor:UIColor.whiteColor];
      UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
      button.tag = i;
      button.frame = CGRectMake(self.bounds.size.width / 4 * (1 + i * 2) - 32,
                                self.bounds.size.height * 0.4,
                                64,
                                64);
      [button setImage:image forState:UIControlStateNormal];
      [button addTarget:self action:@selector(arrowButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
      [self addSubview:button];

      UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
      [self addGestureRecognizer:tap];
    }
  }
  return self;
}

- (void)buttonPressed:(UIButton *)button {
  [_delegate listControlDidSelectIndex:(int)button.tag];
}

- (void)arrowButtonPressed:(UIButton *)button {
  if (0 == button.tag) {
    [_delegate listControlPrev];
    return;
  }
  [_delegate listControlNext];
}

- (void)tapped:(UITapGestureRecognizer *)tap {
  [_delegate listControlTapped];
}

@end
