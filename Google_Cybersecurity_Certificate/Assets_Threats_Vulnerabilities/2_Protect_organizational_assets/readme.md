# **Protect Organizational Assets**

In this module, we focus on the security controls that protect organizational assets. You'll explore the role of privacy in asset security, learn how encryption and hashing safeguard information, and examine how authentication and authorization systems verify user identities.

## **Learning Objectives**

- Identify effective data handling processes.
- Understand how security controls mitigate risk.
- Discuss the role of encryption and hashing in securing assets.
- Describe how authentication works as a security control.
- Describe effective authorization practices to verify user access.

## **Safeguard Information**

Organizations are under pressure to implement effective security controls to protect information. Security controls are safeguards designed to reduce risks and include tools that protect assets before, during, and after events. These controls are categorized into three types:

### Types of Security Controls

- **Technical**: Technologies like encryption, authentication systems, etc.
- **Operational**: Daily security practices like awareness training and incident response.
- **Managerial**: Policies, standards, and procedures to manage risk.

### Information Privacy and Security Controls

- **Information Privacy**: Protecting data from unauthorized access or distribution. It's about the right to control one's private information.
- **Principle of Least Privilege**: Users should only have the minimum access necessary to perform tasks, reducing the risk of unauthorized access or accidental misuse.

### Key Concepts in Data Handling

- **Data Owners**: Decide who can access, use, or destroy data.
- **Data Custodians**: Entities responsible for safe handling, transport, and storage of information.
- **Principle of Least Privilege**: Limiting access and authorization to reduce risks.

### Auditing and Monitoring User Accounts

- **Usage Audits**: Review what resources are accessed and used.
- **Privilege Audits**: Ensure users only have access to necessary resources.
- **Account Change Audits**: Monitor changes to user accounts for unauthorized activity.

### Data Lifecycle and Governance

- **Data Lifecycle Stages**: Collection, storage, usage, archival, destruction.
- **Data Governance**: Policies for managing and protecting data. Key roles include:
  - **Data Owner**: Controls access to data.
  - **Data Custodian**: Maintains security of data.
  - **Data Steward**: Implements governance policies.

### Privacy and Legal Considerations

- **Personally Identifiable Information (PII)**: Data used to identify individuals.
- **Protected Health Information (PHI)**: Health-related data protected under regulations like HIPAA.
- **Sensitive PII (SPII)**: More restricted data like bank details or login credentials.

### Notable Privacy Regulations

- **GDPR**: Regulation that gives EU citizens control over their personal data.
- **PCI DSS**: Standards to secure credit card data.
- **HIPAA**: Protects sensitive patient health information.

### Security Audits and Assessments

- **Security Audit**: Review of security controls and compliance.
- **Security Assessment**: Checks system resilience against threats.
- Audits are typically annual, while assessments are more frequent.

## **Encryption Methods**

In this section, we explore encryption methods used to protect data online, especially **Personally Identifiable Information (PII)**. PII includes sensitive data such as names, financial details, photos, and fingerprints. Cryptography is used to protect such data by transforming it into unreadable forms via **encryption** and **decryption** processes.

### Encryption Process

- Plaintext (original readable data) is converted to ciphertext (encrypted data) via **encryption**.
- **Decryption** converts ciphertext back to plaintext, making it readable again.

#### Historical Example: Caesar’s Cipher

- A simple encryption method where letters are shifted by a fixed number (e.g., a shift of 3 turns "hello" into "khoor").
- **Key**: The number of shifts used in the cipher. Without the key, decryption is difficult.
- **Limitations**:
  - Simple ciphers like Caesar’s are vulnerable to **brute-force attacks** (trial and error).
  - Security is compromised if the key is lost or stolen.

#### Modern Encryption: Public Key Infrastructure (PKI)

- **PKI** combines both types depending on security and speed requirements (e.g., **asymmetric** for secure key exchange, **symmetric** for fast data transmission).
- **Digital Certificates**: Used to verify identities and establish trust between parties. Certificates are issued by a trusted **Certificate Authority (CA)**.


##### Asymmetric Encryption

- **Public Key**: Used to encrypt data.
- **Private Key**: Used to decrypt data. Only the private key holder can decrypt the data.
- Example: A "box" with two keys—public (to add data) and private (to remove data).
- **Benefits**: Secure, but slower.

##### Symmetric Encryption

- **Single Key**: Both encryption and decryption use the same secret key.
- **Faster** than asymmetric encryption, but less secure if the key is compromised.

#### Key Length & Algorithms

- **Key Length**: Longer keys are more secure but slower. Modern systems favor longer keys to prevent brute-force attacks.

#### Key Management

- **OpenSSL**: Commonly used to generate public and private keys.
- **Heartbleed Bug**: A vulnerability discovered in OpenSSL in 2014, demonstrating the importance of using up-to-date software.

#### Common Encryption Algorithms

- **Symmetric Algorithms**:
  - **Triple DES (3DES)**: Based on the older **DES** algorithm; uses 168-bit keys.
  - **AES** (Advanced Encryption Standard): More secure, with 128, 192, or 256-bit keys.
- **Asymmetric Algorithms**:
  - **RSA**: One of the first asymmetric algorithms, using key sizes of 1,024, 2,048, or 4,096 bits.
  - **DSA** (Digital Signature Algorithm): Standard asymmetric algorithm used in PKI with key sizes of 2,048 bits.

#### Best Practices

- Ciphers should be **publicly known** and proven secure (Kerckhoff’s principle).
- **Custom encryption systems** are risky and should not be used.

### Real-World Application of Encryption

- Websites often use **asymmetric encryption** for login credentials and then switch to **symmetric encryption** for faster data exchange once the connection is established.

### Compliance and Regulation

- **FIPS 140-3** and **GDPR** outline how data should be encrypted and handled, ensuring compliance and protecting user privacy.

### Encryption Key Vulnerabilities

We've spent some time together exploring a couple of forms of encryption. The two types we've discussed produce keys that are shared when communicating information. Encryption keys are vulnerable to being lost or stolen, which can put sensitive information at risk. To address this weakness, there are other security controls available.

## **Data Integrity and Non-repudiation**

Data integrity relates to the accuracy and consistency of information. This is known as **non-repudiation**, the concept that the authenticity of information can't be denied. Hash functions help achieve data integrity and are frequently used to verify whether files or applications have been tampered with.

### Hash Functions

A hash function is an algorithm that produces a code that can't be decrypted. Unlike asymmetric and symmetric algorithms, hash functions are one-way processes that do not generate decryption keys. Instead, these algorithms produce a unique identifier known as a **hash value** or **digest**.

#### Example

Imagine a company has an internal application used by employees and stored in a shared drive. After passing through a hashing function, the program receives its hash value. For example, we created this relatively short hash value with the **MD5 hashing function**. Generally, standard hash functions that produce longer hashes are preferred for being more secure.

#### Detecting Modifications with Hashes

Now, imagine an attacker replaces the program with a modified version that performs malicious actions. The malicious program may work like the original. However, if so much as one line of code is different from the original, it will produce a different hash value. By comparing the hash values, we can validate that the programs are different. Hash values help identify when something like this is happening.

In security, hashes are primarily used as a way to determine the **integrity** of files and applications.

#### Using Hash Functions for Security

Hash functions allow security analysts to validate files by comparing hash values. For example, using the Linux command line, a user can generate the hash value for any file and compare it against known malicious files.

#### Comparing Hashes with VirusTotal

One such tool is **VirusTotal**, a popular service among security practitioners that analyzes suspicious files, domains, IPs, and URLs by comparing them with a database of known hash values.

### The Evolution of Hash Functions

Hash functions are important security controls that are part of every company's security strategy. They are widely used for authentication and ensuring non-repudiation.

#### Origins of Hashing

Hash functions have been around since the early days of computing, created as a way to quickly search for data. One of the earliest hash functions, **Message Digest 5 (MD5)**, was developed by Professor Ronald Rivest at MIT in the early 1990s. MD5 was initially used to verify that a file sent over a network matched its source.

MD5 converts data into a **128-bit value** and is represented as a 32-character string. Altering anything in the source file generates a completely new hash value. However, MD5's 128-bit hash is vulnerable to attacks due to its relatively small size.

#### Hash Collisions

A **hash collision** occurs when two different inputs produce the same hash value. Since hash functions are designed to map any input to a fixed-size value, hash collisions are possible. This vulnerability allows attackers to impersonate authentic data by exploiting this flaw.

### Next-Generation Hash Functions

To mitigate hash collisions, longer hash values were needed. This led to the development of the **Secure Hashing Algorithms (SHA)**, which are now widely used for generating secure hash values. The National Institute of Standards and Technology (NIST) approves these algorithms. These include:

- **SHA-1** (produces a 160-bit digest)
- **SHA-224**
- **SHA-256**
- **SHA-384**
- **SHA-512**

While these are more secure than MD5, they are not immune to all types of exploits.

### Secure Password Storage

Passwords are typically stored in databases where they are mapped to usernames. If passwords are stored as plain text, attackers gaining access to the database can steal them. By hashing passwords before storing them, sensitive login credentials are protected.

#### Rainbow Tables

A **rainbow table** is a precomputed set of hash values mapped to their corresponding plaintext values. Attackers can use rainbow tables to easily match hashed passwords with common plaintext passwords.

#### Adding Salt to Hash Functions

To counteract rainbow table attacks, **salting** is used. A **salt** is a random string of characters added to data before it is hashed. This ensures that even if the same password is used multiple times, each entry will have a different hash value. Salting strengthens hash functions and makes them more resistant to rainbow table attacks.

For example, even if a database contains the password "password" multiple times, each salted hash will be unique. This makes it much harder for attackers to use rainbow tables to crack passwords.



## **Authentication, Authorization, and Accounting**

Protecting data involves access controls, which are critical to maintaining data confidentiality, integrity, and availability. Authentication, authorization, and accounting (AAA) are key elements of these controls.

### Authentication

Authentication is the process of verifying who a user is. It answers the question: "Who are you?" Access control systems use three factors for authentication:

1. **Knowledge**: Something the user knows (e.g., password or security question).
2. **Ownership**: Something the user has (e.g., OTP via text or email).
3. **Characteristic**: Something the user is (e.g., fingerprint or facial scan).

Authentication can fail when credentials don’t match and succeed when they do.

#### Single Sign-On (SSO)

SSO allows users to authenticate once and gain access to multiple systems. While convenient, SSO is vulnerable when relying solely on one authentication factor.

#### Multi-Factor Authentication (MFA)

MFA requires two or more authentication methods to verify a user’s identity, combining:

- Something a user knows (password)
- Something a user has (OTP)
- Something a user is (biometrics)

MFA enhances security and is especially useful in cloud environments.

### Authorization

Authorization determines what users can do after authentication. It’s tied to:

- **Principle of Least Privilege**: Users should only have access to the information they need.
- **Separation of Duties**: Users should not have excessive authorization that could lead to misuse.

Common access control systems include:

- **HTTP Basic Authentication**: Sends credentials with each request but is vulnerable to attacks.
- **OAuth**: Uses API tokens instead of credentials to authorize access between applications securely.

### Accounting

Accounting involves tracking and monitoring user activity through access logs. These logs provide insights into:

- Who accessed the system
- When and what resources were used
- Identifying failed login attempts or potential data breaches

Access logs are essential for investigating security events, helping detect threats like **session hijacking**, where attackers impersonate users by stealing session tokens.

#### Session Management

A session is initiated when a user accesses a system, creating a session ID and exchanging session cookies to track activity. **Session hijacking** occurs when an attacker steals a session ID and impersonates the user.

## **Key Takeaways**

- **Data Privacy**: Organizations need to protect sensitive data and respect individuals' privacy choices.
- **Security Audits**: Vital for compliance and maintaining data security.
- **Symmetric encryption**: Uses a single key for encryption/decryption.
- **Asymmetric encryption**: Uses a public and private key pair.
- **PKI**: A system combining both types to secure communications.
- Strong encryption is essential for compliance and data protection online.
- Hashing is crucial for validating the integrity of files and protecting data from modification.
- MD5 and similar algorithms are vulnerable to attacks, including hash collisions and rainbow table attacks.
- Newer SHA algorithms, such as SHA-256, are more secure and widely used for hashing.
- Salting hashes adds an additional layer of security, particularly for password storage.
- Understanding and utilizing hash functions, including salting and using the most secure algorithms, is essential for securing sensitive data and maintaining data integrity.
