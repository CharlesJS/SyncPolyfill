// Adapted from tests at:
// https://github.com/swiftlang/swift/blob/4afc2d4d6d358dca2c87310b7d9c7e5f9160ff13/unittests/Threading/LockingHelpers.h

import Foundation
import Testing
@testable import SyncPolyfill

// Test that a Mutex object can be locked and unlocked from a single thread
@Test func basicLockable() {
    let mutex = Mutex<Int>(0)

    // We can lock, unlock, lock and unlock an unlocked lock
    mutex.withLock { $0 += 1 }
    mutex.withLock { $0 += 1 }

    #expect(mutex.withLock { $0 } == 2)
}

// Test that a Mutex object's try_lock() method works.
@Test func tryLockable() {
    let mutex = Mutex<String>("")

    // We can lock an unlocked lock
    mutex.withLock { value in
        value = "Foo"

        // We cannot lock a locked lock
        #expect(mutex.withLockIfAvailable { $0 == "Bar" } == nil)
    }

    #expect(mutex.withLock { $0 } == "Foo")
}

// Test that a Mutex object can be locked and unlocked
@Test func basicLockableThreaded() {
    let mutex = Mutex<Int>(0)
    let queue = OperationQueue()

    for _ in 0..<10 {
        queue.addOperation {
            for _ in 0..<50 {
                mutex.withLock { $0 += 1 }
            }
        }
    }

    queue.waitUntilAllOperationsAreFinished()
    #expect(mutex.withLockIfAvailable { $0 } == 500)
}

@Test func lockableThreaded() {
    let mutex = Mutex<Int>(0)
    let queue = OperationQueue()

    mutex.withLock { _ in
        for _ in 0..<5 {
            queue.addOperation {
                #expect(mutex.withLockIfAvailable { _ in } == nil)
            }
        }

        queue.waitUntilAllOperationsAreFinished()
    }

    queue.addOperation {
        #expect(mutex.withLockIfAvailable { $0 } == 0)
    }

    queue.waitUntilAllOperationsAreFinished()

    for _ in 0..<10 {
        queue.addOperation {
            for _ in 0..<50 {
                while mutex.withLockIfAvailable({ $0 += 1 }) == nil {}
            }
        }
    }

    queue.waitUntilAllOperationsAreFinished()
    #expect(mutex.withLockIfAvailable { $0 } == 500)
}
