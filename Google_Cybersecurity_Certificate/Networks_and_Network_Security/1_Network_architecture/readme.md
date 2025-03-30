# **Network Architecture**

Understanding network design and functionality is essential for securing a network. This module covers the structure of networks, standard networking tools, cloud networks, and the **TCP/IP model**, which provides the framework for network communication.

## **Learning Objectives**

By the end of this module, you should be able to:

- **Define types of networks**
- **Describe physical components of a network**
- **Understand how the TCP/IP model provides a framework for network communication**
- **Explain how data is sent and received over a network**
- **Explain network architecture**

## **Introduction to Networks**

### What is a Network?

A **network** is a group of connected devices that communicate over wired or wireless connections. Common networked devices include:

- **Home networks**: Laptops, smartphones, smart devices (e.g., refrigerators, air conditioners).
- **Office networks**: Workstations, printers, servers.

Devices on a network communicate using unique **IP addresses** and **MAC addresses** to ensure data is sent to the correct destination.

### Types of Networks

Networks are categorized based on their scale and reach:

- **Local Area Network (LAN)**: Covers a small area like an office, school, or home. Example: A home Wi-Fi network.
- **Wide Area Network (WAN)**: Covers a large geographic area, such as a city, country, or the internet itself.

### Common Network Devices

Networks rely on various devices to facilitate communication and data transfer:

#### **1. Hub**

- Broadcasts data to all connected devices.
- Lacks intelligence—sends data to all recipients, regardless of destination.
- Less secure and efficient than modern alternatives.

#### **2. Switch**

- Directs data only to the intended recipient.
- Uses MAC addresses to manage traffic.
- Enhances performance and security compared to hubs.

#### **3. Router**

- Connects multiple networks.
- Directs data between networks using IP addresses.
- Example: Sending data from a computer in one network to a tablet in another.

#### **4. Modem**

- Connects a local network to the internet.
- Translates signals between a router and the internet service provider (ISP).

#### **5. Wireless Access Point**

- Extends a network wirelessly using Wi-Fi.
- Allows devices with wireless adapters to connect without physical cables.

### Virtualized Network Tools

Many traditional network functions are now performed by **virtualized tools** offered by cloud service providers. These tools replicate the functionality of hubs, switches, routers, and modems while offering:

- **Cost savings**: No need for physical infrastructure.
- **Scalability**: Resources can be adjusted based on demand.

### Network Diagrams

Security analysts use **network diagrams** to visualize network structure, showing:

- Device connections (e.g., routers, switches, firewalls).
- Traffic flow.
- Security layers.


## **Network Communication**

### Data Packets and Network Communication

Network communication occurs when **data packets** are transferred from one point to another. A **data packet** contains:

- **Header**: Includes the source and destination IP addresses, MAC addresses, and protocol number.
- **Body**: Contains the actual message being transmitted.
- **Footer**: Signals the receiving device that the packet is complete.

Packets move through networks based on addressing and routing protocols, ensuring data reaches its intended recipient.

### Bandwidth and Speed

- **Bandwidth**: The amount of data transferred per second. Calculated as:
  \[
  \text{Bandwidth} = \frac{\text{Data Transferred}}{\text{Time (seconds)}}
  \]
- **Speed**: The rate at which packets are transmitted or received.
- **Packet Sniffing**: A technique used to inspect network traffic for anomalies or potential security threats.

### Ports and Network Traffic

- **Port**: A software-based endpoint in a device's operating system that directs data to specific services.
- **Common Ports**:
  - **Port 25**: Email (SMTP)
  - **Port 443**: Secure internet communication (HTTPS)
  - **Port 20**: Large file transfers (FTP)

### TCP/IP Model

The **Transmission Control Protocol/Internet Protocol (TCP/IP)** is the standard model for network communication. It consists of:

- **TCP (Transmission Control Protocol)**: Establishes a connection, organizes data, and ensures reliable transmission.
- **IP (Internet Protocol)**: Assigns addresses and routes packets across networks.

#### TCP/IP Model Layers

1. **Network Access Layer**: Manages physical transmission, including network cables, switches, and MAC address resolution (ARP).
2. **Internet Layer**: Assigns IP addresses and routes packets to their destinations.
3. **Transport Layer**: Controls traffic flow and connection reliability using **TCP (connection-based)** and **UDP (connectionless, used for real-time applications)**.
4. **Application Layer**: Defines how data packets interact with services (e.g., HTTP, FTP, DNS, SMTP).


### TCP/IP vs. OSI Model

The **OSI (Open Systems Interconnection) model** expands upon TCP/IP with **seven layers**:

1. **Application Layer**: Interfaces directly with user applications (e.g., web browsers, email clients).
2. **Presentation Layer**: Manages encryption and data formatting (e.g., SSL/TLS).
3. **Session Layer**: Maintains connections and session checkpoints.
4. **Transport Layer**: Handles segmentation, flow control, and reliable transmission (TCP/UDP).
5. **Network Layer**: Routes packets between different networks (IP, ICMP).
6. **Data Link Layer**: Organizes packet delivery within a single network (MAC addressing, switches).
7. **Physical Layer**: Deals with hardware components (cables, hubs, modems).


## **Local and Wide Area Networks**

### IP Addresses and Network Communication

An **IP address (Internet Protocol address)** is a unique identifier assigned to a device on a network, similar to a home mailing address.

#### Types of IP Addresses

1. **IPv4**: 
   - Written as four 1-3 digit numbers separated by dots (e.g., `192.168.1.1`).
   - Originally designed to accommodate all internet-connected devices.
   - Limited to **4.3 billion unique addresses**.

2. **IPv6**:
   - 32-character hexadecimal format separated by colons (e.g., `2002:0db8::ff21:0023:1234`).
   - Developed to accommodate **340 undecillion (10³⁶) addresses**.

#### Public vs. Private IP Addresses

- **Public IP Address**: Assigned by an ISP (Internet Service Provider) and visible on the internet.
- **Private IP Address**: Used for local device communication within a **Local Area Network (LAN)** and is not visible externally.

### MAC Addresses and Network Devices

- **MAC Address (Media Access Control)**: A unique alphanumeric identifier assigned to a network device.
- **MAC Address Table**: Maintained by switches to map MAC addresses to physical ports for efficient packet forwarding.

### Network Layer (Layer 3) Operations

At **Layer 3 (Network Layer)** of the **OSI Model**, devices organize and direct data packets from a **source IP address** to a **destination IP address**.

- **Routing**: Data packets move between networks via routers based on routing tables.
- **IP Packets**: Used in **TCP connections**, whereas **datagrams** are used in **UDP connections**.

### IPv4 Packet Structure

An **IPv4 packet** consists of:

1. **Header**: Contains metadata such as source/destination IP, TTL, and protocol type.
2. **Data**: The actual message being transmitted.

#### IPv4 Header Fields

| Field | Description |
|--------|-------------|
| **Version (VER)** | Identifies the IP protocol version (e.g., IPv4). |
| **Header Length (HLEN/IHL)** | Specifies where the header ends and data begins. |
| **Type of Service (ToS)** | Helps prioritize network traffic. |
| **Total Length** | Specifies the total size of the packet. |
| **Identification** | Unique ID for fragmented packets. |
| **Flags** | Indicates if packet fragmentation is allowed. |
| **Fragment Offset** | Identifies position of fragmented packets. |
| **Time to Live (TTL)** | Limits the lifespan of a packet (prevents infinite loops). |
| **Protocol** | Indicates which transport protocol is used (e.g., TCP/UDP). |
| **Header Checksum** | Verifies header integrity. |
| **Source IP Address** | The sender's IP address. |
| **Destination IP Address** | The recipient's IP address. |
| **Options** | Allows for extra routing and security options. |

### Differences Between IPv4 and IPv6

| Feature | IPv4 | IPv6 |
|---------|------|------|
| **Address Format** | 32-bit (e.g., `192.168.1.1`) | 128-bit (e.g., `2002:0db8::ff21:0023:1234`) |
| **Total Addresses** | 4.3 billion | 340 undecillion |
| **Packet Header Complexity** | More fields, more overhead | Simpler, more efficient |
| **Security** | Manual configuration for encryption | Built-in encryption and security features |
| **Addressing Method** | Uses NAT for private IPs | Eliminates NAT due to large address space |



## **Key Takeaways**

- Networks connect devices using wired or wireless communication.
- Devices identify each other using **IP and MAC addresses**.
- Networks are classified as **LANs** (local) or **WANs** (wide-area).
- Common network devices include **hubs, switches, routers, modems, and wireless access points**.
- **Virtualized networking tools** reduce costs and increase scalability.
- **Network diagrams** help security analysts visualize and manage network security.
- **Data packets** contain headers, bodies, and footers to ensure structured network communication.
- **Bandwidth and speed** impact network performance and security monitoring.
- **The TCP/IP model** has four layers, while the **OSI model** has seven layers.
- **Network ports** categorize traffic, ensuring efficient data delivery.
- **Security professionals use network models** to analyze threats, diagnose issues, and optimize network performance.
- **IP addresses** are unique identifiers for networked devices.
- **MAC addresses** are hardware-specific identifiers used for local device communication.
- **Layer 3 (Network Layer)** handles **IP addressing and routing** across different networks.
- **IPv6** was developed to solve **IPv4 address exhaustion** and includes security enhancements.
- **Understanding IP packet headers** is essential for network security analysis.
