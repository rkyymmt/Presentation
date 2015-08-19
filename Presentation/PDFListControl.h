#import <UIKit/UIKit.h>

@protocol PDFListControlDelegate
- (void)listControlDidSelectIndex:(int)index;
- (void)listControlPrev;
- (void)listControlNext;
- (void)listControlTapped;
@end

@interface PDFListControl : UIView
- (instancetype)initWithDelegate:(id<PDFListControlDelegate>)delegate;
@end
