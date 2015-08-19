#import "PDFViewController.h"
#import "Common.h"
#import "FileManager.h"
#import "NavigationBar.h"
#import "PDFFooter.h"
#import <CoreRing/CoreRing.h>

@interface PDFViewController () <UIScrollViewDelegate, NavigationBarDelegate, PDFFooterDelegate>
@end

@implementation PDFViewController {
  NSString *_item;
  int _numberOfPages;
  UIScrollView *_scrollView;
  NSArray *_imageViews;
  NavigationBar *_navigationBar;
  PDFFooter *_footer;
  int _lastPage;
  BOOL _listMode;
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

  _footer = [[PDFFooter alloc] initWithDelegate:self];
  _footer.alpha = 0.0;
  [self.view addSubview:_footer];
}

#pragma mark - UI Event

- (void)leftButtonPressed {
  _L();
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tapped:(UIGestureRecognizer *)tap {
  _L();
  if (_listMode) {
    CGPoint point = [tap locationInView:_scrollView];
    for (UIImageView *imageView in _imageViews) {
      if (CGRectContainsPoint(imageView.frame, point)) {
        [self listPageDidSelect:imageView.tag % 4];
        return;
      }
    }
  }
  [self toggleControls];
}

- (void)PDFFooterButtonPressed:(int)index {
  _L();
  switch (index) {
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
  int currentPage = self.currentPage;
  if (0 < currentPage) {
    [self setPage:currentPage - 1];
  }
}

- (void)reload {
  _L();
  [self setPage:0];
}

- (void)list {
  _L();
  [self startListMode];
}

- (void)next {
  _L();
  int currentPage = self.currentPage;
  if (currentPage < _numberOfPages - 1) {
    [self setPage:currentPage + 1];
  }
}

- (void)setPage:(int)page {
  _L();
  [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * page, 0) animated:YES];
}

#pragma mark - list mode

- (int)currentListPage {
  int minIndex = _numberOfPages;
  int maxIndex = 0;
  for (UIImageView *imageView in _imageViews) {
    minIndex = MIN(minIndex, imageView.tag);
    maxIndex = MAX(maxIndex, imageView.tag);
  }
  return (minIndex + maxIndex) / 2 / 4;
}

- (void)startListMode {
  _L();
  _listMode = YES;
  [UIView animateWithDuration:0.2 animations:^{
      [self setListPage:self.currentPage / 4];
    }];
}

- (void)setListPage:(int)listPage {
  int currentPage = self.currentPage;
  CGFloat offsetX = currentPage * _scrollView.frame.size.width + 16;
  CGFloat viewWidth = (self.view.bounds.size.width - 32) / 4;
  int startIndex = listPage * 4;
  for (int i = startIndex; i < MIN(startIndex + 4, _numberOfPages); i++) {
    UIImageView *imageView = _imageViews[i % 5];
    imageView.frame = CGRectMake(offsetX + viewWidth * (i % 4) + 4,
                                 (_scrollView.frame.size.height - viewWidth) / 2 - 64,
                                 viewWidth - 8,
                                 viewWidth - 8);
    if (imageView.tag == i)
      continue;
    imageView.tag = i;
    imageView.image = [FileManager.fileManager imageWithItem:_item page:i + 1];
  }
}

- (void)listPageDidSelect:(int)indexInListPage {
  _L();
  [UIView animateWithDuration:0.2
          animations:^{
              int page = [self currentListPage] * 4 + indexInListPage;
              [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * page, 0) animated:NO];

              int startPage = MAX(0, page - 2);
              for (int i = startPage; i < MIN(startPage + 5, _numberOfPages); i++) {
                UIImageView *imageView = _imageViews[i % 5];
                if (page != i)
                  imageView.alpha = 0.0;
                imageView.frame = [self imageViewFrameWithIndex:i];
                if (imageView.tag == i)
                  continue;
                imageView.tag = i;
                imageView.image = [FileManager.fileManager imageWithItem:_item page:i + 1];
              }
            }
          completion:^(BOOL finished) {
              for (UIImageView *imageView in _imageViews) {
                imageView.alpha = 1.0;
              }
            }];
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
  _footer.alpha = 1.0;
}

- (void)hideControls {
  _L();
  _navigationBar.alpha = 0.0;
  _footer.alpha = 0.0;
}

@end
