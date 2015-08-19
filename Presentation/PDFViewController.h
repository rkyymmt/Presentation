#import <UIKit/UIKit.h>

@interface PDFViewController : UIViewController
- (instancetype)initWithItem:(NSString *)item;
- (void)prev;
- (void)next;
- (void)reload;
- (void)setPage:(int)page;
- (void)list;
- (void)listPrev;
- (void)listNext;
- (void)setPageInList:(int)indexInList;
@end
