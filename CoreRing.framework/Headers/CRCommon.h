#import <UIKit/UIKit.h>


// Ring

typedef NS_ENUM(int, CRRingEvent) {
  CRRingEventTap,
  CRRingEventLongPress
};

typedef NS_ENUM(int, CRRingMode) {
  CRRingModeGesture,
  CRRingModeQuaternion,
  CRRingModePoint
};

typedef struct {
  float w;
  float x;
  float y;
  float z;
} CRQuaternion;


// Error

#define CR_ERROR_DOMAIN @"jp.logbar.corering"

typedef NS_ENUM(int, CRErrorCode) {
  CRErrorCodeUnknown = -1,
  CRErrorCodeSuccess,
  CRErrorCodeInvalidPoints,
  CRErrorCodeSQLiteError
};


// Gesture

#define CR_POINTS_LEFT     @"64dc5cdc55dc4ddc3fdc2fdc1ddc09dcf1dddeddcbddb8ddacdda3dd9fdc9ddc9ddc9ddc9edc9fdca0dca1dca6e1b1ecc0face08dc15e41ee922ea24eb25eb25"
#define CR_POINTS_RIGHT    @"a2e3a7e2b0e2c0e2d3e1ece002df19df2cdf3edf4cdf56e05be15ee25fe35ee35de35de35be456e94bf23dfe300a26131e19191d142113221322142214221621"
#define CR_POINTS_UP       @"1d9f17a417a917b417c417d717e417f1170918221835184718511859165e14611362126212621162116210610d5c054ffc3ef22deb20e718e514e411e412e514"
#define CR_POINTS_DOWN     @"dc69db62db59db49db3adb2cdb19db07dbf7dbe7dbdadbcddbc3dbb9ddabdfa0e09be198e198e298e29ae8a1f3aefcb805c20dca16d220da24de25df26df26df"
#define CR_POINTS_CIRCLE   @"d7a5cba7bcb2b0c3a7d8a3e5a1f3a222a62fac3bb347bc51d260df65f96b1b6b2668395d4851533f5c2b601960fc5ff05bd557c94cb744ae32a1279b1b97f89a"
#define CR_POINTS_HEART    @"ebd5e6d9e1e0dce7d7efd2f8cc04c80fc519c525c530c53ace48d34ede54e854f04af838fe1cff1c0531215135523d403d2b3c1c310319e20ed6f7c3d8afd2ad"
#define CR_POINTS_TRIANGLE @"e611e20ddc06d4fac9ebc0dcb9d1a5b5a3b0a1aea0adb5adbcadc8addaad09b036b253b25fb361b460b45db759bb52c349cf3de12ff81f110d28fe3cf050ee54"
#define CR_POINTS_PIGTALE  @"abe4a9d6aec2b4b8c3accfaadaaae6b1f2befccd0ef6140c16201731174f0c57fd57f454e745e338e314e403ebe5f0d700c009b915b521b432b540bf4dcb57f5"


// Helper

@interface CRCommon : NSObject

+ (UIImage *)imageWithPoints:(NSString *)points
                       width:(CGFloat)width
                   lineColor:(UIColor *)lineColor
                  pointColor:(UIColor *)pointColor;

@end
