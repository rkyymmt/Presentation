#import <UIKit/UIKit.h>

@protocol PDFListControlDelegate
- (void)listControlDidSelectIndex:(int)index;
- (void)listControlPrev;
- (void)listControlNext;
- (void)listControlTapped;
@end

@interface PDFListControl : UIView
@property (nonatomic, strong) NSArray<UIButton *> *numberButtons;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
- (instancetype)initWithDelegate:(id<PDFListControlDelegate>)delegate;
@end
