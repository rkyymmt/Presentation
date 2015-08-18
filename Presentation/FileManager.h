#import <UIKit/UIKit.h>

@interface FileManager : NSObject
+ (FileManager *)fileManager;
- (void)reload;
- (NSArray *)itemLists;
- (UIImage *)imageWithItem:(NSString *)item;
@end
