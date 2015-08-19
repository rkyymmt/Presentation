#import <UIKit/UIKit.h>

@interface PDFViewController : UIViewController
- (instancetype)initWithItem:(NSString *)item;
- (void)prev;
- (void)next;
- (void)reload;
- (void)list;
- (void)setPageInList:(int)indexInList;
@end
