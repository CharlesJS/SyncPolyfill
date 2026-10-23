import Foundation
@testable import SyncPolyfill
import Testing

enum AtomicLoadOrdering: CaseIterable {
    case acquiring
    case relaxed
    case sequentiallyConsistent
}

enum AtomicStoreOrdering: CaseIterable {
    case relaxed
    case releasing
    case sequentiallyConsistent
}

enum AtomicUpdateOrdering: CaseIterable {
    case acquiring
    case acquiringAndReleasing
    case relaxed
    case releasing
    case sequentiallyConsistent
}

private func strongCompareExchange(
    _ a: borrowing Atomic<Int>,
    expected: Int,
    desired: Int,
    success: AtomicUpdateOrdering,
    failure: AtomicLoadOrdering
) -> (exchanged: Bool, original: Int) {
    switch (success, failure) {
    case (.acquiring, .acquiring):
        a.compareExchange(expected: expected, desired: desired, successOrdering: .acquiring, failureOrdering: .acquiring)
    case (.acquiring, .relaxed):
        a.compareExchange(expected: expected, desired: desired, successOrdering: .acquiring, failureOrdering: .relaxed)
    case (.acquiring, .sequentiallyConsistent):
        a.compareExchange(expected: expected, desired: desired, successOrdering: .acquiring, failureOrdering: .sequentiallyConsistent)
    case (.acquiringAndReleasing, .acquiring):
        a.compareExchange(expected: expected, desired: desired, successOrdering: .acquiringAndReleasing, failureOrdering: .acquiring)
    case (.acquiringAndReleasing, .relaxed):
        a.compareExchange(
            expected: expected,
            desired: desired,
            successOrdering: .acquiringAndReleasing,
            failureOrdering: .relaxed
        )
    case (.acquiringAndReleasing, .sequentiallyConsistent):
        a.compareExchange(
            expected: expected,
            desired: desired,
            successOrdering: .acquiringAndReleasing,
            failureOrdering: .sequentiallyConsistent
        )
    case (.relaxed, .acquiring):
        a.compareExchange(expected: expected, desired: desired, successOrdering: .relaxed, failureOrdering: .acquiring)
    case (.relaxed, .relaxed):
        a.compareExchange(expected: expected, desired: desired, successOrdering: .relaxed, failureOrdering: .relaxed)
    case (.relaxed, .sequentiallyConsistent):
        a.compareExchange(expected: expected, desired: desired, successOrdering: .relaxed, failureOrdering: .sequentiallyConsistent)
    case (.releasing, .acquiring):
        a.compareExchange(expected: expected, desired: desired, successOrdering: .releasing, failureOrdering: .acquiring)
    case (.releasing, .relaxed):
        a.compareExchange(expected: expected, desired: desired, successOrdering: .releasing, failureOrdering: .relaxed)
    case (.releasing, .sequentiallyConsistent):
        a.compareExchange(
            expected: expected,
            desired: desired,
            successOrdering: .releasing,
            failureOrdering: .sequentiallyConsistent
        )
    case (.sequentiallyConsistent, .acquiring):
        a.compareExchange(
            expected: expected,
            desired: desired,
            successOrdering: .sequentiallyConsistent,
            failureOrdering: .acquiring
        )
    case (.sequentiallyConsistent, .relaxed):
        a.compareExchange(
            expected: expected,
            desired: desired,
            successOrdering: .sequentiallyConsistent,
            failureOrdering: .relaxed
        )
    case (.sequentiallyConsistent, .sequentiallyConsistent):
        a.compareExchange(
            expected: expected,
            desired: desired,
            successOrdering: .sequentiallyConsistent,
            failureOrdering: .sequentiallyConsistent
        )
    }
}

private func weakCompareExchange(
    _ a: borrowing Atomic<Int>,
    expected: Int,
    desired: Int,
    success: AtomicUpdateOrdering,
    failure: AtomicLoadOrdering
) -> (exchanged: Bool, original: Int) {
    switch (success, failure) {
    case (.acquiring, .acquiring):
        a.weakCompareExchange(expected: expected, desired: desired, successOrdering: .acquiring, failureOrdering: .acquiring)
    case (.acquiring, .relaxed):
        a.weakCompareExchange(expected: expected, desired: desired, successOrdering: .acquiring, failureOrdering: .relaxed)
    case (.acquiring, .sequentiallyConsistent):
        a.weakCompareExchange(expected: expected, desired: desired, successOrdering: .acquiring, failureOrdering: .sequentiallyConsistent)
    case (.acquiringAndReleasing, .acquiring):
        a.weakCompareExchange(
            expected: expected,
            desired: desired,
            successOrdering: .acquiringAndReleasing,
            failureOrdering: .acquiring
        )
    case (.acquiringAndReleasing, .relaxed):
        a.weakCompareExchange(
            expected: expected,
            desired: desired,
            successOrdering: .acquiringAndReleasing,
            failureOrdering: .relaxed
        )
    case (.acquiringAndReleasing, .sequentiallyConsistent):
        a.weakCompareExchange(
            expected: expected,
            desired: desired,
            successOrdering: .acquiringAndReleasing,
            failureOrdering: .sequentiallyConsistent
        )
    case (.relaxed, .acquiring):
        a.weakCompareExchange(expected: expected, desired: desired, successOrdering: .relaxed, failureOrdering: .acquiring)
    case (.relaxed, .relaxed):
        a.weakCompareExchange(expected: expected, desired: desired, successOrdering: .relaxed, failureOrdering: .relaxed)
    case (.relaxed, .sequentiallyConsistent):
        a.weakCompareExchange(expected: expected, desired: desired, successOrdering: .relaxed, failureOrdering: .sequentiallyConsistent)
    case (.releasing, .acquiring):
        a.weakCompareExchange(expected: expected, desired: desired, successOrdering: .releasing, failureOrdering: .acquiring)
    case (.releasing, .relaxed):
        a.weakCompareExchange(expected: expected, desired: desired, successOrdering: .releasing, failureOrdering: .relaxed)
    case (.releasing, .sequentiallyConsistent):
        a.weakCompareExchange(expected: expected, desired: desired, successOrdering: .releasing, failureOrdering: .sequentiallyConsistent)
    case (.sequentiallyConsistent, .acquiring):
        a.weakCompareExchange(
            expected: expected,
            desired: desired,
            successOrdering: .sequentiallyConsistent,
            failureOrdering: .acquiring
        )
    case (.sequentiallyConsistent, .relaxed):
        a.weakCompareExchange(
            expected: expected,
            desired: desired,
            successOrdering: .sequentiallyConsistent,
            failureOrdering: .relaxed
        )
    case (.sequentiallyConsistent, .sequentiallyConsistent):
        a.weakCompareExchange(
            expected: expected,
            desired: desired,
            successOrdering: .sequentiallyConsistent,
            failureOrdering: .sequentiallyConsistent
        )
    }
}

@Suite("Atomic basic tests")
struct BasicOperationTests {
    @Test(arguments: AtomicLoadOrdering.allCases)
    func initAndLoad(ordering: AtomicLoadOrdering) {
        let a = Atomic(42)

        switch ordering {
        case .acquiring: #expect(a.load(ordering: .acquiring) == 42)
        case .relaxed: #expect(a.load(ordering: .relaxed) == 42)
        case .sequentiallyConsistent: #expect(a.load(ordering: .sequentiallyConsistent) == 42)
        }
    }

    @Test
    func initBool() {
        let t = Atomic(true)
        let f = Atomic(false)
        #expect(t.load(ordering: .relaxed) == true)
        #expect(f.load(ordering: .relaxed) == false)
    }

    @Test(arguments: AtomicStoreOrdering.allCases)
    func store(ordering: AtomicStoreOrdering) {
        let a = Atomic(0)

        switch ordering {
        case .relaxed: a.store(7, ordering: .relaxed)
        case .releasing: a.store(7, ordering: .releasing)
        case .sequentiallyConsistent: a.store(7, ordering: .sequentiallyConsistent)
        }

        #expect(a.load(ordering: .relaxed) == 7)
    }

    @Test(arguments: AtomicUpdateOrdering.allCases)
    func exchange(ordering: AtomicUpdateOrdering) {
        let a = Atomic(1)

        switch ordering {
        case .acquiring: #expect(a.exchange(2, ordering: .acquiring) == 1)
        case .acquiringAndReleasing: #expect(a.exchange(2, ordering: .acquiringAndReleasing) == 1)
        case .relaxed: #expect(a.exchange(2, ordering: .relaxed) == 1)
        case .releasing: #expect(a.exchange(2, ordering: .releasing) == 1)
        case .sequentiallyConsistent: #expect(a.exchange(2, ordering: .sequentiallyConsistent) == 1)
        }

        #expect(a.load(ordering: .relaxed) == 2)
    }

    @Test
    func exchangeBool() {
        let a = Atomic(false)
        #expect(a.exchange(true, ordering: .relaxed) == false)
        #expect(a.exchange(true, ordering: .relaxed) == true)
        #expect(a.load(ordering: .relaxed) == true)
    }
}

@Suite("Atomic compareExchange tests")
struct CompareExchangeTests {
    @Test(arguments: AtomicUpdateOrdering.allCases)
    func strongSucceedsWhenExpectedMatches(ordering: AtomicUpdateOrdering) {
        let a = Atomic(10)
        let r: (exchanged: Bool, original: Int)

        switch ordering {
        case .acquiring: r = a.compareExchange(expected: 10, desired: 20, ordering: .acquiring)
        case .acquiringAndReleasing: r = a.compareExchange(expected: 10, desired: 20, ordering: .acquiringAndReleasing)
        case .relaxed: r = a.compareExchange(expected: 10, desired: 20, ordering: .relaxed)
        case .releasing: r = a.compareExchange(expected: 10, desired: 20, ordering: .releasing)
        case .sequentiallyConsistent: r = a.compareExchange(expected: 10, desired: 20, ordering: .sequentiallyConsistent)
        }

        #expect(r.exchanged)
        #expect(r.original == 10)
        #expect(a.load(ordering: .relaxed) == 20)
    }

    @Test(arguments: AtomicUpdateOrdering.allCases)
    func strongFailsWhenExpectedDiffers(ordering: AtomicUpdateOrdering) {
        let a = Atomic(10)
        let r: (exchanged: Bool, original: Int)

        switch ordering {
        case .acquiring: r = a.compareExchange(expected: 99, desired: 20, ordering: .acquiring)
        case .acquiringAndReleasing: r = a.compareExchange(expected: 99, desired: 20, ordering: .acquiringAndReleasing)
        case .relaxed: r = a.compareExchange(expected: 99, desired: 20, ordering: .relaxed)
        case .releasing: r = a.compareExchange(expected: 99, desired: 20, ordering: .releasing)
        case .sequentiallyConsistent: r = a.compareExchange(expected: 99, desired: 20, ordering: .sequentiallyConsistent)
        }

        #expect(!r.exchanged)
        #expect(r.original == 10)
        #expect(a.load(ordering: .relaxed) == 10)
    }

    @Test(arguments: AtomicUpdateOrdering.allCases, AtomicLoadOrdering.allCases)
    func strongWithSeparateOrderings(success: AtomicUpdateOrdering, failure: AtomicLoadOrdering) {
        let a = Atomic(1)

        let hit = strongCompareExchange(a, expected: 1, desired: 2, success: success, failure: failure)
        #expect(hit.exchanged && hit.original == 1)

        let miss = strongCompareExchange(a, expected: 1, desired: 3, success: success, failure: failure)
        #expect(!miss.exchanged && miss.original == 2)
        #expect(a.load(ordering: .relaxed) == 2)
    }

    // A weak compare-exchange may fail spuriously, so success is tested
    // by retrying. A failure must never write.
    @Test(arguments: AtomicUpdateOrdering.allCases)
    func weakEventuallySucceedsWhenExpectedMatches(ordering: AtomicUpdateOrdering) {
        let a = Atomic(10)
        var result: (exchanged: Bool, original: Int)

        repeat {
            switch ordering {
            case .acquiring: result = a.weakCompareExchange(expected: 10, desired: 20, ordering: .acquiring)
            case .acquiringAndReleasing: result = a.weakCompareExchange(expected: 10, desired: 20, ordering: .acquiringAndReleasing)
            case .relaxed: result = a.weakCompareExchange(expected: 10, desired: 20, ordering: .relaxed)
            case .releasing: result = a.weakCompareExchange(expected: 10, desired: 20, ordering: .releasing)
            case .sequentiallyConsistent: result = a.weakCompareExchange(expected: 10, desired: 20, ordering: .sequentiallyConsistent)
            }

            if !result.exchanged {
                #expect(result.original == 10)
                #expect(a.load(ordering: .relaxed) == 10)
            }
        } while !result.exchanged

        #expect(result.original == 10)
        #expect(a.load(ordering: .relaxed) == 20)
    }

    @Test(arguments: AtomicUpdateOrdering.allCases)
    func weakFailsWhenExpectedDiffers(ordering: AtomicUpdateOrdering) {
        let a = Atomic(10)
        let r: (exchanged: Bool, original: Int)

        switch ordering {
        case .acquiring: r = a.weakCompareExchange(expected: 99, desired: 20, ordering: .acquiring)
        case .acquiringAndReleasing: r = a.weakCompareExchange(expected: 99, desired: 20, ordering: .acquiringAndReleasing)
        case .relaxed: r = a.weakCompareExchange(expected: 99, desired: 20, ordering: .relaxed)
        case .releasing: r = a.weakCompareExchange(expected: 99, desired: 20, ordering: .releasing)
        case .sequentiallyConsistent: r = a.weakCompareExchange(expected: 99, desired: 20, ordering: .sequentiallyConsistent)
        }

        #expect(!r.exchanged)
        #expect(r.original == 10)
        #expect(a.load(ordering: .relaxed) == 10)
    }

    @Test(arguments: AtomicUpdateOrdering.allCases, AtomicLoadOrdering.allCases)
    func weakWithSeparateOrderings(success: AtomicUpdateOrdering, failure: AtomicLoadOrdering) {
        let a = Atomic(1)

        var hit: (exchanged: Bool, original: Int)
        repeat {
            hit = weakCompareExchange(a, expected: 1, desired: 2, success: success, failure: failure)
        } while !hit.exchanged
        #expect(hit.original == 1)

        let miss = weakCompareExchange(a, expected: 1, desired: 3, success: success, failure: failure)
        #expect(!miss.exchanged && miss.original == 2)
        #expect(a.load(ordering: .relaxed) == 2)
    }
}

@Suite("Atomic wrapping arithmetic tests")
struct WrappingArithmeticTests {
    @Test(arguments: AtomicUpdateOrdering.allCases)
    func wrappingAdd(ordering: AtomicUpdateOrdering) {
        let a = Atomic(5)
        let r: (oldValue: Int, newValue: Int)

        switch ordering {
        case .acquiring: r = a.wrappingAdd(3, ordering: .acquiring)
        case .acquiringAndReleasing: r = a.wrappingAdd(3, ordering: .acquiringAndReleasing)
        case .relaxed: r = a.wrappingAdd(3, ordering: .relaxed)
        case .releasing: r = a.wrappingAdd(3, ordering: .releasing)
        case .sequentiallyConsistent: r = a.wrappingAdd(3, ordering: .sequentiallyConsistent)
        }

        #expect(r.oldValue == 5 && r.newValue == 8)
        #expect(a.load(ordering: .relaxed) == 8)
    }

    @Test(arguments: AtomicUpdateOrdering.allCases)
    func wrappingSubtract(ordering: AtomicUpdateOrdering) {
        let a = Atomic(5)
        let r: (oldValue: Int, newValue: Int)

        switch ordering {
        case .acquiring: r = a.wrappingSubtract(3, ordering: .acquiring)
        case .acquiringAndReleasing: r = a.wrappingSubtract(3, ordering: .acquiringAndReleasing)
        case .relaxed: r = a.wrappingSubtract(3, ordering: .relaxed)
        case .releasing: r = a.wrappingSubtract(3, ordering: .releasing)
        case .sequentiallyConsistent: r = a.wrappingSubtract(3, ordering: .sequentiallyConsistent)
        }

        #expect(r.oldValue == 5 && r.newValue == 2)
        #expect(a.load(ordering: .relaxed) == 2)
    }

    @Test
    func wrappingAddWrapsAtMax() {
        let a = Atomic<UInt8>(.max)
        let r = a.wrappingAdd(1, ordering: .relaxed)
        #expect(r.oldValue == .max && r.newValue == 0)
        #expect(a.load(ordering: .relaxed) == 0)

        let s = Atomic<Int8>(.max)
        let q = s.wrappingAdd(1, ordering: .relaxed)
        #expect(q.newValue == .min)
        #expect(s.load(ordering: .relaxed) == .min)
    }

    @Test
    func wrappingSubtractWrapsAtMin() {
        let a = Atomic<UInt8>(0)
        let r = a.wrappingSubtract(1, ordering: .relaxed)
        #expect(r.oldValue == 0 && r.newValue == .max)
        #expect(a.load(ordering: .relaxed) == .max)

        let s = Atomic<Int8>(.min)
        let q = s.wrappingSubtract(1, ordering: .relaxed)
        #expect(q.newValue == .max)
        #expect(s.load(ordering: .relaxed) == .max)
    }
}

@Suite("Atomic checked arithmetic tests")
struct CheckedArithmeticTests {
    @Test(arguments: AtomicUpdateOrdering.allCases)
    func add(ordering: AtomicUpdateOrdering) {
        let a = Atomic(5)
        let r: (oldValue: Int, newValue: Int)

        switch ordering {
        case .acquiring: r = a.add(3, ordering: .acquiring)
        case .acquiringAndReleasing: r = a.add(3, ordering: .acquiringAndReleasing)
        case .relaxed: r = a.add(3, ordering: .relaxed)
        case .releasing: r = a.add(3, ordering: .releasing)
        case .sequentiallyConsistent: r = a.add(3, ordering: .sequentiallyConsistent)
        }

        #expect(r.oldValue == 5 && r.newValue == 8)
        #expect(a.load(ordering: .relaxed) == 8)
    }

    @Test(arguments: AtomicUpdateOrdering.allCases)
    func subtract(ordering: AtomicUpdateOrdering) {
        let a = Atomic(5)
        let r: (oldValue: Int, newValue: Int)

        switch ordering {
        case .acquiring: r = a.subtract(3, ordering: .acquiring)
        case .acquiringAndReleasing: r = a.subtract(3, ordering: .acquiringAndReleasing)
        case .relaxed: r = a.subtract(3, ordering: .relaxed)
        case .releasing: r = a.subtract(3, ordering: .releasing)
        case .sequentiallyConsistent: r = a.subtract(3, ordering: .sequentiallyConsistent)
        }

        #expect(r.oldValue == 5 && r.newValue == 2)
        #expect(a.load(ordering: .relaxed) == 2)
    }

    @Test
    func addUpToMaxDoesNotTrap() {
        let a = Atomic<UInt8>(250)
        let r = a.add(5, ordering: .relaxed)
        #expect(r.newValue == .max)
    }

    @Test
    func subtractDownToMinDoesNotTrap() {
        let a = Atomic<Int8>(-120)
        let r = a.subtract(8, ordering: .relaxed)
        #expect(r.newValue == .min)
    }

#if compiler(>=6.2)
    @Test
    func addTrapsOnOverflow() async {
        await #expect(processExitsWith: .failure) {
            let a = Atomic<Int8>(.max)
            a.add(1, ordering: .relaxed)
        }
    }

    @Test
    func subtractTrapsOnUnderflow() async {
        await #expect(processExitsWith: .failure) {
            let a = Atomic<UInt8>(0)
            a.subtract(1, ordering: .relaxed)
        }
    }
#endif
}

@Suite("Atomic bitwise tests")
struct BitwiseTests {
    @Test(arguments: AtomicUpdateOrdering.allCases)
    func bitwiseAnd(ordering: AtomicUpdateOrdering) {
        let a = Atomic<UInt8>(0b1100)
        let r: (oldValue: UInt8, newValue: UInt8)

        switch ordering {
        case .acquiring: r = a.bitwiseAnd(0b1010, ordering: .acquiring)
        case .acquiringAndReleasing: r = a.bitwiseAnd(0b1010, ordering: .acquiringAndReleasing)
        case .relaxed: r = a.bitwiseAnd(0b1010, ordering: .relaxed)
        case .releasing: r = a.bitwiseAnd(0b1010, ordering: .releasing)
        case .sequentiallyConsistent: r = a.bitwiseAnd(0b1010, ordering: .sequentiallyConsistent)
        }

        #expect(r.oldValue == 0b1100 && r.newValue == 0b1000)
        #expect(a.load(ordering: .relaxed) == 0b1000)
    }

    @Test(arguments: AtomicUpdateOrdering.allCases)
    func bitwiseOr(ordering: AtomicUpdateOrdering) {
        let a = Atomic<UInt8>(0b1100)
        let r: (oldValue: UInt8, newValue: UInt8)

        switch ordering {
        case .acquiring: r = a.bitwiseOr(0b1010, ordering: .acquiring)
        case .acquiringAndReleasing: r = a.bitwiseOr(0b1010, ordering: .acquiringAndReleasing)
        case .relaxed: r = a.bitwiseOr(0b1010, ordering: .relaxed)
        case .releasing: r = a.bitwiseOr(0b1010, ordering: .releasing)
        case .sequentiallyConsistent: r = a.bitwiseOr(0b1010, ordering: .sequentiallyConsistent)
        }

        #expect(r.oldValue == 0b1100 && r.newValue == 0b1110)
        #expect(a.load(ordering: .relaxed) == 0b1110)
    }

    @Test(arguments: AtomicUpdateOrdering.allCases)
    func bitwiseXor(ordering: AtomicUpdateOrdering) {
        let a = Atomic<UInt8>(0b1100)
        let r: (oldValue: UInt8, newValue: UInt8)

        switch ordering {
        case .acquiring: r = a.bitwiseXor(0b1010, ordering: .acquiring)
        case .acquiringAndReleasing: r = a.bitwiseXor(0b1010, ordering: .acquiringAndReleasing)
        case .relaxed: r = a.bitwiseXor(0b1010, ordering: .relaxed)
        case .releasing: r = a.bitwiseXor(0b1010, ordering: .releasing)
        case .sequentiallyConsistent: r = a.bitwiseXor(0b1010, ordering: .sequentiallyConsistent)
        }

        #expect(r.oldValue == 0b1100 && r.newValue == 0b0110)
        #expect(a.load(ordering: .relaxed) == 0b0110)
    }

    @Test
    func identities() {
        let a = Atomic<UInt32>(0xDEAD_BEEF)
        #expect(a.bitwiseAnd(.max, ordering: .relaxed).newValue == 0xDEAD_BEEF)
        #expect(a.bitwiseOr(0, ordering: .relaxed).newValue == 0xDEAD_BEEF)
        #expect(a.bitwiseXor(0, ordering: .relaxed).newValue == 0xDEAD_BEEF)

        // x ^ x == 0, and x & 0 == 0
        #expect(a.bitwiseXor(0xDEAD_BEEF, ordering: .relaxed).newValue == 0)
        a.store(0xDEAD_BEEF, ordering: .relaxed)
        #expect(a.bitwiseAnd(0, ordering: .relaxed).newValue == 0)
    }

    // Signed values operate on the two's-complement bit pattern.
    @Test
    func signedOperands() {
        let a = Atomic<Int8>(-1)                                            // 0b1111_1111
        #expect(a.bitwiseAnd(0x0F, ordering: .relaxed).newValue == 0x0F)     // 0b0000_1111
        #expect(a.bitwiseOr(Int8.min, ordering: .relaxed).newValue == -113)  // 0b1000_1111
        #expect(a.bitwiseXor(-1, ordering: .relaxed).newValue == 112)        // 0b0111_0000
    }

    // Each thread sets its own bit; all bits must end up set.
    @Test
    func concurrentOrSetsEveryBit() {
        let a = Atomic<UInt64>(0)
        DispatchQueue.concurrentPerform(iterations: 64) { i in
            a.bitwiseOr(1 << UInt64(i), ordering: .relaxed)
        }
        #expect(a.load(ordering: .relaxed) == .max)
    }

    // Each thread clears its own bit; all bits must end up clear.
    @Test
    func concurrentAndClearsEveryBit() {
        let a = Atomic<UInt64>(.max)
        DispatchQueue.concurrentPerform(iterations: 64) { i in
            a.bitwiseAnd(~(1 << UInt64(i)), ordering: .relaxed)
        }
        #expect(a.load(ordering: .relaxed) == 0)
    }

    // An even number of toggles must restore the original value.
    @Test
    func concurrentXorTogglesCancel() {
        let start: UInt64 = 0x0123_4567_89AB_CDEF
        let a = Atomic(start)
        DispatchQueue.concurrentPerform(iterations: 8) { _ in
            for _ in 0..<10_000 {
                a.bitwiseXor(.max, ordering: .relaxed)
            }
        }
        #expect(a.load(ordering: .relaxed) == start)
    }
}

@Suite("Atomic min/max tests")
struct MinMaxTests {
    @Test(arguments: AtomicUpdateOrdering.allCases)
    func maxRaisesValue(ordering: AtomicUpdateOrdering) {
        let a = Atomic(5)
        let r: (oldValue: Int, newValue: Int)

        switch ordering {
        case .acquiring: r = a.max(9, ordering: .acquiring)
        case .acquiringAndReleasing: r = a.max(9, ordering: .acquiringAndReleasing)
        case .relaxed: r = a.max(9, ordering: .relaxed)
        case .releasing: r = a.max(9, ordering: .releasing)
        case .sequentiallyConsistent: r = a.max(9, ordering: .sequentiallyConsistent)
        }

        #expect(r.oldValue == 5 && r.newValue == 9)
        #expect(a.load(ordering: .relaxed) == 9)
    }

    @Test(arguments: AtomicUpdateOrdering.allCases)
    func maxLeavesLargerValue(ordering: AtomicUpdateOrdering) {
        let a = Atomic(9)
        let r: (oldValue: Int, newValue: Int)

        switch ordering {
        case .acquiring: r = a.max(5, ordering: .acquiring)
        case .acquiringAndReleasing: r = a.max(5, ordering: .acquiringAndReleasing)
        case .relaxed: r = a.max(5, ordering: .relaxed)
        case .releasing: r = a.max(5, ordering: .releasing)
        case .sequentiallyConsistent: r = a.max(5, ordering: .sequentiallyConsistent)
        }

        #expect(r.oldValue == 9 && r.newValue == 9)
        #expect(a.load(ordering: .relaxed) == 9)
    }

    @Test(arguments: AtomicUpdateOrdering.allCases)
    func minLowersValue(ordering: AtomicUpdateOrdering) {
        let a = Atomic(9)
        let r: (oldValue: Int, newValue: Int)

        switch ordering {
        case .acquiring: r = a.min(5, ordering: .acquiring)
        case .acquiringAndReleasing: r = a.min(5, ordering: .acquiringAndReleasing)
        case .relaxed: r = a.min(5, ordering: .relaxed)
        case .releasing: r = a.min(5, ordering: .releasing)
        case .sequentiallyConsistent: r = a.min(5, ordering: .sequentiallyConsistent)
        }

        #expect(r.oldValue == 9 && r.newValue == 5)
        #expect(a.load(ordering: .relaxed) == 5)
    }

    @Test(arguments: AtomicUpdateOrdering.allCases)
    func minLeavesSmallerValue(ordering: AtomicUpdateOrdering) {
        let a = Atomic(5)
        let r: (oldValue: Int, newValue: Int)

        switch ordering {
        case .acquiring: r = a.min(9, ordering: .acquiring)
        case .acquiringAndReleasing: r = a.min(9, ordering: .acquiringAndReleasing)
        case .relaxed: r = a.min(9, ordering: .relaxed)
        case .releasing: r = a.min(9, ordering: .releasing)
        case .sequentiallyConsistent: r = a.min(9, ordering: .sequentiallyConsistent)
        }

        #expect(r.oldValue == 5 && r.newValue == 5)
        #expect(a.load(ordering: .relaxed) == 5)
    }

    // Same bit patterns, different answers: signed vs. unsigned comparison.
    @Test
    func signedComparison() {
        let a = Atomic<Int8>(1)
        #expect(a.max(-1, ordering: .relaxed).newValue == 1)
        #expect(a.min(-1, ordering: .relaxed).newValue == -1)
    }

    @Test
    func unsignedComparison() {
        let a = Atomic<UInt8>(1)
        #expect(a.max(0xFF, ordering: .relaxed).newValue == 0xFF)
        let b = Atomic<UInt8>(1)
        #expect(b.min(0xFF, ordering: .relaxed).newValue == 1)
    }
}

@Suite("Atomic logical tests")
struct LogicalTests {
    static let truthTable: [(Bool, Bool)] = [
        (false, false), (false, true), (true, false), (true, true),
    ]

    @Test(arguments: AtomicUpdateOrdering.allCases)
    func logicalAndTruthTable(ordering: AtomicUpdateOrdering) {
        for (start, operand) in Self.truthTable {
            let a = Atomic(start)
            let r: (oldValue: Bool, newValue: Bool)

            switch ordering {
            case .acquiring: r = a.logicalAnd(operand, ordering: .acquiring)
            case .acquiringAndReleasing: r = a.logicalAnd(operand, ordering: .acquiringAndReleasing)
            case .relaxed: r = a.logicalAnd(operand, ordering: .relaxed)
            case .releasing: r = a.logicalAnd(operand, ordering: .releasing)
            case .sequentiallyConsistent: r = a.logicalAnd(operand, ordering: .sequentiallyConsistent)
            }

            #expect(r.oldValue == start)
            #expect(r.newValue == (start && operand))
            #expect(a.load(ordering: .relaxed) == (start && operand))
        }
    }

    @Test(arguments: AtomicUpdateOrdering.allCases)
    func logicalOrTruthTable(ordering: AtomicUpdateOrdering) {
        for (start, operand) in Self.truthTable {
            let a = Atomic(start)
            let r: (oldValue: Bool, newValue: Bool)

            switch ordering {
            case .acquiring: r = a.logicalOr(operand, ordering: .acquiring)
            case .acquiringAndReleasing: r = a.logicalOr(operand, ordering: .acquiringAndReleasing)
            case .relaxed: r = a.logicalOr(operand, ordering: .relaxed)
            case .releasing: r = a.logicalOr(operand, ordering: .releasing)
            case .sequentiallyConsistent: r = a.logicalOr(operand, ordering: .sequentiallyConsistent)
            }

            #expect(r.oldValue == start)
            #expect(r.newValue == (start || operand))
            #expect(a.load(ordering: .relaxed) == (start || operand))
        }
    }

    @Test(arguments: AtomicUpdateOrdering.allCases)
    func logicalXorTruthTable(ordering: AtomicUpdateOrdering) {
        for (start, operand) in Self.truthTable {
            let a = Atomic(start)
            let r: (oldValue: Bool, newValue: Bool)

            switch ordering {
            case .acquiring: r = a.logicalXor(operand, ordering: .acquiring)
            case .acquiringAndReleasing: r = a.logicalXor(operand, ordering: .acquiringAndReleasing)
            case .relaxed: r = a.logicalXor(operand, ordering: .relaxed)
            case .releasing: r = a.logicalXor(operand, ordering: .releasing)
            case .sequentiallyConsistent: r = a.logicalXor(operand, ordering: .sequentiallyConsistent)
            }

            #expect(r.oldValue == start)
            #expect(r.newValue == (start != operand))
            #expect(a.load(ordering: .relaxed) == (start != operand))
        }
    }

    @Test
    func logicalXorTrueToggles() {
        let a = Atomic(false)
        #expect(a.logicalXor(true, ordering: .relaxed).newValue == true)
        #expect(a.logicalXor(true, ordering: .relaxed).newValue == false)
        #expect(a.logicalXor(false, ordering: .relaxed).newValue == false)
    }

    // A single false among many trues must leave the flag false.
    @Test
    func concurrentAndAnyFalseWins() {
        let a = Atomic(true)
        DispatchQueue.concurrentPerform(iterations: 64) { i in
            a.logicalAnd(i != 37, ordering: .relaxed)
        }
        #expect(a.load(ordering: .relaxed) == false)
    }

    // A single true among many falses must leave the flag true.
    @Test
    func concurrentOrAnyTrueWins() {
        let a = Atomic(false)
        DispatchQueue.concurrentPerform(iterations: 64) { i in
            a.logicalOr(i == 37, ordering: .relaxed)
        }
        #expect(a.load(ordering: .relaxed) == true)
    }

    // logicalOr(true) as a once-flag: exactly one caller sees the old false.
    @Test
    func concurrentOrHasSingleFirstSetter() {
        let flag = Atomic(false)
        let firsts = Atomic(0)
        DispatchQueue.concurrentPerform(iterations: 64) { _ in
            if !flag.logicalOr(true, ordering: .acquiringAndReleasing).oldValue {
                firsts.wrappingAdd(1, ordering: .relaxed)
            }
        }
        #expect(firsts.load(ordering: .relaxed) == 1)
    }

    // logicalAnd(false) as a once-flag: exactly one caller sees the old true.
    @Test
    func concurrentAndHasSingleFirstClearer() {
        let flag = Atomic(true)
        let firsts = Atomic(0)
        DispatchQueue.concurrentPerform(iterations: 64) { _ in
            if flag.logicalAnd(false, ordering: .acquiringAndReleasing).oldValue {
                firsts.wrappingAdd(1, ordering: .relaxed)
            }
        }
        #expect(firsts.load(ordering: .relaxed) == 1)
    }

    // An even number of concurrent toggles must restore the starting value;
    // a lost update would flip the parity.
    @Test(arguments: [false, true])
    func concurrentXorTogglesCancel(start: Bool) {
        let a = Atomic(start)
        DispatchQueue.concurrentPerform(iterations: 8) { _ in
            for _ in 0..<10_000 {
                a.logicalXor(true, ordering: .relaxed)
            }
        }
        #expect(a.load(ordering: .relaxed) == start)
    }
}

@Suite("Atomic concurrent correctness")
struct ConcurrencyTests {
    static let threads = 8
    static let iterations = 100_000
    static let total = threads * iterations

    @Test
    func concurrentWrappingAdd() {
        let a = Atomic(0)
        DispatchQueue.concurrentPerform(iterations: Self.threads) { _ in
            for _ in 0..<Self.iterations {
                a.wrappingAdd(1, ordering: .relaxed)
            }
        }
        #expect(a.load(ordering: .relaxed) == Self.total)
    }

    // Exercises the weak compare-exchange retry loop under contention.
    @Test
    func concurrentCheckedAdd() {
        let a = Atomic(0)
        DispatchQueue.concurrentPerform(iterations: Self.threads) { _ in
            for _ in 0..<Self.iterations {
                a.add(1, ordering: .relaxed)
            }
        }
        #expect(a.load(ordering: .relaxed) == Self.total)
    }

    @Test
    func concurrentAddAndSubtractCancel() {
        let a = Atomic(0)
        DispatchQueue.concurrentPerform(iterations: Self.threads) { i in
            for _ in 0..<Self.iterations {
                if i.isMultiple(of: 2) {
                    a.add(1, ordering: .relaxed)
                } else {
                    a.subtract(1, ordering: .relaxed)
                }
            }
        }
        #expect(a.load(ordering: .relaxed) == 0)
    }

    @Test
    func concurrentMax() {
        let a = Atomic(Int.min)
        DispatchQueue.concurrentPerform(iterations: Self.threads) { i in
            for j in 0..<Self.iterations {
                a.max(j * Self.threads + i, ordering: .relaxed)
            }
        }
        #expect(a.load(ordering: .relaxed) == Self.total - 1)
    }

    @Test
    func concurrentMin() {
        let a = Atomic(Int.max)
        DispatchQueue.concurrentPerform(iterations: Self.threads) { i in
            for j in 0..<Self.iterations {
                a.min(j * Self.threads + i, ordering: .relaxed)
            }
        }
        #expect(a.load(ordering: .relaxed) == 0)
    }

    // Exactly one thread should win each strong compare-exchange round.
    @Test
    func compareExchangeHasSingleWinner() {
        let flag = Atomic(false)
        let winners = Atomic(0)
        DispatchQueue.concurrentPerform(iterations: Self.threads) { _ in
            if flag.compareExchange(expected: false, desired: true, ordering: .acquiringAndReleasing).exchanged {
                winners.wrappingAdd(1, ordering: .relaxed)
            }
        }
        #expect(winners.load(ordering: .relaxed) == 1)
    }

    // A hand-written weak CAS increment loop must not double-count.
    @Test
    func weakCompareExchangeLoopCountsExactly() {
        let a = Atomic(0)
        DispatchQueue.concurrentPerform(iterations: Self.threads) { _ in
            for _ in 0..<Self.iterations {
                var old = a.load(ordering: .relaxed)
                while true {
                    let r = a.weakCompareExchange(expected: old, desired: old + 1, ordering: .relaxed)
                    if r.exchanged { break }
                    old = r.original
                }
            }
        }
        #expect(a.load(ordering: .relaxed) == Self.total)
    }

    // Release/acquire publication: a reader that sees the flag
    // must also see the payload written before it.
    @Test
    func releaseAcquirePublishesWrites() {
        final class Payload: @unchecked Sendable { var value = 0 }
        for _ in 0..<1_000 {
            let payload = Payload()
            let ready = Atomic(false)
            DispatchQueue.concurrentPerform(iterations: 2) { i in
                if i == 0 {
                    payload.value = 42
                    ready.store(true, ordering: .releasing)
                } else {
                    while !ready.load(ordering: .acquiring) {}
                    #expect(payload.value == 42)
                }
            }
        }
    }
}
