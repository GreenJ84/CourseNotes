# **Securing Against Network Intrusions**

In this module, you will learn about various network attack methods and techniques used to secure compromised systems and devices. Cybersecurity professionals play a crucial role in identifying vulnerabilities and mitigating risks to protect network infrastructure from malicious actors.

## **Learning Objectives**

- Describe the intrusion tactics that malicious actors exploit vulnerabilities in network infrastructure.
- Describe how cybersecurity analysts detect and prevent network intrusions.
- Explain methods to secure networks against intrusion.
- Investigate security breaches.
- Understand different types of network attacks.
- Troubleshoot basic network issues using appropriate tools and methods.

By understanding these key concepts, you will develop the skills necessary to safeguard networks from potential threats. Let’s get started!

## **Introduction to Network Intrusion Tactics**

### Why Secure Networks?

Networks are constantly at risk of attack from malicious actors. Common attack methods include:

- **Malware** – Malicious software used to infiltrate systems.
- **Spoofing** – Impersonation of a trusted device or user.
- **Packet Sniffing** – Intercepting and inspecting network traffic.
- **Packet Flooding** – Overloading a network to disrupt operations.

#### Impact of Network Attacks

Network intrusions can have severe consequences:

- **Financial Loss** – Downtime and ransomware costs can be significant.
- **Reputation Damage** – Customers may lose trust after a security breach.
- **Public Safety Risks** – Critical infrastructure, such as power grids and water systems, could be compromised.

### How Intrusions Compromise Networks

#### Network Interception Attacks

Network interception attacks involve capturing and modifying data in transit.

- **Packet Sniffing** – Attackers use tools to capture and inspect data.
- **On-Path Attacks** – Intercepting communication between two parties.
- **Replay Attacks** – Re-sending captured transmissions to gain access or manipulate systems.

#### Backdoor Attacks

Backdoors are hidden vulnerabilities in software that bypass normal security measures.

- **Legitimate Use** – Programmers may create backdoors for troubleshooting.
- **Malicious Use** – Attackers install backdoors to maintain persistent access.
- **Potential Damage** – Attackers can install malware, launch denial-of-service (DoS) attacks, or steal sensitive data.

### Consequences of Network Attacks

- **Financial Loss** – Downtime, ransomware, and legal costs.
- **Reputation Damage** – Loss of customer trust and market competitiveness.
- **Public Safety Risks** – Cyber attacks on infrastructure can impact national security and safety.

## **Secure Networks Against Denial of Service (DoS) Attacks**

### What is a Denial of Service (DoS) Attack?

A **Denial of Service (DoS) attack** is an attempt to overwhelm a network or server with excessive traffic, preventing legitimate users from accessing services. The goal is to crash the system or render it unresponsive, leading to:

- **Operational disruptions** – Preventing normal business functions.
- **Financial loss** – Downtime can result in lost revenue.
- **Security vulnerabilities** – A disabled system can be exposed to further attacks.

#### Common Network-Level DoS Attacks

##### 1. SYN Flood Attack

A **SYN flood attack** exploits the **TCP handshake process** by overwhelming the server with SYN requests but never completing the handshake, causing:

- Server resource exhaustion.
- Unavailability of network services.

##### 2. ICMP Flood Attack

An **ICMP flood attack** (ping flood) abuses the **Internet Control Message Protocol (ICMP)** by sending a flood of requests, forcing the server to respond and overloading bandwidth.

##### 3. Ping of Death Attack

A **Ping of Death attack** sends **oversized ICMP packets** (greater than 64KB) to crash a system, similar to dropping a heavy rock on an ant colony, disrupting operations.

### Distributed Denial of Service (DDoS) Attacks

A **DDoS attack** is a large-scale version of a DoS attack that utilizes multiple compromised devices (botnets) to flood the target with traffic.

- In DDoS attacks, multiple sources send malicious requests, making it harder to block the attack.
- Attackers may craft special packets that force network devices to use excessive processing power.

### Network Protocol Analyzers and DoS Detection

#### What is a Network Protocol Analyzer?

A **network protocol analyzer** (packet sniffer) is a tool used to capture and analyze network traffic to detect and investigate DoS attacks. Examples include:

- **Wireshark**
- **tcpdump**
- **SolarWinds NetFlow Traffic Analyzer**
- **ManageEngine OpManager**
- **Azure Network Watcher**

#### Using `tcpdump` for DoS Analysis

`tcpdump` is a **command-line network analyzer** that provides insights into network traffic.
Key details captured:

- **Timestamp** – Time of packet capture.
- **Source IP and Port** – Where the packet originated.
- **Destination IP and Port** – Where the packet is going.

Security analysts use `tcpdump` to:

- Establish **baseline network traffic patterns**.
- Detect and identify **malicious traffic**.
- Generate **customized alerts** for unusual network activity.

### Real-Life DDoS Attack: 2016 DNS Attack

A **DDoS attack in 2016** targeted a major DNS provider, leading to widespread outages across North America and Europe.

#### Attack Breakdown

1. **Botnet Creation** – University students created and released a botnet.
2. **Botnet Misuse** – Cybercriminals hijacked the botnet to target the DNS provider.
3. **Attack Execution** – Tens of millions of DNS requests flooded the provider at **7:00 a.m.**, shutting down websites.
4. **Recovery** – After **two hours**, the provider mitigated the attack and restored services.

## **Network Attack Tactics and Defense**

### Packet Sniffing

Packet sniffing is the practice of using software tools to observe data as it moves across a network. This technique can be used by both security analysts for legitimate purposes (such as investigating incidents or debugging network issues) and by malicious actors who seek unauthorized access to information.

- **Malicious Use**: Threat actors may intercept data packets as they travel across the network. These packets contain valuable information such as personal details, financial data, and more. Attackers can insert themselves in the middle of a connection between two devices to spy on data packets.
- **Passive vs. Active Sniffing**:
  - **Passive Packet Sniffing**: Malicious actors listen to network traffic without altering the data, similar to reading someone else's mail.
  - **Active Packet Sniffing**: Attackers manipulate or alter data in transit, like redirecting packets or changing the information they contain.

#### Preventing Malicious Packet Sniffing

To protect against malicious packet sniffing:

1. **VPN (Virtual Private Network)**: Encrypts data so that hackers cannot decode and read it.
2. **HTTPS**: Ensures that websites use SSL/TLS encryption, preventing eavesdropping on network transmissions.
3. **Avoid Unprotected WiFi**: Avoid using public WiFi without a VPN, as these networks lack encryption, making data vulnerable to attackers.

### IP Spoofing

IP spoofing involves changing the source IP address of a data packet to impersonate an authorized system and bypass security measures like firewalls.

- **Common IP Spoofing Attacks**:
  1. **On-Path Attack**: The attacker positions themselves between two trusted devices, intercepting and altering data in transit.
  2. **Replay Attack**: The attacker intercepts and delays or repeats a data packet to impersonate an authorized user.
  3. **Smurf Attack**: A Denial of Service (DoS) attack where an attacker floods the network with spoofed packets, causing system overload.

#### Protecting Against IP Spoofing

To defend against IP spoofing attacks:

- **Firewalls**: Configure firewalls to reject packets with spoofed IP addresses.
- **Encryption**: Always use encryption to protect data in transit and prevent interception.

### Interception Attacks

Interception attacks use packet sniffing and IP spoofing to intercept sensitive data as it travels across the network. Key attack techniques include:

1. **On-Path Attack**: The attacker intercepts communications between trusted devices, collecting sensitive information like usernames and passwords.
2. **Smurf Attack**: Combines IP spoofing with a DoS attack to overwhelm a network by flooding it with packets.

#### Defense Measures

- **On-Path Attacks**: Use **TLS encryption** to protect data during transit.
- **Smurf Attacks**: Use **next-gen firewalls (NGFW)** to detect and block oversized broadcast traffic before it can disrupt the network.

## **Key Takeaways**

- Network intrusions exploit vulnerabilities to steal data, disrupt operations, or damage reputations.
- Attackers use **network interception** and **backdoor attacks** to gain unauthorized access.
- Security analysts must stay informed about emerging threats to protect networks effectively.
- **DoS and DDoS attacks** overwhelm networks, preventing access to critical services.
- **SYN flood, ICMP flood, and Ping of Death** are common network-layer DoS attacks.
- **Network protocol analyzers like `tcpdump` help security analysts detect and investigate threats.**
- **Real-world DDoS attacks, such as the 2016 DNS attack, demonstrate the impact of DoS attacks on global businesses.**
- Packet sniffing and IP spoofing are used in various attacks, including on-path, replay, and smurf attacks.
- Implement encryption (VPN, HTTPS) and properly configure firewalls to protect against these attacks.
- Use defense-in-depth strategies to ensure robust network security against interception attacks.

