import Foundation
import ReactiveSwift

private var lifetimeKey: UInt8 = 0
private var lifetimeTokenKey: UInt8 = 0

extension Reactive where Base: NSObject {
	/// Returns a lifetime that ends when the object is deallocated.
	@nonobjc public var lifetime: Lifetime {
		return base.synchronized {
			if let lifetime = objc_getAssociatedObject(base, &lifetimeKey) as! Lifetime? {
				return lifetime
			}

			let token = Lifetime.Token()
			let lifetime = Lifetime(token)

			let objcClass: AnyClass = (base as AnyObject).objcClass

			// Swizzle `-dealloc` so that the lifetime token is released at the
			// beginning of the deallocation chain, and only after the KVO `-dealloc`.
			objc_sync_enter(objcClass)
			if objc_getAssociatedObject(objcClass, &lifetimeKey) == nil {
				objc_setAssociatedObject(objcClass, &lifetimeKey, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
				_racLifetimeNewDeallocImplementation(objcClass, &lifetimeTokenKey)
			}
			objc_sync_exit(objcClass)

			objc_setAssociatedObject(base, &lifetimeTokenKey, token, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			objc_setAssociatedObject(base, &lifetimeKey, lifetime, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

			return lifetime
		}
	}
}

@objc private protocol ObjCClassReporting {
	@objc(class)
	var objcClass: AnyClass { get }
}
