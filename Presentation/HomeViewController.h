#import <UIKit/UIKit.h>
#import "PDFViewController.h"

@interface HomeViewController : UIViewController
- (PDFViewController *)pdfViewController;
- (void)openURL:(NSURL *)url;
@end
