# **Module 2: Security Frameworks and Controls**

## **Introduction**

As a security analyst, your role extends beyond protecting organizations—you also help safeguard individuals from financial and reputational harm. Security breaches affecting customers, vendors, and employees can have severe consequences. Your work is essential in maintaining the confidentiality and integrity of sensitive data.

In this module, we will explore security frameworks, controls, and design principles in greater depth. We will also discuss how these elements apply to security audits, ensuring organizations and individuals remain protected against threats and vulnerabilities.

A key component of security frameworks is the **NIST Cybersecurity Framework (CSF)**, which plays a crucial role in safeguarding customer tools and personal work devices through the implementation of security controls.

### **What to Expect in This Module**

- Understanding security frameworks and their role in cybersecurity.
- Exploring security controls and their application in protecting assets.
- Learning about security design principles that guide risk mitigation.
- Applying these frameworks and controls in security audits.


## **Frameworks and Controls**

Security frameworks provide structured guidelines to help organizations mitigate risks and threats to data and privacy. These frameworks support compliance with industry regulations and standards.

### **Security Frameworks**

- **Cyber Threat Framework (CTF)**: Developed by the U.S. government to provide a common language for describing and communicating cyber threat activity, allowing organizations to analyze and respond to threats efficiently.
- **ISO/IEC 27001**: A globally recognized standard that helps organizations manage security risks by outlining best practices and controls for securing financial information, intellectual property, and personal data.

### **Security Controls**

Security controls are measures implemented to reduce specific security risks. They are categorized as **physical**, **technical**, and **administrative** controls.

- **Physical Controls**: Security measures for safeguarding physical assets.
  - Gates, fences, and locks
  - Security guards and surveillance cameras
  - Access cards or badges for entry

- **Technical Controls**: Technology-based security mechanisms.
  - Firewalls
  - Multi-Factor Authentication (MFA)
  - Antivirus software

- **Administrative Controls**: Policies and procedures for enforcing security standards.
  - Separation of duties
  - Authorization mechanisms
  - Asset classification

## **The CIA Triad: Confidentiality, Integrity, Availability**/sdeswa.sd./xçxze

### **CIA Overview**

The **CIA triad** is a foundational security model that helps organizations manage risk by ensuring **Confidentiality, Integrity, and Availability** of data. Security analysts use these principles to safeguard assets from threats, risks, and vulnerabilities.

### **Confidentiality**

- Ensures that only **authorized users** can access specific data.
- **Principle of Least Privilege (PoLP):** Limits access based on necessity.
- **Encryption:** Converts readable data into encoded formats to prevent unauthorized access.

### **Integrity**

- Ensures data is **correct, authentic, and reliable**.
- **Cryptography:** Secures data to prevent tampering.
- **Data Validation:** Ensures accuracy and authenticity of information.
- **Example:** Banks detect unusual transactions and temporarily disable access until verification.

### **Availability**

- Ensures data is **accessible** to authorized users when needed.
- **System Uptime:** Reliable networks, servers, and applications to minimize downtime.
- **Access Management:** Remote employees access necessary resources while ensuring security.

## **NIST Frameworks**

### **NIST Overview**

Organizations use security frameworks to develop structured plans for mitigating risks, threats, and vulnerabilities. The **National Institute of Standards and Technology (NIST)** provides widely respected frameworks used by security professionals worldwide.

### **NIST Cybersecurity Framework (CSF)**

The **NIST Cybersecurity Framework (CSF)** is a voluntary framework consisting of standards, guidelines, and best practices for managing cybersecurity risks. The latest version, **CSF v2.0**, introduces six core functions:

1. **Govern** – Establishes and maintains cybersecurity risk management structures and processes.
2. **Identify** – Manages cybersecurity risks affecting people, systems, assets, and data.
3. **Protect** – Implements policies, procedures, and training to mitigate cybersecurity threats.
4. **Detect** – Identifies potential security incidents and improves monitoring capabilities.
5. **Respond** – Ensures proper procedures are used to contain, neutralize, and analyze security incidents.
6. **Recover** – Restores affected systems, data, and assets after an incident.

#### **Example Application of CSF**

- A security analyst identifies a **compromised workstation**.
- The analyst **blocks an unknown device** remotely to prevent further threats.
- Security tools detect **additional threat actor activity**.
- The analyst investigates and responds, identifying an infected employee device.
- The team recovers affected files and corrects system damage.

### **NIST Special Publication (SP) 800-53**

**NIST SP 800-53** provides security controls to protect information systems, primarily for U.S. federal agencies and government contractors. It aligns with the **CIA triad** to maintain confidentiality, integrity, and availability in government systems.

#### **Key Benefits of NIST Frameworks**

- Establishes **clear cybersecurity governance**.
- Helps organizations **proactively and reactively** manage risks.
- Supports compliance with **federal and international security standards**.
- Enhances cybersecurity **incident response and recovery** strategies.

### **Conclusion**

The **NIST CSF and SP 800-53** frameworks provide essential guidance for managing cybersecurity risks. Understanding and applying these frameworks ensures organizations can protect critical assets, respond effectively to incidents, and maintain regulatory compliance.

~## **OWASP Security Principles**Qq

## **Core OWASP Principles**

Security analysts use OWASP principles to minimize threats and risks in an organization. These principles help define security strategies and ensure safe development practices.

### **1. Minimize Attack Surface Area**

- Reducing potential vulnerabilities that threat actors can exploit.
- Example: Disabling unnecessary software features, restricting asset access, and enforcing strong password policies.

### **2. Principle of Least Privilege**

- Users receive only the minimum access necessary to perform their tasks.
- Example: An entry-level analyst may view log data but cannot change user permissions.

### **3. Defense in Depth**

- Implementing multiple layers of security controls.
- Examples: Multi-factor authentication (MFA), firewalls, intrusion detection systems.

### **4. Separation of Duties**

- No single individual should have excessive privileges that allow system misuse.
- Example: The person preparing payroll should not also approve payments.

### **5. Keep Security Simple**

- Avoid overly complex security measures that make collaboration difficult.
- Example: Simplifying authentication processes without reducing effectiveness.

### **6. Fix Security Issues Correctly**

- Address vulnerabilities at the root cause and verify that fixes are effective.
- Example: Implementing strict password policies to prevent WiFi breaches.

### **7. Establish Secure Defaults**

- Default settings should be the most secure option for users.
- Example: Applications should require strong passwords by default.

### **8. Fail Securely**

- If a security control fails, it should default to a secure state.
- Example: A firewall failure should block all connections instead of allowing unrestricted access.

### **9. Don’t Trust Services**

- External third-party services should not be blindly trusted.
- Example: Verifying the accuracy of customer reward balances from third-party vendors before sharing with users.

### **10. Avoid Security by Obscurity**

- Security should not rely on secrecy alone.
- Example: Application security should be based on strong password policies, solid network architecture, and fraud prevention controls rather than just hiding source code.

## **Security Audits**

Security audits assess an organization's security controls, policies, and/or procedures to ensure compliance with internal and external security expectations. The goal of an audit is to ensure an organization's information technology (IT) practices are meeting industry and organizational standards. The objective is to identify and address areas of remediation and growth. Audits provide direction and clarity by identifying what the current failures are and developing a plan to correct them.

### **Types of Security Audits:**

- **Internal Audits**: Conducted by an organization’s own security team to assess risks, verify compliance, and improve security posture.
- **External Audits**: Performed by third-party entities to ensure compliance with industry regulations and standards.

### **Elements of an Internal Security Audit:**

1. **Establish Scope and Goals**
   - Define assets, policies, and technologies to be assessed.
   - Set security objectives (e.g., implementing NIST CSF functions, ensuring compliance, strengthening controls).
2. **Conduct a Risk Assessment**
   - Identify threats, vulnerabilities, and risks to assets.
   - Analyze security gaps in physical and digital asset management.
3. **Complete a Controls Assessment**
   - Review security controls categorized as:
     - **Administrative Controls**: Policies, training, password management.
     - **Technical Controls**: IDS, encryption, MFA.
     - **Physical Controls**: Surveillance cameras, locks, biometric access.
4. **Assess Compliance**
   - Evaluate adherence to legal and regulatory standards (e.g., GDPR, PCI DSS).
5. **Communicate Results**
   - Provide stakeholders with findings, risk levels, compliance gaps, and recommended actions for mitigation.

### **Security Audit Checklist:**

- Identify audit scope.
- Conduct risk assessment.
- Evaluate controls and compliance.
- Develop a mitigation plan.
- Report findings to stakeholders.


## **Key Takeaways**

- Security frameworks help organizations create structured security policies and ensure regulatory compliance.
- Controls work alongside frameworks to prevent, detect, and mitigate security risks.
- Organizations are strongly encouraged to adopt these frameworks and controls to protect critical assets and maintain a strong security posture.
- The **CIA triad** is essential in shaping an organization’s **security posture**.
- Security teams use these principles to protect sensitive data from **social engineering, malware, and data theft**.
- Organizations implement **encryption, access control, and system monitoring** to uphold the CIA triad.
- OWASP security principles help organizations reduce risks and improve security posture.
- Applying these principles supports safe development practices and protects sensitive data from potential threats.
- Security analysts must continuously implement and refine these principles to safeguard digital and physical assets.
- Security audits ensure compliance, improve security posture, and identify gaps.
- Effective audits integrate frameworks (e.g., NIST CSF, ISO 27000) and security controls.
- Analysts play a critical role in assessing, mitigating, and reporting security risks.
