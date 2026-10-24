# SyncPolyfill

A quick-and-dirty polyfill that allows use of Synchronization types on older versions of macOS / iOS.
Currently, `Mutex` and `Atomic` are implemented.

On Apple platforms, `Atomic` is backed by [swift-atomics](https://github.com/apple/swift-atomics), so it supports the types that package does. 
Since this polyfill is meant to be small and minimal, `Atomic` may not be able to wrap some types that are not supported by `swift-atomics`, such as `OpaquePointer` or `ObjectIdentifier`. 
Please open an issue if you have a need to wrap anything that is currently not possible in an `Atomic`.
