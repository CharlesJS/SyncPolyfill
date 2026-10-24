#if !canImport(Darwin)
@_exported import struct Synchronization.Atomic
typealias Atomic = Synchronization.Atomic

@_exported import protocol Synchronization.AtomicRepresentable
typealias AtomicRepresentable = Synchronization.AtomicRepresentable

@_exported import protocol Synchronization.AtomicOptionalRepresentable
typealias AtomicOptionalRepresentable = Synchronization.AtomicOptionalRepresentable
#else
import Atomics

public enum AtomicLoadOrdering {
    case acquiring
    case relaxed
    case sequentiallyConsistent
}

public enum AtomicStoreOrdering {
    case relaxed
    case releasing
    case sequentiallyConsistent
}

public enum AtomicUpdateOrdering {
    case acquiring
    case acquiringAndReleasing
    case relaxed
    case releasing
    case sequentiallyConsistent
}

public typealias AtomicRepresentable = AtomicValue
public typealias AtomicOptionalRepresentable = AtomicOptionalWrappable

public struct Atomic<Value: AtomicRepresentable>: ~Copyable where Value.AtomicRepresentation.Value == Value {
    public let storage: UnsafeAtomic<Value>

    public init(_ initialValue: consuming Value) {
        self.storage = UnsafeAtomic.create(initialValue)
    }

    deinit {
        self.storage.destroy()
    }

    @inline(always)
    public func load(ordering: AtomicLoadOrdering) -> Value {
        switch ordering {
        case .acquiring: storage.load(ordering: .acquiring)
        case .relaxed: storage.load(ordering: .relaxed)
        case .sequentiallyConsistent: storage.load(ordering: .sequentiallyConsistent)
        }
    }

    @inline(always)
    public func store(_ desired: consuming Value, ordering: AtomicStoreOrdering) {
        switch ordering {
        case .relaxed: storage.store(desired, ordering: .relaxed)
        case .releasing: storage.store(desired, ordering: .releasing)
        case .sequentiallyConsistent: storage.store(desired, ordering: .sequentiallyConsistent)
        }
    }

    @inline(always)
    public func exchange(_ desired: consuming Value, ordering: AtomicUpdateOrdering) -> Value {
        switch ordering {
        case .acquiring: storage.exchange(desired, ordering: .acquiring)
        case .acquiringAndReleasing: storage.exchange(desired, ordering: .acquiringAndReleasing)
        case .relaxed: storage.exchange(desired, ordering: .relaxed)
        case .releasing: storage.exchange(desired, ordering: .releasing)
        case .sequentiallyConsistent: storage.exchange(desired, ordering: .sequentiallyConsistent)
        }
    }

    @inline(always)
    public func compareExchange(
        expected: consuming Value,
        desired: consuming Value,
        ordering: AtomicUpdateOrdering
    ) -> (exchanged: Bool, original: Value) {
        switch ordering {
        case .acquiring:
            storage.compareExchange(expected: expected, desired: desired, ordering: .acquiring)
        case .acquiringAndReleasing:
            storage.compareExchange(expected: expected, desired: desired, ordering: .acquiringAndReleasing)
        case .relaxed:
            storage.compareExchange(expected: expected, desired: desired, ordering: .relaxed)
        case .releasing:
            storage.compareExchange(expected: expected, desired: desired, ordering: .releasing)
        case .sequentiallyConsistent:
            storage.compareExchange(expected: expected, desired: desired, ordering: .sequentiallyConsistent)
        }
    }

    @inline(always)
    public func compareExchange(
        expected: consuming Value,
        desired: consuming Value,
        successOrdering: AtomicUpdateOrdering,
        failureOrdering: AtomicLoadOrdering
    ) -> (exchanged: Bool, original: Value) {
        switch successOrdering {
        case .acquiring:
            switch failureOrdering {
            case .acquiring:
                storage.compareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .acquiring,
                    failureOrdering: .acquiring
                )
            case .relaxed:
                storage.compareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .acquiring,
                    failureOrdering: .relaxed
                )
            case .sequentiallyConsistent:
                storage.compareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .acquiring,
                    failureOrdering: .sequentiallyConsistent
                )
            }
        case .acquiringAndReleasing:
            switch failureOrdering {
            case .acquiring:
                storage.compareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .acquiringAndReleasing,
                    failureOrdering: .acquiring
                )
            case .relaxed:
                storage.compareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .acquiringAndReleasing,
                    failureOrdering: .relaxed
                )
            case .sequentiallyConsistent:
                storage.compareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .acquiringAndReleasing,
                    failureOrdering: .sequentiallyConsistent
                )
            }
        case .relaxed:
            switch failureOrdering {
            case .acquiring:
                storage.compareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .relaxed,
                    failureOrdering: .acquiring
                )
            case .relaxed:
                storage.compareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .relaxed,
                    failureOrdering: .relaxed
                )
            case .sequentiallyConsistent:
                storage.compareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .relaxed,
                    failureOrdering: .sequentiallyConsistent
                )
            }
        case .releasing:
            switch failureOrdering {
            case .acquiring:
                storage.compareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .releasing,
                    failureOrdering: .acquiring
                )
            case .relaxed:
                storage.compareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .releasing,
                    failureOrdering: .relaxed
                )
            case .sequentiallyConsistent:
                storage.compareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .releasing,
                    failureOrdering: .sequentiallyConsistent
                )
            }
        case .sequentiallyConsistent:
            switch failureOrdering {
            case .acquiring:
                storage.compareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .sequentiallyConsistent,
                    failureOrdering: .acquiring
                )
            case .relaxed:
                storage.compareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .sequentiallyConsistent,
                    failureOrdering: .relaxed
                )
            case .sequentiallyConsistent:
                storage.compareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .sequentiallyConsistent,
                    failureOrdering: .sequentiallyConsistent
                )
            }
        }
    }

    @inline(always)
    public func weakCompareExchange(
        expected: consuming Value,
        desired: consuming Value,
        ordering: AtomicUpdateOrdering
    ) -> (exchanged: Bool, original: Value) {
        switch ordering {
        case .acquiring:
            storage.weakCompareExchange(expected: expected, desired: desired, ordering: .acquiring)
        case .acquiringAndReleasing:
            storage.weakCompareExchange(expected: expected, desired: desired, ordering: .acquiringAndReleasing)
        case .relaxed:
            storage.weakCompareExchange(expected: expected, desired: desired, ordering: .relaxed)
        case .releasing:
            storage.weakCompareExchange(expected: expected, desired: desired, ordering: .releasing)
        case .sequentiallyConsistent:
            storage.weakCompareExchange(expected: expected, desired: desired, ordering: .sequentiallyConsistent)
        }
    }

    @inline(always)
    public func weakCompareExchange(
        expected: consuming Value,
        desired: consuming Value,
        successOrdering: AtomicUpdateOrdering,
        failureOrdering: AtomicLoadOrdering
    ) -> (exchanged: Bool, original: Value) {
        switch successOrdering {
        case .acquiring:
            switch failureOrdering {
            case .acquiring:
                storage.weakCompareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .acquiring,
                    failureOrdering: .acquiring
                )
            case .relaxed:
                storage.weakCompareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .acquiring,
                    failureOrdering: .relaxed
                )
            case .sequentiallyConsistent:
                storage.weakCompareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .acquiring,
                    failureOrdering: .sequentiallyConsistent
                )
            }
        case .acquiringAndReleasing:
            switch failureOrdering {
            case .acquiring:
                storage.weakCompareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .acquiringAndReleasing,
                    failureOrdering: .acquiring
                )
            case .relaxed:
                storage.weakCompareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .acquiringAndReleasing,
                    failureOrdering: .relaxed
                )
            case .sequentiallyConsistent:
                storage.weakCompareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .acquiringAndReleasing,
                    failureOrdering: .sequentiallyConsistent
                )
            }
        case .relaxed:
            switch failureOrdering {
            case .acquiring:
                storage.weakCompareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .relaxed,
                    failureOrdering: .acquiring
                )
            case .relaxed:
                storage.weakCompareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .relaxed,
                    failureOrdering: .relaxed
                )
            case .sequentiallyConsistent:
                storage.weakCompareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .relaxed,
                    failureOrdering: .sequentiallyConsistent
                )
            }
        case .releasing:
            switch failureOrdering {
            case .acquiring:
                storage.weakCompareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .releasing,
                    failureOrdering: .acquiring
                )
            case .relaxed:
                storage.weakCompareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .releasing,
                    failureOrdering: .relaxed
                )
            case .sequentiallyConsistent:
                storage.weakCompareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .releasing,
                    failureOrdering: .sequentiallyConsistent
                )
            }
        case .sequentiallyConsistent:
            switch failureOrdering {
            case .acquiring:
                storage.weakCompareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .sequentiallyConsistent,
                    failureOrdering: .acquiring
                )
            case .relaxed:
                storage.weakCompareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .sequentiallyConsistent,
                    failureOrdering: .relaxed
                )
            case .sequentiallyConsistent:
                storage.weakCompareExchange(
                    expected: expected,
                    desired: desired,
                    successOrdering: .sequentiallyConsistent,
                    failureOrdering: .sequentiallyConsistent
                )
            }
        }
    }
}

extension Atomic: @unchecked Sendable where Value: Sendable {}

extension Atomic where Value: AtomicInteger {
    @inline(always)
    @discardableResult
    public func add(_ operand: Value, ordering: AtomicUpdateOrdering) -> (oldValue: Value, newValue: Value) {
        self._update(ordering: ordering) { $0 + operand }
    }

    @inline(always)
    @discardableResult
    public func bitwiseAnd(_ operand: Value, ordering: AtomicUpdateOrdering) -> (oldValue: Value, newValue: Value) {
        let old = switch ordering {
        case .acquiring: storage.loadThenBitwiseAnd(with: operand, ordering: .acquiring)
        case .acquiringAndReleasing: storage.loadThenBitwiseAnd(with: operand, ordering: .acquiringAndReleasing)
        case .relaxed: storage.loadThenBitwiseAnd(with: operand, ordering: .relaxed)
        case .releasing: storage.loadThenBitwiseAnd(with: operand, ordering: .releasing)
        case .sequentiallyConsistent: storage.loadThenBitwiseAnd(with: operand, ordering: .sequentiallyConsistent)
        }

        return (old, old & operand)
    }

    @inline(always)
    @discardableResult
    public func bitwiseOr(_ operand: Value, ordering: AtomicUpdateOrdering) -> (oldValue: Value, newValue: Value) {
        let old = switch ordering {
        case .acquiring: storage.loadThenBitwiseOr(with: operand, ordering: .acquiring)
        case .acquiringAndReleasing: storage.loadThenBitwiseOr(with: operand, ordering: .acquiringAndReleasing)
        case .relaxed: storage.loadThenBitwiseOr(with: operand, ordering: .relaxed)
        case .releasing: storage.loadThenBitwiseOr(with: operand, ordering: .releasing)
        case .sequentiallyConsistent: storage.loadThenBitwiseOr(with: operand, ordering: .sequentiallyConsistent)
        }

        return (old, old | operand)
    }

    @inline(always)
    @discardableResult
    public func bitwiseXor(_ operand: Value, ordering: AtomicUpdateOrdering) -> (oldValue: Value, newValue: Value) {
        let old = switch ordering {
        case .acquiring: storage.loadThenBitwiseXor(with: operand, ordering: .acquiring)
        case .acquiringAndReleasing: storage.loadThenBitwiseXor(with: operand, ordering: .acquiringAndReleasing)
        case .relaxed: storage.loadThenBitwiseXor(with: operand, ordering: .relaxed)
        case .releasing: storage.loadThenBitwiseXor(with: operand, ordering: .releasing)
        case .sequentiallyConsistent: storage.loadThenBitwiseXor(with: operand, ordering: .sequentiallyConsistent)
        }

        return (old, old ^ operand)
    }

    @inline(always)
    @discardableResult
    func max(_ operand: Value, ordering: AtomicUpdateOrdering) -> (oldValue: Value, newValue: Value) {
        self._update(ordering: ordering) { Swift.max($0, operand) }
    }

    @inline(always)
    @discardableResult
    func min(_ operand: Value, ordering: AtomicUpdateOrdering) -> (oldValue: Value, newValue: Value) {
        self._update(ordering: ordering) { Swift.min($0, operand) }
    }

    @inline(always)
    @discardableResult
    public func subtract(_ operand: Value, ordering: AtomicUpdateOrdering) -> (oldValue: Value, newValue: Value) {
        self._update(ordering: ordering) { $0 - operand }
    }

    @inline(always)
    @discardableResult
    public func wrappingAdd(_ operand: Value, ordering: AtomicUpdateOrdering) -> (oldValue: Value, newValue: Value) {
        let old = switch ordering {
        case .acquiring: storage.loadThenWrappingIncrement(by: operand, ordering: .acquiring)
        case .acquiringAndReleasing: storage.loadThenWrappingIncrement(by: operand, ordering: .acquiringAndReleasing)
        case .relaxed: storage.loadThenWrappingIncrement(by: operand, ordering: .relaxed)
        case .releasing: storage.loadThenWrappingIncrement(by: operand, ordering: .releasing)
        case .sequentiallyConsistent: storage.loadThenWrappingIncrement(by: operand, ordering: .sequentiallyConsistent)
        }

        return (old, old &+ operand)
    }

    @inline(always)
    @discardableResult
    public func wrappingSubtract(_ operand: Value, ordering: AtomicUpdateOrdering) -> (oldValue: Value, newValue: Value) {
        let old = switch ordering {
        case .acquiring: storage.loadThenWrappingDecrement(by: operand, ordering: .acquiring)
        case .acquiringAndReleasing: storage.loadThenWrappingDecrement(by: operand, ordering: .acquiringAndReleasing)
        case .relaxed: storage.loadThenWrappingDecrement(by: operand, ordering: .relaxed)
        case .releasing: storage.loadThenWrappingDecrement(by: operand, ordering: .releasing)
        case .sequentiallyConsistent: storage.loadThenWrappingDecrement(by: operand, ordering: .sequentiallyConsistent)
        }

        return (old, old &- operand)
    }

    @inline(always)
    @discardableResult
    public func _update(
        ordering: AtomicUpdateOrdering,
        closure: (Value) -> Value
    ) -> (oldValue: Value, newValue: Value) {
        var old = storage.load(ordering: .relaxed)
        while true {
            let new = closure(old)
            let (done, current) = switch ordering {
            case .acquiring:
                storage.weakCompareExchange(
                    expected: old,
                    desired: new,
                    successOrdering: .acquiring,
                    failureOrdering: .relaxed
                )
            case .acquiringAndReleasing:
                storage.weakCompareExchange(
                    expected: old,
                    desired: new,
                    successOrdering: .acquiringAndReleasing,
                    failureOrdering: .relaxed
                )
            case .relaxed:
                storage.weakCompareExchange(
                    expected: old,
                    desired: new,
                    successOrdering: .relaxed,
                    failureOrdering: .relaxed
                )
            case .releasing:
                storage.weakCompareExchange(
                    expected: old,
                    desired: new,
                    successOrdering: .releasing,
                    failureOrdering: .relaxed
                )
            case .sequentiallyConsistent:
                storage.weakCompareExchange(
                    expected: old,
                    desired: new,
                    successOrdering: .sequentiallyConsistent,
                    failureOrdering: .relaxed
                )
            }

            if done { return (old, new) }
            old = current
        }
    }
}

extension Atomic where Value == Bool {
    @discardableResult
    public func logicalAnd(_ operand: Bool, ordering: AtomicUpdateOrdering)
    -> (oldValue: Bool, newValue: Bool) {
        let old = switch ordering {
        case .acquiring: storage.loadThenLogicalAnd(with: operand, ordering: .acquiring)
        case .acquiringAndReleasing: storage.loadThenLogicalAnd(with: operand, ordering: .acquiringAndReleasing)
        case .relaxed: storage.loadThenLogicalAnd(with: operand, ordering: .relaxed)
        case .releasing: storage.loadThenLogicalAnd(with: operand, ordering: .releasing)
        case .sequentiallyConsistent: storage.loadThenLogicalAnd(with: operand, ordering: .sequentiallyConsistent)
        }

        return (old, old && operand)
    }

    @discardableResult
    public func logicalOr(_ operand: Bool, ordering: AtomicUpdateOrdering)
    -> (oldValue: Bool, newValue: Bool) {
        let old = switch ordering {
        case .acquiring: storage.loadThenLogicalOr(with: operand, ordering: .acquiring)
        case .acquiringAndReleasing: storage.loadThenLogicalOr(with: operand, ordering: .acquiringAndReleasing)
        case .relaxed: storage.loadThenLogicalOr(with: operand, ordering: .relaxed)
        case .releasing: storage.loadThenLogicalOr(with: operand, ordering: .releasing)
        case .sequentiallyConsistent: storage.loadThenLogicalOr(with: operand, ordering: .sequentiallyConsistent)
        }

        return (old, old || operand)
    }

    @discardableResult
    public func logicalXor(_ operand: Bool, ordering: AtomicUpdateOrdering)
    -> (oldValue: Bool, newValue: Bool) {
        let old = switch ordering {
        case .acquiring: storage.loadThenLogicalXor(with: operand, ordering: .acquiring)
        case .acquiringAndReleasing: storage.loadThenLogicalXor(with: operand, ordering: .acquiringAndReleasing)
        case .relaxed: storage.loadThenLogicalXor(with: operand, ordering: .relaxed)
        case .releasing: storage.loadThenLogicalXor(with: operand, ordering: .releasing)
        case .sequentiallyConsistent: storage.loadThenLogicalXor(with: operand, ordering: .sequentiallyConsistent)
        }

        return (old, old != operand)
    }
}

#endif
