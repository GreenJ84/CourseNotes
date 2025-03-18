# Security Hardening

## Introduction

Security hardening involves implementing protective measures across devices, networks, applications, and cloud infrastructures. This process is aimed at reducing the system's vulnerabilities and attack surface, making it more difficult for malicious actors to exploit potential weaknesses. To help you understand this concept, imagine a network as a house: the attack surface would be all the doors and windows that a robber could use to enter. Just like adding locks to every door and window to protect the house, security hardening minimizes the attack surface to secure the network.

As a security analyst, tasks like patch updates, backups, and regular security checks will become a regular part of your duties. You'll also learn about penetration testing, a strategy that simulates attacks to identify vulnerabilities in systems. By the end of this module, you'll have a clear understanding of how to reduce the attack surface and apply security hardening practices to protect your organization effectively.

## Learning Objectives

- Describe OS hardening techniques
- Describe network hardening techniques
- Describe cloud hardening
- Explain cloud security practices

By the end of this module, you'll understand how security hardening helps defend against malicious attacks and how to apply these techniques in your day-to-day tasks.

## OS Hardening

Operating system (OS) hardening is an essential step to ensure the security of networks. The OS serves as the interface between computer hardware and users, and it is loaded first when a system powers on. It acts as an intermediary between applications and hardware. Securing the OS is crucial because a vulnerable OS can compromise the entire network.

### Regular OS Hardening Tasks

Some OS hardening tasks are performed regularly, including:

1. **Patch Updates**
   A patch update addresses security vulnerabilities within the OS. These patches are released by OS vendors to fix flaws or vulnerabilities. Updating the OS to the latest version is essential because malicious actors can exploit unpatched systems once vulnerabilities are discovered. A baseline configuration, which includes updated OS versions, is created and compared during security checks to ensure the system hasn’t been compromised.

2. **Hardware and Software Disposal**
   Proper disposal of outdated hardware and unused software is important to prevent unnecessary vulnerabilities. Unused software may have known security flaws, so removing it reduces the attack surface.

3. **Strong Password Policies**
   Implementing a strong password policy helps secure user accounts. A policy might require long, complex passwords, limit login attempts, and enforce multi-factor authentication (MFA). MFA requires additional verification, such as an ID card or fingerprint, in addition to a password.

### Brute Force Attacks and Prevention

Brute force attacks attempt to guess a system's login credentials using a trial-and-error method. Attackers often use tools to automate this process. Two common types of brute force attacks are:

- **Simple brute force attacks**: Attackers try all possible combinations of usernames and passwords.
- **Dictionary attacks**: Attackers use a list of common passwords or stolen credentials to gain access.

#### Hardening to Defend

To prevent brute force attacks, several OS hardening practices are recommended:

1. **Salting and Hashing**
   Hashing converts passwords into a unique value that is irreversible, while salting adds random characters to passwords to increase security.

2. **Multi-Factor Authentication (MFA)**
   MFA requires users to verify their identity using multiple methods, such as a password and fingerprint or a one-time password (OTP).

3. **CAPTCHA and reCAPTCHA**
   These tools prevent automated attacks by requiring users to complete simple tasks, verifying they are human and not a bot.

4. **Password Policies**
   Organizations should enforce strict password policies, such as complexity requirements and limits on login attempts to enhance security.

### Assessing Vulnerabilities

Organizations can assess vulnerabilities by using **Virtual Machines (VMs)** and **sandbox environments**. VMs allow security teams to test and isolate suspicious files or malware, while sandboxes let them run untrusted software in a controlled environment. These tools help identify vulnerabilities before a breach occurs.

## Network Hardening

Network hardening focuses on securing network-related aspects of an organization's infrastructure, such as port filtering, network access privileges, and encryption. It involves both regular tasks and one-time tasks that are updated as needed.

### Regularly Performed Tasks

- **Firewall Rules Maintenance**: Ensures proper traffic filtering.
- **Network Log Analysis**: Involves reviewing logs using tools like SIEM to monitor security events. SIEM collects and analyzes log data, providing a centralized dashboard for security teams to inspect, prioritize, and respond to network vulnerabilities.
- **Patch Updates & Server Backups**: Ensure systems are up-to-date and critical data is backed up.

### One-Time Tasks

- **Port Filtering**: Limits unwanted communication by blocking or allowing specific port numbers. Only necessary ports should be allowed.
- **Network Access Privileges**: Ensures users have access only to the necessary network segments.
- **Network Segmentation**: Creates isolated subnets for departments to prevent cross-contamination of issues.
- **Encryption**: Secures data in transit, especially in restricted zones where stronger encryption standards are necessary.

### Defense in Depth

The concept of adding layers of security to a network, progressively hardening it through multiple tools and techniques. This approach ensures a more robust defense by combining firewalls, intrusion detection/prevention systems, and security monitoring tools.

### Network Security Tools

- **Firewall**: Blocks traffic based on set rules, inspecting packet headers. Next-generation firewalls (NGFWs) can inspect packet payloads. It is crucial to ensure each system has its own firewall.
  - Can be Hardware or Software.
- **Intrusion Detection System (IDS)**: Alerts administrators about possible intrusions based on known attack signatures or traffic anomalies. It does not stop malicious traffic.
  - Can be Hardware or Software.
- **Intrusion Prevention System (IPS)**: Actively prevents malicious activity by blocking suspicious traffic. It is positioned between the firewall and the internal network to protect critical systems.
  - Can be Hardware or Software.
- **Security Information and Event Management (SIEM)**: Aggregates logs from multiple network devices into a central dashboard, helping security analysts identify and respond to suspicious activities.

## Cloud Hardening

With many organizations adopting cloud services, securing cloud networks is essential alongside securing on-premises networks. Cloud networks consist of servers and resources stored in remote data centers, accessible via the internet. These resources host data and applications, providing on-demand storage, processing power, and analytics. Cloud servers require proper maintenance and security hardening, just like traditional web servers. Though cloud service providers (CSPs) host these servers, they can't prevent intrusions, particularly from internal or external malicious actors.

### Key Considerations for Cloud Network Hardening

1. **Server Baseline Image**: A server baseline image ensures security by comparing cloud servers' data to the baseline to check for unverified changes, potentially indicating an intrusion.
2. **Separation of Data and Applications**: Just like OS hardening, data and applications are separated based on their service categories. For example, internal and external applications should be kept separate.

### Shared Responsibility Model

The cloud service provider (CSP) and the organization share responsibility for cloud security. CSPs manage the cloud infrastructure's physical security, but the organization is responsible for configuring and securing services within the cloud.Misunderstanding this division of responsibility can lead to security gaps.

### Cloud Security Considerations

- **Identity Access Management (IAM)**: IAM is crucial for managing digital identities and authorizing access to cloud resources. Misconfigured user roles can lead to unauthorized access and security risks.
- **Configuration**: Cloud services require careful configuration to meet security and compliance standards. Misconfigurations, especially during cloud migrations, can expose the network to vulnerabilities.
- **Attack Surface**: Every cloud service or application adds potential security risks. Multiple services increase entry points to an organization's network, but with proper design, these risks can be minimized.
- **Zero-Day Attacks**: These attacks exploit previously unknown vulnerabilities. CSPs often patch zero-day vulnerabilities faster than traditional IT organizations, minimizing impact.
- **Visibility and Tracking**: CSPs provide tools like flow logs and packet mirroring for traffic visibility, but organizations may have limited access to monitor CSP servers.

### Cloud Networking and Updates

Cloud service providers regularly update their infrastructure, and organizations must adjust their IT processes to align with these updates. Security personnel must stay vigilant as cloud service changes can impact security configurations.

### Hardening Practices

To secure cloud networks, several practices are essential:

1. **Identity Access Management (IAM)**: Manage user access and permissions.
2. **Hypervisors**: CSPs use hypervisors to manage virtualized resources. Misconfigurations or vulnerabilities can lead to exploits like VM escapes.
3. **Baselining**: Establishing a baseline configuration helps detect unauthorized changes and improve security.
4. **Cryptography**: Encrypting data in the cloud protects its confidentiality and integrity. Cryptographic erasure (crypto-shredding) ensures data is irretrievable by destroying encryption keys.
5. **Key Management**: Secure key storage solutions like Trusted Platform Module (TPM) and Cloud Hardware Security Module (CloudHSM) protect encryption keys.

### Cryptography in the Cloud

Cryptography ensures data confidentiality and integrity in cloud environments. Organizations should use encryption and manage keys securely to protect sensitive data. CSPs typically manage encryption, but customers can opt to provide their own encryption keys, taking responsibility for their management.


## Key Takeaways

- OS hardening tasks, such as patch updates, password policies, and secure disposal of hardware and software, can significantly reduce the risk of successful brute force attacks and other cybersecurity threats.
- **Firewall**: Filters traffic based on rules but can only inspect packet headers.
- **IDS**: Alerts about potential intrusions but cannot stop them.
- **IPS**: Takes action to stop malicious traffic but can cause disruptions if it fails.
- **SIEM**: Provides centralized log analysis but does not actively stop threats.
- **Cloud Security Hardening**: Essential for securing cloud infrastructure using IAM, hypervisor management, baselining, cryptography, and cryptographic erasure.
- **Shared Responsibility**: The CSP secures the infrastructure, while the organization ensures secure configuration and maintenance of cloud services.
