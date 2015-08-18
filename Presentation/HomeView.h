#import <UIKit/UIKit.h>

@protocol HomeViewDelegate
- (void)itemTapped:(NSString *)item;
@end

@interface HomeView : UIView
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<HomeViewDelegate>)delegate;
// - (void)reloadActionAtIndex:(int)index inPage:(int)page;
// - (void)removeActionAtIndex:(int)index inPage:(int)page;
@end
