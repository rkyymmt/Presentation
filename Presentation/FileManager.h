#import <UIKit/UIKit.h>

@interface FileManager : NSObject
+ (FileManager *)fileManager;
- (void)reload;
- (NSArray *)itemLists;
- (UIImage *)thumbnailForItem:(NSString *)item;
- (int)numberOfPages:(NSString *)item;
- (UIImage *)imageWithItem:(NSString *)item page:(int)page;
@end
