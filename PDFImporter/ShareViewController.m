#import "ShareViewController.h"
#import "Common.h"
@import MobileCoreServices;

@interface ShareViewController ()
@end

@implementation ShareViewController {
  UIActivityIndicatorView *_indicator;
}

- (void)viewDidLoad {
  _L();
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];

  _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  _indicator.frame = self.view.bounds;
  [_indicator startAnimating];
  [self.view addSubview:_indicator];

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [self importPDF];
    });
}

- (void)importPDF {
  _L();
  if (!self.extensionContext.inputItems.count) {
    [self showAlertWithTitle:@"Error" message:@"Parameter is not valid."];
    return;
  }

  NSExtensionItem *item = self.extensionContext.inputItems[0];
  _L(@"%@", item);
  for (NSItemProvider *provider in item.attachments) {
    if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
      [provider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error) {
          [self itemDidLoad:url error:error];
        }];
      break;
    }
    if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeFileURL]) {
      [provider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error) {
          [self itemDidLoad:url error:error];
        }];
      break;
    }
  }
}

- (void)itemDidLoad:(NSURL *)url error:(NSError *)error {
  _L(@"%@", url);
  if (error) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlertWithTitle:@"Error" message:error.localizedDescription];
      });
    return;
  }
  if (NSOrderedSame != [@"pdf" caseInsensitiveCompare:url.pathExtension]) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlertWithTitle:@"Error" message:@"You can import only a PDF file."];
      });
    return;
  }

  NSError *dataError;
  NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&dataError];
  if (dataError) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlertWithTitle:@"Error" message:dataError.localizedDescription];
      });
    return;
  }

  NSString *groupId = @"group.jp.logbar.ring.Presentation";
  NSURL *containerURL = [NSFileManager.defaultManager containerURLForSecurityApplicationGroupIdentifier:groupId];
  NSURL *fileURL = [containerURL URLByAppendingPathComponent:url.lastPathComponent];
  _L(@"%@", fileURL);
  NSError *fileError;
  [data writeToURL:fileURL options:NSDataWritingAtomic error:&fileError];
  if (fileError) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlertWithTitle:@"Error" message:fileError.localizedDescription];
      });
    return;
  }
  dispatch_async(dispatch_get_main_queue(), ^{
      [_indicator stopAnimating];
      [self showAlertWithTitle:@"Presentation" message:@"PDF file has been imported successfully."];
    });
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
  _L();
  UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                message:message
                                                preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
      [self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
      [alert dismissViewControllerAnimated:YES completion:nil];
    }];
  [alert addAction:ok];
  [self presentViewController:alert animated:YES completion:nil];
}

@end
