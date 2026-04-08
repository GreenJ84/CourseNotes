# **Topic 4.2.2: Hardware Interaction and Peripherals**

Embedded systems derive their functionality from direct interaction with hardware components. Unlike general-purpose systems where hardware access is abstracted by operating systems and drivers, embedded software often operates at or near the register level. That proximity gives you control, but it also makes correctness, timing, and concurrency part of the design problem. This topic explores how software communicates with hardware, how common peripherals are structured and used, and how Rust enables safe, maintainable, and efficient hardware interaction through strong abstractions and ownership guarantees.

## **Learning Objectives**

- Understand how software interfaces with hardware at the register and bus level
- Identify and utilize common embedded peripherals
- Apply register-level programming techniques safely and effectively
- Evaluate the role and trade-offs of Hardware Abstraction Layers (HALs)
- Implement safe encapsulation patterns for hardware access in Rust
- Design robust interfaces that prevent invalid hardware states
- Reason about peripheral ownership, mutability, and concurrency in embedded Rust
- Recognize when direct register access is appropriate and when abstraction is the better choice
- Read register operations as part of a larger hardware state machine, not isolated instructions

---

## **Hardware Model Overview**

Embedded hardware is controlled through **memory-mapped interfaces** and **communication buses**, not through high-level APIs. A peripheral is usually a small hardware block with a set of registers that define configuration, status, and data transfer behavior. The software is not calling a function inside the peripheral; it is changing the state of a device that responds to those writes.

### Registers

- Small memory locations within peripherals
- Control behavior through configuration registers or expose state through status registers
- Typically accessed via fixed memory addresses described in the chip reference manual
- May be read-only, write-only, or read-write depending on the block
- Often individual bits or bit fields have independent meaning

A register is best understood as a contract. Writing the wrong value may do nothing, do the wrong thing, or put the peripheral into an invalid state that is hard to debug.

### Memory-Mapped I/O (MMIO)

- Hardware registers mapped into the system’s address space
- Accessed like normal memory reads and writes
- Requires volatile operations so the compiler does not optimize away hardware access
- Example (conceptual):

  ```rust
  let reg = 0x4000_1000 as *mut u32;
  unsafe { core::ptr::write_volatile(reg, 0x1); }
  ```

This looks like an ordinary memory write, but the semantics are different. The compiler must treat it as an observable side effect because the hardware depends on the write happening exactly as written.

### Peripheral Buses

- Communication pathways connecting CPU to peripherals
- Examples:
  - Internal: AMBA (AHB/APB)
  - External: SPI, I2C, UART, CAN, USB
- Define how data is transferred, clocked, and arbitrated between components
- Influence latency, throughput, and how peripherals are accessed by software

Bus choice matters. A fast peripheral on a slow bus may still become a bottleneck, and a simple peripheral may impose protocol delays that shape the structure of your driver.

### Key Insight

Hardware interaction is fundamentally *state manipulation through memory*, requiring precise control, an understanding of timing, and respect for concurrency boundaries.

In practice, the software is often coordinating a state machine that lives partly in hardware and partly in firmware.

---

## **Common Peripherals**

Embedded systems typically include a variety of peripherals that provide essential functionality. Each peripheral has its own programming model, configuration options, and use cases. Understanding these common peripherals is crucial for effective embedded software development.

### GPIO (General Purpose Input/Output)

- Digital pins configurable as input or output
- Used for LEDs, buttons, interrupts, chip selects, and general signaling
- Operations typically include:
  - Set high or low
  - Read pin state
  - Select pull-up or pull-down behavior
  - Configure output type or drive strength

GPIO is often the first peripheral you touch because it provides visible feedback. Toggling an LED is useful, but the important lesson is that even a simple pin is still a stateful hardware resource with configuration and ownership concerns.

#### Example

Turning a pin on and then off in a controlled way

```rust
struct LedPin {
  out_reg: *mut u32,
}

impl LedPin {
  fn on(&self) {
    unsafe { core::ptr::write_volatile(self.out_reg, 1); }
  }

  fn off(&self) {
    unsafe { core::ptr::write_volatile(self.out_reg, 0); }
  }
}
```

This example is intentionally small, but it shows an important design choice: the rest of the program uses `on` and `off`, not raw bit manipulation. That keeps the unsafe portion narrow and the call site meaningful.


### Timers and Counters

- Track time or count events
- Used for scheduling, delays, pulse measurement, and timeouts
- Can trigger interrupts on overflow or compare match
- Often provide prescalers, capture/compare channels, and PWM generation support

Timers are more than delay helpers. A well-designed embedded system uses timers to build periodic work, measure external events, timestamp input changes, and coordinate actions without busy waiting.

#### Example

Expressing a timeout in a driver

```rust
fn wait_for_ready<F>(mut is_ready: F, timeout_cycles: u32) -> bool
where
  F: FnMut() -> bool,
{
  let mut elapsed = 0;

  while elapsed < timeout_cycles {
    if is_ready() {
      return true;
    }
    elapsed += 1;
  }

  false
}
```

The code above does not talk to a specific timer peripheral, but it shows the driver-level pattern: hardware interactions should fail predictably instead of spinning forever when a device stops responding.


### ADC (Analog-to-Digital Converter)

- Converts analog signals such as voltage into digital values
- Used for sensors including temperature, light, pressure, and battery monitoring
- May support different sampling rates, reference voltages, resolutions, and channel muxing

ADC work is a reminder that peripherals are not just digital switches. The value you read depends on hardware configuration: reference voltage, sampling time, resolution, and electrical characteristics of the source.

If an ADC reading looks wrong, the bug may be in setup rather than in the measurement call itself.


### DAC (Digital-to-Analog Converter)

- Converts digital values into analog output voltages
- Used in audio output, waveform generation, calibration, and control signals
- Often needs buffering or filtering depending on the final analog use case

DACs are often paired with timers so that output updates occur at a stable rate. That combination is common in waveform generation and simple signal synthesis.


### PWM (Pulse Width Modulation)

- Generates variable duty cycle signals by switching a pin on and off at a fixed frequency
- Used for motor control, dimming LEDs, servos, buzzers, and power control
- Works by encoding average power or signal behavior in the duty cycle rather than changing voltage directly

PWM is useful because it gives you a controllable output using simple digital hardware. The key idea is that the load responds to the average effect of a rapid on/off signal, not just the instantaneous state of the pin.


### Serial Interfaces

- Communication with external devices and companion chips
- Common when a peripheral is too complex for direct GPIO-style control
- Common types:
  - UART: asynchronous, simple serial communication
  - SPI: fast, full-duplex communication with explicit chip-select handling
  - I2C: multi-device bus with addressing and shared-wire communication

Each interface makes different trade-offs:

- UART is simple and robust for point-to-point communication
- SPI is good for speed and predictable framing
- I2C is efficient for connecting many low-speed devices with fewer wires

When writing drivers, the serial protocol often determines the public API shape. A device that requires register writes, readback verification, and command delays should usually expose those constraints directly rather than hiding them behind a thin convenience layer.

---

## **Register-Level Programming**

Embedded software often needs to manipulate hardware registers directly. That is a powerful but dangerous tool. The key to doing it well is to understand the hardware contract, use Rust’s safety features to enforce correct usage, and keep the unsafe code as small and auditable as possible.

### Reading and Writing Registers

Registers are manipulated through bit-level operations, usually with masks, shifts, and volatile access.

```rust
const GPIO_OUT: *mut u32 = 0x4000_2000 as *mut u32;

unsafe {
    core::ptr::write_volatile(GPIO_OUT, 0x1); // Set output high
}
```

This example writes a literal value to a peripheral register. In real code, the register may be part of a larger structure, and only one bit might control the output level. The important part is not the exact address; it is the pattern of precise, deliberate, volatile access.


### Bit Masks and Bitfields

- Registers often control multiple features via individual bits or compact bit fields
- Masks let you modify one feature without disturbing unrelated configuration
- Bitfields are useful when a register contains several related settings packed together

```rust
let value = unsafe { core::ptr::read_volatile(GPIO_OUT) };
let new_value = value | (1 << 3); // Set bit 3
unsafe { core::ptr::write_volatile(GPIO_OUT, new_value); }
```

The key concern is preserving the other bits. A read-modify-write sequence is common, but it is not always safe if interrupts or another execution context can change the same register concurrently.

Bitfields define structured layouts within registers. In Rust, typed wrappers often model those layouts so the call site uses clear methods instead of raw magic numbers.

#### Example

Making a register update easier to read

```rust
const ENABLE_BIT: u32 = 1 << 0;
const MODE_BITS: u32 = 0b11 << 4;

fn enable_pwm(current: u32) -> u32 {
  let cleared = current & !MODE_BITS;
  cleared | ENABLE_BIT | (0b10 << 4)
}
```

The example separates intent into named constants. That is a small change, but it makes the hardware contract visible and reduces accidental misuse.


### Safety Issues with Direct Access

- Undefined behavior from incorrect memory access
- Race conditions between CPU and interrupts
- Invalid hardware states from incorrect configuration or illegal register combinations
- Lack of compile-time guarantees in raw pointer usage
- Hardware side effects that occur on read, write, or clear operations

### Volatile Access Concerns

Volatile operations (`read_volatile`, `write_volatile`) prevent the compiler from removing or reordering hardware interactions in ways that would break device behavior. They do not make access thread-safe, atomic, or logically correct. They only preserve the fact that the access happens.

That distinction matters. Many bugs in embedded code come from assuming that “volatile” is a safety feature. It is not. It is only a compiler barrier for that specific access pattern.

In addition, some registers have special semantics. Reading may clear a status bit, writing one may trigger an action, and writing zero may mean “leave unchanged” or “disable.” Always check the reference manual before assuming a register behaves like ordinary memory.

---

## **Hardware Abstraction Layers (HALs)**

A Hardware Abstraction Layer (HAL) is a software layer that provides a higher-level interface to hardware peripherals. The goal of a HAL is to make it easier and safer to interact with hardware by abstracting away low-level details while still exposing the necessary functionality.

### Why HALs Exist

- Provide safe, structured interfaces over raw hardware
- Abstract away register-level complexity
- Improve portability across hardware platforms and chip families
- Capture peripheral constraints in the type system when possible
- Reduce duplicated register code across drivers and applications

HALs are most valuable when they convert low-level rules into ordinary Rust APIs. Instead of every feature consumer learning a register map, the HAL lets them work with concepts such as `set_high`, `read`, `write`, `enable`, or `configure`.


### Portability vs Direct Control Trade-Offs

| Approach               | Advantages                       | Disadvantages               |
| ---------------------- | -------------------------------- | --------------------------- |
| Direct Register Access | Maximum control, performance     | Error-prone, non-portable   |
| HAL                    | Safety, portability, readability | Slight abstraction overhead |

The trade-off is rarely binary. Many real systems use a HAL for most of the code and direct register access for a small set of performance-sensitive or unsupported features.

That is usually a healthy design. The goal is not to avoid all low-level work; it is to keep low-level work contained and understandable.


### Vendor APIs vs Portable Crates

- **Vendor APIs**

  - Provided by chip manufacturers
  - Highly optimized for specific hardware
  - Often less idiomatic or portable
  - Frequently expose the exact chip terminology, which can be helpful for advanced features but noisy for common tasks

- **Portable Crates (Rust Ecosystem)**

  - Example patterns: `embedded-hal` traits and ecosystem drivers
  - Enable hardware-agnostic driver development
  - Promote ecosystem interoperability
  - Make it easier to swap peripherals without rewriting application logic

> **Senior Insight:**
> Use HALs for most development; drop to registers only when necessary for performance, precise timing, unsupported features, or when debugging hardware behavior.
>
> The best abstraction is the one that preserves the hardware model without making the software harder to reason about.

---

## **Rust Access Patterns**

Accessing hardware in Rust is not just about using `unsafe`. It is about designing APIs that reflect the hardware contract while leveraging Rust’s safety features to prevent misuse.

### Safe Peripheral Access

Rust encourages structured access through ownership and narrow interfaces. A peripheral wrapper should represent a real hardware capability, not just a bundle of raw pointers.

```rust
struct GpioPin {
    address: *mut u32,
}

impl GpioPin {
    fn set_high(&self) {
        unsafe { core::ptr::write_volatile(self.address, 1); }
    }

    fn set_low(&self) {
        unsafe { core::ptr::write_volatile(self.address, 0); }
    }
}
```

Here, `set_high` and `set_low` are intentionally simple. The benefit is that the unsafe write is hidden behind a safe API that expresses intent. Callers do not need to know register addresses or bit layouts.


### Type-Safe Peripheral Ownership

- Each peripheral is owned by a single abstraction
- Prevents conflicting access
- Shared access should be explicit and carefully synchronized

```rust
struct Timer {
    // exclusive ownership of timer peripheral
}
```

Ownership becomes especially important when a peripheral has multiple consumers. If a timer is used both for delays and for PWM output, the API should make that relationship obvious instead of allowing random code paths to reconfigure it unexpectedly.

In practice, many embedded crates use singleton initialization or a peripheral split pattern so the hardware is consumed once and then divided into safe sub-components.


### Avoiding Invalid States

- Use types to encode valid configurations
- Model state transitions explicitly
- Prevent illegal sequences at compile time when possible

```rust
struct ConfiguredPin;
struct UnconfiguredPin;
```

This pattern is useful when a peripheral must follow a setup sequence. For example, a pin may need to be configured as output before it can be driven, or a serial peripheral may need clock setup before use.

The compiler can enforce those rules if the API exposes separate types for each phase of configuration.

> This is known as the *typestate pattern*, widely used in Rust embedded design.

---

## **Safety and Abstraction Strategies**

Safety in hardware interaction is about more than just avoiding undefined behavior. It is about designing APIs that prevent invalid hardware states, reduce the chance of race conditions, and make the hardware contract clear to users of the API.

### Encapsulation of Unsafe Code

- Keep unsafe blocks small, isolated, and easy to audit
- Put the unsafe code in one place and expose safe methods around it
- Document the assumptions that must remain true for the unsafe code to be correct

```rust
pub fn write_register(addr: *mut u32, value: u32) {
    unsafe { core::ptr::write_volatile(addr, value); }
}
```

The strength of this pattern is that the unsafe boundary is visible. You can review the assumptions once instead of re-checking pointer manipulation in every caller.


### Designing Safe APIs

- Expose safe interfaces while hiding unsafe internals
- Validate inputs before hardware interaction
- Prevent misuse through type constraints
- Prefer meaningful types over loosely structured integers where the domain is known
- Return clear results when hardware can fail or time out

For example, a baud-rate configuration function should not accept arbitrary values if only a specific range is valid for a given clock setup. The API should either validate the value or encode the constraint in the type system.

This is one of the strongest reasons to use Rust in embedded work: the compiler can help express hardware rules that would otherwise live only in comments or in a datasheet.


### Concurrency and Interrupt Safety

- Protect shared resources accessed by interrupts
- Use critical sections, atomics, or interrupt masking when required
- Avoid data races through ownership rules
- Be aware of read-modify-write hazards on registers shared across contexts

An embedded system often has at least two execution contexts: foreground code and interrupt handlers. If both can touch the same register or buffer, the design must make that interaction explicit and safe.

When a resource is shared, one of the following is usually true:

- Access is serialized through ownership
- Access is protected by a critical section
- Access is designed to be atomic at the hardware level

The wrong choice can create rare, timing-sensitive bugs that are difficult to reproduce.


### Zero-Cost Abstractions

- High-level interfaces compile to efficient machine code
- No runtime penalty for abstraction when designed correctly
- Generic drivers can be optimized away into direct calls by the compiler
- Strong types improve clarity without necessarily adding runtime cost

In embedded Rust, “safe” does not have to mean “slow.” If the abstraction is expressed well, the compiler can inline the simple parts and remove wrapper overhead, leaving you with code that is both readable and efficient.

---

## **Professional Applications and Implementation**


Hardware interaction is central to embedded engineering roles:

- Firmware engineers controlling microcontrollers and peripherals
- IoT developers interfacing with sensors and communication modules
- Automotive engineers designing ECU-level control systems
- Robotics engineers managing actuators and feedback systems
- Systems engineers optimizing low-level performance and reliability

The practical value of this topic is that the same concepts appear across many kinds of embedded work. Whether you are reading a sensor over I2C, driving a motor with PWM, or handling a serial protocol, the underlying concerns are the same: initialize correctly, preserve invariants, avoid races, and keep hardware access predictable.

Rust’s approach enables building systems that are both *safe and performant*, reducing common failure modes present in traditional C/C++ implementations. That advantage becomes most visible when a project grows and multiple developers start touching the same peripherals. The type system and ownership model help keep the hardware contract intact over time.

Common implementation patterns include:

- Wrapping peripheral registers in a dedicated module
- Splitting a device into read/write/control pieces
- Representing configuration phases with separate types
- Keeping `unsafe` isolated to register access and raw pointer conversion
- Building reusable drivers against `embedded-hal` traits when possible

---

## **Key Takeaways**

| Concept Area         | Summary                                                                                                        |
| -------------------- | -------------------------------------------------------------------------------------------------------------- |
| Hardware Model       | Software interacts with hardware through registers, buses, and device state machines.                          |
| Peripherals          | Core components include GPIO, timers, ADC/DAC, PWM, and serial communication interfaces.                       |
| Register Programming | Requires precise bit-level control, volatile access, and careful handling of shared state.                     |
| HALs                 | Provide safer, portable abstractions over low-level hardware access while preserving useful hardware concepts. |
| Rust Patterns        | Ownership, borrowing, and typestate patterns enforce safe peripheral usage.                                    |
| Safety Strategies    | Encapsulation, validation, and compile-time guarantees reduce hardware interaction risks.                      |

- Hardware interaction is fundamentally low-level and state-driven
- Direct register access offers control but introduces significant risk
- HALs balance safety, portability, and usability
- Rust enforces safe access patterns through ownership, borrowing, and types
- Proper abstraction design is critical for maintainable embedded systems
- The best embedded APIs reflect the real constraints of the underlying hardware
- Unsafe code should be small enough that its assumptions can be reviewed quickly
