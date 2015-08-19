#import "PDFViewController.h"
#import "Common.h"
#import "FileManager.h"

@interface PDFViewController () <UIScrollViewDelegate>
@end

@implementation PDFViewController {
  NSString *_item;
  int _numberOfPages;
  UIScrollView *_scrollView;
  NSArray *_imageViews;
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
  self.view.backgroundColor = UIColor.blackColor;

  _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
  _scrollView.delegate = self;
  _scrollView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
  _scrollView.pagingEnabled = YES;
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
}

- (CGRect)imageViewFrameWithIndex:(int)index {
  return CGRectMake(_scrollView.frame.size.width * index,
                    0,
                    _scrollView.frame.size.width,
                    _scrollView.frame.size.height);
}

- (int)currentPage {
  return (_scrollView.contentOffset.x + _scrollView.frame.size.width * 0.5) / _scrollView.frame.size.width;
}

#pragma mark - UIScrollViewDelegate

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
