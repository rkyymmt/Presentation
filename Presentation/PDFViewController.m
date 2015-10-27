#import "PDFViewController.h"
#import "Common.h"
#import "FileManager.h"
#import "NavigationBar.h"
#import "PDFFooter.h"
#import "PDFListControl.h"
#import "RootViewController.h"

@interface PDFViewController () <UIScrollViewDelegate, NavigationBarDelegate, PDFFooterDelegate, PDFListControlDelegate>
@end

@implementation PDFViewController {
  NSString *_item;
  int _numberOfPages;
  UIScrollView *_scrollView;
  NSArray *_imageViews;
  NavigationBar *_navigationBar;
  PDFFooter *_footer;
  PDFListControl *_listControl;
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
  self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];

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

  _listControl = [[PDFListControl alloc] initWithDelegate:self];
  _listControl.alpha = 0.0;
  [self.view addSubview:_listControl];

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
        [self setPageInList:imageView.tag % 4];
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

#pragma mark - PDFListControlDelegate

- (void)listControlDidSelectIndex:(int)index {
  _L();
  [self setPageInList:index];
}

- (void)listControlPrev {
  _L();
  [self listPrev];
}

- (void)listControlNext {
  _L();
  [self listNext];
}

- (void)listControlTapped {
  _L();
  [self toggleControls];
}

#pragma mark - action

- (void)prev {
  _L();
  if (_listMode) {
    [self listPrev];
    return;
  }
  int currentPage = self.currentPage;
  if (0 < currentPage) {
    [self setPage:currentPage - 1];
  }
}

- (void)next {
  _L();
  if (_listMode) {
    [self listNext];
    return;
  }
  int currentPage = self.currentPage;
  if (currentPage < _numberOfPages - 1) {
    [self setPage:currentPage + 1];
  }
}

- (void)reload {
  _L();
  [_imageViews[0] setFrame:[self imageViewFrameWithIndex:0]];
  [self setPage:0];
}

- (void)setPage:(int)page {
  _L();
  [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * page, 0) animated:YES];
}

#pragma mark - list mode

- (void)list {
  _L();
  _listMode = YES;
  _scrollView.scrollEnabled = NO;
  [self setListPage:self.currentPage / 4];
  [RootViewController.rootViewController setActiveGestures:YES];

  // mmm...
  for (UIImageView *imageView in _imageViews) {
    if (imageView.frame.size.width == _scrollView.frame.size.width) {
      CGFloat viewWidth = (self.view.bounds.size.width - 32) / 4;
      imageView.frame = CGRectMake(imageView.frame.origin.x,
                                   _scrollView.frame.size.height * 0.6 - viewWidth,
                                   viewWidth - 8,
                                   viewWidth - 8);
    }
  }

  if (0.0 == _navigationBar.alpha) {
    [self hideControls];
  } else {
    [self showControls];
  }
}

- (void)listPrev {
  _L();
  int prevListPage = self.currentListPage - 1;
  if (prevListPage < 0)
    return;

  int currentPage = self.currentPage;
  CGFloat offsetX = currentPage * _scrollView.frame.size.width + 16;

  [UIView animateWithDuration:0.2
          animations:^{
              for (UIImageView *imageView in _imageViews) {
                imageView.frame = CGRectMake(offsetX + self.view.bounds.size.width / 4 * 5,
                                             imageView.frame.origin.y,
                                             imageView.frame.size.width,
                                             imageView.frame.size.height);
              }
            }
          completion:^(BOOL finished) {
              for (UIImageView *imageView in _imageViews) {
                imageView.frame = CGRectMake(offsetX + -1.0 * self.view.bounds.size.width / 4,
                                             imageView.frame.origin.y,
                                             imageView.frame.size.width,
                                             imageView.frame.size.height);
              }
              [self setListPage:prevListPage];
            }];
}

- (void)listNext {
  _L();
  int nextListPage = self.currentListPage + 1;
  if (nextListPage * 4 >= _numberOfPages)
    return;

  int currentPage = self.currentPage;
  CGFloat offsetX = currentPage * _scrollView.frame.size.width + 16;

  [UIView animateWithDuration:0.2
          animations:^{
              for (UIImageView *imageView in _imageViews) {
                imageView.frame = CGRectMake(offsetX + -1.0 * self.view.bounds.size.width / 4,
                                             imageView.frame.origin.y,
                                             imageView.frame.size.width,
                                             imageView.frame.size.height);
              }
            }
          completion:^(BOOL finished) {
              for (UIImageView *imageView in _imageViews) {
                imageView.frame = CGRectMake(offsetX + self.view.bounds.size.width / 4 * 5,
                                             imageView.frame.origin.y,
                                             imageView.frame.size.width,
                                             imageView.frame.size.height);
              }
              [self setListPage:nextListPage];
            }];
}

- (void)setPageInList:(int)indexInList {
  _L();
  [UIView animateWithDuration:0.2
          animations:^{
              int page = [self currentListPage] * 4 + indexInList;
              [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * page, 0) animated:NO];

              int startPage = MAX(0, page - 2);
              for (int i = startPage; i < MIN(startPage + 5, _numberOfPages); i++) {
                UIImageView *imageView = _imageViews[i % 5];
                if (page != i)
                  imageView.hidden = YES;
                imageView.frame = [self imageViewFrameWithIndex:i];
                if (imageView.tag == i)
                  continue;
                imageView.tag = i;
                imageView.image = [FileManager.fileManager imageWithItem:_item page:i + 1];
              }
            }
          completion:^(BOOL finished) {
              for (UIImageView *imageView in _imageViews) {
                imageView.hidden = NO;
                _listMode = NO;
                _scrollView.scrollEnabled = YES;
                [RootViewController.rootViewController setActiveGestures:NO];
                if (0.0 == _navigationBar.alpha) {
                  [self hideControls];
                } else {
                  [self showControls];
                }
              }
            }];
}

- (int)currentListPage {
  CGFloat minX = _scrollView.frame.size.width * _numberOfPages;
  CGFloat offsetX = self.currentPage * _scrollView.frame.size.width;
  int index = 0;
  for (UIImageView *imageView in _imageViews) {
    _L(@"%d", (int)imageView.tag);
    if (0 == imageView.tag % 4 && offsetX < imageView.frame.origin.x && imageView.frame.origin.x <= minX) {
      _L(@"%f", imageView.frame.origin.x);
      minX = imageView.frame.origin.x;
      index = (int)imageView.tag;
    }
  }
  _L(@"%d, %d", index, index / 4);
  return index / 4;
}

- (void)setListPage:(int)listPage {
  [UIView animateWithDuration:0.2 animations:^{
      int currentPage = self.currentPage;
      CGFloat offsetX = currentPage * _scrollView.frame.size.width + 16;
      CGFloat viewWidth = (self.view.bounds.size.width - 32) / 4;
      int startIndex = listPage * 4;
      for (int i = startIndex; i < MIN(startIndex + 4, _numberOfPages); i++) {
        UIImageView *imageView = _imageViews[i % 5];
        imageView.frame = CGRectMake(offsetX + viewWidth * (i % 4) + 4,
                                     _scrollView.frame.size.height * 0.6 - viewWidth,
                                     viewWidth - 8,
                                     viewWidth - 8);
        if (imageView.tag == i)
          continue;
        imageView.tag = i;
        imageView.image = [FileManager.fileManager imageWithItem:_item page:i + 1];
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
    int currentPage = self.currentPage;
    int startPage = MAX(0, currentPage - 2);
    for (int i = startPage; i < MIN(startPage + 5, _numberOfPages); i++) {
      UIImageView *imageView = _imageViews[i % 5];
      imageView.frame = [self imageViewFrameWithIndex:i];
      if (imageView.tag == i)
        continue;
      imageView.tag = i;
      imageView.image = [FileManager.fileManager imageWithItem:_item page:i + 1];
    }
  }
}

#pragma mark - Controls

- (void)toggleControls {
  _L();
  if (0.0 == _navigationBar.alpha) {
    [self showControls];
  } else {
    [self hideControls];
  }
}

- (void)showControls {
  _L();
  [UIView animateWithDuration:0.2 animations:^{
      _navigationBar.alpha = 1.0;
      if (_listMode) {
        _listControl.alpha = 1.0;
        _footer.alpha = 0.0;
      } else {
        _listControl.alpha = 0.0;
        _footer.alpha = 1.0;
      }
    }];
}

- (void)hideControls {
  _L();
  [UIView animateWithDuration:0.2 animations:^{
      _navigationBar.alpha = 0.0;
      _listControl.alpha = 0.0;
      _footer.alpha = 0.0;
    }];
}

@end
