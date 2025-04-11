# **Vulnerabilities in Systems**

In this module, you'll develop an understanding of the vulnerability management process. You'll learn about common vulnerabilities and how they can become threats to asset security if exploited. By adopting an attacker mindset, you'll explore how vulnerabilities pose risks and the ways security professionals can manage and protect systems.

## **Learning Objectives**

- Differentiate between vulnerabilities and threats.
- Describe the defense in depth strategy.
- Explain how common vulnerability exposures are identified by MITRE.
- Explain how vulnerability assessments are used to assess potential risk.
- Analyze an attack surface.
- Develop an attacker mindset to recognize threats.

## **Flaws in the System**

Every asset has vulnerabilities that can potentially be exploited by threats. The key to protecting assets is identifying and fixing these vulnerabilities before they are exploited. Security teams focus on recognizing vulnerabilities and thinking about possible exploits to prevent harm.

### Key Concepts

- **Vulnerabilities** are weaknesses that can be exploited by threats.
- **Exploits** take advantage of vulnerabilities to cause harm.
- **Vulnerability management** is the process of identifying, assessing, defending, and evaluating vulnerabilities in systems.

### Vulnerability Management Process

1. **Identify vulnerabilities**: Detect weaknesses in systems.
2. **Consider potential exploits**: Assess how vulnerabilities can be exploited.
3. **Prepare defenses**: Implement measures to mitigate risks.
4. **Evaluate defenses**: Continuously assess and improve security measures.

Vulnerability management is a continuous cycle that helps protect assets by staying ahead of potential exploits, including zero-day exploits—vulnerabilities that are newly discovered and exploited before a fix is available.

### CI/CD Vulnerabilities

CI/CD pipelines, which automate software delivery, also require vulnerability management. Common CI/CD pipeline vulnerabilities include:

- **Insecure dependencies**: Use of vulnerable third-party code.
- **Misconfigured permissions**: Weak access controls.
- **Lack of automated security testing**: Failure to integrate security checks.
- **Exposed secrets**: Hardcoding sensitive information.
- **Unsecured build environments**: Risk to pipeline infrastructure.

**Securing CI/CD Pipelines**:

- **Integrate security** from the start (DevSecOps).
- **Implement strong access controls** (MFA, RBAC).
- **Automate security testing** (SAST, DAST).
- **Keep dependencies updated** and monitor for vulnerabilities.
- **Use secure secrets management** tools.

## **Defense in Depth: A Layered Approach to Security**

A layered defense is difficult to penetrate. When one barrier fails, another takes its place to stop an attack. **Defense in Depth** is a security model that uses this concept. It's a layered approach to vulnerability management that reduces risk. This approach is often referred to as the "castle approach" because it resembles the layered defenses of a castle.

### Layers of Defense in Depth

#### 1. **Perimeter Layer**

- This layer includes basic technologies such as usernames and passwords. It's focused on user authentication, filtering external access, and ensuring that only trusted partners can access the network.

#### 2. **Network Layer**

- The network layer deals with authorization and includes technologies like firewalls, which help prevent unauthorized access to internal networks and systems.

#### 3. **Endpoint Layer**

- Endpoints refer to devices like laptops, desktops, or servers that connect to the network. This layer employs protections like anti-virus software to secure these devices from malware and other security threats.

#### 4. **Application Layer**

- The application layer focuses on the interfaces through which users interact with systems. Security measures like multi-factor authentication (MFA) are part of this layer to prevent unauthorized access.

#### 5. **Data Layer**

- The data layer deals with protecting critical data such as Personally Identifiable Information (PII). Asset classification and other measures are used to secure and manage data in this final defense layer.

### Vulnerabilities and Exposures libraries

There are publicly accessible libraries that help share and document known vulnerabilities and exposures. These resources include:

- **CVE List (Common Vulnerabilities and Exposures)**
  The CVE list is an openly accessible dictionary of known vulnerabilities. It was created by MITRE in 1999 and helps organizations identify potential security risks. CVE IDs are assigned to vulnerabilities after a rigorous review process, ensuring that only well-researched and validated vulnerabilities are listed.

- **CVE Review Process**
  A CVE Numbering Authority (CNA) is responsible for reviewing submissions to the CVE list. The process tests vulnerabilities based on their independence, security risk potential, supporting evidence, and whether they affect only one codebase.

- **CVSS (Common Vulnerability Scoring System)**
  The CVSS is a scoring system that helps evaluate the severity of vulnerabilities. The score ranges from 0-10, with scores above 9 indicating critical risks that need immediate attention.

### OWASP Top 10

To stay informed and protect against new risks, security professionals refer to resources like **OWASP (Open Worldwide Application Security Project)**. One of their most valuable resources is the **OWASP Top 10**, a list of the most common and critical vulnerabilities in web applications.

#### Key Vulnerabilities in the OWASP Top 10

1. **Broken Access Control**
   - Improper access control mechanisms can allow unauthorized access to data or functionalities, leading to severe security breaches.

2. **Cryptographic Failures**
   - Insufficient encryption or weak cryptographic algorithms can expose sensitive data, risking data breaches.

3. **Injection**
   - Attackers can insert malicious code into vulnerable applications, potentially allowing them to steal or modify data.

4. **Insecure Design**
   - Security flaws in the design phase can leave applications vulnerable to attacks like injection or malware.

5. **Security Misconfiguration**
   - Misconfigured settings, such as default settings on network servers, can leave systems open to exploitation.

6. **Vulnerable and Outdated Components**
   - Using outdated software components that are no longer maintained can lead to vulnerabilities being exploited.

7. **Identification and Authentication Failures**
   - Weak authentication mechanisms can allow unauthorized users to gain access to sensitive data or systems.

8. **Software and Data Integrity Failures**
   - Insufficient review of updates and patches can allow malicious software to be introduced, leading to supply chain attacks.

9. **Security Logging and Monitoring Failures**
   - Lack of proper logging and monitoring makes it difficult to track suspicious activities and respond to incidents.

10. **Server-Side Request Forgery (SSRF)**
    - SSRFs occur when attackers manipulate server requests to read or update unauthorized data stored on the server.


## **Open Source Intelligence (OSINT)**

Cyber attacks can sometimes be prevented with the right information, which starts with knowing where your systems are vulnerable. Previously, you learned that the CVE® list and scanning tools are two useful ways of finding weaknesses. But, there are other ways to identify vulnerabilities and threats.

### What is OSINT?

**Open Source Intelligence (OSINT)** is the collection and analysis of information from publicly available sources to generate usable intelligence. It’s commonly used in cybersecurity to identify potential threats and vulnerabilities, improving overall security.

### Information vs Intelligence

The terms **intelligence** and **information** are often used interchangeably but differ in meaning:

- **Information**: Refers to the raw data or facts about a specific subject.
- **Intelligence**: Refers to the analysis of information to produce knowledge or insights for decision-making.

For example, information might be about a new operating system update. Intelligence is derived when cybersecurity researchers analyze related data, discovering emerging threats linked to the update, guiding decisions on whether to apply the update.

### How OSINT Improves Cybersecurity

OSINT helps security teams monitor emerging vulnerabilities and attacks. For example, a company might monitor online forums or hacker communities for discussions about newly discovered weaknesses in software. If a vulnerability is identified, the security team can prioritize patching efforts to mitigate the risk.

### OSINT Applications

OSINT can be used in the following ways:

- Provide insights into **cyber attacks**.
- Detect potential **data exposures**.
- Evaluate **existing defenses**.
- Identify **unknown vulnerabilities**.

Security teams use OSINT to make data-driven decisions, improving their defenses and reducing risks.

### OSINT Tools

There are many tools available to assist with OSINT. Some of the most useful ones include:

- **VirusTotal**: Analyzes suspicious files, URLs, and IP addresses for malicious content.
- **MITRE ATT&CK®**: A knowledge base of adversary tactics and techniques based on real-world observations.
- **OSINT Framework**: A web-based platform to find OSINT tools for almost any kind of source.
- **Have I Been Pwned**: A tool to search for breached email accounts.

## **Identify System Vulnerabilities**

### Vulnerability Assessments

A vulnerability assessment is the internal review process where an organization's security systems are evaluated for weaknesses. These assessments are used to identify, categorize, and address vulnerabilities. Security teams often perform assessments using scanning tools and manual testing to find flaws.

#### Steps in Vulnerability Assessment

1. **Identification**: Use scanning tools and manual testing to find vulnerabilities and understand the system's current state.
2. **Vulnerability Analysis**: Analyze identified vulnerabilities to find their source.
3. **Risk Assessment**: Assign a score based on the severity and likelihood of exploitation.
4. **Remediation**: Address vulnerabilities through collaborative efforts between security and IT teams, including enforcing new security procedures or implementing patches.

### Vulnerability Scanners

Vulnerability scanners are tools that compare known vulnerabilities against systems to find misconfigurations or flaws. They scan the following attack surfaces:

- **Perimeter**: Authentication systems.
- **Network**: Firewalls and other technologies.
- **Endpoint**: Devices on the network.
- **Application**: Software applications.
- **Data**: Stored, in-transit, or in-use information.

Scanners operate by comparing findings against vulnerability databases, which are regularly updated.

#### Types of Vulnerability Scans

- **External vs. Internal**: External scans simulate attacks from outside the network; internal scans analyze internal systems.
- **Authenticated vs. Unauthenticated**: Authenticated scans log in with valid accounts, while unauthenticated scans simulate attacks from external actors.
- **Limited vs. Comprehensive**: Limited scans focus on specific devices, while comprehensive scans evaluate all devices on the network.

### Update Strategies for Security

Regular updates help patch security vulnerabilities. Organizations use:

- **Manual Updates**: Installed by users or IT departments.
- **Automatic Updates**: Automatically installed by systems to keep software up to date.

**End-of-Life Software**: When software reaches its end of life (EOL), it no longer receives updates, posing security risks. Replacing EOL software is recommended.

### Penetration Testing

Penetration testing (pen testing) simulates attacks to identify vulnerabilities. This ethical hacking process helps organizations understand the potential consequences of an attack.

- **Red Team Tests**: Simulate attacks to identify vulnerabilities.
- **Blue Team Tests**: Focus on defense and incident response.
- **Purple Team Tests**: Combine red and blue team strategies.

#### Penetration Testing Strategies

1. **Open-box Testing**: Tester has full knowledge of the system.
2. **Closed-box Testing**: Tester has little to no knowledge of the system, simulating a real-world attack.
3. **Partial Knowledge Testing**: Tester has limited knowledge, like an employee.

#### Becoming a Penetration Tester

Penetration testers require skills in network and application security, operating systems, programming, vulnerability analysis, and more. Bug bounty programs provide opportunities for freelance testers to earn rewards and improve their skills.

## **Cyber attacker mindset**

Cybersecurity is a continuously changing field. It's a fast-paced environment where new threats and innovative technologies can disrupt your plans at a moment's notice. As a security professional, it’s up to you to be prepared by anticipating change.

### Attack Surface and Vulnerabilities

Organizations need to assess vulnerabilities within their systems to understand potential threats. The first step is identifying the attack surface, which refers to all the potential entry points an attacker can exploit.

- **Physical vs. Digital Attack Surface**:
  - **Physical Attack Surface**: Composed of people and their devices, accessible from both inside and outside the organization.
    - Example: An unattended laptop in a coffee shop could expose sensitive information to external threats, while an angry employee could intentionally leak internal data.
    - **Security Hardening**: Strengthening a system by reducing vulnerabilities and minimizing points of entry.
  - **Digital Attack Surface**: Includes everything beyond the organization's firewall, such as cloud services. The move to cloud computing has expanded this surface, increasing entry points for threats.

#### Attacker mindset

To stay ahead of threats, security professionals must apply an attacker mindset. This involves identifying and simulating potential attacks to evaluate defenses proactively.

- **Attack Simulations**:
  - **Proactive (Red Team)**: Simulating an attacker exploiting vulnerabilities.
  - **Reactive (Blue Team)**: Defenders respond to an attack and remediate weaknesses.
- **Vulnerability Scanning**: Using tools to identify weaknesses in systems, followed by analysis and remediation.

### Types of Threat Actors

Threat actors are divided into five categories based on their motivations:

1. **Competitors**: Rival organizations attempting to steal sensitive information.
2. **State Actors**: Government agencies involved in espionage or cyber warfare.
3. **Criminal Syndicates**: Organized groups for financial gain.
4. **Insider Threats**: Employees who either unintentionally or intentionally compromise security.
5. **Shadow IT**: Employees using unauthorized technologies, like personal email for work.

### Types of Hackers

Hackers fall into three broad categories:

1. **Unauthorized Hackers (Malicious)**: Attackers who exploit vulnerabilities for personal or financial gain.
2. **Authorized Hackers (Ethical)**: Security professionals testing systems to improve security (e.g., bug bounty programs).
3. **Semi-Authorized Hackers**: Individuals like hacktivists who exploit vulnerabilities to promote political agendas.

### Advanced Persistent Threats (APT)

APTs are long-term attacks by sophisticated actors who maintain unauthorized access for extended periods, typically associated with state-sponsored actors. They target both government and private sectors, gathering intelligence to manipulate or disrupt services.

### Attack Vectors

Attack vectors are pathways attackers use to exploit vulnerabilities. Examples include:

- **Direct Access**: Physical access to systems.
- **Removable Media**: USB drives.
- **Social Media**: Platforms used to unintentionally leak sensitive information.
- **Email**: A common vector for phishing attacks.
- **Wireless Networks**: On-premise Wi-Fi vulnerabilities.
- **Cloud Services**: Third-party providers as attack entry points.
- **Supply Chains**: Vendor-related security gaps.

Recognizing these vectors helps predict where attackers may focus their efforts.

#### Defending Against Attack Vectors

Organizations must understand how to defend against attack vectors by thinking like an attacker. This involves:

1. Identifying targets (systems, data, users).
2. Understanding how to access the target (available information).
3. Evaluating which attack vectors can be exploited.
4. Determining the tools and methods of attack.

Common defense rules:

- **User Education**: Teaching staff about security risks.
- **Principle of Least Privilege**: Limiting access to the minimum necessary for tasks.
- **Security Tools**: Using antivirus and other software to reduce human error and defend attack vectors.
- **Diverse Security Teams**: Bringing different perspectives to improve security strategies.

### Fortify Against Brute Force Cyber Attacks

Brute force attacks involve attackers trying various combinations of credentials to gain unauthorized access. There are several tactics:

1. **Simple Brute Force**: Random guesses for usernames and passwords.
2. **Dictionary Attacks**: Using a precompiled list of common passwords.
3. **Reverse Brute Force**: Using a known credential across multiple systems.
4. **Credential Stuffing**: Reusing credentials from previous data breaches.
5. **Exhaustive Key Search**: Brute-forcing encrypted data.

#### Tools of the Trade

- **Aircrack-ng**, **Hashcat**, **John the Ripper**, **Ophcrack**, **THC Hydra** are commonly used brute force tools.

#### Prevention Measures

- **Hashing and Salting**: Converting passwords into unreadable values and adding random data to increase complexity.
- **Multi-Factor Authentication (MFA)**: Requiring multiple forms of identification to access systems.
- **CAPTCHA**: Ensuring users are human, preventing automated attacks.
- **Password Policies**: Enforcing complex passwords, lockout policies, and regular password changes.

## **Key Takeaways**

- Securing the CI/CD pipeline ensures that vulnerabilities are addressed early in the software delivery process, improving the overall security posture of applications.
- Staying informed about common vulnerabilities, such as those in the **OWASP Top 10**, and using resources like the **CVE List** and **CVSS scores**, is crucial for cybersecurity professionals.
- By following the defense in depth model and staying updated on new vulnerabilities, security professionals can build resilient systems that reduce risks and mitigate potential attacks.
- Gathering information and intelligence is critical to cybersecurity. OSINT allows security teams to make evidence-based decisions, helping to prevent attacks before they occur.
- Familiarity with OSINT tools and resources is essential for improving the efficiency of your research and intelligence-gathering efforts.
- Vulnerability assessments and penetration testing are crucial for identifying and addressing security flaws.
- Regular updates and patching are essential to prevent cyberattacks.
- Penetration testing provides a deeper understanding of how vulnerabilities could be exploited by attackers.
- Brute force attacks are effective but can be mitigated by strong passwords, MFA, and proper encryption techniques.
- Attack vectors are critical points of entry for attackers, and it’s essential to defend them with user education, security controls, and diverse teams.
- Think like an attacker to anticipate vulnerabilities and improve defenses.
