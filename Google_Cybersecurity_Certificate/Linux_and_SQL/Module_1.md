# Introduction to Operating Systems

## Overview

Operating systems (OS) are essential for managing computer hardware and software. They enable users to interact with computers, run multiple applications, and manage external devices.

## Learning Objrectives

- Describe common operating systems and their functions
- Describe the relationship between operating systems, applications, and hardware
- Differentiate between graphical user interfaces (GUI) and command-line interfaces (CLI)
- Understand security considerations for operating systems

## The Operating System

An **operating system (OS)** is software that acts as an interface between hardware and the user, ensuring efficient operation and ease of use. It allows users to run applications, manage files, and control hardware components. This section covers:

- The boot process and how an OS starts
- How applications interact with the OS and hardware
- The role of the OS in security

### Evolution of Operating Systems

Early computers lacked operating systems, requiring users to manually load and reset programs. Modern OSs support multitasking, enabling multiple applications to run simultaneously while managing input devices like keyboards, mice, and printers.

### The OS at Work

An operating system functions like a car engine—it handles complex operations behind the scenes to allow users to perform tasks efficiently.

#### **Booting the Computer**

When you turn on a computer, the following sequence occurs:

1. **BIOS/UEFI activation** – A microchip containing boot instructions starts the process.
   - **BIOS** (Basic Input/Output System) – Used in older systems.
   - **UEFI** (Unified Extensible Firmware Interface) – Replaced BIOS in newer systems and offers better security.
2. **Bootloader activation** – Loads the OS into memory.
3. **Operating system initialization** – The system is ready for use.

**Security Concern:**

- The BIOS/UEFI is often not scanned by antivirus software, making it vulnerable to malware.

#### **Processing a User Request**

When a user performs an action, such as opening an application, the OS manages the request through the following steps:

1. **User initiates a task** (e.g., opening a calculator).
2. **Application sends request** to the OS.
3. **OS processes the request** and communicates with hardware.
4. **Hardware executes the task** (e.g., CPU calculates numbers).
5. **Result is sent back** through the OS to the application.

This cycle ensures seamless interaction between the user, software, and hardware.

#### **Security Implications**

Understanding this process helps analysts investigate security incidents by tracing events through the system.

### OS Resource Management

The OS ensures system resources like CPU, memory, and storage are used efficiently.

- **Task Manager** shows active processes, memory, and CPU usage.  
- **Security analysts** use resource monitoring to detect malware or system slowdowns.

### OS and Security

Operating systems play a crucial role in cybersecurity by managing:

- **User authentication** and **data access controls**  
- **File security** to prevent unauthorized access  
- **Malware protection** against viruses, worms, and other threats  
- **System monitoring** through logging and auditing to detect suspicious activity

Security analysts use OS knowledge to configure firewalls, enforce security policies, and maintain system integrity.  

### Common Operating Systems

Several operating systems are widely used in cybersecurity:

#### **Windows & macOS**

- **Windows** (introduced in 1985) is a **closed-source** OS used in both personal and enterprise environments.
- **macOS** (introduced in 1984) is **partially open source**, with its kernel being open but other components closed.

#### **Linux**

- Introduced in **1991**, Linux is **fully open source**, allowing developers to modify and improve it.
- Linux is commonly used in the security industry, with specialized distributions designed for security tasks.

#### **ChromeOS**

- Launched in **2011**, ChromeOS is **partially open source**, derived from Chromium OS.
- Frequently used in educational environments.

#### **Android & iOS**

- **Android** (2008) is an **open-source** mobile OS.
- **iOS** (2007) is **partially open source** but includes proprietary components.
- Mobile OSs are commonly used on smartphones, tablets, and wearable devices.

### OS Vulnerabilities & Security Risks

All operating systems have security risks, and keeping them updated is critical for protection.

#### **Legacy Operating Systems**

- **Legacy OS** refers to outdated systems still in use, often due to software compatibility.
- These systems are vulnerable as they no longer receive security updates, making them prime targets for cyberattacks.

#### **Other Vulnerabilities**

Even up-to-date systems can be attacked. Security professionals monitor vulnerabilities using sources like:

- **Microsoft Security Response Center (MSRC)** – Windows vulnerabilities
- **Apple Security Updates** – macOS & iOS security patches
- **Common Vulnerabilities and Exposures (CVE) for Ubuntu** – Linux security reports
- **Google Cloud Security Bulletin** – Security updates for Google services


## Virtualization Technology

Virtualization allows multiple virtual machines (VMs) to run on a single physical system.

### **What is a Virtual Machine?**

A **VM** is a software-based simulation of a physical computer, running its own OS. VMs:

- Use **virtual CPUs, storage, and memory** instead of dedicated hardware.
- Share physical resources efficiently.

### **Benefits of Virtualization**

- **Security:** VMs provide isolated environments, useful for malware analysis.
- **Efficiency:** Multiple VMs can run simultaneously, reducing hardware costs.

**Security Risk:**

- Malicious software can sometimes escape the virtual environment and infect the host system.

### **Managing Virtual Machines**

- **Hypervisors** manage VMs and allocate resources.
- **Kernel-based Virtual Machine (KVM)** is a Linux-based open-source hypervisor.

### **Other Forms of Virtualization**

- **Virtual Servers**: Multiple virtual servers on a single physical server.
- **Virtual Networks**: Software-defined networking solutions.

## The User Interface


The user interface (UI) allows interaction between the user and the operating system. There are two primary types of user interfaces:

- **Graphical User Interface (GUI)** – Uses icons and visuals.
- **Command-Line Interface (CLI)** – Uses text commands.

### GUI vs. CLI

#### **Graphical User Interface (GUI)**

A GUI provides a **visual** way to interact with the operating system.

- Common elements: **Start menu, taskbar, desktop icons**
- Users interact by **clicking icons** or **searching for applications**
- **Pros:** Easy to use, visually intuitive
- **Cons:** Limited automation, slower for repetitive tasks

#### **Command-Line Interface (CLI)**

A CLI is a **text-based** interface where users enter commands to execute tasks.

- **Pros:**
  - More **powerful and flexible** than GUI
  - Allows **automation and scripting** for efficiency
  - Supports **batch processing** of multiple tasks
- **Cons:**
  - Steeper learning curve
  - No visual representation

### Comparison: GUI vs. CLI

| Feature      | GUI  | CLI  |
|-------------|------|------|
| **Display** | Icons, graphics | Text-based commands |
| **Efficiency** | One request at a time | Multiple requests simultaneously |
| **Customization** | Limited to available options | Highly customizable |
| **Automation** | Low | High |
| **Security Use** | Limited | Essential for security tasks |

#### **CLI in Cybersecurity**

Security analysts frequently use the CLI for:

- **Incident Response:** Running playbooks and analyzing logs
- **Efficiency:** Quickly executing multiple commands
- **History Tracking:** CLI records a **history file**, useful for:
  - Verifying executed commands
  - Investigating security incidents

## Key Takeaways

- Common operating systems include **Windows, macOS, Linux, ChromeOS, Android, and iOS**.
- **Security analysts** must understand OS security, including **legacy OS risks and vulnerability management**.
- Keeping operating systems **updated and secured** is essential in cybersecurity.
- **GUIs** provide a user-friendly, visual interface.
- **CLIs** offer efficiency, automation, and advanced functionality.
- Security analysts **must** be proficient in CLI for log analysis, authentication, and system forensics.
- The OS connects users, applications, and hardware.
- The boot process involves BIOS/UEFI, the bootloader, and OS initialization.
- The OS manages system resources for efficiency and security.
- Virtualization is a critical technology in cybersecurity.

Understanding these concepts is essential for security professionals to analyze system behavior and detect security threats.
