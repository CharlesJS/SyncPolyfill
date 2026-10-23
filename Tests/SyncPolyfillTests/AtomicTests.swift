import Foundation
@testable import SyncPolyfill
import Testing

// MARK: - Orderings exercised by the tests

nonisolated(unsafe) private let loadOrderings: [AtomicLoadOrdering] = [
    .relaxed, .acquiring, .sequentiallyConsistent,
]

nonisolated(unsafe) private let storeOrderings: [AtomicStoreOrdering] = [
    .relaxed, .releasing, .sequentiallyConsistent,
]

nonisolated(unsafe) private let updateOrderings: [AtomicUpdateOrdering] = [
    .relaxed, .acquiring, .releasing, .acquiringAndReleasing, .sequentiallyConsistent,
]

@Suite("Atomic basic tests")
struct BasicOperationTests {
    @Test func initAndLoad() {
        for ordering in loadOrderings {
            let a = Atomic(42)
            #expect(a.load(ordering: ordering) == 42)
        }
    }

    @Test func initBool() {
        let t = Atomic(true)
        let f = Atomic(false)
        #expect(t.load(ordering: .relaxed) == true)
        #expect(f.load(ordering: .relaxed) == false)
    }

    @Test func store() {
        for ordering in storeOrderings {
            let a = Atomic(0)
            a.store(7, ordering: ordering)
            #expect(a.load(ordering: .relaxed) == 7)
        }
    }

    @Test func exchange() {
        for ordering in updateOrderings {
            let a = Atomic(1)
            #expect(a.exchange(2, ordering: ordering) == 1)
            #expect(a.load(ordering: .relaxed) == 2)
        }
    }

    @Test func exchangeBool() {
        let a = Atomic(false)
        #expect(a.exchange(true, ordering: .relaxed) == false)
        #expect(a.exchange(true, ordering: .relaxed) == true)
        #expect(a.load(ordering: .relaxed) == true)
    }
}

@Suite("Atomic compareExchange tests")
struct CompareExchangeTests {
    @Test func strongSucceedsWhenExpectedMatches() {
        for ordering in updateOrderings {
            let a = Atomic(10)
            let (exchanged, original) = a.compareExchange(expected: 10, desired: 20, ordering: ordering)
            #expect(exchanged)
            #expect(original == 10)
            #expect(a.load(ordering: .relaxed) == 20)
        }
    }

    @Test func strongFailsWhenExpectedDiffers() {
        for ordering in updateOrderings {
            let a = Atomic(10)
            let (exchanged, original) = a.compareExchange(expected: 99, desired: 20, ordering: ordering)
            #expect(!exchanged)
            #expect(original == 10)
            #expect(a.load(ordering: .relaxed) == 10)
        }
    }

    @Test func strongWithSeparateOrderings() {
        for success in updateOrderings {
            for failure in loadOrderings {
                let a = Atomic(1)
                let hit = a.compareExchange(expected: 1, desired: 2, successOrdering: success, failureOrdering: failure)
                #expect(hit.exchanged && hit.original == 1)

                let miss = a.compareExchange(expected: 1, desired: 3, successOrdering: success, failureOrdering: failure)
                #expect(!miss.exchanged && miss.original == 2)
                #expect(a.load(ordering: .relaxed) == 2)
            }
        }
    }

    // A weak compare-exchange may fail spuriously, so success is tested
    // by retrying. A failure must never write.
    @Test func weakEventuallySucceedsWhenExpectedMatches() {
        for ordering in updateOrderings {
            let a = Atomic(10)
            var result: (exchanged: Bool, original: Int)
            repeat {
                result = a.weakCompareExchange(expected: 10, desired: 20, ordering: ordering)
                if !result.exchanged {
                    #expect(result.original == 10)
                    #expect(a.load(ordering: .relaxed) == 10)
                }
            } while !result.exchanged
            #expect(result.original == 10)
            #expect(a.load(ordering: .relaxed) == 20)
        }
    }

    @Test func weakFailsWhenExpectedDiffers() {
        for ordering in updateOrderings {
            let a = Atomic(10)
            let (exchanged, original) = a.weakCompareExchange(expected: 99, desired: 20, ordering: ordering)
            #expect(!exchanged)
            #expect(original == 10)
            #expect(a.load(ordering: .relaxed) == 10)
        }
    }

    @Test func weakWithSeparateOrderings() {
        for success in updateOrderings {
            for failure in loadOrderings {
                let a = Atomic(1)
                var hit: (exchanged: Bool, original: Int)
                repeat {
                    hit = a.weakCompareExchange(expected: 1, desired: 2, successOrdering: success, failureOrdering: failure)
                } while !hit.exchanged
                #expect(hit.original == 1)

                let miss = a.weakCompareExchange(expected: 1, desired: 3, successOrdering: success, failureOrdering: failure)
                #expect(!miss.exchanged && miss.original == 2)
                #expect(a.load(ordering: .relaxed) == 2)
            }
        }
    }
}

@Suite("Atomic wrapping arithmetic tests")
struct WrappingArithmeticTests {
    @Test func wrappingAdd() {
        for ordering in updateOrderings {
            let a = Atomic(5)
            let r = a.wrappingAdd(3, ordering: ordering)
            #expect(r.oldValue == 5 && r.newValue == 8)
            #expect(a.load(ordering: .relaxed) == 8)
        }
    }

    @Test func wrappingSubtract() {
        for ordering in updateOrderings {
            let a = Atomic(5)
            let r = a.wrappingSubtract(3, ordering: ordering)
            #expect(r.oldValue == 5 && r.newValue == 2)
            #expect(a.load(ordering: .relaxed) == 2)
        }
    }

    @Test func wrappingAddWrapsAtMax() {
        let a = Atomic<UInt8>(.max)
        let r = a.wrappingAdd(1, ordering: .relaxed)
        #expect(r.oldValue == .max && r.newValue == 0)
        #expect(a.load(ordering: .relaxed) == 0)

        let s = Atomic<Int8>(.max)
        let q = s.wrappingAdd(1, ordering: .relaxed)
        #expect(q.newValue == .min)
        #expect(s.load(ordering: .relaxed) == .min)
    }

    @Test func wrappingSubtractWrapsAtMin() {
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
    @Test func add() {
        for ordering in updateOrderings {
            let a = Atomic(5)
            let r = a.add(3, ordering: ordering)
            #expect(r.oldValue == 5 && r.newValue == 8)
            #expect(a.load(ordering: .relaxed) == 8)
        }
    }

    @Test func subtract() {
        for ordering in updateOrderings {
            let a = Atomic(5)
            let r = a.subtract(3, ordering: ordering)
            #expect(r.oldValue == 5 && r.newValue == 2)
            #expect(a.load(ordering: .relaxed) == 2)
        }
    }

    @Test func addUpToMaxDoesNotTrap() {
        let a = Atomic<UInt8>(250)
        let r = a.add(5, ordering: .relaxed)
        #expect(r.newValue == .max)
    }

    @Test func subtractDownToMinDoesNotTrap() {
        let a = Atomic<Int8>(-120)
        let r = a.subtract(8, ordering: .relaxed)
        #expect(r.newValue == .min)
    }

#if compiler(>=6.2)
    @Test func addTrapsOnOverflow() async {
        await #expect(processExitsWith: .failure) {
            let a = Atomic<Int8>(.max)
            a.add(1, ordering: .relaxed)
        }
    }

    @Test func subtractTrapsOnUnderflow() async {
        await #expect(processExitsWith: .failure) {
            let a = Atomic<UInt8>(0)
            a.subtract(1, ordering: .relaxed)
        }
    }
#endif
}

@Suite("Atomic bitwise tests")
struct BitwiseTests {
    @Test func bitwiseAnd() {
        for ordering in updateOrderings {
            let a = Atomic<UInt8>(0b1100)
            let r = a.bitwiseAnd(0b1010, ordering: ordering)
            #expect(r.oldValue == 0b1100 && r.newValue == 0b1000)
            #expect(a.load(ordering: .relaxed) == 0b1000)
        }
    }

    @Test func bitwiseOr() {
        for ordering in updateOrderings {
            let a = Atomic<UInt8>(0b1100)
            let r = a.bitwiseOr(0b1010, ordering: ordering)
            #expect(r.oldValue == 0b1100 && r.newValue == 0b1110)
            #expect(a.load(ordering: .relaxed) == 0b1110)
        }
    }

    @Test func bitwiseXor() {
        for ordering in updateOrderings {
            let a = Atomic<UInt8>(0b1100)
            let r = a.bitwiseXor(0b1010, ordering: ordering)
            #expect(r.oldValue == 0b1100 && r.newValue == 0b0110)
            #expect(a.load(ordering: .relaxed) == 0b0110)
        }
    }

    @Test func identities() {
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
    @Test func signedOperands() {
        let a = Atomic<Int8>(-1)                                            // 0b1111_1111
        #expect(a.bitwiseAnd(0x0F, ordering: .relaxed).newValue == 0x0F)     // 0b0000_1111
        #expect(a.bitwiseOr(Int8.min, ordering: .relaxed).newValue == -113)  // 0b1000_1111
        #expect(a.bitwiseXor(-1, ordering: .relaxed).newValue == 112)        // 0b0111_0000
    }

    // Each thread sets its own bit; all bits must end up set.
    @Test func concurrentOrSetsEveryBit() {
        let a = Atomic<UInt64>(0)
        DispatchQueue.concurrentPerform(iterations: 64) { i in
            a.bitwiseOr(1 << UInt64(i), ordering: .relaxed)
        }
        #expect(a.load(ordering: .relaxed) == .max)
    }

    // Each thread clears its own bit; all bits must end up clear.
    @Test func concurrentAndClearsEveryBit() {
        let a = Atomic<UInt64>(.max)
        DispatchQueue.concurrentPerform(iterations: 64) { i in
            a.bitwiseAnd(~(1 << UInt64(i)), ordering: .relaxed)
        }
        #expect(a.load(ordering: .relaxed) == 0)
    }

    // An even number of toggles must restore the original value.
    @Test func concurrentXorTogglesCancel() {
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
    @Test func maxRaisesValue() {
        for ordering in updateOrderings {
            let a = Atomic(5)
            let r = a.max(9, ordering: ordering)
            #expect(r.oldValue == 5 && r.newValue == 9)
            #expect(a.load(ordering: .relaxed) == 9)
        }
    }

    @Test func maxLeavesLargerValue() {
        for ordering in updateOrderings {
            let a = Atomic(9)
            let r = a.max(5, ordering: ordering)
            #expect(r.oldValue == 9 && r.newValue == 9)
            #expect(a.load(ordering: .relaxed) == 9)
        }
    }

    @Test func minLowersValue() {
        for ordering in updateOrderings {
            let a = Atomic(9)
            let r = a.min(5, ordering: ordering)
            #expect(r.oldValue == 9 && r.newValue == 5)
            #expect(a.load(ordering: .relaxed) == 5)
        }
    }

    @Test func minLeavesSmallerValue() {
        for ordering in updateOrderings {
            let a = Atomic(5)
            let r = a.min(9, ordering: ordering)
            #expect(r.oldValue == 5 && r.newValue == 5)
            #expect(a.load(ordering: .relaxed) == 5)
        }
    }

    // Same bit patterns, different answers: signed vs. unsigned comparison.
    @Test func signedComparison() {
        let a = Atomic<Int8>(1)
        #expect(a.max(-1, ordering: .relaxed).newValue == 1)
        #expect(a.min(-1, ordering: .relaxed).newValue == -1)
    }

    @Test func unsignedComparison() {
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

    @Test func logicalAndTruthTable() {
        for ordering in updateOrderings {
            for (start, operand) in Self.truthTable {
                let a = Atomic(start)
                let r = a.logicalAnd(operand, ordering: ordering)
                #expect(r.oldValue == start)
                #expect(r.newValue == (start && operand))
                #expect(a.load(ordering: .relaxed) == (start && operand))
            }
        }
    }

    @Test func logicalOrTruthTable() {
        for ordering in updateOrderings {
            for (start, operand) in Self.truthTable {
                let a = Atomic(start)
                let r = a.logicalOr(operand, ordering: ordering)
                #expect(r.oldValue == start)
                #expect(r.newValue == (start || operand))
                #expect(a.load(ordering: .relaxed) == (start || operand))
            }
        }
    }

    @Test func logicalXorTruthTable() {
        for ordering in updateOrderings {
            for (start, operand) in Self.truthTable {
                let a = Atomic(start)
                let r = a.logicalXor(operand, ordering: ordering)
                #expect(r.oldValue == start)
                #expect(r.newValue == (start != operand))
                #expect(a.load(ordering: .relaxed) == (start != operand))
            }
        }
    }

    @Test func logicalXorTrueToggles() {
        let a = Atomic(false)
        #expect(a.logicalXor(true, ordering: .relaxed).newValue == true)
        #expect(a.logicalXor(true, ordering: .relaxed).newValue == false)
        #expect(a.logicalXor(false, ordering: .relaxed).newValue == false)
    }

    // A single false among many trues must leave the flag false.
    @Test func concurrentAndAnyFalseWins() {
        let a = Atomic(true)
        DispatchQueue.concurrentPerform(iterations: 64) { i in
            a.logicalAnd(i != 37, ordering: .relaxed)
        }
        #expect(a.load(ordering: .relaxed) == false)
    }

    // A single true among many falses must leave the flag true.
    @Test func concurrentOrAnyTrueWins() {
        let a = Atomic(false)
        DispatchQueue.concurrentPerform(iterations: 64) { i in
            a.logicalOr(i == 37, ordering: .relaxed)
        }
        #expect(a.load(ordering: .relaxed) == true)
    }

    // logicalOr(true) as a once-flag: exactly one caller sees the old false.
    @Test func concurrentOrHasSingleFirstSetter() {
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
    @Test func concurrentAndHasSingleFirstClearer() {
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
    @Test func concurrentXorTogglesCancel() {
        for start in [false, true] {
            let a = Atomic(start)
            DispatchQueue.concurrentPerform(iterations: 8) { _ in
                for _ in 0..<10_000 {
                    a.logicalXor(true, ordering: .relaxed)
                }
            }
            #expect(a.load(ordering: .relaxed) == start)
        }
    }
}

@Suite("Atomic concurrent correctness")
struct ConcurrencyTests {
    static let threads = 8
    static let iterations = 100_000
    static let total = threads * iterations

    @Test func concurrentWrappingAdd() {
        let a = Atomic(0)
        DispatchQueue.concurrentPerform(iterations: Self.threads) { _ in
            for _ in 0..<Self.iterations {
                a.wrappingAdd(1, ordering: .relaxed)
            }
        }
        #expect(a.load(ordering: .relaxed) == Self.total)
    }

    // Exercises the weak compare-exchange retry loop under contention.
    @Test func concurrentCheckedAdd() {
        let a = Atomic(0)
        DispatchQueue.concurrentPerform(iterations: Self.threads) { _ in
            for _ in 0..<Self.iterations {
                a.add(1, ordering: .relaxed)
            }
        }
        #expect(a.load(ordering: .relaxed) == Self.total)
    }

    @Test func concurrentAddAndSubtractCancel() {
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

    @Test func concurrentMax() {
        let a = Atomic(Int.min)
        DispatchQueue.concurrentPerform(iterations: Self.threads) { i in
            for j in 0..<Self.iterations {
                a.max(j * Self.threads + i, ordering: .relaxed)
            }
        }
        #expect(a.load(ordering: .relaxed) == Self.total - 1)
    }

    @Test func concurrentMin() {
        let a = Atomic(Int.max)
        DispatchQueue.concurrentPerform(iterations: Self.threads) { i in
            for j in 0..<Self.iterations {
                a.min(j * Self.threads + i, ordering: .relaxed)
            }
        }
        #expect(a.load(ordering: .relaxed) == 0)
    }

    // Exactly one thread should win each strong compare-exchange round.
    @Test func compareExchangeHasSingleWinner() {
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
    @Test func weakCompareExchangeLoopCountsExactly() {
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
    @Test func releaseAcquirePublishesWrites() {
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
