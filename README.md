# Test project to reproduce linking issue

This fork demonstrates a linking issue that occurs when using `Inspektify` with `Unity` in an iOS app.  
It runs only on a physical device, not in the simulator.

## Problem Description

When building as a _static library_, the iOS app fails to run if Xcode's `Thread Performance Checker` is enabled. Upon startup, the following error is triggered:
```
libRPAC.dylib`invocation function for block in initializePrimitiveMap():
    0x10329a9c8 <+0>:   pacibsp 
    0x10329a9cc <+4>:   stp    x22, x21, [sp, #-0x30]!
    0x10329a9d0 <+8>:   stp    x20, x19, [sp, #0x10]
    0x10329a9d4 <+12>:  stp    x29, x30, [sp, #0x20]
    0x10329a9d8 <+16>:  add    x29, sp, #0x20
    0x10329a9dc <+20>:  bl     0x103297904               ; getNumCPU
    0x10329a9e0 <+24>:  sub    w8, w0, #0x1
    0x10329a9e4 <+28>:  cmp    w8, #0x3e
    0x10329a9e8 <+32>:  b.hi   0x10329a9f4               ; <+44>
    0x10329a9ec <+36>:  adrp   x8, 14
    0x10329a9f0 <+40>:  str    w0, [x8, #0x840]
    0x10329a9f4 <+44>:  mov    x19, #0x0                 ; =0 
    0x10329a9f8 <+48>:  mov    w20, #0x3f800000          ; =1065353216 
    0x10329a9fc <+52>:  adrp   x21, 1166
    0x10329aa00 <+56>:  add    x21, x21, #0xd20          ; primitive_map
    0x10329aa04 <+60>:  mov    w0, #0x28                 ; =40 
    0x10329aa08 <+64>:  mov    x1, #0x4b1c               ; =19228 
    0x10329aa0c <+68>:  movk   x1, #0x8ef2, lsl #16
    0x10329aa10 <+72>:  movk   x1, #0x80, lsl #32
    0x10329aa14 <+76>:  movk   x1, #0x10a, lsl #48
    0x10329aa18 <+80>:  bl     0x10329ebb0               ; symbol stub for: operator new(unsigned long, std::__type_descriptor_t)
->  0x10329aa1c <+84>:  movi.2d v0, #0000000000000000
...
```

When Xcode’s `Thread Performance Checker` is disabled, the app runs without issues.

## Analysis

This issue appears to stem from a conflict between the `sqlite3` libraries used by `Inspektify` and, presumably, by `Unity` as well.

- Building the `kmp library` as a _dynamic library_ resolves this issue but isn’t a feasible solution for our project due to other downstream issues.
- With `Thread Performance Checker` enabled, `libRPAC` seems to perform analyses related to `SQLite` symbols, which leads to this error. A similar issue is discussed in this article: [Dynamic Linking Crash with Xcode 16](https://www.nutrient.io/blog/dynamic-linking-crash-xcode-16/).
