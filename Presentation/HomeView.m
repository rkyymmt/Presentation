#import "HomeView.h"
#import "Common.h"
#import "HomeItemView.h"
#import "FileManager.h"

typedef enum {
  PagingTypeNone,
  PagingTypeLeft,
  PagingTypeRight
} PagingType;

@interface HomeView () <UIScrollViewDelegate>
@end

@implementation HomeView {
  __weak id<HomeViewDelegate> _delegate;
  UIScrollView *_scrollView;
  UIPageControl *_pageControl;
  NSMutableArray *_itemViews;
  HomeItemView *_draggingView;
  int _draggingViewIndex;
  NSTimer *_pagingTimer;
  PagingType _pagingType;
}

- (void)dealloc {
  _L();
}

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<HomeViewDelegate>)delegate {
  self = [super initWithFrame:frame];
  if (self) {
    _delegate = delegate;

    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.clipsToBounds = NO;
    _scrollView.delegate = self;
    [self addSubview:_scrollView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [_scrollView addGestureRecognizer:tap];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(longPressed:)];
    longPress.minimumPressDuration = 0.75;
    [_scrollView addGestureRecognizer:longPress];

    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0,
                                                                   self.bounds.size.height - 24,
                                                                   self.bounds.size.width,
                                                                   24)];
    _pageControl.currentPageIndicatorTintColor = UIColor.whiteColor;
    _pageControl.pageIndicatorTintColor = UIColor.grayColor;
    [self addSubview:_pageControl];

    [self reloadData];
  }
  return self;
}

- (void)reloadData {
  _L();
  for (NSArray *itemViewsInPage in _itemViews) {
    for (HomeItemView *itemView in itemViewsInPage) {
      [itemView removeFromSuperview];
    }
  }
  _itemViews = NSMutableArray.new;

  NSArray *itemLists = [FileManager.fileManager itemLists];

  int page = 0;
  for (NSArray *itemList in itemLists) {
    int index = 0;
    NSMutableArray *itemViewsInPage = NSMutableArray.new;
    for (NSString *item in itemList) {
      CGRect itemViewFrame = [self itemViewFrameWithIndex:index inPage:page];
      HomeItemView *homeItemView = [[HomeItemView alloc] initWithFrame:itemViewFrame item:item];
      [_scrollView addSubview:homeItemView];
      [itemViewsInPage addObject:homeItemView];
      index++;
    }
    [_itemViews addObject:itemViewsInPage];
    page++;
  }
  _scrollView.contentSize = CGSizeMake(self.bounds.size.width * itemLists.count, self.bounds.size.height);
  _pageControl.numberOfPages = itemLists.count;
}

// - (void)removeItemAtIndex:(int)index inPage:(int)page {
//   _L();
//   if (page < _itemViews.count && index < [_itemViews[page] count]) {
//     HomeItemView *itemView = _itemViews[page][index];
//     [UIView animateWithDuration:0.4
//             animations:^{
//                 itemView.alpha = 0.0;
//               }
//             completion:^(BOOL finished) {
//                 [itemView removeFromSuperview];
//                 [_itemViews[page] removeObjectAtIndex:index];
//                 if ([_itemViews[page] count]) {
//                   [self setItemViewsInCurrentPage];
//                   return;
//                 }

//                 [_itemViews removeObjectAtIndex:page];
//                 int newPage = MAX(0, page - 1);
//                 [UIView animateWithDuration:0.2
//                         animations:^{
//                             _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width * newPage, 0);
//                           }
//                         completion:^(BOOL finished) {
//                             _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _itemViews.count,
//                                                                  _scrollView.frame.size.height);
//                             _pageControl.numberOfPages = _itemViews.count;

//                             int p = 0;
//                             for (NSArray *itemViewsInPage in _itemViews) {
//                               int i = 0;
//                               for (HomeItemView *homeItemView in itemViewsInPage) {
//                                 homeItemView.frame = [self itemViewFrameWithIndex:i inPage:p];
//                                 i++;
//                               }
//                               p++;
//                             }
//                           }];
//               }];
//   }
// }

#pragma mark - Gesture Recognizer

- (void)tapped:(UITapGestureRecognizer *)tap {
  _L();
  CGPoint point = [tap locationInView:_scrollView];
  HomeItemView *itemView = [self itemViewAtPoint:point];
  if (itemView)
    [_delegate itemTapped:itemView.item];
}

- (void)longPressed:(UILongPressGestureRecognizer *)longPress {
  @synchronized (self) {
    CGPoint point = [longPress locationInView:_scrollView];
    switch (longPress.state) {
    case UIGestureRecognizerStateBegan: {
      // _L(@"UIGestureRecognizerStateBegan");
      int index = 0;
      for (HomeItemView *itemView in _itemViews[self.currentPage]) {
        if (CGRectContainsPoint(itemView.frame, point)) {
          _draggingView = itemView;
          _draggingView.alpha = 0.7;
          _draggingView.center = point;
          _draggingViewIndex = index;
          [_scrollView bringSubviewToFront:_draggingView];
          _scrollView.scrollEnabled = NO;
          [_itemViews addObject:NSMutableArray.new];
          [self setPageState];
          [self startPagingTimer];
          for (NSArray *itemViewsInPage in _itemViews) {
            for (HomeItemView *itemView in itemViewsInPage) {
              [itemView startAnimating];
            }
          }
          [_delegate itemDidBeginDragging:_draggingView.item];
          break;
        }
        index++;
      }
      break;
    }
    case UIGestureRecognizerStateChanged: {
      // _L(@"UIGestureRecognizerStateChanged");
      if (!_draggingView)
        break;
      _draggingView.center = point;
      [_delegate itemDidMove:_draggingView.item inRemoveArea:point.y < 0];
      [self sortItemViewsInCurrentPage];
      [self setItemViewsInCurrentPage];
      break;
    }
    case UIGestureRecognizerStateEnded: {
      // _L(@"UIGestureRecognizerStateEnded");
      NSString *item = _draggingView.item;
      BOOL inRemoveArea = point.y < 0;
      [self endPagingTimer];
      [self sortItemViewsInCurrentPage];
      _draggingView.alpha = 1.0;
      _draggingView = nil;
      [self finishSorting];
      _scrollView.scrollEnabled = YES;
      for (NSArray *itemViewsInPage in _itemViews) {
        for (HomeItemView *itemView in itemViewsInPage) {
          [itemView endAnimating];
        }
      }
      [_delegate itemDidEndDragging:item inRemoveArea:inRemoveArea];
      break;
    }
    default:
      break;
    }
  }
}

#pragma mark - Sorting

- (void)sortItemViewsInCurrentPage {
  int currentPage = [self currentPage];
  if (_itemViews.count == currentPage)
    return;

  if (!_draggingView)
    return;

  int newIndex = [self indexForDraggingView];
  if (_draggingViewIndex == newIndex)
    return;
  _L(@"newIndex : %d", newIndex);
  _draggingViewIndex = newIndex;

  NSMutableArray *itemViewsInPage = _itemViews[currentPage];
  [itemViewsInPage removeObject:_draggingView];
  [itemViewsInPage insertObject:_draggingView atIndex:MIN(itemViewsInPage.count, newIndex)];
}

- (void)setItemViewsInCurrentPage {
  [UIView animateWithDuration:0.2 animations:^{
      int currentPage = [self currentPage];
      int index = 0;
      for (HomeItemView *itemView in _itemViews[currentPage]) {
        if (_draggingView != itemView) {
          if (index < 6) {
            itemView.hidden = NO;
          } else {
            itemView.hidden = YES;
          }
          itemView.frame = [self itemViewFrameWithIndex:index inPage:currentPage];
        }
        index++;
      }
    }];
}

- (void)finishSorting {
  _L();
  NSArray *moveItemViews;
  for (NSMutableArray *itemViewsInPage in _itemViews) {
    if (moveItemViews && moveItemViews.count) {
      NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, moveItemViews.count)];
      [itemViewsInPage insertObjects:moveItemViews atIndexes:indexSet];
      moveItemViews = nil;
    }
    if (6 < itemViewsInPage.count) {
      NSRange range = NSMakeRange(6, itemViewsInPage.count - 6);
      moveItemViews = [itemViewsInPage subarrayWithRange:range];
      [itemViewsInPage removeObjectsInRange:range];
    }
  }

  NSMutableArray *emptyItemViews = NSMutableArray.new;
  for (NSMutableArray *itemViewsInPage in _itemViews) {
    if (!itemViewsInPage.count)
      [emptyItemViews addObject:itemViewsInPage];
  }
  [_itemViews removeObjectsInArray:emptyItemViews];
  [self setPageState];

  [self setItemViewsInCurrentPage];

  int currentPage = [self currentPage];
  int page = 0;
  for (NSArray *itemViewsInPage in _itemViews) {
    if (page != currentPage) {
      int index = 0;
      for (HomeItemView *itemView in itemViewsInPage) {
        itemView.hidden = NO;
        itemView.frame = [self itemViewFrameWithIndex:index inPage:page];
        index++;
      }
    }
    page++;
  }

  NSMutableArray *itemLists = NSMutableArray.new;
  for (NSArray *itemViewsInPage in _itemViews) {
    NSMutableArray *itemList = NSMutableArray.new;
    for (HomeItemView *itemView in itemViewsInPage) {
      [itemList addObject:itemView.item];
    }
    [itemLists addObject:itemList];
  }

  // TODO
  // [App.app.itemListManager saveItemLists:itemLists];
}

#pragma mark - Paging

- (void)setPageState {
  _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _itemViews.count, _scrollView.frame.size.height);
  _pageControl.numberOfPages = _itemViews.count;
  _pageControl.currentPage = [self currentPage];
}

- (void)startPagingTimer {
  _L();
  if (_pagingTimer)
    [_pagingTimer invalidate];
  _pagingType = PagingTypeNone;
  _pagingTimer = [NSTimer scheduledTimerWithTimeInterval:0.4
                          target:self
                          selector:@selector(pagingTimer:)
                          userInfo:nil
                          repeats:YES];
}

- (void)endPagingTimer {
  _L();
  _pagingType = PagingTypeNone;
  [_pagingTimer invalidate];
  _pagingTimer = nil;
}

- (void)pagingTimer:(NSTimer *)timer {
  _L();
  if (!_draggingView) {
    [self endPagingTimer];
    return;
  }
  int currentPage = [self currentPage];
  CGFloat pagingMargin = 44;

  CGFloat pagingLeftX = _scrollView.frame.size.width * currentPage + pagingMargin;
  if (_draggingView.center.x < pagingLeftX) {
    if (PagingTypeLeft == _pagingType) {
      _L(@"Paging to Left!");
      [self paging:PagingTypeLeft];
      _pagingType = PagingTypeNone;
      return;
    }
    _L(@"Set _pagingType = PagingTypeLeft");
    _pagingType = PagingTypeLeft;
    return;
  }

  CGFloat pagingRightX = _scrollView.frame.size.width * (currentPage + 1) - pagingMargin;
  if (pagingRightX < _draggingView.center.x) {
    if (PagingTypeRight == _pagingType) {
      _L(@"Paging to right!");
      [self paging:PagingTypeRight];
      _pagingType = PagingTypeNone;
      return;
    }
    _L(@"Set _pagingType = PagingTypeRight");
    _pagingType = PagingTypeRight;
    return;
  }

  _pagingType = PagingTypeNone;
}

- (void)paging:(PagingType)pagingType {
  _L();
  int currentPage = [self currentPage];
  if (PagingTypeLeft == pagingType) {
    if (0 == currentPage)
      return;
  } else {
    if (_itemViews.count - 1 <= currentPage)
      return;
  }

  int nextPage = pagingType == PagingTypeLeft ? currentPage - 1 : currentPage + 1;
  int index = [self indexForDraggingView];

  NSMutableArray *itemViewsInCurrentPage = _itemViews[currentPage];
  [itemViewsInCurrentPage removeObject:_draggingView];

  NSMutableArray *itemViewsInNextPage = _itemViews[nextPage];
  [itemViewsInNextPage insertObject:_draggingView atIndex:MIN(itemViewsInNextPage.count, index)];

  [self setItemViewsInCurrentPage];

  [UIView animateWithDuration:0.2
          animations:^{
              CGFloat moveX = pagingType == PagingTypeLeft ? -_scrollView.frame.size.width : _scrollView.frame.size.width;
              _draggingView.center = CGPointMake(_draggingView.center.x + moveX, _draggingView.center.y);
              _scrollView.contentOffset = CGPointMake(_scrollView.contentOffset.x + moveX, 0);
            }
          completion:^(BOOL finished) {
              [self sortItemViewsInCurrentPage];
              [self setItemViewsInCurrentPage];
            }];
}

#pragma mark - Property

- (int)currentPage {
  return (_scrollView.contentOffset.x + _scrollView.frame.size.width * 0.5) / _scrollView.frame.size.width;
}

- (int)indexForDraggingView {
  int currentPage = [self currentPage];
  int x = (_draggingView.center.x - self.bounds.size.width * currentPage) / (self.bounds.size.width / 3);
  int y = _draggingView.center.y / (self.bounds.size.height / 2);
  return x + y * 3;
}

- (CGRect)itemViewFrameWithIndex:(int)index inPage:(int)page {
  CGFloat pageOffsetX = self.bounds.size.width * page;
  CGFloat width = (self.bounds.size.width - 16) / 3;
  CGFloat height = (self.bounds.size.height - 24) / 2;
  return CGRectMake(pageOffsetX + 8 + width * (index % 3),
                    8 + height * (index / 3),
                    width,
                    height);
}

- (HomeItemView *)itemViewAtPoint:(CGPoint)point {
  int currentPage = [self currentPage];
  int x = (point.x - self.bounds.size.width * currentPage) / (self.bounds.size.width / 3);
  int y = point.y / (self.bounds.size.height / 2);
  int index = x + y * 3;
  NSArray *itemViewsInPage = _itemViews[currentPage];
  if (index < itemViewsInPage.count)
    return itemViewsInPage[index];
  return nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  _pageControl.currentPage = [self currentPage];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (scrollView.decelerating)
    return;
  [self indexChanged];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  [self indexChanged];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
  [self indexChanged];
}

- (void)indexChanged {
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(indexChangedAfterDelay) object:nil];
  [self performSelector:@selector(indexChangedAfterDelay) withObject:nil afterDelay:0.8];
}

- (void)indexChangedAfterDelay {
  // [App.app setCurrentItemListIndex:[self currentPage]];
}

@end
