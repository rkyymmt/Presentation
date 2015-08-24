#import "PDFFooter.h"
#import <CoreRing/CoreRing.h>
#import "Common.h"

@implementation PDFFooter {
  __weak id<PDFFooterDelegate> _delegate;
}

- (instancetype)initWithDelegate:(id<PDFFooterDelegate>)delegate {
  self = [super initWithFrame:CGRectMake(0,
                                         UIScreen.mainScreen.bounds.size.height - 64,
                                         UIScreen.mainScreen.bounds.size.width,
                                         64)];
  if (self) {
    _delegate = delegate;
    self.backgroundColor = UIColor.blackColor;

    NSArray *points = @[CR_POINTS_LEFT, CR_POINTS_CIRCLE, CR_POINTS_PIGTAIL, CR_POINTS_RIGHT];
    for (int i = 0; i < points.count; i++) {
      UIImage *image = [CRCommon imageWithPoints:points[i]
                                 width:48
                                 lineColor:UIColor.lightGrayColor
                                 pointColor:UIColor.whiteColor];

      UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
      button.tag = i;
      button.frame = CGRectMake((self.bounds.size.width / (points.count + 1)) * (1 + i) - 32,
                                0,
                                64,
                                64);
      [button setImage:image forState:UIControlStateNormal];
      [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
      [self addSubview:button];
    }
  }
  return self;
}

- (void)buttonPressed:(UIButton *)button {
  [_delegate PDFFooterButtonPressed:(int)button.tag];
}

@end
