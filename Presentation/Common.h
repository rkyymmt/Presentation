#import <Foundation/Foundation.h>

#if DEBUG
#define _L(message, ...) NSLog((@"%04d:%s " message), __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__)
#else
#define _L(message, ...) (void)0
#endif

#define CR_POINTS_ONE                                                 \
  @"f72cf730f730f733f838fb3dfd430047024b054f0650075007500750074f074f" \
  @"084c0847093c092b091f091209f909e109cc09be09b509b109af09af0aaf0aaf"

#define CR_POINTS_TWO                                                 \
  @"daf3d2f6cff8cdfcc804c709c719c924ce2fd439d940e047e84bf24dfd4d064c" \
  @"163f1f2f200d1b0013f2fed7dbbac7b2cab2ccb2e4b7f5b926bd2fbe39be3abe"

#define CR_POINTS_THREE                                               \
  @"d516d01cd025d02cd536db40e448ee4ef851045210511a4b243b1d1b0b0cef02" \
  @"0e0623fc2fef31d72ec825bd18b308aefaadeeade4b0dcb7d6c1d3c8d1cdd0d4"

#define CR_POINTS_FOUR                                                \
  @"25591f551f5513490138ef25cc02c1f7b9f1b6edb4ecc6eeedf017f037f142f3" \
  @"48f44cf54df64df74df845fe4001360d2c1725172417231722ef1fbb1fa61fa7"

@interface Common : NSObject
@end
