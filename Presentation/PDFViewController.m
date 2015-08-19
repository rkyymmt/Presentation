#import "PDFViewController.h"
#import "Common.h"
#import "FileManager.h"
#import "NavigationBar.h"
#import <CoreRing/CoreRing.h>

@interface PDFViewController () <UIScrollViewDelegate, NavigationBarDelegate>
@end

@implementation PDFViewController {
  NSString *_item;
  int _numberOfPages;
  UIScrollView *_scrollView;
  NSArray *_imageViews;
  NavigationBar *_navigationBar;
  UIView *_footerView;
  int _lastPage;
}

- (instancetype)initWithItem:(NSString *)item {
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    _item = item;
    _numberOfPages = [FileManager.fileManager numberOfPages:_item];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];

  _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
  _scrollView.delegate = self;
  _scrollView.pagingEnabled = YES;
  _scrollView.showsHorizontalScrollIndicator = NO;
  [self.view addSubview:_scrollView];

  NSMutableArray *imageViews = NSMutableArray.new;
  for (int i = 0; i < MIN(_numberOfPages, 5); i++) {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[self imageViewFrameWithIndex:i]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [FileManager.fileManager imageWithItem:_item page:i + 1];
    [_scrollView addSubview:imageView];
    [imageViews addObject:imageView];
  }
  _imageViews = imageViews;
  _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _numberOfPages, _scrollView.frame.size.height);

  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
  [_scrollView addGestureRecognizer:tap];

  _navigationBar = [[NavigationBar alloc] initWithDelegate:self];
  _navigationBar.titleLabel.text = _item;
  _navigationBar.alpha = 0.0;
  [self.view addSubview:_navigationBar];

  _footerView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                         self.view.bounds.size.height - 64,
                                                         self.view.bounds.size.width,
                                                         64)];
  _footerView.alpha = 0.0;
  _footerView.backgroundColor = UIColor.blackColor;
  [self.view addSubview:_footerView];

  NSArray *keys = @[@"Prev", @"Top", @"List", @"Next"];
  NSArray *points = @[CR_POINTS_LEFT, CR_POINTS_CIRCLE, CR_POINTS_PIGTALE, CR_POINTS_RIGHT];
  for (int i = 0; i < keys.count; i++) {
    UIImage *image = [CRCommon imageWithPoints:points[i]
                               width:48
                               lineColor:UIColor.lightGrayColor
                               pointColor:UIColor.whiteColor];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = i;
    button.frame = CGRectMake((self.view.bounds.size.width / (keys.count + 1)) * (1 + i) - 32,
                              0,
                              64,
                              64);
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_footerView addSubview:button];
  }
}

#pragma mark - UI Event

- (void)leftButtonPressed {
  _L();
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tapped:(UIGestureRecognizer *)tap {
  _L();
  [self toggleControls];
}

- (void)buttonPressed:(UIButton *)button {
  _L();
  switch (button.tag) {
  case 0:
    [self prev];
    break;
  case 1:
    [self reload];
    break;
  case 2:
    [self list];
    break;
  case 3:
    [self next];
    break;
  }
}

#pragma mark - action

- (void)prev {
  _L();
}

- (void)reload {
  _L();
}

- (void)list {
  _L();
}

- (void)next {
  _L();
}


#pragma mark - Properties

- (CGRect)imageViewFrameWithIndex:(int)index {
  return CGRectMake(_scrollView.frame.size.width * index,
                    0,
                    _scrollView.frame.size.width,
                    _scrollView.frame.size.height);
}

- (int)currentPage {
  return (_scrollView.contentOffset.x + _scrollView.frame.size.width * 0.5) / _scrollView.frame.size.width;
}

#pragma mark - Controls

- (void)toggleControls {
  _L();
  [UIView animateWithDuration:0.2 animations:^{
      if (0.0 == _navigationBar.alpha) {
        [self showControls];
      } else {
        [self hideControls];
      }
    }];
}

- (void)showControls {
  _L();
  _navigationBar.alpha = 1.0;
  _footerView.alpha = 1.0;
}

- (void)hideControls {
  _L();
  _navigationBar.alpha = 0.0;
  _footerView.alpha = 0.0;
}

#pragma mark - UIScrollViewDelegate, Page

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  int currentPage = self.currentPage;
  if (_lastPage != currentPage) {
    _lastPage = currentPage;
    [self pageChanged];
  }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (scrollView.decelerating)
    return;
  [self pageChanged];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  [self pageChanged];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
  [self pageChanged];
}

- (void)pageChanged {
  _L();
  @synchronized (self) {
    if (_numberOfPages <= 5)
      return;
    int currentPage = self.currentPage;
    int startPage = MAX(0, currentPage - 2);
    for (int i = startPage; i < MIN(startPage + 5, _numberOfPages); i++) {
      UIImageView *imageView = _imageViews[i % 5];
      if (imageView.tag == i)
        continue;
      imageView.tag = i;
      imageView.frame = [self imageViewFrameWithIndex:i];
      imageView.image = [FileManager.fileManager imageWithItem:_item page:i + 1];
    }
  }
}

@end
