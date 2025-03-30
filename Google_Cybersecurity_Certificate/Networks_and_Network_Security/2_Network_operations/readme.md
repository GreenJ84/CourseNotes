# **Network Operations**

This module explores **network protocols**, their vulnerabilities, and **security measures** that help maintain safe and reliable network operations. Networks rely on **protocols and security tools** to function effectively and securely. Malicious actors often exploit network communication, but **firewalls, VPNs, security zones, and proxy servers** help mitigate threats. Understanding these concepts is essential for protecting an organization's network from attacks.

By understanding these tools and techniques, security analysts can **detect and prevent network attacks** before they cause harm.

## **Learning Objectives**

- Recognize **network protocols**.
- Describe the protocols used for **wireless network communication**.
- Define **irtual Private Networks (VPNs), firewalls, security zones, and proxy servers** and their role in network security.
- Identify **common network security measures and protocols**.


## **Introduction to Network Protocols**

Network protocols are sets of rules that govern how data is transmitted between devices on a network. They define the structure and delivery order of data, ensuring communication is organized and efficient. Understanding network protocols is essential for security analysts to detect and mitigate vulnerabilities.

### How Network Protocols Work

When accessing a website, multiple protocols work together:

1. **Transmission Control Protocol (TCP)** – Establishes a connection and ensures data is reliably transmitted.
2. **Address Resolution Protocol (ARP)** – Determines the MAC address of the next device in the network path.
3. **Hypertext Transfer Protocol Secure (HTTPS)** – Encrypts web communication for secure transmission.
4. **Domain Name System (DNS)** – Translates domain names into IP addresses.

### Categories of Network Protocols

Network protocols fall into three main categories:

#### 1. Communication Protocols

These protocols define how data is transmitted and received across a network.

- **TCP (Transmission Control Protocol)** – Ensures reliable, ordered data transmission using a three-way handshake.
- **UDP (User Datagram Protocol)** – A faster but less reliable protocol used for real-time communication like video streaming.
- **HTTP (Hypertext Transfer Protocol)** – Facilitates communication between web clients and servers (port 80).
- **HTTPS (Hypertext Transfer Protocol Secure)** – Secure version of HTTP using SSL/TLS encryption (port 443).
- **DNS (Domain Name System)** – Resolves domain names to IP addresses (port 53).
- **NAT (Network Address Translation)** – Allows multiple devices on a local network to share a single public IP address.
- **Telnet** – Used for remote access but is insecure and replaced by SSH (port 23).
- Email Transmission Protocols that govern how email is sent, retrieved, and synchronized:
  - **POP3 (Post Office Protocol v3)** – Retrieves email from a server and downloads it locally (ports 110 & 995 for SSL/TLS).
  - **IMAP (Internet Message Access Protocol)** – Syncs email across multiple devices (ports 143 & 993 for SSL/TLS).
  - **SMTP (Simple Mail Transfer Protocol)** – Sends emails and routes them to the recipient's address (ports 25 & 587 for TLS).

#### 2. Management Protocols

Used for monitoring and managing network activity.

- **DHCP (Dynamic Host Configuration Protocol)** – Automatically assigns IP addresses to devices (UDP ports 67 & 68).
- **SNMP (Simple Network Management Protocol)** – Collects and manages device performance data.
- **ICMP (Internet Control Message Protocol)** – Reports network errors and is used in troubleshooting (e.g., `ping` command).
- **ARP (Address Resolution Protocol)** – Maps IP addresses to MAC addresses for local network communication.

#### 3. Security Protocols

These protocols protect data in transit using encryption.

- **HTTPS (Hypertext Transfer Protocol Secure)** – Encrypts web traffic using SSL/TLS (port 443).
- **SFTP (Secure File Transfer Protocol)** – Securely transfers files over SSH (port 22).
- **SSH (Secure Shell)** – Provides secure remote access and authentication (port 22).

## **Wireless Security**

IEEE 802.11, commonly known as Wi-Fi, is a set of standards that define communication for wireless LANs. The Institute of Electrical and Electronics Engineers (IEEE) maintains these standards. Over time, Wi-Fi security protocols have evolved to ensure secure communication, providing the same level of security as wired connections.

### Wi-Fi and IEEE 802.11

- Wi-Fi is a marketing term commissioned by the Wireless Ethernet Compatibility Alliance (WECA), now known as the Wi-Fi Alliance.
- Based on the IEEE 802.11 family of standards.
- Used for wireless LAN communication.

### Evolution of Wireless Security

- Initially, internet communication relied on physical cables.
- In the mid-1980s, the U.S. allocated a spectrum for wireless internet.
- Wireless communication became widespread in the late 1990s and early 2000s.
- Modern wireless networks support smart devices like thermostats and security cameras.

### Wireless Security Protocols

#### Wired Equivalent Privacy (WEP)

- Introduced in 1999 as the first wireless security protocol.
- Aimed to provide privacy similar to wired networks.
- Weak encryption made it highly vulnerable to attacks.
- Still found in older devices, posing security risks.

#### Wi-Fi Protected Access (WPA)

- Introduced in 2003 to replace WEP.
- Utilized Temporal Key Integrity Protocol (TKIP) for stronger encryption.
- Introduced message integrity checks to prevent data tampering.
- Vulnerable to key reinstallation attacks (KRACK attacks), leading to the development of WPA2.

#### WPA2

- Released in 2004, improving upon WPA.
- Uses Advanced Encryption Standard (AES) and Counter Mode Cipher Block Chaining Message Authentication Code Protocol (CCMP).
- Considered the security standard for Wi-Fi today but still vulnerable to KRACK attacks.

##### Personal Mode

- Best for home networks.
- Requires a shared passphrase for all devices.

##### Enterprise Mode

- Designed for business environments.
- Provides centralized authentication.
- Prevents access to encryption keys by end users.

#### WPA3

- Introduced in 2018 to address WPA2 vulnerabilities.
- Uses Simultaneous Authentication of Equals (SAE) to prevent offline attacks.
- Offers improved encryption with 128-bit security and an optional 192-bit encryption for enterprise mode.

## **System Identification**

### Firewalls

A **firewall** is a network security device that monitors and controls traffic to and from a network based on predefined security rules. It can filter traffic using port numbers, allowing or blocking communication based on security policies.

#### Types of Firewalls

1. **Hardware Firewalls** – Physical devices that inspect data packets before they enter the network.
2. **Software Firewalls** – Installed on computers or servers, analyzing incoming traffic and providing protection.
3. **Cloud-Based Firewalls** – Firewalls as a service (FaaS) offered by cloud providers, protecting both cloud-based and on-premise assets.

#### Stateful vs. Stateless Firewalls

- **Stateful Firewalls** – Track ongoing connections and filter packets based on behavior.
- **Stateless Firewalls** – Apply predefined rules without analyzing connection history, making them less secure.

#### Next-Generation Firewalls (NGFWs)

NGFWs offer advanced security features such as deep packet inspection, intrusion prevention, and cloud-based threat intelligence updates.

---

### Virtual Private Networks (VPNs)

A **VPN** is a security service that encrypts data, masks a user’s IP address, and protects privacy when using public networks.

#### VPN Security Features

- **Encapsulation** – Wraps encrypted data within additional packets to maintain routing information while securing content.
- **Encrypted Tunnel** – Secures data between the user’s device and the VPN server, preventing interception.

#### VPN Types

1. **Remote Access VPN** – Connects a personal device to a VPN server for secure internet access.
2. **Site-to-Site VPN** – Connects entire networks, commonly used by organizations to link offices securely.

#### VPN Protocols

- **WireGuard** – High-speed, lightweight, open-source VPN protocol with modern encryption.
- **IPSec** – A widely adopted VPN protocol for encrypting and authenticating network traffic.

---

### Security Zones & Network Segmentation

Security zones divide a network into sections to control access and protect sensitive data.

#### Types of Security Zones

- **Uncontrolled Zone** – External networks, such as the internet.
- **Controlled Zone** – Internal protected networks.
  - **Demilitarized Zone (DMZ)** – Public-facing services (e.g., web servers, DNS servers).
  - **Internal Network** – Private servers and data.
  - **Restricted Zone** – Confidential data accessible only to privileged users.

#### Network Segmentation

Dividing a network into smaller subnetworks (subnets) enhances security by isolating sensitive areas.

- **Classless Inter-Domain Routing (CIDR)** – Allows flexible subnetting by appending a prefix (e.g., `192.168.1.0/24`).
- **Security Benefits** – Limits attack spread, controls access, and improves performance.

---

### Proxy Servers

A **proxy server** acts as an intermediary between a client and external servers, adding security by masking internal network IP addresses.

#### Types of Proxy Servers

1. **Forward Proxy** – Hides client IP addresses and filters outgoing traffic.
2. **Reverse Proxy** – Protects internal servers by filtering incoming traffic.
3. **Email Proxy** – Filters spam and detects forged sender addresses.

## **Key Takeaways**

- Network protocols define **how devices communicate** and ensure **secure, efficient** data transfer.
- **Communication, management, and security protocols** play essential roles in network operations.
- Security analysts must understand these protocols to **detect vulnerabilities and prevent attacks**.
- **Firewalls** filter traffic using hardware, software, or cloud-based solutions.
- **VPNs** encrypt data and provide secure network access.
- **Security zones** and **network segmentation** help isolate sensitive resources.
- **Proxy servers** enhance security by anonymizing requests and filtering malicious traffic.
