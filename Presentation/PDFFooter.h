#import <UIKit/UIKit.h>

@protocol PDFFooterDelegate
- (void)PDFFooterButtonPressed:(int)index;
@end

@interface PDFFooter : UIView
- (instancetype)initWithDelegate:(id<PDFFooterDelegate>)delegate;
@end
