#if !canImport(Darwin)
import Synchronization
typealias Mutex = Synchronization.Mutex
#else
import Darwin

public struct Mutex<Value: ~Copyable>: ~Copyable, @unchecked Sendable {
    let lock = os_unfair_lock_t.allocate(capacity: 1)
    let value = UnsafeMutablePointer<Value>.allocate(capacity: 1)

    public init(_ initialValue: consuming sending Value) {
        self.lock.initialize(to: os_unfair_lock())
        self.value.initialize(to: initialValue)
    }

    deinit {
        self.lock.deinitialize(count: 1)
        self.lock.deallocate()

        self.value.deinitialize(count: 1)
        self.value.deallocate()
    }

    public borrowing func withLock<Result: ~Copyable, E: Error>(
        _ body: (inout sending Value) throws(E) -> sending Result
    ) throws(E) -> sending Result {
        os_unfair_lock_lock(self.lock)
        defer { os_unfair_lock_unlock(self.lock) }

        return try body(&value.pointee)
    }

    public borrowing func withLockIfAvailable<Result: ~Copyable, E: Error>(
        _ body: (inout sending Value) throws(E) -> sending Result
    ) throws(E) -> sending Result? {
        guard os_unfair_lock_trylock(self.lock) else { return nil }
        defer { os_unfair_lock_unlock(self.lock) }

        return try body(&value.pointee)
    }
}
#endif
