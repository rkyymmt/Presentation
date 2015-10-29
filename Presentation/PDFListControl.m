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

    NSMutableArray<UIButton *> *numberButtons = NSMutableArray.new;
    NSArray *points = @[CR_POINTS_ONE, CR_POINTS_TWO, CR_POINTS_THREE, CR_POINTS_FOUR];
    for (int i = 0; i < points.count; i++) {
      UIButton *button = [self createButton:points[i]];
      button.tag = i;
      button.frame = CGRectMake(self.bounds.size.width / (points.count * 2) * (2 * i + 1) - 32,
                                0,
                                64,
                                64);
      [button addTarget:self action:@selector(numberButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
      [self addSubview:button];
      [numberButtons addObject:button];
    }
    _numberButtons = numberButtons;

    _leftButton = [self createButton:CR_POINTS_LEFT];
    _leftButton.frame = CGRectMake(self.bounds.size.width / 4 - 32,
                                   self.bounds.size.height * 0.4,
                                   64,
                                   64);
    [_leftButton addTarget:self action:@selector(leftButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_leftButton];

    _rightButton = [self createButton:CR_POINTS_RIGHT];
    _rightButton.frame = CGRectMake(self.bounds.size.width / 4 * 3 - 32,
                                    self.bounds.size.height * 0.4,
                                    64,
                                    64);
    [_rightButton addTarget:self action:@selector(rightButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rightButton];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:tap];
  }
  return self;
}

#pragma mark - UI Events

- (void)numberButtonPressed:(UIButton *)button {
  [_delegate listControlDidSelectIndex:(int)button.tag];
}

- (void)leftButtonPressed:(UIButton *)button {
  [_delegate listControlPrev];
}

- (void)rightButtonPressed:(UIButton *)button {
  [_delegate listControlNext];
}

- (void)tapped:(UITapGestureRecognizer *)tap {
  [_delegate listControlTapped];
}

#pragma mark - private

- (UIButton *)createButton:(NSString *)pointsString {
  UIImage *image = [CRCommon imageWithPoints:pointsString
                             width:48
                             lineColor:UIColor.lightGrayColor
                             pointColor:UIColor.whiteColor];
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.frame = CGRectMake(0, 0, 64, 64);
  [button setImage:image forState:UIControlStateNormal];
  return button;
}

@end
