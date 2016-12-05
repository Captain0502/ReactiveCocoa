#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
void _racLifetimeNewDeallocImplementation(Class baseClass, void* lifetimeTokenKey);

@interface NSObject (RACObjCRuntimeUtilities)

/// Register a block which would be triggered when `selector` is called.
///
/// Warning: The callee is responsible for synchronization.
-(BOOL) _rac_setupInvocationObservationForSelector:(SEL)selector protocol:(nullable Protocol *)protocol receiver:(void (^)(void)) receiver;

@end
NS_ASSUME_NONNULL_END
