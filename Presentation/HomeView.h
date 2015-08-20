#import <UIKit/UIKit.h>

@protocol HomeViewDelegate
- (void)itemTapped:(NSString *)item;
- (void)itemDidBeginDragging:(NSString *)item;
- (void)itemDidMove:(NSString *)item inRemoveArea:(BOOL)inRemoveArea;
- (void)itemDidEndDragging:(NSString *)item inRemoveArea:(BOOL)inRemoveArea;
@end

@interface HomeView : UIView
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<HomeViewDelegate>)delegate;
- (void)removeItem:(NSString *)item;
@end
